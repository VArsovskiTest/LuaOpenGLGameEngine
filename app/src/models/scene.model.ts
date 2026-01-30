import { EntityState } from "@ngrx/entity";


// src/app/models/scene.model.ts
export interface Scene {
  id: string;
  name: string | null;
  size: 's' | 'm' | 'l' | 'xl' | null;
  winCondition?: string;
  nextSceneId?: string;
  // ... data, assets, nodes, etc.
}

export interface SceneState {// extends EntityState<Scene> {
  currentScene: Scene | null;
  pendingNewParams: { size: string; winCondition?: string } | null;
  isLoading: boolean;
  error: string | null;
}
