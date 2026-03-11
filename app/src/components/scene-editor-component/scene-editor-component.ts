import { AfterViewInit, ChangeDetectorRef, Component, ElementRef, inject, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Store } from '@ngrx/store';
import Konva from "konva";

import * as ActorActions from '../../store/actors/actors.actions'
import { Actor, ActorImageUploadModel } from '../../store/actors/actor.model'
import { selectAllActors, selectSelectedActor, selectSelectedActorId } from '../../store/actors/actors.selectors';
import { BehaviorSubject, map, Observable, Subject, take, throttleTime, withLatestFrom } from 'rxjs';
import { Scene, SceneState } from '../../store/scenes/scene.model';
import { selectSceneState } from '../../store/scenes/scenes.selectors';
import { ActorSvc, SceneService, SceneSvc } from '../../services/scene-service';
import { ActorsService } from '../../services/actors-service';
import { generateRandom, roundTo3Decimals } from '../../shared/helpers/math-helper';
import { Shape, ShapeConfig } from 'konva/lib/Shape';
import { SceneSizeEnum } from '../../enums/enums';
import { CalculateHeight, CalculateWidth, generateRandomColor } from '../../shared/helpers/scene.helper';

import { Stage } from 'konva/lib/Stage';
import { ActorTypeEnum } from '../../enums/enums';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { BackgroundAdapter, CircleAdapter, GenericActorAdapter, ImageAdapter, RectangleAdapter, ResourceBarAdapter } from '../../models/actor-adapters';
import { Update } from '@ngrx/entity';

@Component({
  selector: 'scene-editor',
  standalone: false,
  templateUrl: './scene-editor-component.html',
  styleUrl: './scene-editor-component.scss',
})

export class SceneEditorComponent implements OnInit, AfterViewInit, OnDestroy {

  @ViewChild("stageContainer") stageCongainer!: ElementRef<HTMLDivElement>;
  showFileLoader: BehaviorSubject<boolean> = new BehaviorSubject(false);

  private sceneService: SceneService = inject(SceneService);
  private actorsService: ActorsService = inject(ActorsService);

  private store = inject(Store);
  actors$ = this.store.select(selectAllActors);
  selectedId$ = this.store.select(selectSelectedActorId);
  selectedActor$ = this.store.select(selectSelectedActor);
  currentScene$ = this.store.select(selectSceneState);

  actors = new BehaviorSubject<Actor[]>([]);
  selectedActor = new BehaviorSubject<Actor | null | undefined>(undefined);
  imageActor = new BehaviorSubject<ActorImageUploadModel | null>(null);
  currentScene = new BehaviorSubject<SceneState | null>(null);

  private fb = inject(FormBuilder);
  protected addActorFormData: FormGroup = this.fb.group({
    actorType: ActorTypeEnum, // TODO: Do validation later if need be: Validators.apply(() =>{...})
    sceneId: '',
    file: File,
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
      const backgroundActorId = this.backgroundActor.getValue().id;
      const backgroundActor = actors.find(actor => actor.id == backgroundActorId);
      if (backgroundActor) this.backgroundActor.next(backgroundActor);
      this.redrawShapes(actors, this.VISIBLE_WIDTH, this.VISIBLE_HEIGHT);
    });

