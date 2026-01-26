// src/app/models/actor.model.ts
export interface Actor {
  id: string;               // uuid or your own id generator
  type: 'rectangle' | 'circle' | 'resource-bar';
  x: number;
  y: number;
  width?: number;           // rectangle & resource-bar
  height?: number;
  radius?: number;          // circle
  color: string;            // hex or named
  // you can add later: rotation, scale, name/label, zIndex, locked, etc.
}

export interface ActorsState {
    ids: string[];
    entities: { [id: string]: Actor };
    selectedId: string | null;
}

