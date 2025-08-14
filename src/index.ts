// Reexport the native module. On web, it will be resolved to ExpoAmapModule.web.ts
// and on native platforms to ExpoAmapModule.ts
export { default } from './ExpoAmapModule';
export { default as ExpoAmapView } from './ExpoAmapView';
export * from  './ExpoAmap.types';
