import { RouterOutlet } from '@angular/router';
import { AfterViewInit, Component, OnDestroy, OutputRefSubscription, ViewChild } from '@angular/core';
import { EditorMenuComponent } from '../editor-menu-component/editor-menu-component';
import { SceneEditorComponent } from '../scene-editor-component/scene-editor-component';

@Component({
  selector: 'app-component',
  templateUrl: './app-component.html',
  standalone: true,
  imports: [RouterOutlet, EditorMenuComponent, SceneEditorComponent],
})

export class AppComponent implements AfterViewInit, OnDestroy {
  @ViewChild(EditorMenuComponent) editorMenu!: EditorMenuComponent;

  protected showEditor = false;
  private outputSub?: OutputRefSubscription;

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
