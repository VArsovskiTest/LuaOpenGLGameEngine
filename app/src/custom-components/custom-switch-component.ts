import { Component, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

@Component({
  selector: 'minimal-gl-custom-switch',
  standalone: false,
  template: `
    <div 
      class="toggle" 
      [class.active]="value" 
      (click)="toggle()"
      [attr.disabled]="disabled ? true : null">
      {{ value ? 'ON' : 'OFF' }}
    </div>
  `,
  styles: [`
    .toggle {
      width: 60px;
      height: 30px;
      border-radius: 15px;
      background: #ccc;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      user-select: none;
    }
    .toggle.active {
      background: #4caf50;
      color: white;
    }
    .toggle[disabled] {
      opacity: 0.5;
      cursor: not-allowed;
    }
  `],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => CustomSwitchComponent),
      multi: true
    }
  ]
})
export class CustomSwitchComponent implements ControlValueAccessor {
  value = false;
  disabled = false;

  private onChange: (value: boolean) => void = () => {};
  private onTouched: () => void = () => {};

  toggle() {
    if (this.disabled) return;
    this.value = !this.value;
    this.onChange(this.value);
    this.onTouched();
  }

  writeValue(value: boolean): void {
    this.value = !!value;
  }

  registerOnChange(fn: any): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: any): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }
}
