import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LoadSceneListComponent } from './load-scene-list-component';

describe('LoadSceneListComponent', () => {
  let component: LoadSceneListComponent;
  let fixture: ComponentFixture<LoadSceneListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LoadSceneListComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(LoadSceneListComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
