import { IRect } from "konva/lib/types";
import { ActorTypeEnum } from "../enums/enums";

// src/app/models/actor.model.ts

export interface ActorTransformations {
  rotation?: number;
  scaleX?: number;
  scaleY?: number;
}

export interface ActorBase {
  id: string;
  type: ActorTypeEnum;
  x: number;
  y: number;
  transform?: ActorTransformations;
  movable?: boolean;
}

export interface ActorRectangle extends ActorBase {
  width?: number;
  height?: number;
  color?: string;
}

export interface ActorCircle extends ActorBase {
  radius?: number;
  color?: string;
}

export interface ActorImage extends ActorBase {
  image?: ImageBitmap;// | HTMLImageElement | SVGImageElement | HTMLVideoElement | HTMLCanvasElement | Blob | ImageData | OffscreenCanvas | VideoFrame
  crop?: IRect;
  cornerRadius?: number;
}

export interface ActorResourceBar extends ActorBase {
  percentage?: number;
  thickness?: number;
  name?: string;
}

export type ActorGeneric = ActorRectangle | ActorCircle | ActorResourceBar | ActorImage

export interface Actor {
  data: ActorGeneric;
}

export interface ActorState {

}

export interface ActorStoreState { // TODO: Think of new name, you'll need ActorState for something else soon..
    ids: string[];
    entities: { [id: string]: Actor };
    selectedId: string | null;
}
