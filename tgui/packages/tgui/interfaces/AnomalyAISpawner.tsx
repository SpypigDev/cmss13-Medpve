import { classes } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type AnomalyAIPreset = {
  name: string;
  path: string;
  description: string;
  type: string;
  requires_spawn_config: boolean;
  icon: string;
};

type BackendContext = {
  presets: { [key: string]: AnomalyAIPreset[] };
};

export const AnomalyAISpawner = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const [chosenPreset, setPreset] = useState<AnomalyAIPreset | null>(null);
  const { presets } = data;
  return (
    <Window title="Human AI Spawner" width={450} height={300}>
      <Window.Content className="AnomalySpawner__Background">
        <Box className="AnomalySpawner__Casing">
          <Box className="AnomalySpawner__Gradient" width="100%" height="100%">
            <Box className="AnomalySpawner__Static" width="100%" height="100%">
              <Box
                className="AnomalySpawner__Screen"
                width="100%"
                height="100%"
              >
                <AnomalyAISpawnerr />
              </Box>
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};

const AnomalyAISpawnerr = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const [chosenPreset, setPreset] = useState<AnomalyAIPreset | null>(null);
  const { presets } = data;
  return (
    <Section fill className="AnomalySpawner__Main">
      <Stack fill vertical>
        <Stack fill>
          <Stack.Item grow mr={1}>
            <Section fill scrollable>
              {Object.keys(presets).map((dictKey) => (
                <Collapsible
                  title={dictKey}
                  key={dictKey}
                  className="AnomalyClass"
                >
                  {presets[dictKey].map((squad) => (
                    <Box pb={'12px'} key={squad.path}>
                      <Button
                        className="AnomalyType"
                        selected={squad === chosenPreset}
                        key={squad.path}
                        onClick={() => setPreset(squad)}
                      >
                        {squad.name}
                      </Button>
                    </Box>
                  ))}
                </Collapsible>
              ))}
            </Section>
          </Stack.Item>
          <Divider vertical />
          <Stack.Item width="35%">
            <Section title="Selected Preset" height="100%">
              <Stack vertical height="100%">
                <Stack.Item height="50%">
                  <Box align="center">
                    <span
                      className={classes([
                        'anomaly_menu128x128',
                        `${chosenPreset ? chosenPreset.icon : 'ss13'}`,
                      ])}
                    />
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  {chosenPreset ? chosenPreset.description : 'NULL'}
                </Stack.Item>
                <Stack.Item>
                  <Button
                    textAlign="center"
                    width="100%"
                    onClick={() =>
                      act('create_ai', {
                        path: chosenPreset && chosenPreset.path,
                      })
                    }
                  >
                    Spawn
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack>
    </Section>
  );
};
