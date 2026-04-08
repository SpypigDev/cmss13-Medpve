import { useBackend } from '../backend';
import { Button, Dropdown, Section, Slider, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  selectable_hives: string[];
  selected_hive: string;
  embryo_stage: number;
}

export const GameMasterSubmenuInfest = (props, context) => {
  const { data, act } = useBackend();

  return (
    <Window width={400} height={400}>
      <Window.Content scrollable>
        <Stack direction="column" vertical>
          <GameMasterSubmenuInfestInfestingPanel />
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const GameMasterSubmenuInfestInfestingPanel = (props, context) => {
  const { data, act } = useBackend<Data>();

  return (
    <Section title="Infesting">
      <Stack direction="column" vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Dropdown
                options={data.selectable_hives}
                selected={data.selected_hive}
                width="15rem"
                onSelected={(new_hive) => {
                  act('set_selected_hive', { new_hive });
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item mt={1}>Embryo Stage</Stack.Item>
        <Stack.Item>
          <Slider
            maxValue={5}
            minValue={0}
            stepPixelSize={40}
            value={data.embryo_stage}
            onChange={(e, stage) => {
              act('set_embryo_stage', { stage });
            }}
          />
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                align="center"
                onClick={() => {
                  act('infest');
                }}
              >
                Set
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                align="center"
                onClick={() => {
                  act('clear_infest');
                }}
              >
                Clear
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            align="center"
            onClick={() => {
              act('burst');
            }}
          >
            Burst Now
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
