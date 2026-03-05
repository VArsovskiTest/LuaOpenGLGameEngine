import { AfterViewInit, ChangeDetectorRef, Component, ElementRef, inject, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Store } from '@ngrx/store';
import Konva from "konva";

import * as ActorActions from '../../store/actors/actors.actions'
import { Actor, ActorBase, ActorCircle, ActorGeneric, ActorImage, ActorRectangle, ActorResourceBar, ActorTransformations } from '../../store/actors/actor.model'
import { selectAllActors, selectSelectedActor, selectSelectedActorId } from '../../store/actors/actors.selectors';
import { BehaviorSubject, delay, map, Observable, Subject, switchMap, take, throttleTime, withLatestFrom } from 'rxjs';
import { Scene, SceneState } from '../../store/scenes/scene.model';
import { selectSceneState } from '../../store/scenes/scenes.selectors';
import { ActorSvc, SceneService, SceneSvc } from '../../services/scene-service';
import { ActorsService } from '../../services/actors-service';
import { generateRandom, roundTo3Decimals } from '../../shared/math-helper';
import { Shape, ShapeConfig } from 'konva/lib/Shape';
import { KonvaEventObject } from 'konva/lib/Node';
import { SceneSizeEnum } from '../../enums/enums';
import { CalculateHeight, CalculateWidth } from '../../shared/scene-helper';
import { Stage } from 'konva/lib/Stage';
import { SceneHelper } from '../../shared/scene.helper';
import { ActorTypeEnum } from '../../enums/enums';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'scene-editor',
  standalone: false,
  templateUrl: './scene-editor-component.html',
  styleUrl: './scene-editor-component.scss',
})

export class SceneEditorComponent implements OnInit, AfterViewInit, OnDestroy {

  @ViewChild("stageContainer") stageCongainer!: ElementRef<HTMLDivElement>;
  private sceneService: SceneService = inject(SceneService);
  private actorsService: ActorsService = inject(ActorsService);

  private store = inject(Store);
  actors$ = this.store.select(selectAllActors);
  selectedId$ = this.store.select(selectSelectedActorId);
  selectedActor$ = this.store.select(selectSelectedActor);
  currentScene$ = this.store.select(selectSceneState);

  actors = new BehaviorSubject<Actor[]>([]);
  selectedActor = new BehaviorSubject<Actor | null | undefined>(undefined);
  currentScene = new BehaviorSubject<SceneState | null>(null);

  private fb = inject(FormBuilder);
  protected addActorFormData: FormGroup = this.fb.group({
    actorType: [''] // TODO: Do validation later if need be: Validators.apply(() =>{...})
  });

  protected defaultColor: string = "#000000";
  protected selectedColor: BehaviorSubject<string> = new BehaviorSubject<string>(this.defaultColor);
  protected selectedColor$: Observable<string> = new Observable();
  private actorColorChange$ = new Subject<string>();
  private backgroundColorChange$ = new Subject<string>();

  protected showActorMenu: BehaviorSubject<boolean> = new BehaviorSubject(false);
  protected showActorMenu$: Observable<boolean> = new Observable();
  protected showStageMenu: BehaviorSubject<boolean> = new BehaviorSubject(false);
  protected showStageMenu$: Observable<boolean> = new Observable();

  private keyboardHandler: (e: KeyboardEvent) => any = () => { };
  private sceneHelper = new SceneHelper();

  private VISIBLE_WIDTH = 1200; // Default stage width
  private VISIBLE_HEIGHT = 800; // Default stage height
  private stage!: Konva.Stage;
  private layer!: Konva.Layer;
  private background: BehaviorSubject<Konva.Shape> = new BehaviorSubject<Konva.Shape>({} as Shape);
  private backgroundActor: BehaviorSubject<Actor> = new BehaviorSubject<Actor>({} as Actor);

  private shapes: { [id: string]: Konva.Shape } = {};
  private tr: Konva.Transformer = new Konva.Transformer({});

  constructor(private cdr: ChangeDetectorRef) { };

  //#region Stage Handlers

