import { auto } from '@popperjs/core';

import { useBackend } from '../backend';
import { Button, Collapsible, Section, Stack } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';

type Data = {
  fire_support_click_intercept: BooleanLike;
  missile_ordnance_options: string[];
  orbital_ordnance_options: string[];
  mortar_ordnance_options: string[];
  misc_ordnance_options: string[];
  chemical_ordnance_options: string[];
  throwables_ordnance_options: string[];
  selected_ordnance: string;
}

type MissileData = {
  selected_ordnance: string;
}

export const GameMasterFireSupportMenu = (props, context) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={450}>
      <Window.Content scrollable>
        <Section
          fill
          title="Fire Support Menu"
          align="center"
          height={auto}
        >
          <Stack vertical>
            <Stack.Item>
              <Button
                minWidth={'150px'}
                fontSize="15px"
                ml={1}
                selected={data.fire_support_click_intercept}
                onClick={() => {
                  act('toggle_click_fire_support');
                }}
              >
                CALL FIRE SUPPORT
              </Button>
            </Stack.Item>
          </Stack>

          <Collapsible title="Missiles">
            {data.missile_ordnance_options.map((ordnance, i) => (
              <Button
                selected={data.selected_ordnance === ordnance}
                key={i}
                width={'140px'}
                onClick={() => {
                  act('set_selected_ordnance', { ordnance });
                }}
              >
                {ordnance}
              </Button>
            ))}
          </Collapsible>

          <Collapsible title="Orbital Bombardments">
            {data.orbital_ordnance_options.map((ordnance, i) => (
              <Button
                selected={data.selected_ordnance === ordnance}
                key={i}
                width={'140px'}
                onClick={() => {
                  act('set_selected_ordnance', { ordnance });
                }}
              >
                {ordnance}
              </Button>
            ))}
          </Collapsible>

          <Collapsible title="Mortar Shells">
            {data.mortar_ordnance_options.map((ordnance, i) => (
              <Button
                selected={data.selected_ordnance === ordnance}
                key={i}
                width={'140px'}
                onClick={() => {
                  act('set_selected_ordnance', { ordnance });
                }}
              >
                {ordnance}
              </Button>
            ))}
          </Collapsible>

          <Collapsible title="Misc Ordnance">
            {data.misc_ordnance_options.map((ordnance, i) => (
              <Button
                selected={data.selected_ordnance === ordnance}
                key={i}
                width={'140px'}
                onClick={() => {
                  act('set_selected_ordnance', { ordnance });
                }}
              >
                {ordnance}
              </Button>
            ))}
          </Collapsible>

          <Collapsible title="Chemical Weapons">
            {data.chemical_ordnance_options.map((ordnance, i) => (
              <Button
                selected={data.selected_ordnance === ordnance}
                key={i}
                width={'140px'}
                onClick={() => {
                  act('set_selected_ordnance', { ordnance });
                }}
              >
                {ordnance}
              </Button>
            ))}
          </Collapsible>

          <Collapsible title="Throwables">
            {data.throwables_ordnance_options.map((ordnance, i) => (
              <Button
                selected={data.selected_ordnance === ordnance}
                key={i}
                width={'100px'}
                onClick={() => {
                  act('set_selected_ordnance', { ordnance });
                }}
              >
                {ordnance}
              </Button>
            ))}
          </Collapsible>
        </Section>
      </Window.Content>
    </Window>
  );
};
