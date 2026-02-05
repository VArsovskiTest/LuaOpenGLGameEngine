import { Injectable } from "@angular/core";
import { BehaviorSubject } from "rxjs";
import { Actor } from "../models/actor.model";
import { SceneState } from "../models/scene.model";

@Injectable({providedIn: 'root'})
export class SceneService {
  saveScene(model: { scene: BehaviorSubject<SceneState | null>; actors: BehaviorSubject<Actor[]>; }) {
    alert(JSON.stringify(model));
    throw new Error('Method not implemented.');
  }
}
