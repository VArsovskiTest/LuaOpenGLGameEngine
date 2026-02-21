export function roundTo3Decimals(num: number): number | undefined {
    if (typeof num !== 'number' || isNaN(num)) return undefined;
    return Math.round(num * 1000) / 1000;
}
