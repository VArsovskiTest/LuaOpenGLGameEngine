import { Component, inject, output } from '@angular/core';
import { sizeEnum } from '../../enums/enums';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { Store } from '@ngrx/store';
import * as SceneActions from '../../store/scenes/scenes.actions';
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
  selectedMenuItem = output<Record<number, string>>();
  store = inject(Store);

  private fb = inject(FormBuilder);
  formData = this.fb.group({
    sceneName: ['', Validators.required],
    sceneSize: ['s', Validators.required]
  });

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

      this.store.dispatch(SceneActions.startNewScene({ name: data?.sceneName, size: data?.sceneSize }));
    }
  }
}
