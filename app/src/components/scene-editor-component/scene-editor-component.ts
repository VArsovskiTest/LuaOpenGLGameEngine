import { AfterViewInit, Component, ElementRef, inject, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Store } from '@ngrx/store';
import Konva from "konva";

import * as ActorActions from '../../store/actors/actors.actions'
import { Actor } from '../../models/actor.model'
import { selectAllActors, selectSelectedActor, selectSelectedActorId } from '../../store/actors/actors.selectors';
import { Container } from 'konva/lib/Container';
import { BehaviorSubject, map, of, switchMap, take, tap, withLatestFrom } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { Scene, SceneState } from '../../models/scene.model';
import { Circle } from 'konva/lib/shapes/Circle';
import { selectSceneState } from '../../store/scenes/scenes.selectors';
import { ActorSvc, SceneService, SceneSvc } from '../../services/scene-service';
import { ActorsService } from '../../services/actors-service';

@Component({
  selector: 'scene-editor-component',
  standalone: false,
  templateUrl: './scene-editor-component.html',
  styleUrl: './scene-editor-component.scss',
})

export class SceneEditorComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild("stageContainer") stageCongainer!: ElementRef<HTMLDivElement>;
  private sceneService: SceneService = inject(SceneService);
  private actorsService: ActorsService = inject(ActorsService);

  private store = inject(Store);
  private http = inject(HttpClient);

  actors$ = this.store.select(selectAllActors);
  selectedId$ = this.store.select(selectSelectedActorId);
  selectedActor$ = this.store.select(selectSelectedActor);
  selectedActor = new BehaviorSubject<Actor | null | undefined>(undefined);
  actors = new BehaviorSubject<Actor[]>([]);
  currentScene$ = this.store.select(selectSceneState);
  currentScene = new BehaviorSubject<SceneState | null>(null);

  ngOnInit(): void {
    this.currentScene$.subscribe(scene => {
      this.currentScene.next(scene);
      const sceneId = this.currentScene.getValue()?.currentScene?.id;
      if (sceneId) {
        this.actorsService.getActorsForScene(sceneId).subscribe(actors => {
          // TODO: Find out why actors don't drawn even though we have actors here
          this.actors.next(actors);
          this.redrawShapes(actors, this.VISIBLE_WIDTH, this.VISIBLE_HEIGHT);
      })};
    });
    console.log("Scene loaded from Store", this.currentScene);
  }

  private stage!: Konva.Stage;
  private layer!: Konva.Layer;
  private shapes: { [id: string]: Konva.Shape } = {};
  private tr: Konva.Transformer = new Konva.Transformer({});
  private keyboardHandler: (e: KeyboardEvent) => any = () => { };

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
    this.tr = new Konva.Transformer({
      borderStroke: '#0099ff',
      borderStrokeWidth: 2,
      anchorStroke: '#0099ff',
      anchorFill: 'white',
      anchorSize: 10,
      anchorCornerRadius: 5,
    });
    this.layer.add(this.tr);
    this.stage.add(this.layer);

    this.stage.on('click tap', (e) => {
      if (e.target === this.stage) {
        this.tr.nodes([]);
        this.layer.batchDraw();
      }
    });

    this.keyboardHandler = (e: KeyboardEvent) => {
      console.log("Keyboard event captured:", e.key);

      let selectedNodes = this.tr?.nodes() ?? [];
      if (selectedNodes.length === 0) { return; }

      const DELTA = 3;
      let handled = false;

      const survivingNodes: Konva.Node[] = [];

      selectedNodes.forEach((node) => {
        const nodeHasBeenRemoved = !node || !node.parent;
        if (nodeHasBeenRemoved) { return; }

        const id = node.id();

        switch (e.key) {
          case 'ArrowLeft':
            node.x(node.x() - DELTA);
            handled = true;
            survivingNodes.push(node);
            break;
          case 'ArrowUp':
            node.y(node.y() - DELTA);
            handled = true;
            survivingNodes.push(node);
            break;
          case 'ArrowRight':
            node.x(node.x() + DELTA);
            handled = true;
            survivingNodes.push(node);
            break;
          case 'ArrowDown':
            node.y(node.y() + DELTA);
            handled = true;
            survivingNodes.push(node);
            break;
          case 'Delete':
          case 'Backspace':
            if (id) {
              this.store.dispatch(ActorActions.removeActor({ id }));
              delete this.shapes[id];
            }
            node.destroy();
            handled = true;
            break;
        }
      });

      if (handled) {
        // Only keep surviving nodes in transformer
        this.tr.nodes(survivingNodes);
        this.layer.batchDraw();
        e.preventDefault();
        e.stopPropagation();
      }
    };

    const container = this.stage.container();
    container.tabIndex = 1;           // Required for keyboard focus
    // container.style.outline = 'none'; // Optional: remove focus outline
    container.focus();
    this.stage.container().addEventListener('keydown', this.keyboardHandler);

    this.actors$.subscribe(actors => {
      this.actors.next(actors);
      this.redrawShapes(actors, this.VISIBLE_WIDTH, this.VISIBLE_HEIGHT)
    });

    // Handle selection from store (attach transformer here for robustness)
    this.selectedId$.subscribe(id => {
      this.highlightSelected(id);
      if (id && this.shapes[id]) {
        this.tr.nodes([this.shapes[id]]);  // Attach to selected shape
      } else {
        this.tr.nodes([]);  // Clear if no ID
      }
      this.layer.batchDraw();
    });
  }

  private redrawShapes(actors: Actor[], vw: number, vh: number) {
    // this.layer.destroyChildren();   // ← Preserve transformer instead
    this.layer.getChildren().forEach(child => { if (child !== this.tr) { child.destroy(); } });
    this.shapes = {};

    actors.forEach(actor => {
      let shape: Konva.Shape;
      switch (actor.type) {
        case 'rectangle': {
          shape = new Konva.Rect({
            id: actor.id,
            x: actor.x,
            y: actor.y,
            width: actor.width ?? 100,
            height: actor.height ?? 80,
            rotation: actor.rotation,
            fill: actor.color,
            stroke: 'black',
            strokeWidth: 2,
            draggable: true,
            resizable: true,
            dragBoundFunc: function (pos) {
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
            rotation: actor.rotation,
            fill: actor.color,
            stroke: "black",
            strokeWidth: 2,
            draggable: true,
            resizable: true,
            dragBoundFunc: function (pos) {
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
            width: (actor.percentage ?? 100) / 100 * 500,
            thickness: actor.thickness ?? 20,
            rotation: actor.rotation,
            name: actor.name,
            draggable: false
          })
        }
      }

      shape.on("click tap", (e) => {
        this.store.dispatch(ActorActions.selectActor({ id: actor.id }));
        e.cancelBubble = true;  // Prevent bubbling to stage
        this.layer.batchDraw();
      });

      shape.on("dragend", () => {
        this.onActorMoved(actor.id, shape.x(), shape.y())
      });

      // Inside the place where you create the shape (inside redrawShapes, after creating shape)
      shape.on('transformend', () => {
        // Get the updated properties

        const changes: Partial<Actor> = {
          x: shape.x(),
          y: shape.y(),
          rotation: shape.rotation(),
          scaleX: shape.scaleX(),
          scaleY: shape.scaleY(),
        };

        if (actor.type === 'rectangle') {
          changes.width = shape.width() * shape.scaleX();
          changes.height = shape.height() * shape.scaleY();
        } else if (actor.type === 'circle') {
          changes.radius = (shape as Circle).radius() * shape.scale().x;
        }

        // Dispatch to store
        const id = shape.getAttr("id") || "no_Id";
        this.store.dispatch(
          ActorActions.updateActor({
            id: id,
            actorUpdate: { id: id, changes: changes }
          })
        );

        console.log('Actor updated after transform:');
        console.log(changes);
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

  ngOnDestroy(): void {
    if (this.keyboardHandler) {
      this.stage?.container()?.removeEventListener('keydown', this.keyboardHandler);
    }
    this.stage?.destroy();
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
      id: id, actorUpdate: { id, changes: { color: newColor } }
    }));
  }

  onActorMoved(id: string, newX: number, newY: number) {
    const currentlySelected = this.findById(id, this.actors.getValue());
    if (currentlySelected) {
      this.selectedActor.next(currentlySelected);
      this.store.dispatch(ActorActions.updateActor({ id: id, actorUpdate: { id, changes: { x: newX, y: newY } } }))
    }
  }

  private findById(id: string, list: Actor[]): Actor {
    return (list.filter(actor => actor.id == id) || [null])[0];
  }

  undo() {
    const previous = this.selectedActor.getValue();
    if (previous) {
      this.store.dispatch(ActorActions.updateActor({ id: previous.id, actorUpdate: { id: previous.id, changes: previous } }))
    }
  }

  clearAll() {
    this.store.dispatch(ActorActions.clearScene());
  }

  saveScene() {
    const sceneToSave$ = this.currentScene$.pipe(
      take(1),
      map(s => {
        const sceneData = s?.currentScene;
        const scene = {
          name: sceneData?.name,
          actors: sceneData?.actors,
          size: sceneData?.name,
          nextSceneId: sceneData?.name,
          winCondition: sceneData?.winCondition,
        } as SceneSvc;
        if (sceneData?.id) { scene.updatedAt = new Date(); }
        else scene.createdAt = new Date();
        return scene;
      }),
      withLatestFrom(this.actors), map(([sd, ad]) => {
        return {
          ...sd, actors: ad.map(actor => {
            const actorData = {
              ...actor,
              type: actor.type, name: actor.name,
              x: actor.x, y: actor.y, scaleX: actor.scaleX, scaleY: actor.scaleY,
              rotation: actor.rotation, width: actor.width, height: actor.height, radius: actor.radius,
              color: actor.color,
              movable: actor.movable,
            } as ActorSvc;
            if (sd?.id) { actorData.updatedAt = new Date(); }
            else actorData.createdAt = new Date();
            return actorData;
          })
        };
      }),
      // tap(savedScene => console.log("Saving scene", savedScene)),
      // switchMap(scene => { debugger; return this.sceneService.saveScene(scene); })
    );
    let sceneSaved: Scene | null = null;
    sceneToSave$.subscribe(scene => this.sceneService.saveScene(scene).subscribe(savedScene => sceneSaved = savedScene));
  }

  loadActors(json: any) {
    const actors = json.actors as Actor[];
    this.store.dispatch(ActorActions.loadActors({ actors }))
  }
}
