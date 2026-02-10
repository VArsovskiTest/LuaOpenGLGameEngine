// src/app/shared/custom-form-controls/custom-radio-group.component.ts
import { Component, Input, inject } from '@angular/core';
import { CURRENT_FORM_GROUP } from '../../helpers/dialog-form-tokens';

@Component({
  selector: 'app-custom-radio-group',
  standalone: false,
  template: `
    <div class="radio-group">
      <!--<mat-label>{{ label }}</mat-label>-->
      <!--<mat-radio-group [formControl]="control">-->
        <mat-radio-button *ngFor="let option of options" [value]="option.value">
          {{ option.label }}
        </mat-radio-button>
      <!--</mat-radio-group>-->
      <mat-error *ngIf="control?.hasError('required')">
        Please select an option
      </mat-error>
    </div>
  `,
  styles: [`
    .radio-group {
      margin: 16px 0;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
  `]
})
export class CustomRadioGroupComponent {
  private formGroup = inject(CURRENT_FORM_GROUP);

  @Input() controlName!: string;
  @Input() label: string = '';
  @Input() options: { value: string; label: string }[] = [];

  get control() {
    const ctrl = this.formGroup.get(this.controlName);
    if (!ctrl) {
      throw new Error(`Control "${this.controlName}" not found in FormGroup`);
    }
    return ctrl;
  }
}
