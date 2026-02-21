// src/app/models/actor.model.ts
export interface ActorTransformations {
  rotation?: number;
  scaleX?: number;
  scaleY?: number;
}

export interface Actor {
  id: string;
  type: 'rectangle' | 'circle' | 'resource-bar';
  x: number;
  y: number;
  width?: number;
  height?: number;
  radius?: number;
  color: string;
  transform?: ActorTransformations;
  transformDataJson?: string; // TODO: figure out how to remove this field, without it transform save doesn't work
  movable?: boolean;
  percentage?: number;
  thickness?: number;
  name?: string;
  // you can add later: rotation, scale, name/label, zIndex, locked, etc.
}

export interface ActorsState {
    ids: string[];
    entities: { [id: string]: Actor };
    selectedId: string | null;
}
