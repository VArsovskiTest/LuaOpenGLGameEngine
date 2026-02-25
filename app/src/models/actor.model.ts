import { IRect } from "konva/lib/types";
import { ActorTypeEnum } from "../enums/enums";

// src/app/models/actor.model.ts
export interface ActorTransformations {
  rotation?: number;
  scaleX?: number;
  scaleY?: number;
}

export interface Actor {
  id: string;
  type: ActorTypeEnum;
  x: number;
  y: number;
  width?: number;
  height?: number;
  radius?: number;
  image?: ImageBitmap;
  crop?: IRect;
  cornerRadius?: number;
  color: string;
  transform?: ActorTransformations;
  transformDataJson?: string; // TODO: figure out how to remove this field, without it transform save doesn't work
  movable?: boolean;
  percentage?: number;
  thickness?: number;
  name?: string;
  // you can add later: rotation, scale, name/label, zIndex, locked, etc.
}

export interface ActorImage {
  
}

export interface ActorState {
  
}

export interface ActorStoreState { // TODO: Think of new name, you'll need ActorState for something else soon..
    ids: string[];
    entities: { [id: string]: Actor };
    selectedId: string | null;
}
