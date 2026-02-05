// dialog-loader-directive.ts
import { Directive, HostListener, ContentChild, TemplateRef, ElementRef, Renderer2, ViewContainerRef, EnvironmentInjector, inject, Input, Output } from "@angular/core";
import { AfterContentInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { ConfirmDialogData, InlineDialogContentComponent } from "./inline-dialog-content-component";
import { Store } from "@ngrx/store";
import * as SceneActions from '../store/scenes/scenes.actions';

@Directive({
  standalone: false,
  selector: '[appDialogLoader]'
})

export class DialogLoaderDirective implements AfterContentInit {
  constructor(
    private vcr: ViewContainerRef,
    private dialog: MatDialog,   // if still needed
  ) { }

  store = inject(Store);

  @Input('appDialogLoader') dialogOptions!: ConfirmDialogData | null;
  @Input('appDialogLoaderFormData') dialogData!: FormData | null;
  @Input('appDialogLoaderSuccess') successFn!: (params: any) => any;
  @Input('appDialogLoaderError') errorFn!: (params: any) => any;
  @ContentChild('appDialogLoaderContent') customTemplate?: TemplateRef<any>;

  @HostListener('click')
  onHostClick() {

    const params = {
      title: this.dialogOptions?.title || 'Confirm action',
      message: this.dialogOptions?.message || 'Are you sure?',
      okText: this.dialogOptions?.okText || 'Yes',
      cancelText: this.dialogOptions?.cancelText || 'No',
      innerContent: this.customTemplate,
      formData: this.dialogOptions?.formData
    }

    console.log(this.customTemplate);

    const dialogRef = this.dialog.open(InlineDialogContentComponent, {
      width: '450px',
      data: params
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        // const formControls = (this.dialogData as any).getRawValue();
        const formErrors = {}; // TODO: find the errors.. this.dialogData.errors
        if (this.successFn != null) {
          this.successFn(this.dialogData);
        }
        else if (this.errorFn != null) {
          this.errorFn(formErrors);
        }
      }
    });
  }

  ngAfterContentInit(): void {
    console.log("AfterContentInit: customTemplate: ");
    console.log(this.customTemplate);
  }
}