    this.selectedActor.subscribe(actor => {
      if (actor) { this.selectedColor.next(actor.color); }
      this.cdr.detectChanges(); // usually needed
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

  private initializeActorsAndBackground(actors: Actor[]) {
    let backgroundData = actors.find(actor => actor.type == "background");

    if (backgroundData) { this.backgroundActor.next(backgroundData); }
    else {
      backgroundData = this.getOrGenerateBackground();
      actors.push(backgroundData);
      this.backgroundActor.next(backgroundData);
      this.background.next(RectangleAdapter.actorToShape(this.backgroundActor.getValue()));
      this.store.dispatch(ActorActions.addActor({ actor: this.backgroundActor.getValue() }));
    }

    actors.forEach(actor => {
      if (!actor.color) actor.color = generateRandomColor();
      this.store.dispatch(ActorActions.addActor({ actor: actor }));
    });

    this.actors.next(actors);
  }

  //#endregion

  ngOnInit(): void {
    console.log("Scene loaded from Store", this.currentScene);

    this.showActorMenu$ = this.showActorMenu.asObservable();
    this.showStageMenu$ = this.showStageMenu.asObservable();
    this.selectedColor$ = this.selectedColor.asObservable();

    this.actorColorChange$.pipe(throttleTime(50, undefined, { leading: true, trailing: false })) // Immediate first, then at most every 50ms
      .subscribe(color => {
        const updated = { ...this.selectedActor.getValue(), color } as Actor;
        this.updateColor(updated.id, color);
      });

    this.backgroundColorChange$.pipe(throttleTime(50, undefined, { leading: true, trailing: false })) // Immediate first, then at most every 750ms
      .subscribe(color => {
        const updated = { ...this.backgroundActor.getValue(), color } as Actor;
        this.updateColor(updated.id, color);
        this.backgroundActor.next(updated);
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

  //#region Canvas methods
  private redrawShapes(actors: Actor[], vw: number, vh: number) {
    // this.layer.destroyChildren();   // ← Preserve transformer instead
    this.layer.getChildren().forEach(child => { if (child !== this.tr) { child.destroy(); } });
    this.shapes = {};

    actors.sort((actor1, actor2) => actor1.type > actor2.type ? 1 : -1) // Parse background first
      .forEach(actor => {
        let shape: Konva.Shape;
        switch (actor.type) {
          case ActorTypeEnum.background:
            {
              let backgroundData = this.backgroundActor.getValue();
              backgroundData = { ...backgroundData, id: backgroundData.id, width: this.VISIBLE_WIDTH, height: this.VISIBLE_HEIGHT, transform: { scaleX: 1.0, scaleY: 1.0 } };
              shape = BackgroundAdapter.actorToShape(backgroundData);
              break;
            }
          case ActorTypeEnum.rectangle: {
            shape = RectangleAdapter.actorToShape(actor, {
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
            shape = CircleAdapter.actorToShape(actor, {
              draggable: true,
              resizable: true,
              dragBoundFunc: function (pos: any) {
                const newX = Math.max(0, Math.min(pos.x, vw - (actor.radius ?? 0)));
                const newY = Math.max(0, Math.min(pos.y, vh - (actor.radius ?? 0)));
                return { x: newX, y: newY };
              }
            });
            break;
          }
          case ActorTypeEnum.image: {
            shape = ImageAdapter.actorToShape({} as Actor, 
            {
              image: actor?.image || new ImageBitmap(), //HTMLOrSVGImageElement | HTMLVideoElement | HTMLCanvasElement | ImageBitmap | OffscreenCanvas | VideoFrame
              crop: actor?.crop || {x: 0, y: 0, width: 0, height: 0},
              cornerRadius: actor?.cornerRadius,
              dragBoundFunc: function (pos: any) {
                const newX = Math.max(0, Math.min(pos.x, vw - (actor.crop?.width ?? 0)));
                const newY = Math.max(0, Math.min(pos.y, vh - (actor.crop?.height ?? 0)));
                return { x: newX, y: newY };
              }
            })
            shape = new Konva.Image();
            break;
          }
          case ActorTypeEnum.resourcebar: {
            shape = ResourceBarAdapter.actorToShape(actor, { draggable: false });
          }
        }

        if (shape!) {
          shape.on("click tap", (e) => {
            this.selectedColor.next(actor.color);
            const backgroundClick = actor.type == 'background';
            const targetId = e.target.attrs["id"];
            const selectedId = this.selectedActor.getValue()?.id;

            this.showTransformer(actor.id, targetId);
            if (!backgroundClick) this.highlightActor(selectedId!, targetId)
            else {
              this.highlightStage();
              this.backgroundActor.next(actor);
            }
            this.store.dispatch(ActorActions.selectActor({ id: actor.id }));

            this.selectedActor.next(this.findById(actor.id, this.actors.getValue()));
            e.cancelBubble = true;
            this.layer.batchDraw();
          });

          shape.on("dragend", () => { this.onActorMoved(actor.id, shape.x(), shape.y()) });
          shape.on('transformend', (shape) => { this.onActorTransformed(actor.id, shape.currentTarget); });

          if (shape.getParent()) {
            if (actor.type == "background") shape.moveToBottom(); else shape.moveToTop();
          }

          shape.zIndex(actor.z);
          this.layer.add(shape);
          this.shapes[actor.id] = shape;
        }
      });

    this.layer.draw();
  }

  private highlightOutline(id: string | null) {
    this.actors.getValue().forEach(actor => {
      this.shapes[actor.id].strokeWidth(actor.id == id ? 4 : 2);
    });
  }

  private highlightActor(id: string, targetId: string) {
    this.showStageMenu.next(false);
    this.showActorMenu.next(targetId == id);
    this.highlightOutline(id!);
  }

  private highlightStage() {
    this.showActorMenu.next(false);
    this.showStageMenu.next(true);
    this.highlightOutline(null);
  }

  private showTransformer(id: string, targetId: string | undefined) {
    this.showActorMenu.next(false);
    this.showStageMenu.next(false);

    const backgroundClick = this.actors.getValue().find(actor => actor.id == targetId)?.type == "background";
    const sameActorClick = (this.selectedActor.getValue()?.id || false) && (targetId == this.selectedActor.getValue()?.id);
    const transformNodes = targetId && !sameActorClick && !backgroundClick ? [this.shapes[targetId]] : [];
    const showTransformer = transformNodes.length ? !this.tr.isTransforming() : false;

    this.tr.nodes(transformNodes);
    this.tr.moveToTop(); // Set transforming actor to top
    this.tr.setAttr("isTransforming", showTransformer);
  }

  addRectangle() {
    const newActor: Actor = {
      id: crypto.randomUUID(),
      type: "rectangle",
      x: generateRandom(100, 500),
      y: generateRandom(100, 250),
      z: 1,
      width: generateRandom(50, 150),
      height: generateRandom(50, 100),
      color: generateRandomColor(20, 50)
    };
    this.store.dispatch(ActorActions.addActor({ actor: newActor }))
  }

  addCircle() {
    const newActor: Actor = {
      id: crypto.randomUUID(),
      type: "circle",
      x: generateRandom(100, 500),
      y: generateRandom(100, 250),
      z: 1,
      radius: generateRandom(30, 100),
      color: generateRandomColor(20, 50)
    };
    this.store.dispatch(ActorActions.addActor({ actor: newActor }))
  }

  addImage(actorType: any) {
    this.showFileLoader.next(actorType.value as ActorTypeEnum == "image");
  }

  addActor = (dialogData: any) => {
    const actorType = dialogData.actorType;
    switch(actorType) {
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
        this.uploadImage();
        break;
      }
    }
  }

  updateColor(id: string, newColor: string) {
    this.store.dispatch(ActorActions.updateActor({ id: id, actorUpdate: { id, changes: { color: newColor } } }));
  }

  onActorMoved(id: string, newX: number, newY: number) {
    const currentlySelected = this.findById(id, this.actors.getValue());
    if (currentlySelected) {
      this.selectedActor.next(currentlySelected);
      this.store.dispatch(ActorActions.updateActor({ id: id, actorUpdate: { id, changes: { x: newX, y: newY } } }))
    }
  }

  onActorTransformed(id: string, shape: Shape<ShapeConfig>) {
    const changes: Partial<Actor> = {
      x: roundTo3Decimals(shape.x()),
      y: roundTo3Decimals(shape.y()),
      transform: {
        rotation: roundTo3Decimals(shape.rotation()),
        scaleX: roundTo3Decimals(shape.scaleX()),
        scaleY: roundTo3Decimals(shape.scaleY()),
      }
    };
    this.store.dispatch(ActorActions.updateActor({ id: id, actorUpdate: { id: id, changes: changes } }));
  }

  //#endregion

  undo() {
    const previous = this.selectedActor.getValue();
    if (previous) {
      this.store.dispatch(ActorActions.updateActor({ id: previous.id, actorUpdate: { id: previous.id, changes: previous } }))
    }
  }

  clearAll() {
    this.store.dispatch(ActorActions.clearScene());
  }

  setUploadedImage(imageData: any) {
    this.imageActor.next(imageData);
  }

  uploadImage() {
    const file = this.imageActor.getValue()?.file as File;
    const uploadedImage$ = this.actorsService.uploadActor(this.currentScene.getValue()?.currentScene?.id!, file);
    uploadedImage$.subscribe(image => alert(image));
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
            const actorData = {
              ...actor,
              type: actor.type, name: actor.name,
              x: actor.x, y: actor.y, z: actor.z,
              width: actor.width, height: actor.height, radius: actor.radius,
              color: actor.color,
              transform: actor.transform,
              transformDataJson: JSON.stringify(actor.transform),
              movable: actor.movable,
            } as ActorSvc;
            if (sd?.id) { actorData.updatedAt = new Date(); }
            else actorData.createdAt = new Date();
            return actorData;
          })
        };
      }),
    );
    let sceneSaved: Scene | null = null;
    sceneToSave$.subscribe(scene => {
      this.sceneService.saveScene(scene).subscribe(savedScene => sceneSaved = savedScene);
    });
  }

