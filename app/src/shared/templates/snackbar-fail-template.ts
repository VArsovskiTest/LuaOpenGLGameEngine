import { ChangeDetectorRef, Component, Inject, TemplateRef } from '@angular/core';
import { SNACKBAR_CONTENT_TOKEN } from '../snackbar-content-tokens';
import { SnackbarModel } from '../../models/miscelaneous.models';
import { MatSnackBarRef } from '@angular/material/snack-bar';

@Component({
  selector: 'snackbar-fail-template',
  imports: [],
  template: `<div class='dialog-title'>
    {{ data.errorTitle || 'Fail' }}
  </div>
  <div class='dialog-subtitle'>
    {{ data.message || 'An error occurred' }}
  </div>`,
})
export class SnackbarFailTemplate {    
    constructor(private cdr: ChangeDetectorRef
      , protected templateRef: MatSnackBarRef<TemplateRef<any>>
      , @Inject(SNACKBAR_CONTENT_TOKEN) public data: SnackbarModel) { }
}