  private keyboardHandlerLogic = (e: KeyboardEvent) => {
    const DELTA = 3;
    let handled = false;
    let selectedNodes = this.tr?.nodes() ?? [];
    if (selectedNodes.length === 0) { return; }

    const survivingNodes: Konva.Node[] = [];
    selectedNodes.forEach((node) => {
      const nodeHasBeenRemoved = !node || !node.parent;
      if (nodeHasBeenRemoved) { return; }

      const id = node.id();
      switch (e.key) {
        case 'w': case 'ArrowUp': { node.y(node.y() - DELTA); handled = true; survivingNodes.push(node); break; }
        case 'a': case 'ArrowLeft': { node.x(node.x() - DELTA); handled = true; survivingNodes.push(node); break; }
        case 's': case 'ArrowDown': { node.y(node.y() + DELTA); handled = true; survivingNodes.push(node); break; }
        case 'd': case 'ArrowRight': { node.x(node.x() + DELTA); handled = true; survivingNodes.push(node); break; }
        case 'Delete':
        case 'Backspace':
          if (id) {
            this.store.dispatch(ActorActions.removeActor({ id }));
            delete this.shapes[id];
          }
          node.destroy(); handled = true; break;
      }
    });

    if (handled) {
      // Only keep surviving nodes in transformer
      this.tr.nodes(survivingNodes);
      this.layer.batchDraw();
      // e.preventDefault();
      e.stopPropagation();
    }
  }

  private setupBindings() {
    this.stage = new Konva.Stage({
      container: this.stageCongainer.nativeElement,
      width: this.VISIBLE_WIDTH,
      height: this.VISIBLE_HEIGHT,
    });

    this.stage.draggable(false);
    this.stage.dragBoundFunc((pos) => {
      const x = Math.max(this.VISIBLE_WIDTH, Math.min(0, pos.x));
      const y = Math.max(this.VISIBLE_HEIGHT, Math.min(0, pos.y));
      return { x, y };
    });

    this.stage.on('click tap', (e) => {
      console.log("Selected stage");
      this.highlightStage();
    });

    this.layer = new Konva.Layer();
    this.tr = new Konva.Transformer({
      borderStroke: '#0099ff', anchorStroke: '#0099ff',
      borderStrokeWidth: 2, anchorCornerRadius: 5, anchorSize: 10,
      anchorFill: 'white',
    });

    this.layer.add(this.tr);
    this.stage.add(this.layer);

    const container = this.stage.container();
    container.tabIndex = 1; // Required for keyboard focus
    container.focus();

    this.stage.container().addEventListener('keydown', this.keyboardHandler);
    this.actors$.subscribe(actors => {
      this.actors.next(actors);
      this.redrawShapes(actors.filter(actor => actor?.data || false).map(actor => actor.data), this.VISIBLE_WIDTH, this.VISIBLE_HEIGHT);
    });

    this.selectedActor.subscribe(actor => {
      if (actor) {
        const color = actor?.data.type != 'image' ? (actor?.data as ActorRectangle).color : undefined;
        if (actor && color) { this.selectedColor.next(color); }
        this.cdr.detectChanges(); // usually needed
      }
    });

    this.currentScene$.subscribe(scene => {
      this.currentScene.next(scene);
      const sceneId = this.currentScene.getValue()?.currentScene?.id;
      if (sceneId) {
        this.actorsService.getActorsForScene(sceneId).subscribe(actors => {
          this.store.dispatch(ActorActions.clearScene());
          // TODO: Detect if multiple backgrounds, if yes show popup, if user clicks yes this gets executed:
          // this.removeDuplicateBackgrounds(actors); // Just fix the initial state for scenes with multiple backgrounds by mistake
          this.initializeActorsAndBackground(actors);
        })
      };
    });
  }

  // private removeDuplicateBackgrounds(actors: Actor[]) {
  //   const allBackgroundData = actors.filter(actor => actor.type == "background");
  //   if (allBackgroundData.length > 1) {
  //     allBackgroundData.forEach(actor => this.store.dispatch(ActorActions.removeActor({id: actor.id})));
  //     this.initializeActorsAndBackground(actors.filter(actor => actor.type != "background"));
  //   }
  // }

  private initializeActorsAndBackground(actors: ActorGeneric[]) {
    let backgroundData = actors.find(actor => actor && actor.type == "background");

    if (backgroundData) {
      console.log("Background exists in actors list:", backgroundData);
      this.backgroundActor.next({ data: backgroundData });
    }
    else {
      console.log("Initializing new background:", backgroundData);
      backgroundData = this.getOrGenerateBackground().data;
      actors.push(backgroundData);
      this.backgroundActor.next({ data: backgroundData });
      this.background.next(this.sceneHelper.getRectangleFromActor(this.backgroundActor.getValue().data));
      this.store.dispatch(ActorActions.addActor({ actor: this.backgroundActor.getValue() }));
    }

    actors.forEach(actor => {
      const actorData = actor && actor.type != 'image' ? (actor as ActorRectangle) : undefined;
      if (actorData && !actorData.color) actorData.color = this.sceneHelper.generateRandomColor();
      this.store.dispatch(ActorActions.addActor({ actor: { data: actorData } as Actor }));
    });

    this.actors.next(actors.map(
      actor => {
        const actorWithData = { data: actor } as Actor;
        return actorWithData;
      }));
    // return this.actors.getValue();
  }

