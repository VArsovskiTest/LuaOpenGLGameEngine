import { sizeEnum } from "../enums/enums";

export const sceneSizes = ():{x: number, y: number}[] => {
  return [
    {x: 1050, y:600},
    {x: 1625, y:900},
    {x: 2100, y:1200},
    {x: 3150, y:1800},
  ];
}

export function CalculateWidth(size: sizeEnum): number | null {
  return  size == 's' ? sceneSizes()[0].x
        : size == 'm' ? sceneSizes()[1].x
        : size == 'l' ? sceneSizes()[2].x
        : size == 'xl' ? sceneSizes()[3].x : null;
}

export function CalculateHeight(size: sizeEnum): number | null {
  return  size == 's' ? sceneSizes()[0].y
        : size == 'm' ? sceneSizes()[1].y
        : size == 'l' ? sceneSizes()[2].y
        : size == 'xl' ? sceneSizes()[3].y : null;
}
