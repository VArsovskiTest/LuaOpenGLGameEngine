import { ChangeDetectorRef, Component, inject, Input, input, OnDestroy, OnInit, OutputRefSubscription, ViewChild } from '@angular/core';
import { EditorMenuComponent } from '../editor-menu-component/editor-menu-component';
import { Store } from '@ngrx/store';
import { selectCurrentScene } from '../../store/scenes/scenes.selectors';
import { ofType } from '@ngrx/effects';
import { BehaviorSubject, combineLatest, Observable, Subscription, take, tap } from 'rxjs';
import * as SceneActions from '../../store/scenes/scenes.actions';
import { MenuItem } from '../../models/miscelaneous.models';
import { MenuItemsEnum } from '../../enums/enums';

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
  protected showEditor = false;
  private outputSub?: OutputRefSubscription;
  protected loadScene?:boolean;

  private cdr = inject(ChangeDetectorRef);

  constructor() {
    this.store.select(selectCurrentScene).subscribe(() => {
      this.cdr.markForCheck();  // or detectChanges() if isolated
    });
  }

  ngOnInit() {
    this.store.select(selectCurrentScene).subscribe(scene => {
      console.log("Current scene updated:", scene);
      this.showEditor = scene != null;
    });
    this.store.pipe(
      ofType(SceneActions.setCurrentScene),
      tap(a => console.log("setCurrentScene action received in component:", a))
    ).subscribe();
  }

  protected handleSelectedMenuItem(item: MenuItem) {
      this.loadScene = item.id == MenuItemsEnum.LoadScene;
      console.log("load scene", this.loadScene);
  }

  ngOnDestroy() {
    this.outputSub?.unsubscribe();
  }
}
