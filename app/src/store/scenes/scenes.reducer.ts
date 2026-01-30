import { createReducer, on } from '@ngrx/store';
import * as SceneActions from '../scenes/scenes.actions';
import { SceneState } from '../../models/scene.model';

const initialState: SceneState = {
    currentScene: null,
    pendingNewParams: null,
    isLoading: false,
    error: null
}

export const sceneReducer = createReducer(
  initialState,

  // ── New scene flow ───────────────────────────────────────
  on(SceneActions.startNewScene, (state) => ({
    ...state,
    isLoading: true,
    error: null,
  })),

  on(SceneActions.setCurrentScene, (state, { scene }) => ({
    ...state,
    current: scene,
    isLoading: false,
    error: null,
  })),

  // ── Editor updates (sync, immediate) ─────────────────────
  on(SceneActions.updateCurrentScene, (state, { changes }) => ({
    ...state,
    current: state.currentScene ? { ...state.currentScene, ...changes } : null,
  })),

  // ── Load ─────────────────────────────────────────────────
  on(SceneActions.loadScene, (state) => ({
    ...state,
    isLoading: true,
    error: null,
  })),

  // ── Save (can be optimistic or just set dirty flag) ──────
  on(SceneActions.saveCurrentScene, (state) => state), // no change needed in reducer if async

  // ── Optional success/failure ─────────────────────────────
  // on(saveSuccess, (state, { updatedScene }) => ({ ...state, current: updatedScene })),
  // on(loadSuccess, (state, { scene }) => ({ ...state, current: scene, isLoading: false })),
);
