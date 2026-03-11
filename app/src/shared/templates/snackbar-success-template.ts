import { ChangeDetectorRef, Component, Inject, TemplateRef } from '@angular/core';
import { SNACKBAR_CONTENT_TOKEN } from '../snackbar-content-tokens';
import { SnackbarModel } from '../../models/miscelaneous.models';
import { MatSnackBarRef } from '@angular/material/snack-bar';

@Component({
  selector: 'snackbar-success-template',
  imports: [],
  template: `<div class='dialog-title'>
    {{ data.successTitle || 'Success' }}
  </div>
  <div class='dialog-subtitle'>
    {{ data.message || 'Action completed successfully' }}
  </div>`,
})
export class SnackbarSuccessTemplate {
    constructor(private cdr: ChangeDetectorRef
      , protected templateRef: MatSnackBarRef<TemplateRef<any>>
      , @Inject(SNACKBAR_CONTENT_TOKEN) public data: SnackbarModel) { }
}
