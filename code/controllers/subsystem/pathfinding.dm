SUBSYSTEM_DEF(pathfinding)
	name = "Pathfinding"
	priority = SS_PRIORITY_PATHFINDING
	flags = SS_NO_INIT|SS_TICKER|SS_BACKGROUND
	wait = 1
	/// A list of mobs scheduled to process
	var/list/datum/xeno_pathinfo/current_processing = list()
	/// A list of paths to calculate
	var/list/datum/xeno_pathinfo/paths_to_calculate = list()

	var/list/hash_path = list()
	var/current_position = 1

/datum/controller/subsystem/pathfinding/stat_entry(msg)
	msg = "P:[length(paths_to_calculate)]"
	return ..()

/datum/controller/subsystem/pathfinding/fire(resumed = FALSE)	// marked for refactoring to A* pathfinding
	if(!resumed)
		current_processing = paths_to_calculate.Copy()

	while(length(current_processing))
		// A* Pathfinding. Uses priority queue
		// morrow is the best coder since CM dev btw
		if(current_position < 1 || current_position > length(current_processing))
			current_position = length(current_processing)

		var/datum/xeno_pathinfo/current_run = current_processing[current_position]
		current_position++

		var/turf/target = current_run.finish

		//var/list/visited_nodess = current_run.visited_nodes
		// Distance from agent to node
		//var/list/distancess = current_run.distances
		// Combined distance from agent to node, and node to target, including special factors
		//var/list/f_distancess = current_run.f_distances
		//var/list/prevv = current_run.prev

		/// list of tiles already part of the path
		var/list/visited_nodes = current_run.visited_nodes
		/// stores the precursor node for all tiles added to the path
		var/list/previous_node_link = current_run.previous_node_link
		/// list of tiles being considered for path routing
		var/list/expansion_nodes = current_run.expansion_nodes

		while(length(expansion_nodes))
			var/list/unpacked_node = expansion_nodes[1]
			current_run.current_node = unpacked_node["node"]
			expansion_nodes -= unpacked_node
			if(!current_run.current_node)
				current_run.to_return.Invoke()
				log_debug("PATHFINDING FAULT! Unable to identify current node in expansion list ([length(expansion_nodes)] contained nodes) for [current_run.agent].")
				QDEL_NULL(current_run)
				return

			for(var/direction in GLOB.cardinals)
				var/turf/neighbor = get_step(current_run.current_node, direction)
				if(neighbor == listgetindex(previous_node_link, current_run.current_node))
					continue
				if(listgetindex(visited_nodes, neighbor))
					continue
				if(get_dist(neighbor, current_run.agent) > current_run.path_range)
					continue
				var/distance_between = listgetindex(visited_nodes, current_run.current_node) * DISTANCE_PENALTY
				if(!distance_between)
					visited_nodes[neighbor] = INFINITY
					continue
				if(isclosedturf(neighbor))
					visited_nodes[neighbor] = INFINITY
					continue
				if(direction != get_dir(previous_node_link[current_run.current_node], neighbor))
					distance_between += DIRECTION_CHANGE_PENALTY
				if(isxeno(current_run.agent) && !neighbor.weeds)
					distance_between += NO_WEED_PENALTY
				var/list/blockers = LinkBlocked(current_run.agent, current_run.current_node, neighbor, current_run.ignore, TRUE)
				blockers |= check_special_blockers(current_run.agent, neighbor)
				if(length(blockers))
					if(isxeno(current_run.agent))
						for(var/atom/A as anything in blockers)
							distance_between += A.xeno_ai_obstacle(current_run.agent, direction, target)
					else
						var/datum/component/human_ai/ai_component = current_run.agent.GetComponent(/datum/component/human_ai)
						var/datum/human_ai_brain/brain = ai_component.ai_brain
						for(var/atom/A as anything in blockers)
							distance_between += A.human_ai_obstacle(current_run.agent, brain, direction, target)
				var/f_distance = distance_between + ASTAR_COST_FUNCTION(neighbor)
				for(var/index in 1 to length(expansion_nodes))
					var/list/indexed_node = listgetindex(expansion_nodes, index)
					var/list/subindexed_node = listgetindex(indexed_node, 1)
					if(!subindexed_node || subindexed_node["f_distance"] >= f_distance)
						expansion_nodes[index] |= list(list("node" = neighbor, "f_distance" = f_distance))
						visited_nodes[neighbor] = distance_between
						previous_node_link[neighbor] = current_run.current_node
						current_run.current_node.maptext = "<h2>[f_distance]</h2>"
						break

			if(MC_TICK_CHECK)	// take a shot for every time this returns true
				return

		if(!previous_node_link[target])	// we never made it
			current_run.to_return.Invoke()
			QDEL_NULL(current_run)
			return

		var/list/path = list()
		var/turf/current_node = target
		while(current_node)
			if(current_node == current_run.start)
				break
			path |= current_node
			if(!listgetindex(previous_node_link, current_node))
				current_run.to_return.Invoke()
				log_debug("PATHFINDING FAULT! Discontinuous node encountered at ([current_node.x], [current_node.y]) when attempting to pathfind [current_run.agent] to [target] after [length(path)] indexed tiles!")
				QDEL_NULL(current_run)
				return
			current_node = previous_node_link[current_node]

		current_run.to_return.Invoke(path)
		QDEL_NULL(current_run)

