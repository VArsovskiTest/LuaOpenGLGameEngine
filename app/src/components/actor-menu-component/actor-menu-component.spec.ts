import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ActorMenuComponent } from './actor-menu-component';

describe('ActorMenuComponent', () => {
  let component: ActorMenuComponent;
  let fixture: ComponentFixture<ActorMenuComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ActorMenuComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ActorMenuComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
