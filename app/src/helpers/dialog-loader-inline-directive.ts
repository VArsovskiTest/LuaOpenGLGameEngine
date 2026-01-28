// dialog-loader-directive.ts
import { Directive, HostListener, ContentChild, TemplateRef, ElementRef, Renderer2, ViewContainerRef, EnvironmentInjector, inject } from "@angular/core";
import { AfterContentInit } from '@angular/core';
import { InlineDialogContentComponent } from "./inline-dialog-content-component";

@Directive({
  standalone: true,
  selector: '[appDialogLoaderInline]'
})

export class DialogLoaderInlineDirective implements AfterContentInit {
  constructor(
    private el: ElementRef,
    private renderer: Renderer2,
    private vcr: ViewContainerRef
  ) { }

  injector = inject(EnvironmentInjector);

  @ContentChild('appDialogLoaderInlineContent') customTemplate?: TemplateRef<any>;

  @HostListener('click')
  onHostClick() {
    console.log("Dialog-Loader-Inline-Directive: click");

    // If custom template exists: embed it
    if (this.customTemplate) {
      const view = this.vcr.createEmbeddedView(this.customTemplate);
      view.rootNodes.forEach(node => {
        this.renderer.appendChild(this.el.nativeElement, node);
      })
    }
    else {
      // Embed dialog-like content inside
      const componentRef = this.vcr.createComponent(InlineDialogContentComponent, {
        injector: this.injector,
        // You can pass data via modern inputs if needed
      });

      // Pass data (if any)
      Object.assign(componentRef.instance, {
        title: 'My Title',
        message: 'Content here',
        okText: 'OK',
        cancelText: 'Cancel'
      });

      // Optional: subscribe to outputs if the component has any
      // componentRef.instance.someOutput.subscribe(...);
    }
  }

  ngAfterContentInit(): void {
    console.log("AfterContentInit: customTemplate: ");
    console.log(this.customTemplate);
  }
}
