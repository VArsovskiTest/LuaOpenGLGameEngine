export class MenuItem {
    id: number = 0;
    name?: string;

    constructor(name: string, id: number) {
        this.id = id; this.name = name;        
    }
}
