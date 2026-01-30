// scene.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { SceneState } from '../../models/scene.model';

export const selectSceneState = createFeatureSelector<SceneState>('scenes');

export const selectCurrentScene = createSelector(
  selectSceneState,
  state => state?.currentScene
);

export const selectIsLoading = createSelector(
  selectSceneState,
  state => state.isLoading
);

export const selectHasActiveScene = createSelector(
  selectCurrentScene,
  scene => !!scene
);

export const selectSceneSize = createSelector(
  selectCurrentScene,
  scene => scene?.size ?? null
);