  loadActors(json: any) {
    const actors = json.actors as Actor[];
    this.store.dispatch(ActorActions.loadActors({ actors }))
  }

  protected onColorChange(event: any) {
    const newColor = event.value;
    const selectionMode = this.showStageMenu.getValue() ? "stage" : this.showActorMenu.getValue() ? "actor" : "none ?";
    if (this.showActorMenu.getValue()) this.actorColorChange$.next(newColor);
    else this.backgroundColorChange$.next(newColor);
  }

  private updateActors() {
    const actors = this.actors.getValue();
    const actorUpdates = actors.map(actor => { return { id: actor.id, actorUpdate: { id: actor.id, changes: actor }, changes: actor }}) as Update<Actor>[];
    this.store.dispatch(ActorActions.updateAll({ actorUpdates }));
  }

  protected moveToTop() {
    const selectedActor = this.selectedActor.getValue();
    if (selectedActor?.id) {
      const shape = this.shapes[selectedActor.id];
      if (shape) {
        shape.moveToTop();
        // this.updateActors();
      }
    }
  }

  protected moveToBottom() {
    const selectedActor = this.selectedActor.getValue();
    if (selectedActor?.id) {
      const shape = this.shapes[selectedActor.id];
      if (shape) {
        shape.moveToBottom();
        const backgroundActorId = this.backgroundActor.getValue().id;
        const backgroundShape = this.shapes[backgroundActorId];
        if (backgroundShape) {
          backgroundShape.moveToBottom();
        }
        // this.updateActors();
      }
    }
  }

  ngOnDestroy(): void {
    if (this.keyboardHandler) {
      this.stage?.container()?.removeEventListener('keydown', this.keyboardHandler);
    }
    this.stage?.destroy();
  }

  //#region Private Helpers
  private getOrGenerateBackground(color?: string) {
    let existing = this.actors.getValue().find((actor: Actor) => actor.type == 'background');
    if (existing) return existing;

    const colorHex = color || generateRandomColor(35, 75);
    const backgroundData = existing || {
      id: crypto.randomUUID(),
      sceneId: this.currentScene.getValue()?.currentScene?.id,
      type: "background",
      color: colorHex,
      x: 0, y: 0, z:0, width: this.VISIBLE_WIDTH, height: this.VISIBLE_HEIGHT,
      fill: colorHex,
      draggable: false,
      resizable: false
    } as Actor;
    return backgroundData;
  }

  private findById(id: string, list: Actor[]): Actor {
    return (list.filter(actor => actor.id == id) || [null])[0];
  }
  //#endregion
}
