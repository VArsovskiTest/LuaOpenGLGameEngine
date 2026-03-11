// inline-dialog-content.component.ts
import { CommonModule } from '@angular/common';
import { AfterViewInit, ChangeDetectorRef, Component, Inject, TemplateRef } from '@angular/core';
import { FormGroup } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { DialogData } from '../../models/miscelaneous.models';

@Component({
  selector: `inline-dialog-content`,
  template: `
  <ng-content>
    <mat-dialog-content style="padding-bottom: 15px"><!--Removes the scrollbar if not necessary-->
      <h2 class="mat-dialog-title" *ngIf="data?.title">{{ data?.title }}</h2>
      <h4 class="mat-dialog-subtitle" *ngIf="data?.message">{{ data?.message }}</h4>
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
export class InlineDialogContentComponent implements AfterViewInit {
  constructor(
    public dialogRef: MatDialogRef<InlineDialogContentComponent>,
    private cdr: ChangeDetectorRef,
    @Inject(MAT_DIALOG_DATA) public data: DialogData
  ) { }

  ngAfterViewInit(): void {
    this.cdr.markForCheck();
  }

  onOk(): void {
    if (this.data.formGroup) { // TODO: problem: this data is not updated to the new input values from this form..
      this.dialogRef.close(this.data.formGroup.value);
    } else {
      this.dialogRef.close(false);
    }
  }
}
