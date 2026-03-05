import Konva from "konva";
import { Actor } from "../store/actors/actor.model";
import { Shape } from "konva/lib/Shape";
import { roundTo3Decimals } from "../shared/math-helper";

export interface ActorAdapter {
    actorToShape: (actor: Actor, customData?: any) => Shape;
    shapeToActor: (shape: Shape, customData?: any) => Actor;
}

export const RectangleAdapter: ActorAdapter = {
    actorToShape: function (actor: Actor, customData: any): Shape {
        return new Konva.Rect({
            ...(customData || {}),
            id: actor.id,
            type: actor.type,
            x: actor.x,
            y: actor.y,
            color: actor.color,
            width: actor.width ?? 100,
            height: actor.height ?? 80,
            scaleX: roundTo3Decimals(actor.transform?.scaleX ?? 1) ?? 1.0,
            scaleY: roundTo3Decimals(actor.transform?.scaleY ?? 1) ?? 1.0,
            rotation: roundTo3Decimals(actor.transform?.rotation ?? 0) ?? 0.0,
            fill: actor.color,
            stroke: 'black',
            strokeWidth: 2,
        });
    },
    shapeToActor: function (shape: Shape, customData: any): Actor {
        return {} as Actor;
    }
}

export const BackgroundAdapter: ActorAdapter = {
    actorToShape: function (actor: Actor, customData: any): Shape {
        return new Konva.Rect({
            ...(customData || {}),
            id: actor.id,
            type: actor.type,
            color: actor.color,
            width: actor.width ?? 100,
            height: actor.height ?? 80,
            scaleX: roundTo3Decimals(actor.transform?.scaleX ?? 1) ?? 1.0,
            scaleY: roundTo3Decimals(actor.transform?.scaleY ?? 1) ?? 1.0,
            rotation: roundTo3Decimals(actor.transform?.rotation ?? 0) ?? 0.0,
            fill: actor.color,
            stroke: 'black',
            strokeWidth: 2,
        });
    },
    shapeToActor: function (shape: Shape, customData: any): Actor {
        return {} as Actor;
    }
}

export const CircleAdapter: ActorAdapter = {
    actorToShape: function (actor: Actor, customData: any): Shape {
        return new Konva.Circle({
            ...(customData || {}),
            id: actor.id,
            x: actor.x,
            y: actor.y,
            color: actor.color,
            width: actor.width ?? 100,
            height: actor.height ?? 80,
            radius: actor.radius ?? 50,
            scaleX: roundTo3Decimals(actor.transform?.scaleX ?? 1) ?? 1.0,
            scaleY: roundTo3Decimals(actor.transform?.scaleY ?? 1) ?? 1.0,
            rotation: roundTo3Decimals(actor.transform?.rotation ?? 0) ?? 0.0,
            fill: actor.color,
            stroke: 'black',
            strokeWidth: 2,
        });
    },
    shapeToActor: function (shape: Shape, customData: any): Actor {
        return {} as Actor;
    }
}

export const ResourceBarAdapter: ActorAdapter = {
    actorToShape: function (actor: Actor, customData: any): Shape {
        return new Konva.Rect({
            ...(customData || {}),
            id: actor.id,
            x: actor.x ?? 50,
            y: actor.y ?? 50,
            z: actor.z,
            color: actor.color,
            width: (actor.percentage ?? 100) / 100 * 500,
            thickness: actor.thickness ?? 20,
            scaleX: roundTo3Decimals(actor.transform?.scaleX ?? 1) ?? 1.0,
            scaleY: roundTo3Decimals(actor.transform?.scaleY ?? 1) ?? 1.0,
            rotation: roundTo3Decimals(actor.transform?.rotation ?? 0) ?? 0.0,
            name: actor.name});
    },
    shapeToActor: function (shape: Shape, customData: any): Actor {
        return {} as Actor;
    }
}

export const ImageAdapter: ActorAdapter = {
    actorToShape: function (actor: Actor, customData: any): Shape {
        return new Shape({...customData,
            id: actor.id,
            type: actor.type
        });
    },
    shapeToActor: function (shape: Shape, customData: any): Actor {
        return {} as Actor;
    }
}
