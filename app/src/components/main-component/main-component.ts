import { ChangeDetectorRef, Component, inject, OnDestroy, OnInit, OutputRefSubscription, ViewChild } from '@angular/core';
import { EditorMenuComponent } from '../editor-menu-component/editor-menu-component';
import { Store } from '@ngrx/store';
import { selectCurrentScene } from '../../store/scenes/scenes.selectors';
import { ofType } from '@ngrx/effects';
import { tap } from 'rxjs';
import * as SceneActions from '../../store/scenes/scenes.actions';

@Component({
  selector: 'main-component',
  standalone: false,
  templateUrl: './main-component.html',
})

export class MainComponent implements OnDestroy, OnInit {
  @ViewChild(EditorMenuComponent) editorMenu!: EditorMenuComponent;

  private store = inject(Store);
  protected currentScene$ = this.store.select(selectCurrentScene);
  protected showEditor = false;
  private outputSub?: OutputRefSubscription;

  private cdr = inject(ChangeDetectorRef);

  constructor() {
    console.log("MainComponent constructor called");
    this.store.select(selectCurrentScene).subscribe(() => {
      console.log("Selector emitted → forcing CD");
      this.cdr.markForCheck();  // or detectChanges() if isolated
    });
  }

  ngOnInit() {
    console.log("Main component init:");
    console.log(this.store);
    this.store.select(selectCurrentScene).subscribe(scene => {
      console.log("Current scene updated:", scene);
      this.showEditor = scene != null;
    });
    this.store.pipe(
      ofType(SceneActions.setCurrentScene),
      tap(a => console.log("setCurrentScene action received in component:", a))
    ).subscribe();
  }

  ngOnDestroy() {
    this.outputSub?.unsubscribe();
  }
}
