import { EntityState } from "@ngrx/entity";
import { Actor } from "../actors/actor.model";
import { SceneSizeEnum } from "../../enums/enums";


// src/app/models/scene.model.ts
export interface Scene {
  id?: string; // must be optional = before creating in DB we need this not have value
  name: string | null;
  size: SceneSizeEnum;
  winCondition?: string;
  nextSceneId?: string;
  actors?: Actor[];
  // ... data, assets, nodes, etc.
}

export interface SceneState {// extends EntityState<Scene> {
  id?: string,
  currentScene: Scene | null;
  size: SceneSizeEnum;
  pendingNewParams: { size: string; winCondition?: string } | null;
  isLoading: boolean;
  error: string | null;
}
