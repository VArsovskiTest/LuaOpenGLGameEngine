export function roundTo3Decimals(num: number): number | undefined {
    if (typeof num !== 'number' || isNaN(num)) return undefined;
    return Math.round(num * 1000) / 1000;
}

export function generateRandom(min?: number, max?: number): number {
  min = Math.ceil(min || 0);
  max = Math.floor(max || 100);
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
