import { createAction, props } from "@ngrx/store";
import { Scene, SceneState } from '../../models/scene.model'
import { Update } from "@ngrx/entity";
import { sizeEnum } from "../../enums/enums";

// export const createScene = createAction('[Main Menu] Create new Scene', props<{ sceneState: SceneState | null, sceneIdCreated: string }>());
// export const saveScene = createAction('[Main Menu] Save scene', props<{ sceneUpdate: Update<Scene> }>());
// export const loadScene = createAction('[Main Menu] Load scene', props<{ id: string }>());

// scene.actions.ts

// User chooses size in "New Scene" dialog → menu dispatches this
export const startNewScene = createAction(
  '[Main Menu] Start New Scene',
  props<{ size: sizeEnum; name?: string }>()
);

// Later (once created) – can be dispatched from effect or editor
export const setCurrentScene = createAction(
  '[Scene] Set Current Scene',
  props<{ scene: Scene }>()
);

// Editor changes something
export const updateCurrentScene = createAction(
  '[Scene Editor] Update Current Scene',
  props<{ changes: Partial<Scene> }>()
);

// Save (usually no payload needed – takes current from store)
export const saveCurrentScene = createAction('[Scene] Save Current Scene');

// Optional – if user picks specific file name/path
export const saveCurrentSceneAs = createAction(
  '[Scene] Save Current Scene As',
  props<{ filePath: string }>()
);

export const loadScene = createAction(
  '[Main Menu] Load Scene',
  props<{ id: string }>()           // or filePath: string
);
