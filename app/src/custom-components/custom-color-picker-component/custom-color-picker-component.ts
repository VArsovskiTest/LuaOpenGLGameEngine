import { Component, NO_ERRORS_SCHEMA } from '@angular/core';

@Component({
  selector: 'minimal-gl-custom-color-picker',
  imports: [],
  templateUrl: './custom-color-picker-component.html',
  styleUrl: './custom-color-picker-component.scss',
  schemas: [NO_ERRORS_SCHEMA]
})
export class CustomColorPickerComponent {
  protected color: string = "#ffff00";
}
