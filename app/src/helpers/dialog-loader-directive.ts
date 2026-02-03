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
  ) {}

  store = inject(Store);

  @Input('appDialogLoader') data!: ConfirmDialogData | null;
  @ContentChild('appDialogLoaderContent') customTemplate?: TemplateRef<any>;

  @HostListener('click')
  onHostClick(){

    const params = {
        title: this.data?.title || 'Confirm action',
        message: this.data?.message || 'Are you sure?',
        okText: this.data?.okText || 'Yes',
        cancelText: this.data?.cancelText || 'No',
        innerContent: this.customTemplate
    }

    console.log(this.customTemplate);

    const dialogRef = this.dialog.open(InlineDialogContentComponent, {
      width: '450px',
      data: params
    });

    dialogRef.afterClosed().subscribe(result => {
      this.store.dispatch(SceneActions.startNewScene({
        size: "s",
        name: "Sample scene (New) – " + Date.now()   // ← makes name unique
      }));
    });
  }

  ngAfterContentInit(): void {
    console.log("AfterContentInit: customTemplate: ");
    console.log(this.customTemplate);
  }
}
