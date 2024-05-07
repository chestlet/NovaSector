// WOE! NOVA SECTOR!
import {  Feature, FeatureShortTextInput } from '../../base';

export const animal_tongue_say: Feature<string> = {
  name: 'Says.',
  component: FeatureShortTextInput,
};

export const animal_tongue_ask: Feature<string> = {
  name: 'Asks?',
  component: FeatureShortTextInput,
};

export const animal_tongue_exclaim: Feature<string> = {
  name: 'Exclaims!',
  component: FeatureShortTextInput,
};

export const animal_tongue_whisper: Feature<string> = {
  name: 'whispers.',
  component: FeatureShortTextInput,
};

export const animal_tongue_yell: Feature<string> = {
  name: 'Yells!!',
  component: FeatureShortTextInput,
};
