import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SceneEditorComponent } from './scene-editor-component';

describe('SceneEditorComponent', () => {
  let component: SceneEditorComponent;
  let fixture: ComponentFixture<SceneEditorComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SceneEditorComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SceneEditorComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
