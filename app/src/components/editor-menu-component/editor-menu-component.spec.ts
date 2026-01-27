import { ComponentFixture, TestBed } from '@angular/core/testing';

import { EditorMenuComponent } from './editor-menu-component';

describe('EditorMenuComponent', () => {
  let component: EditorMenuComponent;
  let fixture: ComponentFixture<EditorMenuComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [EditorMenuComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(EditorMenuComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
