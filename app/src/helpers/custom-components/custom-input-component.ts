// src/app/helpers/custom-components/custom-input-component.ts
import { Component, Input, inject } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { CURRENT_FORM_GROUP } from '../../helpers/dialog-form-tokens';
import { MatLabel } from '@angular/material/select';

@Component({
    selector: 'app-custom-input',
    standalone: false,
    template: `
    <mat-form-field appearance="fill" class="full-width">
      <mat-label>{{ label }}</mat-label>
      <input matInput
        [formControl]="control"
        [placeholder]="placeholder"
        [type]="type"
        [required]="required"
      />
      <mat-error *ngIf="control?.hasError('required')">
        This field is required
      </mat-error>
      <mat-error *ngIf="control?.hasError('minlength')">
        Minimum length: {{ control?.errors?.['minlength']?.requiredLength }}
      </mat-error>
    </mat-form-field>
  `,
    styles: [`.full-width { width: 100%; }`]
})
export class CustomInputComponent {
    // private formGroup = inject(CURRENT_FORM_GROUP);
    @Input() formGroup!: FormGroup;
    @Input() controlName!: string;     // required: 'sceneName', 'email', etc.
    @Input() label: string = '';
    @Input() placeholder: string = '';
    @Input() type: string = 'text';
    @Input() required: boolean = false;

    get control(): FormControl {
        if (!this.formGroup) {
            throw new Error('formGroup input is required');
        }
        const ctrl = this.formGroup.get(this.controlName);
        if (!ctrl) {
            throw new Error(`Control ${this.controlName} not found`);
        }
        return ctrl as FormControl;
    }
}
