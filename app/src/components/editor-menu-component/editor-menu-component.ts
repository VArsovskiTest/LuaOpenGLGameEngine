import { Component, inject, output } from '@angular/core';
import { MenuItemsEnum, sizeEnum } from '../../enums/enums';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { select, Store } from '@ngrx/store';
import * as SceneActions from '../../store/scenes/scenes.actions';
import { MenuItem } from '../../models/miscelaneous.models';
// import { CURRENT_FORM_GROUP } from '../../helpers/dialog-form-tokens';

@Component({
  selector: 'editor-menu',
  standalone: false,
  templateUrl: "./editor-menu-component.html",
  // providers: [
  //   {
  //     provide: CURRENT_FORM_GROUP,
  //     deps: [FormBuilder],
  //     useFactory: (fb: FormBuilder) => fb.group({
  //       sceneName: ['', Validators.required],
  //       sceneSize: ['s' as sizeEnum, Validators.required]
  //     })
  //   }
  // ]
})

export class EditorMenuComponent {
  selectedMenuItem = output<MenuItem | null>();
  store = inject(Store);

  private fb = inject(FormBuilder);
  formData = this.fb.group({
    sceneName: ['', Validators.required],
    sceneSize: ['s', Validators.required]
  });

  protected itemMap: MenuItem[] = [
    new MenuItem('New scene', MenuItemsEnum.NewScene),
    new MenuItem('Load scene', MenuItemsEnum.LoadScene),
    new MenuItem('Save scene', MenuItemsEnum.SaveScene),
    new MenuItem('Launch scene', MenuItemsEnum.LaunchScene),
    new MenuItem('Add actor', MenuItemsEnum.AddActor),
    new MenuItem('Remove actor', MenuItemsEnum.RemoveActor),
    new MenuItem('Modify actor', MenuItemsEnum.ModivyActor)
  ];

  handleMenuItemClick(action: string) {
    const selectedItem = this.itemMap.find(item => item.name == action) || null;
    this.selectedMenuItem.emit(selectedItem);
  }

  handleNewSceneSuccess = (data: any) => {
    if (data) {
      this.formData.patchValue({
        sceneName: data.sceneName,
        sceneSize: data.sceneSize,
      });

      this.store.dispatch(SceneActions.startNewScene({ name: data?.sceneName, size: data?.sceneSize }));
    }
  }
}
