// inline-dialog-content.component.ts

import { CommonModule } from '@angular/common';
import { Component, Inject, TemplateRef } from '@angular/core';
import { FormGroup } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';

export interface DialogData {
  title?: string;
  message?: string;
  okText?: string;
  cancelText?: string;
  innerContent?: TemplateRef<any>;
  formGroup?: FormGroup;
}

@Component({
  selector: `inline-dialog-content`,
  template: `
    <h2 mat-dialog-title *ngIf="data?.title">{{ data.title }}</h2>
    <mat-dialog-content>
      <p>{{ data?.message || '(no message)' }}</p>
      <ng-container *ngIf="data.formGroup"
        [ngTemplateOutlet]="data.innerContent"
        [ngTemplateOutletContext]="{ $implicit: data.formGroup }">
      </ng-container>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close()">{{ data?.cancelText || 'Cancel' }}</button>
      <button mat-button (click)="onOk()" cdkFocusInitial color="primary">
        {{ data?.okText || 'OK' }}
      </button>
    </mat-dialog-actions>
  `,
  imports: [ CommonModule, MatDialogModule, MatButtonModule ]
})
export class InlineDialogContentComponent {
  constructor(
    public dialogRef: MatDialogRef<InlineDialogContentComponent>,
    @Inject(MAT_DIALOG_DATA) public data: DialogData
  ) { }

  onOk(): void {
    if (this.data.formGroup) { // TODO: problem: this data is not updated to the new input values from this form..
      this.dialogRef.close(this.data.formGroup.value);
    } else {
      this.dialogRef.close(false);
    }
  }
}