  //#endregion

  ngOnInit(): void {
    console.log("Scene loaded from Store", this.currentScene);

    this.showActorMenu$ = this.showActorMenu.asObservable();
    this.showStageMenu$ = this.showStageMenu.asObservable();
    this.selectedColor$ = this.selectedColor.asObservable();

    // Init actions for OnColorChange event
    // If you need to emit the updated actor, you can next it to another subject here
    this.actorColorChange$.pipe(throttleTime(50, undefined, { leading: true, trailing: false })) // Immediate first, then at most every 50ms
      .subscribe(color => {
        const updated = { ...this.selectedActor.getValue(), color } as Actor;
        this.updateColor(updated.data.id, color);
      });

    this.backgroundColorChange$.pipe(throttleTime(50, undefined, { leading: true, trailing: false })) // Immediate first, then at most every 750ms
      .subscribe(color => {
        const updated = { ...this.backgroundActor.getValue(), color } as Actor;
        this.updateColor(updated.data.id, color);
      });

    // Init Keyboard event
    this.keyboardHandler = this.keyboardHandlerLogic;
  }

  ngAfterViewInit(): void {
    this.currentScene$.subscribe(scene => {
      this.currentScene.next(scene);
      const newSceneWidth = CalculateWidth(scene.currentScene?.size as SceneSizeEnum);
      const newSceneHeight = CalculateHeight(scene.currentScene?.size as SceneSizeEnum);
      this.VISIBLE_WIDTH = newSceneWidth || this.VISIBLE_WIDTH;
      this.VISIBLE_HEIGHT = newSceneHeight || this.VISIBLE_HEIGHT;

      // Init scene bindings
      this.setupBindings();
    });
  }

  private getOrGenerateBackground(color?: string) {
    let existing = this.actors.getValue().find((actor: Actor) => actor.data.type == 'background');
    if (existing) return existing;

    const colorHex = color || this.sceneHelper.generateRandomColor(35, 75);
    const backgroundData = existing || {
      data: {
        id: crypto.randomUUID(),
        sceneId: this.currentScene.getValue()?.currentScene?.id,
        type: "background",
        color: colorHex,
        x: 0, y: 0, width: this.VISIBLE_WIDTH, height: this.VISIBLE_HEIGHT,
        fill: colorHex,
        draggable: false,
        resizable: false
      }
    } as Actor;
    return backgroundData;
  }

  private generateShape(actor: ActorGeneric, vw: number, vh: number): Konva.Shape {
    let shape: Konva.Shape = {} as Konva.Shape;
    switch (actor.type) {
      case ActorTypeEnum.background: {
        let backgroundDataContainer = this.backgroundActor.getValue();
        let backgroundData = backgroundDataContainer.data;
        backgroundData = { ...backgroundData, id: backgroundData.id, width: this.VISIBLE_WIDTH, height: this.VISIBLE_HEIGHT, transform: { scaleX: 1.0, scaleY: 1.0 } };
        backgroundDataContainer = { data: backgroundData };
        shape = this.sceneHelper.getRectangleFromActor(backgroundData);
        break;
      }
      case ActorTypeEnum.rectangle: {
        shape = this.sceneHelper.getRectangleFromActor(actor, {
          draggable: true,
          resizable: true,
          dragBoundFunc: function (pos: any) {
            const newX = Math.max(0, Math.min(pos.x, vw - this.width()));
            const newY = Math.max(0, Math.min(pos.y, vh - this.height()));
            return { x: newX, y: newY };
          }
        });
        break;
      }
      case ActorTypeEnum.circle: {
        const radius = (actor as ActorCircle).radius;
        shape = this.sceneHelper.getCircleFromActor(actor, {
          draggable: true,
          resizable: true,
          dragBoundFunc: function (pos: any) {
            const newX = Math.max(0, Math.min(pos.x, vw - (radius ?? 0)));
            const newY = Math.max(0, Math.min(pos.y, vh - (radius ?? 0)));
            return { x: newX, y: newY };
          }
        });
        break;
      }
      case ActorTypeEnum.image: {
        const actorImage = actor as ActorImage;
        shape = new Konva.Image({
          image: actorImage?.image || new ImageBitmap(), //HTMLOrSVGImageElement | HTMLVideoElement | HTMLCanvasElement | ImageBitmap | OffscreenCanvas | VideoFrame
          crop: actorImage?.crop || { x: 0, y: 0, width: 0, height: 0 },
          cornerRadius: actorImage?.cornerRadius
        });
        break;
      }
      case ActorTypeEnum.resourcebar: {
        shape = this.sceneHelper.getResourceBarFromActor(actor, { draggable: false });
      }
    }

    return shape;
  }

