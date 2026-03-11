import { ChangeDetectorRef, Component, inject, Input, input, OnDestroy, OnInit, OutputRefSubscription, ViewChild } from '@angular/core';
import { EditorMenuComponent } from '../editor-menu-component/editor-menu-component';
import { Store } from '@ngrx/store';
import { selectCurrentScene } from '../../store/scenes/scenes.selectors';
import { ofType } from '@ngrx/effects';
import { BehaviorSubject, tap } from 'rxjs';
import * as SceneActions from '../../store/scenes/scenes.actions';
import { MenuItem, SnackbarModel } from '../../models/miscelaneous.models';
import { MenuItemsEnum } from '../../enums/enums';
import { Scene } from '../../store/scenes/scene.model';

@Component({
  selector: 'main-component',
  standalone: false,
  templateUrl: './main-component.html',
})

export class MainComponent implements OnDestroy, OnInit {
  @ViewChild(EditorMenuComponent) editorMenu!: EditorMenuComponent;
  @Input() selectedMenuItem: MenuItem | null = null;

  private store = inject(Store);

  protected currentScene$ = this.store.select(selectCurrentScene);
  protected currentScene: BehaviorSubject<Scene | null> = new BehaviorSubject<Scene | null>(null);
  private outputSub?: OutputRefSubscription;
  protected showCurrentScene: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false);
  protected showLoadScene: BehaviorSubject<boolean> = new BehaviorSubject(false);
  protected showSnackbar: BehaviorSubject<boolean> = new BehaviorSubject(false);
  protected snackbarModel: BehaviorSubject<SnackbarModel> = new BehaviorSubject({} as SnackbarModel);

  private cdr = inject(ChangeDetectorRef);

  constructor() {
    this.store.select(selectCurrentScene).subscribe(() => {
      this.cdr.markForCheck();  // or detectChanges() if isolated
    });
  }

  ngOnInit() {
    this.store.select(selectCurrentScene).subscribe(scene => {
      this.showCurrentScene.next(scene != null);
    });
    this.store.pipe(
      ofType(SceneActions.setCurrentScene),
      tap(scene => this.currentScene.next(scene.scene)),
      tap(a => console.log("setCurrentScene action received in component:", a))
    ).subscribe();
  }

  protected handleSelectedMenuItem(item: MenuItem) {
    this.showLoadScene.next(item.id == MenuItemsEnum.LoadScene);
    if (this.showLoadScene.getValue()) {
      this.showCurrentScene.next(false);
    };
  }

  protected getMainContentClass() {
    return this.currentScene.getValue() && this.showLoadScene.getValue() ? "main-content-editor" : "main-content-empty" ;
  }

  protected getSnackbarClass() {
    return this.snackbarModel.getValue().success ? "snackbar-success-content" : "snackbar-fail-content";
  }

  ngOnDestroy() {
    this.outputSub?.unsubscribe();
  }
}