/datum/controller/subsystem/pathfinding/proc/check_special_blockers(mob/agent, turf/checking_turf)
	var/list/pass_back = list()

	if(is_type_in_list(checking_turf, AI_SPECIAL_BLOCKER_TURFS))
		pass_back |= checking_turf
		return pass_back	// if you cant even enter the turf, the rest doesnt really matter

	for(var/atom/blocker as anything in AI_SPECIAL_BLOCKERS)
		var/blocker_atom = is_type_in_list(blocker, checking_turf.contents, TRUE)
		if(blocker_atom)
			pass_back |= blocker_atom
			continue

	return pass_back

/datum/controller/subsystem/pathfinding/proc/stop_calculating_path(mob/agent)
	var/datum/xeno_pathinfo/data = hash_path[agent]
	qdel(data)

/datum/controller/subsystem/pathfinding/proc/calculate_path(atom/start, atom/finish, path_range, mob/agent, datum/callback/CB, list/ignore)
	if(!get_turf(start) || !get_turf(finish))
		return

	var/datum/xeno_pathinfo/data = hash_path[agent]
	SSpathfinding.current_processing -= data


	if(!data)
		data = new()
		data.RegisterSignal(agent, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/xeno_pathinfo, qdel_wrapper))

		hash_path[agent] = data
		paths_to_calculate += data

	data.current_node = get_turf(start)
	data.start = data.current_node

	var/turf/target = get_turf(finish)

	data.finish = target
	data.agent = agent
	data.to_return = CB
	data.path_range = path_range
	data.ignore = ignore

	data.visited_nodes[data.current_node] = 1
	data.expansion_nodes |= list(list("node" = data.current_node, "f_distance" = ASTAR_COST_FUNCTION(data.current_node)))

/datum/xeno_pathinfo
	var/turf/start
	var/turf/finish
	var/mob/agent
	var/datum/callback/to_return
	var/path_range

	var/turf/current_node
	var/list/ignore
	/// list of tiles already part of the path
	var/list/visited_nodes = list()
	/// stores the precursor node for all tiles added to the path
	var/list/previous_node_link = list()
	/// list of tiles being considered for path routing
	var/list/expansion_nodes = list()

/datum/xeno_pathinfo/proc/qdel_wrapper()
	SIGNAL_HANDLER
	qdel(src)

/datum/xeno_pathinfo/New()
	. = ..()
	visited_nodes = list()
	previous_node_link = list()
	expansion_nodes = list()

/datum/xeno_pathinfo/Destroy(force)
	SSpathfinding.hash_path -= agent
	SSpathfinding.paths_to_calculate -= src
	SSpathfinding.current_processing -= src

	#ifdef TESTING
	addtimer(CALLBACK(src, PROC_REF(clear_colors), distances), 5 SECONDS)
	#endif

	start = null
	finish = null
	agent = null
	to_return = null
	visited_nodes = null
	expansion_nodes = null
	previous_node_link = null
	return ..()

#ifdef TESTING
/datum/xeno_pathinfo/proc/clear_colors(list/L)
	for(var/i in L)
		var/turf/T = i
		for(var/l in T)
			var/atom/A = l
			A.color = null
		T.color = null
#endif
