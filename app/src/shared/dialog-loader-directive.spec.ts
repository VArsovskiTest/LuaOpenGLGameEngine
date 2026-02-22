// // dialog-loader.directive.spec.ts
// import { ComponentFixture, TestBed } from '@angular/core/testing';
// import { MatDialog, MatDialogModule } from '@angular/material/dialog';
// import { NoopAnimationsModule } from '@angular/platform-browser/animations';
// import { DialogLoaderDirective } from '../helpers/dialog-loader-directive';
// import { By } from '@angular/platform-browser';
// import { Component } from '@angular/core';

// @Component({
//   standalone: true,
//   imports: [DialogLoaderDirective],
//   template: `<button appDialogLoader="Test message">Click</button>`
// })
// class TestHost {}

// describe('DialogLoaderDirective', () => {
//   let fixture: ComponentFixture<TestHost>;
//   let dialogSpy: jasmine.SpyObj<MatDialog>;

//   beforeEach(async () => {
//     dialogSpy = jasmine.createSpyObj<MatDialog>('MatDialog', ['open']);
//     dialogSpy.open.and.returnValue({
//       afterClosed: () => ({ subscribe: (cb: Function) => cb(true) })
//     } as any);

//     await TestBed.configureTestingModule({
//       imports: [NoopAnimationsModule, MatDialogModule, DialogLoaderDirective],
//       providers: [{ provide: MatDialog, useValue: dialogSpy }]
//     }).compileComponents();

//     fixture = TestBed.createComponent(TestHost);
//     fixture.detectChanges();
//   });

//   it('should create', () => {
//     expect(fixture.componentInstance).toBeTruthy();
//   });

//   it('should open dialog on click with correct config', () => {
//     const button = fixture.debugElement.query(By.css('button'));
//     button.triggerEventHandler('click', null);

//     expect(dialogSpy.open).toHaveBeenCalled();
//     expect(dialogSpy.open).toHaveBeenCalledWith(
//       jasmine.any(Function),
//       jasmine.objectContaining({
//         width: '480px',
//         data: jasmine.objectContaining({
//           message: 'Test message',
//           title: 'Confirm',
//           okText: 'OK',
//           cancelText: 'Cancel'
//         })
//       })
//     );
//   });
// });
