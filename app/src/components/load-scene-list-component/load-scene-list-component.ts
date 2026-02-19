import { AfterViewInit, Component, inject, OnInit, ViewChild } from '@angular/core';
import { SceneService } from '../../services/scene-service';
import { Scene } from '../../models/scene.model';
import { Observable, tap } from 'rxjs';
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator } from '@angular/material/paginator';
import { Store } from '@ngrx/store';
import * as ScenActions from '../../store/scenes/scenes.actions';

@Component({
  selector: 'load-scene-list-component',
  standalone: false,
  templateUrl: './load-scene-list-component.html',
  styleUrl: './load-scene-list-component.scss',
})
export class LoadSceneListComponent implements OnInit, AfterViewInit {
  store = inject(Store);

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
  }

  handleSelected(selectedScene: Scene) {
    this.selectedScene = selectedScene;
  }

  getSceneCss(scene: Scene): string {
    return scene.id == this.selectedScene?.id ? "table-item-row-selected" : "table-item-row";
  }

  loadScene() {
    debugger;
    if (this.selectedScene) {
      console.log("loading scene", this.selectedScene);
      this.store.dispatch(ScenActions.setCurrentScene({ scene: this.selectedScene }));
    }
  }
}
