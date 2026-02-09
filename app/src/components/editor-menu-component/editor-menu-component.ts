import { Component, inject, output } from '@angular/core';
import { sizeEnum } from '../../enums/enums';
import { FormControl, FormGroup } from '@angular/forms';
import { Store } from '@ngrx/store';
import * as SceneActions from '../../store/scenes/scenes.actions';

@Component({
  selector: 'editor-menu',
  standalone: false,
  templateUrl: "./editor-menu-component.html",
})

export class EditorMenuComponent {
  selectedMenuItem = output<Record<number, string>>();
  store = inject(Store);
  protected formData: FormGroup = new FormGroup({ sceneName: new FormControl<string>("Sample Scene" + crypto.randomUUID()), sceneSize: new FormControl<sizeEnum>("s") });

  protected items: Record<number, string>[] = [
    { 1: 'File' },
    { 2: 'Editor' }
  ];

  protected itemMap: Record<string, number> = {
    'New scene': 1,
    'Load scene': 2,
    'Save scene': 3,
    'Launch scene': 4,
    'Add actor': 5,
    'Remove actor': 6,
    'Modify actor': 7
  };

  handleMenuItemClick(action: string) {
    const itemId = this.itemMap[action];
    this.selectedMenuItem.emit({ [itemId]: action });
  }

  handleNewSceneSuccess = (data: any) => {
    if (data) {
      console.log("values received: ", data);
      this.formData.patchValue({
        sceneName: data.sceneName,
        sceneSize: data.sceneSize,
      });

      this.store.dispatch(SceneActions.startNewScene({name: data?.sceneName, size: data?.sceneSize }));
    }
  }
}