  private redrawShapes(actors: ActorGeneric[], vw: number, vh: number) {
    // this.layer.destroyChildren();   // ← Preserve transformer instead
    this.layer.getChildren().forEach(child => { if (child !== this.tr) { child.destroy(); } });
    this.shapes = {};

    actors.sort((actor1, actor2) => actor1.type > actor2.type ? 1 : -1) // Parse background first
      .forEach(actor => {
        if (!actor.type) {
          console.warn("selectedActor", this.selectedActor);
          console.warn("suspicious actor", actor);
        }
        let shape = this.generateShape(actor, vw, vh);
        shape.on("click tap", (e) => {
          const color = actor.type != 'image' ? (actor as ActorRectangle).color : undefined;
          if (color) this.selectedColor.next(color);

          const sameActorClick = (this.selectedActor.getValue()?.data.id || false) && (e.target.id() == this.selectedActor.getValue()?.data.id);
          const backgroundClick = actor.type == 'background';
          const targetId = e.target.attrs["id"];

          if (!sameActorClick && !backgroundClick) this.showTransformer(actor.id, targetId);
          else {
            if (!backgroundClick) this.highlightActor(this.selectedActor.getValue()?.data.id, targetId)
            else {
              this.highlightStage();
              this.backgroundActor.next({data: actor });
            }
            this.store.dispatch(ActorActions.selectActor({ id: actor.id }));
          }

          this.selectedActor.next(this.findById(actor.id, this.actors.getValue()));
          e.cancelBubble = true;
          this.layer.batchDraw();

          shape.on("dragend", () => { this.onActorMoved(actor.id, shape.x(), shape.y()) });
          shape.on('transformend', (shape) => this.onActorTransformed(actor.id, shape.currentTarget));

          if (shape.getParent()) {
            if (actor.type == "background") shape.moveToBottom(); else shape.moveToTop();
          }
        });

        this.layer.add(shape);
        this.shapes[actor.id] = shape;
      });
    this.layer.draw();
  }

  private highlightActor(id: string | undefined, targetId: string | undefined) {
    this.showStageMenu.next(false);
    this.showActorMenu.next(targetId == id);
  }

  private highlightStage() {
    this.showActorMenu.next(false);
    this.showStageMenu.next(true);
  }

  private showTransformer(id: string, targetId: string | undefined) {
    this.showActorMenu.next(false);
    this.showStageMenu.next(false);

    if (targetId && this.shapes[targetId]) { this.tr.nodes([this.shapes[targetId]]); this.tr.moveToTop(); }
    else { this.tr.nodes([]); };

    this.tr.setAttr("isTransforming", this.tr.nodes.length ? !this.tr.isTransforming : false);
  }

  addRectangle() {
    const newActor: ActorGeneric = {
      id: crypto.randomUUID(),
      type: "rectangle",
      x: generateRandom(100, 500),
      y: generateRandom(100, 250),
      width: generateRandom(50, 150),
      height: generateRandom(50, 100),
      color: this.sceneHelper.generateRandomColor(20, 50)
    };
    this.store.dispatch(ActorActions.addActor({ actor: { data: newActor } as Actor }))
  }

  addCircle() {
    const newActor: ActorGeneric = {
      id: crypto.randomUUID(),
      type: "circle",
      x: generateRandom(100, 500),
      y: generateRandom(100, 250),
      radius: generateRandom(30, 100),
      color: this.sceneHelper.generateRandomColor(20, 50)
    };
    this.store.dispatch(ActorActions.addActor({ actor: { data: newActor } as Actor }))
  }

  async addImage() {
    // Create ImageBitmap from external image
    const response = await fetch('https://example.com/image.jpg');
    const blob = await response.blob();
    const bitmap = await createImageBitmap(blob);
    const newActor: ActorGeneric = {
      id: crypto.randomUUID(),
      type: "image",
      x: generateRandom(100, 500),
      y: generateRandom(100, 250),
      image: bitmap
    }
    this.store.dispatch(ActorActions.addActor({ actor: { data: newActor } as Actor }))
  }

  addActor = (dialogData: any) => { // NOTE: Need arrow function if need to use "this" inside function
    const actorType = dialogData.actorType;
    switch (actorType) {
      case (ActorTypeEnum.background): {
        alert("Adding background not Implemented");
        break;
      }
      case (ActorTypeEnum.rectangle): {
        this.addRectangle();
        break;
      }
      case (ActorTypeEnum.circle): {
        this.addCircle();
        break;
      }
      case (ActorTypeEnum.image): {
        alert("Adding image not implemented");
        break;
      }
    }
  }

