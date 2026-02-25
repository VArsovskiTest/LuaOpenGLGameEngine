export const SceneSizeEnum = {
  s: 's',
  m: 'm',
  l: 'l',
  xl: 'xl',
  u: 'u' // unset
}

export type SceneSizeEnum = typeof SceneSizeEnum[keyof typeof SceneSizeEnum];

export const ActorTypeEnum = { // NOTE: Must do like this so that Switch statements of checking work
  rectangle: 'rectangle',
  circle: 'circle',
  resourcebar: 'resource-bar',
  background: 'background',
  image: 'image'
} as const;

export type ActorTypeEnum = typeof ActorTypeEnum[keyof typeof ActorTypeEnum];

export enum MenuItemsEnum {
    NewScene = 1,// "New Scene",
    LoadScene = 2,// "Load Scene",
    SaveScene = 3,// "Save Scene",
    LaunchScene = 4,// "Launch Scene",
    AddActor  = 5,// "Add Actor",
    RemoveActor = 6,// "Remove Actor",
    ModivyActor = 7,// "Modify Actor",
}
