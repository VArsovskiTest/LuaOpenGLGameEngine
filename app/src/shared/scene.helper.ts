import { Shape } from "konva/lib/Shape";
import { Actor } from "../models/actor.model";
import { roundTo3Decimals } from "./math-helper";
import Konva from "konva";

export class SceneHelper {
    generateRandomColor(minLightness: number = 50, maxLightness: number = 85): string {
        // Saturation can be anything from 0 to 100.
        // Hue can be anything from 0 to 360.
        // Lightness is constrained between min and max lightness.

        const saturation = Math.random() * 100;
        const lightness = minLightness + Math.random() * (maxLightness - minLightness);
        const hue = Math.random() * 360;

        const hslToRgb = (h: number, s: number, l: number): [number, number, number] => {
            s /= 100;
            l /= 100;
            const k = (n: number) => (n + h / 30) % 12;
            const a = s * Math.min(l, 1 - l);
            const f = (n: number) =>
                l - a * Math.max(-1, Math.min(k(n) - 3, Math.min(9 - k(n), 1)));
            return [
                Math.round(255 * f(0)),
                Math.round(255 * f(8)),
                Math.round(255 * f(4)),
            ];
        };

        const [r, g, b] = hslToRgb(hue, saturation, lightness);

        // Helper to convert RGB to HEX
        const toHex = (c: number) => { const hex = c.toString(16); return hex.length === 1 ? '0' + hex : hex; };
        return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
    }

    getRectangleFromActor(actor: Actor, customData?: any): Shape {
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
    }

    getCircleFromActor(actor: Actor, customData?: any): Shape {
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
    }

    getResourceBarFromActor(actor:Actor, customData?: any): Shape {
        return new Konva.Rect({
            ...(customData || {}),
            id: actor.id,
            x: actor.x ?? 50,
            y: actor.y ?? 50,
            color: actor.color,
            width: (actor.percentage ?? 100) / 100 * 500,
            thickness: actor.thickness ?? 20,
            scaleX: roundTo3Decimals(actor.transform?.scaleX ?? 1) ?? 1.0,
            scaleY: roundTo3Decimals(actor.transform?.scaleY ?? 1) ?? 1.0,
            rotation: roundTo3Decimals(actor.transform?.rotation ?? 0) ?? 0.0,
            name: actor.name});
    }
}
