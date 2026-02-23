import { AfterViewInit, Component, inject, OnInit, ViewChild } from '@angular/core';
import { SceneService } from '../../services/scene-service';
import { Scene, SceneState } from '../../models/scene.model';
import { BehaviorSubject, Observable, tap } from 'rxjs';
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator } from '@angular/material/paginator';
import { Store } from '@ngrx/store';
import * as ScenActions from '../../store/scenes/scenes.actions';
import { selectSceneState } from '../../store/scenes/scenes.selectors';

@Component({
  selector: 'load-scene-list',
  standalone: false,
  templateUrl: './load-scene-list-component.html',
  styleUrl: './load-scene-list-component.scss',
})
export class LoadSceneListComponent implements OnInit, AfterViewInit {
  store = inject(Store);
  currentScene$ = this.store.select(selectSceneState);
  private currentScene: BehaviorSubject<SceneState | null> = new BehaviorSubject<SceneState | null>(null);

  protected scenesList$: Observable<Scene[]> = new Observable<Scene[]>();
  displayedColumns: string[] = ['id', 'name', 'size'];

  dataSource: MatTableDataSource<Scene> = new MatTableDataSource();
  // selection = new SelectionModel<Scene>(true, []); // 'true' allows multiple selection
  @ViewChild(MatPaginator) paginator!: MatPaginator;
  protected selectedScene?: Scene;

  constructor(private sceneService: SceneService) {}

  ngOnInit(): void {
    this.scenesList$ = this.sceneService.getScenes();
  }

  ngAfterViewInit() {
    this.scenesList$
    // TODO: if instead to dataSource you want to subscribe with (this.sceneList$ | async) you manually update the paginator
    // .pipe(tap(scene => { if (this.paginator) { this.dataSource.paginator = this.paginator; } }))
    .subscribe(sceneList => { this.dataSource.data = sceneList });
    this.dataSource.paginator = this.paginator;

    this.currentScene$.subscribe(scene => this.currentScene.next(scene));
  }

  handleSelected(selectedScene: Scene) {
    this.selectedScene = selectedScene;
  }

  getSceneCss(scene: Scene): string {
    return scene.id == this.selectedScene?.id ? "table-item-row-selected" : "table-item-row";
  }

  loadScene() {
    if (this.selectedScene) {
      const currentSceneId = this.currentScene.getValue()?.currentScene?.id;
      if (currentSceneId && (this.selectedScene.id != currentSceneId)) {
        this.store.dispatch(ScenActions.resetScene());
      }
      console.log("loading scene", this.selectedScene);
      this.store.dispatch(ScenActions.setCurrentScene({ scene: this.selectedScene }));
    }
  }
}
