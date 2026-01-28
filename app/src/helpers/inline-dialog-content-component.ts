import { CommonModule } from "@angular/common";
import { AfterViewInit, ChangeDetectorRef, Component, CUSTOM_ELEMENTS_SCHEMA, Inject, OnChanges, OnInit, SimpleChanges } from "@angular/core";
import { MatButtonModule } from "@angular/material/button";
import { MAT_DIALOG_DATA, MatDialogRef } from "@angular/material/dialog";
import { MatDialogModule } from '@angular/material/dialog';

export interface ConfirmDialogData {
    title?: string;
    message: string;
    okText?: string;
    cancelText?: string;
    innerContent?: string;
}

@Component({
    selector: `inline-dialog-content`,
    schemas: [CUSTOM_ELEMENTS_SCHEMA],
    template: `
    <h2 mat-dialog-title *ngIf="data?.title">{{ data.title }}</h2>

    <mat-dialog-content>
      <p>{{ data?.message || '(no message)' }}</p>
      <ng-container [ngTemplateOutlet]="data.innerContent"></ng-container>
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>{{ data?.cancelText || 'Cancel' }}</button>
      <button mat-button
              [mat-dialog-close]="true"
              cdkFocusInitial
              color="primary">
        {{ data?.okText || 'OK' }}
      </button>
    </mat-dialog-actions>
    `,
    imports: [
        CommonModule,
        MatDialogModule,
        MatButtonModule
    ]
})

export class InlineDialogContentComponent {
    constructor(
        public dialogRef: MatDialogRef<InlineDialogContentComponent>,
        @Inject(MAT_DIALOG_DATA) public data: ConfirmDialogData,
        private cdr: ChangeDetectorRef
    ) {
        // Force immediate CD after data is available
        // this.cdr.detectChanges();
    }
}
