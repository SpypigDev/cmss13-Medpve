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
    <Window title="Anomaly Spawner Panel" width={600} height={350}>
      <Window.Content>
        <Stack fill vertical>
          <Stack fill>
            <Stack.Item grow mr={1}>
              <Section fill scrollable>
                {Object.keys(presets).map((dictKey) => (
                  <Collapsible title={dictKey} key={dictKey} color="good">
                    {presets[dictKey].map((squad) => (
                      <Box pb={'12px'} key={squad.path}>
                        <Button
                          fontSize="15px"
                          textAlign="center"
                          selected={squad === chosenPreset}
                          width="100%"
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
            <Stack.Item width="30%">
              <Section title="Selected Preset">
                {chosenPreset !== null ? (
                  <Stack vertical>
                    <Stack.Item>
                      <Box>
                        <span
                          className={classes([
                            'anomaly128x128',
                            `${chosenPreset.icon}`,
                          ])}
                        />
                      </Box>
                    </Stack.Item>
                    <Stack.Item>{chosenPreset.description}</Stack.Item>
                    <Stack.Item>
                      <Button
                        textAlign="center"
                        width="100%"
                        onClick={() =>
                          act('create_ai', {
                            path: chosenPreset.path,
                          })
                        }
                      >
                        Spawn
                      </Button>
                    </Stack.Item>
                    {chosenPreset.requires_spawn_config ? (
                      <Stack.Item>
                        <Button
                          textAlign="center"
                          width="100%"
                          onClick={() =>
                            act('create_ai', {
                              path: chosenPreset.path,
                            })
                          }
                        >
                          Configure
                        </Button>
                      </Stack.Item>
                    ) : (
                      <div />
                    )}
                  </Stack>
                ) : (
                  <div />
                )}
              </Section>
            </Stack.Item>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};
