import { AfterViewInit, Component, inject, OnDestroy, OnInit, OutputRefSubscription, ViewChild } from '@angular/core';
import { EditorMenuComponent } from '../editor-menu-component/editor-menu-component';
import { SceneEditorComponent } from '../scene-editor-component/scene-editor-component';
import { Store } from '@ngrx/store';
import { selectCurrentScene } from '../../store/scenes/scenes.selectors';
import { AsyncPipe } from '@angular/common';

@Component({
  selector: 'main-component',
  templateUrl: './main-component.html',
  imports: [ EditorMenuComponent, SceneEditorComponent, AsyncPipe],
})

export class MainComponent implements AfterViewInit, OnDestroy, OnInit {
  @ViewChild(EditorMenuComponent) editorMenu!: EditorMenuComponent;
  private store = inject(Store);

  private currentScene$ = this.store.select(selectCurrentScene);

  protected showEditor = false;
  private outputSub?: OutputRefSubscription;

  ngOnInit(): void {
    this.currentScene$.subscribe(scene => this.showEditor = scene != null);
  }

  ngAfterViewInit() {
    if (this.editorMenu?.selectedMenuItem) {
      this.outputSub = this.editorMenu.selectedMenuItem.subscribe((item) => {
        this.showEditor = (item as any)["value"] == 'Editor';
      });
    } else {
      console.warn('EditorMenu not found');
    }
  }

  ngOnDestroy() {
    this.outputSub?.unsubscribe();
  }
}
