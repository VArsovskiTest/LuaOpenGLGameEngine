import { AfterViewInit, ChangeDetectorRef, Component, Input } from '@angular/core';
import { SnackbarModel } from '../../models/miscelaneous.models';
import { SnackbarSuccessTemplate } from '../../shared/templates/snackbar-success-template';
import { SnackbarFailTemplate } from '../../shared/templates/snackbar-fail-template';

@Component({
  selector: 'app-custom-snackbar-component',
  template: `<ng-container model="snackbarModel"></ng-container>
    <ng-template #appLoadSnackbarSuccessTemplate [appLoadSnackbarSuccessTemplate]="snackbarSuccessTemplate"></ng-template>
    <ng-template #appLoadSnackbarFailTemplate [appLoadSnackbarFailTemplate]="snackbarFailTemplate"></ng-template>`
  })
export class CustomSnackbarComponent implements AfterViewInit {
  @Input() public snackbarModel: SnackbarModel = {} as SnackbarModel;
  constructor(protected snackbarSuccessTemplate: SnackbarSuccessTemplate, protected snackbarFailTemplate: SnackbarFailTemplate, private cdr: ChangeDetectorRef) {
    snackbarSuccessTemplate.data = this.snackbarModel;
    snackbarFailTemplate.data = this.snackbarModel;
  }
  ngAfterViewInit(): void {
    this.cdr.detectChanges();
  }
}
