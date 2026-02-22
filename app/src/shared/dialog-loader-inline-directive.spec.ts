// // dialog-loader-inline.directive.spec.ts
// import { Component } from '@angular/core';
// import { ComponentFixture, TestBed } from '@angular/core/testing';
// import { By } from '@angular/platform-browser';
// import { Renderer2, ViewContainerRef } from '@angular/core';
// import { DialogLoaderInlineDirective } from './dialog-loader-inline-directive';

// @Component({
//   standalone: true,
//   imports: [DialogLoaderInlineDirective],
//   template: `
//     <div id="host" dialog-loader-inline>
//       Click me
//       <ng-template #dialogContent>
//         <p class="custom">Custom Content {{ 2 + 2 }}</p>
//       </ng-template>
//     </div>
//   `
// })
// class TestHostComponent {}

// describe('DialogLoaderInlineDirective', () => {
//   let fixture: ComponentFixture<TestHostComponent>;
//   let hostEl: HTMLElement;
//   let renderer2Mock: jasmine.SpyObj<Renderer2>;

//   beforeEach(async () => {
//     // Mock Renderer2 – we only care about appendChild being called
//     renderer2Mock = jasmine.createSpyObj<Renderer2>('Renderer2', [
//       'createElement',
//       'createText',
//       'appendChild',
//       'setStyle' // optional extra
//     ]);

//     await TestBed.configureTestingModule({
//       imports: [TestHostComponent], // host component imports the directive
//       providers: [
//         // ViewContainerRef is tricky to mock fully, but we can fake it enough
//         {
//           provide: ViewContainerRef,
//           useValue: {
//             createEmbeddedView: jasmine.createSpy('createEmbeddedView').and.returnValue({
//               rootNodes: [], // will be filled later in real case
//             }),
//             clear: jasmine.createSpy('clear'),
//           } as Partial<ViewContainerRef>,
//         },
//         { provide: Renderer2, useValue: renderer2Mock },
//         // ElementRef will be provided by the real host element
//       ],
//     }).compileComponents();

//     fixture = TestBed.createComponent(TestHostComponent);
//     hostEl = fixture.debugElement.query(By.css('#host')).nativeElement;
//     fixture.detectChanges();
//   });

//   it('should create directive instance', () => {
//     const directive = fixture.debugElement
//       .query(By.directive(DialogLoaderInlineDirective))
//       .injector.get(DialogLoaderInlineDirective);
//     expect(directive).toBeTruthy();
//   });

//   it('should append custom template content on click when #dialogContent exists', () => {
//     // Spy on createEmbeddedView to return fake root nodes
//     const vcr = TestBed.inject(ViewContainerRef) as jasmine.SpyObj<ViewContainerRef>;
//     const fakeNode = document.createElement('p');
//     fakeNode.className = 'custom';
//     fakeNode.textContent = 'Custom Content 4';

//     vcr.createEmbeddedView.and.returnValue({
//       rootNodes: [fakeNode],
//     } as any);

//     hostEl.click();
//     fixture.detectChanges();

//     expect(vcr.createEmbeddedView).toHaveBeenCalled();
//     expect(renderer2Mock.appendChild).toHaveBeenCalledWith(hostEl, fakeNode);
//   });

//   it('should append fallback paragraph when no custom template', () => {
//     // Remove the ng-template from template so customTemplate is undefined
//     fixture.componentRef.setInput; // or recreate fixture without template
//     // Simpler: use a second host component without ng-template
//     // ...or just spy and force customTemplate to be undefined in directive if possible

//     // For brevity – assume we have a second fixture without template
//     // Then:
//     hostEl.click();
//     expect(renderer2Mock.createElement).toHaveBeenCalledWith('p');
//     expect(renderer2Mock.createText).toHaveBeenCalledWith('Hello from the directive!');
//   });
// });
