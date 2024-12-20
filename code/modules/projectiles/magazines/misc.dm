

//Minigun

/obj/item/ammo_magazine/minigun
	name = "rotating ammo drum (7.62x51mm)"
	desc = "A huge ammo drum for a huge gun."
	caliber = "7.62x51mm"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/event.dmi'
	icon_state = "painless" //PLACEHOLDER

	matter = list("metal" = 10000)
	default_ammo = /datum/ammo/bullet/minigun
	max_rounds = 300
	reload_delay = 24 //Hard to reload.
	gun_type = /obj/item/weapon/gun/minigun
	w_class = SIZE_MEDIUM

//M60

/obj/item/ammo_magazine/m60
	name = "Mk70 belt box (7.62x51mm)"
	desc = "Limited production run by Henjin-Garcia of old Earth weapons. A 100rnd belt box for their Mk70 reproduction of the M60 GPMG."
	caliber = "7.62x51mm"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/colony.dmi'
	icon_state = "m60" //PLACEHOLDER

	matter = list("metal" = 10000)
	default_ammo = /datum/ammo/bullet/m60
	max_rounds = 100
	reload_delay = 8
	gun_type = /obj/item/weapon/gun/m60

/obj/item/ammo_magazine/pkp
	name = "QYJ-72 ammo box (7.62x54mmR)"
	desc = "A 250 round box for the UPP's standard GPMG, the QYJ-72. Chambered in 7.62x54mmR."
	caliber = "7.62x54mmR"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/upp.dmi'
	icon_state = "qjy72"

	matter = list("metal" = 10000)
	default_ammo = /datum/ammo/bullet/pkp
	max_rounds = 250
	reload_delay = 12
	gun_type = /obj/item/weapon/gun/pkp

//rocket launchers

/obj/item/ammo_magazine/rifle/grenadespawner
	name = "\improper GRENADE SPAWNER AMMO"
	desc = "OH GOD OH FUCK"
	default_ammo = /datum/ammo/grenade_container/rifle
	ammo_band_color = AMMO_BAND_COLOR_LIGHT_EXPLOSIVE

/obj/item/ammo_magazine/rifle/huggerspawner
	name = "\improper HUGGER SPAWNER AMMO"
	desc = "OH GOD OH FUCK"
	default_ammo = /datum/ammo/hugger_container
	ammo_band_color = AMMO_BAND_COLOR_SUPER
