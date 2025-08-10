// THIS IS A NOVA SECTOR UI FILE
import { Fragment } from 'react';
import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DronePanelData = {
  drone_coa: any;
  drone_laws: any;
  drone_meta: any;
};

// Break up your table into parts. Equivalent to \n\n. No clue if there was already a thing for this. I'm the wheel reinventor.
function BreakTable(table: any) {
  return table.map((A, B) => (
    <Fragment key={B}>
      {A}
      {B < table.length - 1 && <br />}
      {'\n'}
    </Fragment>
  ));
}
export const AntagInfoDrone = (props) => {
  const { data } = useBackend<DronePanelData>();

  return (
    <Window title={'Drone Information'} width={900} height={750} theme="ntOS95">
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <Section
                  scrollable
                  fill
                  preserveWhitespace
                  title={'Drone Laws'}
                >
                  {BreakTable(data.drone_laws)}
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  <Stack.Item grow basis={0}>
                    <Section
                      scrollable
                      fill
                      title="Drone Chain of Command - DCOA"
                      preserveWhitespace
                    >
                      {BreakTable(data.drone_coa)}
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <Section
                      scrollable
                      fill
                      preserveWhitespace
                      title="Metaknowledge, Protections, and Additional Rulings"
                    >
                      {BreakTable(data.drone_meta)}
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
