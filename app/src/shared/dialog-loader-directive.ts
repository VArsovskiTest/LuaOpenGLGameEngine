// dialog-loader-directive.ts
import { Directive, HostListener, ContentChild, TemplateRef, ElementRef, inject, Input } from "@angular/core";
import { AfterContentInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { DialogData, InlineDialogContentComponent } from "./inline-dialog-content-component";
import { Store } from "@ngrx/store";
import { FormGroup } from "@angular/forms";

@Directive({
  standalone: false,
  selector: '[appDialogLoader]'
})

export class DialogLoaderDirective implements AfterContentInit {
  constructor(
    private dialog: MatDialog,
  ) { }

  store = inject(Store);

  @Input('appDialogLoader') dialogOptions!: DialogData | null;
  @Input('appDialogLoaderFormData') dialogData!: FormGroup | null; // The FormGroup passed from host control
  @Input('appDialogLoaderSuccess') successFn!: (params: any) => any;
  @Input('appDialogLoaderError') errorFn!: (params: any) => any;
  @ContentChild('appDialogLoaderContent') customTemplate?: TemplateRef<any>;

  @HostListener('click')
  onHostClick() {

    const params = {
      title: this.dialogOptions?.title,
      message: this.dialogOptions?.message,
      okText: this.dialogOptions?.okText || 'Yes',
      cancelText: this.dialogOptions?.cancelText || 'No',
      innerContent: this.customTemplate,
      formGroup: this.dialogData  // This is now the entire FormGroup
    }

    const dialogRef = this.dialog.open(InlineDialogContentComponent, {
      width: '450px',
      data: params
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        console.log("Dialog closed with result:", result);
        if (this.successFn) {
          this.successFn(result);
        }
      }
    });
  }

  ngAfterContentInit(): void {
    console.log("AfterContentInit: customTemplate: ", this.customTemplate);
  }
}