  updateColor(id: string, newColor: string) {
    this.store.dispatch(ActorActions.updateActor({ id: id, actorUpdate: { id, changes: { data: { color: newColor } } as Actor } }));
  }

  onActorMoved(id: string, newX: number, newY: number) {
    const currentlySelected = this.findById(id, this.actors.getValue());
    if (currentlySelected) {
      this.selectedActor.next(currentlySelected);
      this.store.dispatch(ActorActions.updateActor({ id: id, actorUpdate: { id, changes: { data: { x: newX, y: newY } } as Actor } }))
    }
  }

  onActorTransformed(id: string, shape: Shape<ShapeConfig>) {
    const currentActorData = this.selectedActor.getValue()?.data;
    const actorColor = currentActorData?.type != "image" ? (currentActorData as ActorRectangle).color : null;
    const changes: Partial<ActorGeneric> = {
      id: id,
      type: currentActorData?.type,
      x: roundTo3Decimals(shape.x()),
      y: roundTo3Decimals(shape.y()),
      transform: {
        rotation: roundTo3Decimals(shape.rotation()),
        scaleX: roundTo3Decimals(shape.scaleX()),
        scaleY: roundTo3Decimals(shape.scaleY()),
      }
    };

    let updatedChanges = changes as Partial<ActorRectangle>;
    if (actorColor != null) updatedChanges = {...updatedChanges, color: actorColor };
    this.store.dispatch(ActorActions.updateActor({ id: id, actorUpdate: { id: id, changes: { data: changes } as Actor } }));
  }

  private findById(id: string, list: Actor[]): Actor {
    return (list.filter(actor => actor?.data && actor.data.id == id) || [null])[0];
  }

  undo() {
    const previous = this.selectedActor.getValue();
    if (previous) {
      this.store.dispatch(ActorActions.updateActor({ id: previous.data.id, actorUpdate: { id: previous.data.id, changes: previous } }))
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
          id: sceneData?.id,
          name: sceneData?.name,
          actors: sceneData?.actors,
          size: sceneData?.size,
          nextSceneId: sceneData?.nextSceneId,
          winCondition: sceneData?.winCondition,
        } as SceneSvc;
        if (sceneData?.id) { scene.updatedAt = new Date(); }
        else scene.createdAt = new Date();
        return scene;
      }),
      withLatestFrom(this.actors), map(([sd, ad]) => {
        return {
          ...sd, actors: ad.map(actor => {
            const actorBaseProps = (actor.data as ActorBase);
            const actorRectangleProps = (actor.data as ActorRectangle);
            const actorCircleeProps = (actor.data as ActorCircle);
            const actorResourceBarProps = (actor.data as ActorResourceBar);
            const actorImageProps = (actor.data as ActorImage);

            const actorData = {
              ...actor,
              type: actorBaseProps.type, name: actorResourceBarProps.name,
              x: actor.data.x, y: actor.data.y,
              width: actorRectangleProps.width, height: actorRectangleProps.height,
              radius: actorCircleeProps.radius,
              color: actorRectangleProps.color,
              transform: actor.data.transform,
              transformDataJson: JSON.stringify(actor.data.transform),
              movable: actorBaseProps.movable,
            } as ActorSvc;
            if (sd.id) { actorData.updatedAt = new Date(); }
            else actorData.createdAt = new Date();
            return actorData;
          })
        };
      }),
    );
    let sceneSaved: Scene | null = null;
    sceneToSave$.subscribe(scene => {
      this.sceneService.saveScene(scene).subscribe(savedScene => sceneSaved = savedScene)
    });
  }

  loadActors(json: any) {
    const actors = json.actors as Actor[];
    this.store.dispatch(ActorActions.loadActors({ actors }))
  }

  protected onColorChange(event: any) {
    const newColor = event.value;

    const selectionMode = this.showStageMenu.getValue() ? "stage" : this.showActorMenu.getValue() ? "actor" : "none ?";
    console.log("SceneEditor: color received: ", newColor);
    console.log("Selection model: ", selectionMode);
    if (this.showActorMenu.getValue()) {
      this.actorColorChange$.next(newColor);
    } else {
      this.backgroundColorChange$.next(newColor);
    }
  }

  ngOnDestroy(): void {
    if (this.keyboardHandler) {
      this.stage?.container()?.removeEventListener('keydown', this.keyboardHandler);
    }
    this.stage?.destroy();
  }
}
