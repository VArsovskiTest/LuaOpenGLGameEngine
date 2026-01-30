import { AsyncPipe } from '@angular/common';
import { AfterViewInit, Component, ElementRef, inject, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Store } from '@ngrx/store';
import Konva from "konva";

import * as ActorActions from '../../store/actors/actors.actions'
import { Actor } from '../../models/actor.model'
import { selectAllActors, selectSelectedActor, selectSelectedActorId } from '../../store/actors/actors.selectors';
import { Container } from 'konva/lib/Container';
import { BehaviorSubject, find, map, mergeMap, Subject, tap } from 'rxjs';
import { HttpClient } from '@angular/common/http';
// import { selectCurrentScene } from '../../store/scenes/scenes.selectors';
import { Scene } from '../../models/scene.model';

@Component({
  selector: 'scene-editor-component',
  imports: [AsyncPipe],
  templateUrl: './scene-editor-component.html',
  styleUrl: './scene-editor-component.scss',
})

export class SceneEditorComponent implements AfterViewInit, OnDestroy {
  // // TODO: create new, load for the GUID
  // private currentScene = new BehaviorSubject<Scene | null>(null);

  // ngOnInit(): void {
  //   this.currentScene$.subscribe(scene => this.currentScene.next(scene));
  // }

  private store = inject(Store);
  private http = inject(HttpClient);

  actors$ = this.store.select(selectAllActors);
  selectedId$ = this.store.select(selectSelectedActorId);
  selectedActor$ = this.store.select(selectSelectedActor);
  actors = new BehaviorSubject<Actor[]>([]);
  selectedActor = new BehaviorSubject<Actor | null | undefined>(undefined);

  @ViewChild("stageContainer") stageCongainer!: ElementRef<HTMLDivElement>;

  private stage!: Konva.Stage;
  private layer!: Konva.Layer;
  private shapes: { [id: string]: Konva.Shape } = {};
  private VISIBLE_WIDTH = 1120;  // Container div width
  private VISIBLE_HEIGHT = 600; // Container div height

  ngAfterViewInit(): void {
    this.stage = new Konva.Stage({
      container: this.stageCongainer.nativeElement,
      width: this.VISIBLE_WIDTH,
      height: this.VISIBLE_HEIGHT
    });

    this.stage.draggable(true);
    this.stage.dragBoundFunc((pos) => {
      const x = Math.max(this.VISIBLE_WIDTH, Math.min(0, pos.x));
      const y = Math.max(this.VISIBLE_HEIGHT, Math.min(0, pos.y));
      return { x, y };
    });

    this.layer = new Konva.Layer();
    this.stage.add(this.layer);

    this.actors$.subscribe(actors => {
      this.actors.next(actors);
      this.redrawShapes(actors, this.VISIBLE_WIDTH, this.VISIBLE_HEIGHT)
    });
    this.selectedId$.subscribe(id => {
      this.highlightSelected(id)
    });
  }

  ngOnDestroy(): void {
    this.stage.destroy();
  }

  private redrawShapes(actors: Actor[], vw: number, vh: number) {
    this.layer.destroyChildren();
    this.shapes = {};

    actors.forEach(actor => {
      let shape: Konva.Shape;
      switch(actor.type){
        case 'rectangle': {
          shape = new Konva.Rect({
            id: actor.id,
            x: actor.x,
            y: actor.y,
            width: actor.width ?? 100,
            height: actor.height ?? 80,
            fill: actor.color,
            stroke: 'black',
            strokeWidth: 2,
            draggable: true,
            resizable: true,
            dragBoundFunc: function(pos) {
              const newX = Math.max(0, Math.min(pos.x, vw - this.width()));
              const newY = Math.max(0, Math.min(pos.y, vh - this.height()));
              return { x: newX, y: newY };
            }
          });
          break;
        }
        case 'circle': {
          shape = new Konva.Circle({
            id: actor.id,
            x: actor.x,
            y: actor.y,
            radius: actor.radius ?? 50,
            fill: actor.color,
            stroke: "black",
            strokeWidth: 2,
            draggable: true,
            resizable: true,
            dragBoundFunc: function(pos) {
              const newX = Math.max(0, Math.min(pos.x, vw - (actor.radius ?? 0)));
              const newY = Math.max(0, Math.min(pos.y, vh - (actor.radius ?? 0)));
              return { x: newX, y: newY };
            }
          })
          break;
        }
        case 'resource-bar': {
          shape = new Konva.Rect({
            id: actor.id,
            x: actor.x ?? 50,
            y: actor.y ?? 50,
            width: (actor.percentage ?? 100)/100 * 500,
            thickness: actor.thickness ?? 20,
            name: actor.name,
            draggable: false
          })
        }
      }

      shape.on("click", () => {
        this.store.dispatch(ActorActions.selectActor({ id : actor.id }))
      });

      shape.on("dragend", () => {
        this.onActorMoved(actor.id, shape.x(), shape.y())
      });

      this.layer.add(shape);
      this.shapes[actor.id] = shape;
    });

    this.layer.on("dragmove", (event) => {
      // TODO: deny/propagate when draggin empty
    })
    this.layer.draw();
  }

  private highlightSelected(id: string | null) {
    Object.values(this.shapes).forEach(shape => {
      shape.strokeWidth(id === shape.id() ? 4 : 2);
    })

    this.layer.draw();
  }

  addRectangle() {
    const newActor: Actor = {
      id: crypto.randomUUID(),
      type: "rectangle",
      x: 200,
      y: 150,
      width: 120,
      height: 80,
      color: '#e74c3c'
    };
    this.store.dispatch(ActorActions.addActor({ actor: newActor }))
  }

  addCircle() {
    const newActor: Actor = {
      id: crypto.randomUUID(),
      type: "circle",
      x: 200,
      y: 150,
      radius: 50,
      color: '#3498db'
    };
    this.store.dispatch(ActorActions.addActor({ actor: newActor }))
  }

  updateColor(id: string, newColor: string) {
    this.selectedActor.next(this.findById(id, this.actors.getValue()));
    this.store.dispatch(ActorActions.updateActor({
      actorUpdate: { id, changes: { color: newColor }}
    }));
  }

  onActorMoved(id: string, newX: number, newY: number) {
    this.selectedActor.next(this.findById(id, this.actors.getValue()));
    this.store.dispatch(ActorActions.updateActor({ actorUpdate: { id, changes: { x: newX, y: newY } } }))
  }

  private findById(id: string, list: Actor[]): Actor {
    return (list.filter(actor => actor.id == id) || [null])[0];
  }

  undo() {
    const previous = this.selectedActor.getValue();
    if (previous) {
      this.store.dispatch(ActorActions.updateActor({actorUpdate: { id: previous.id, changes: previous }}))
    }
  }

  clearAll() {
    this.store.dispatch(ActorActions.clearScene());
  }

  saveScene() {
    // var url = `http://localhost:4400/api/${this.currentScene.getValue()?.id}`
    // this.http.post(url, this.actors.getValue()).subscribe(resp => {})
  }

  loadActors(json: any) {
    const actors = json.actors as Actor[];
    this.store.dispatch(ActorActions.loadActors({ actors }))
  }
}
