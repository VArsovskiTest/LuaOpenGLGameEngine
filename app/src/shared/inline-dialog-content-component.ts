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
  <ng-content>
    <h2 mat-dialog-title *ngIf="data?.title"><strong>{{ data.title }}</strong></h2>
    <mat-dialog-content style="padding-bottom: 15px"><!--Removes the scrollbar if not necessary-->
    <ng-container *ngIf="data?.message">
      <p><strong>{{ data?.message }}</strong></p>
    </ng-container>
    <ng-container *ngIf="!data?.message">
      <hr/>
    </ng-container>
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
    </ng-content>
  `,
  imports: [CommonModule, MatDialogModule, MatButtonModule]
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
