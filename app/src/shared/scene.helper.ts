import { Shape } from "konva/lib/Shape";
import { Actor } from "../store/actors/actor.model";
import { roundTo3Decimals } from "./math-helper";
import Konva from "konva";
import { SceneSizeEnum } from "../enums/enums";

export const sceneSizes = (): { x: number, y: number }[] => {
    return [
        { x: 1050, y: 600 },
        { x: 1625, y: 900 },
        { x: 2100, y: 1200 },
        { x: 3150, y: 1800 },
    ];
}

export function CalculateWidth(size: SceneSizeEnum): number | null {
    return size == 's' ? sceneSizes()[0].x
        : size == 'm' ? sceneSizes()[1].x
            : size == 'l' ? sceneSizes()[2].x
                : size == 'xl' ? sceneSizes()[3].x : null;
}

export function CalculateHeight(size: SceneSizeEnum): number | null {
    return size == 's' ? sceneSizes()[0].y
        : size == 'm' ? sceneSizes()[1].y
            : size == 'l' ? sceneSizes()[2].y
                : size == 'xl' ? sceneSizes()[3].y : null;
}

export function generateRandomColor(minLightness: number = 50, maxLightness: number = 85): string {
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
