import { AsyncPipe } from '@angular/common';
import { AfterViewInit, Component, ElementRef, inject, OnDestroy, ViewChild } from '@angular/core';
import { Store } from '@ngrx/store';
import Konva from "konva"; // => TODO: need the whole lib ?

import * as ActorActions from '../../store/actors/actors.actions'
import { Actor } from '../../models/actor.model'
import { selectAllActors, selectSelectedActor, selectSelectedActorId } from '../../store/actors/actors.selectors';
import { Container } from 'konva/lib/Container';

@Component({
  selector: 'scene-editor-component',
  imports: [AsyncPipe],
  standalone: true,
  templateUrl: './scene-editor-component.html',
  styleUrl: './scene-editor-component.scss',
})

export class SceneEditorComponent implements AfterViewInit, OnDestroy {
  private store = inject(Store);
  actors$ = this.store.select(selectAllActors);
  selectedId$ = this.store.select(selectSelectedActorId);
  selectedActor$ = this.store.select(selectSelectedActor);

  @ViewChild("stageContainer") stageCongainer!: ElementRef<HTMLDivElement>;

  private stage!: Konva.Stage;
  private layer!: Konva.Layer;
  private shapes: { [id: string]: Konva.Shape } = {};

  ngAfterViewInit(): void {
    this.stage = new Konva.Stage({
      container: this.stageCongainer.nativeElement,
      width: 800,
      height: 600
    });

    this.layer = new Konva.Layer();
    this.stage.add(this.layer);

    this.actors$.subscribe(actors => this.redrawShapes(actors));

    this.selectedId$.subscribe(id => this.highlightSelected(id));
  }

  ngOnDestroy(): void {
    this.stage.destroy();
  }

  private redrawShapes(actors: Actor[]) {
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
            draggable: true
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
            draggable: true
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
            name: actor.name
          })
        }
      }

      shape.on("click", () => {
        this.store.dispatch(ActorActions.selectActor({ id : actor.id }))
      });

      shape.on("dragend", () => {
        this.store.dispatch(ActorActions.updateActor({
          actorUpdate: { id: actor.id, changes: { x: shape.x(), y: shape.y() } }
        }))
      });

      this.layer.add(shape);
      this.shapes[actor.id] = shape;
    });

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
    this.store.dispatch(ActorActions.updateActor({
      actorUpdate: { id, changes: { color: newColor }}
    }));
  }

  onActorMoved(id: string, newX: number, newY: number) {
    this.store.dispatch(ActorActions.updateActor({
      actorUpdate: { id, changes: { x: newX, y: newY} }
    }))
  }

  saveScene() {
    // TODO: later: serialize selectAllActors() to JSON and save to backend/file
  }

  loadScene(json: any) {
    const actors = json.actors as Actor[];
    this.store.dispatch(ActorActions.loadScene({ actors }))
  }
}
