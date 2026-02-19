// src/app/models/actor.model.ts
export interface Actor {
  id: string;
  type: 'rectangle' | 'circle' | 'resource-bar';
  x: number;
  y: number;
  width?: number;
  height?: number;
  radius?: number;
  rotation?: number;
  scaleX?: number;
  scaleY?: number;
  color: string;            // hex or named
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
