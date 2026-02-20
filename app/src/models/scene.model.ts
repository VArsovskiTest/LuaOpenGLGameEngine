import { EntityState } from "@ngrx/entity";
import { Actor } from "./actor.model";


// src/app/models/scene.model.ts
export interface Scene {
  id?: string; // must be optional = before creating in DB we need this not have value
  name: string | null;
  size: 's' | 'm' | 'l' | 'xl' | null;
  winCondition?: string;
  nextSceneId?: string;
  actors?: Actor[];
  // ... data, assets, nodes, etc.
}

export interface SceneState {// extends EntityState<Scene> {
  id?: string,
  currentScene: Scene | null;
  pendingNewParams: { size: string; winCondition?: string } | null;
  isLoading: boolean;
  error: string | null;
}
