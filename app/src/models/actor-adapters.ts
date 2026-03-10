import Konva from "konva";
import { Actor } from "../store/actors/actor.model";
import { Shape } from "konva/lib/Shape";
import { roundTo3Decimals } from "../shared/math-helper";
import { actorsReducer } from "../store/actors/actors.reducer";
import { ActorTypeEnum } from "../enums/enums";
import { ActorBehavior } from "./miscelaneous.models";
import { Circle } from "konva/lib/shapes/Circle";

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
            z: actor.z,
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
        return {
            ...(customData || {}),
            id: shape.id(),
            type: ActorTypeEnum.rectangle,
            x: shape.x(),
            y: shape.y(),
            z: shape.zIndex(),
            width: shape.width(),
            height: shape.height(),
            transform: {
                scaleX: roundTo3Decimals(shape.scaleX()),
                scaleY: roundTo3Decimals(shape.scaleY()),
                rotation: roundTo3Decimals(shape.rotation())
            },
            color: shape.fill(),
        } as Actor;
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
            z: actor.z,
            scaleX: roundTo3Decimals(actor.transform?.scaleX ?? 1) ?? 1.0,
            scaleY: roundTo3Decimals(actor.transform?.scaleY ?? 1) ?? 1.0,
            rotation: roundTo3Decimals(actor.transform?.rotation ?? 0) ?? 0.0,
            fill: actor.color,
            stroke: 'black',
            strokeWidth: 2,
        });
    },
    shapeToActor: function (shape: Shape, customData: any): Actor {
        return {
            ...(customData || {}),
            id: shape.id(),
            type: ActorTypeEnum.rectangle,
            x: shape.x(),
            y: shape.y(),
            z: 0,// shape.zIndex(),
            width: shape.width(),
            height: shape.height(),
            transform: {
                scaleX: roundTo3Decimals(shape.scaleX()),
                scaleY: roundTo3Decimals(shape.scaleY()),
                rotation: roundTo3Decimals(shape.rotation())
            },
            color: shape.fill(),
        } as Actor;
    }
}

export const CircleAdapter: ActorAdapter = {
    actorToShape: function (actor: Actor, customData: any): Shape {
        return new Konva.Circle({
            ...(customData || {}),
            id: actor.id,
            x: actor.x,
            y: actor.y,
            z: actor.z,
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
        return {
            ...(customData || {}),
            id: shape.id(),
            type: ActorTypeEnum.rectangle,
            x: shape.x(),
            y: shape.y(),
            z: shape.zIndex(),
            width: shape.width(),
            height: shape.height(),
            radius: (shape as Circle).radius(),
            transform: {
                scaleX: roundTo3Decimals(shape.scaleX()),
                scaleY: roundTo3Decimals(shape.scaleY()),
                rotation: roundTo3Decimals(shape.rotation())
            },
            color: shape.fill(),
        } as Actor;
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
            height: actor.height ?? 10,
            strokeWidth: actor.thickness ?? 20,
            scaleX: roundTo3Decimals(actor.transform?.scaleX ?? 1) ?? 1.0,
            scaleY: roundTo3Decimals(actor.transform?.scaleY ?? 1) ?? 1.0,
            rotation: roundTo3Decimals(actor.transform?.rotation ?? 0) ?? 0.0,
            name: actor.name});
    },
    shapeToActor: function (shape: Shape, customData: any): Actor {
        return {
            ...(customData || {}),
            id: shape.id(),
            type: ActorTypeEnum.resourcebar,
            x: shape.x(),
            y: shape.y(),
            z: shape.zIndex(),
            width: shape.width(),
            height: shape.height(),
            thickness: shape.strokeWidth(),
            transform: {
                scaleX: roundTo3Decimals(shape.scaleX()),
                scaleY: roundTo3Decimals(shape.scaleY()),
                rotation: roundTo3Decimals(shape.rotation())
            },
            color: shape.fill(),
        } as Actor;
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

export const GenericActorAdapter = (actor: Actor): ActorAdapter | null => {
    let selectedAdapter: ActorAdapter | null = null;
    switch (actor.type) {
        case ActorTypeEnum.background:
            selectedAdapter = BackgroundAdapter; break;
        case ActorTypeEnum.rectangle:
            selectedAdapter = RectangleAdapter; break;
        case ActorTypeEnum.circle:
            selectedAdapter = CircleAdapter; break;
        case ActorTypeEnum.resourcebar:
            selectedAdapter = ResourceBarAdapter; break;      
        default:
            break;
    }

    return selectedAdapter;
}
