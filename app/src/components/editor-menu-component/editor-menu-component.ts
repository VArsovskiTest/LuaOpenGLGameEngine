import { Component, CUSTOM_ELEMENTS_SCHEMA, NO_ERRORS_SCHEMA, output } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { CommonModule } from '@angular/common';
// other imports...

@Component({
  selector: 'editor-menu',
  standalone: true,
  imports: [MatToolbarModule, MatButtonModule, MatIconModule, CommonModule /* + KeyValuePipe if needed */],
  templateUrl: "./editor-menu-component.html" ,
  schemas: [
    CUSTOM_ELEMENTS_SCHEMA, NO_ERRORS_SCHEMA
  ]
})

export class EditorMenuComponent {
    protected items: Record<number, string>[] = [
        { 1: 'File' },
        { 2: 'Editor' }
    ];

    selectedMenuItem = output<Record<number, string>>();

    handleSelected(item: Record<number, string>) {
        this.selectedMenuItem.emit(item);
    }
}
