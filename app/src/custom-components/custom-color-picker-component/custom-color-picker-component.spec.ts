import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CustomColorPickerComponent } from './custom-color-picker-component';

describe('CustomColorPickerComponent', () => {
  let component: CustomColorPickerComponent;
  let fixture: ComponentFixture<CustomColorPickerComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CustomColorPickerComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CustomColorPickerComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
