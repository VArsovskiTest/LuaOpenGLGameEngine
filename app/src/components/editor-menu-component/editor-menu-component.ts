import { Component, output, ViewChild } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { CommonModule } from '@angular/common';
import { MatMenuModule, MatMenuTrigger } from '@angular/material/menu';

@Component({
  selector: 'editor-menu',
  standalone: true,
  imports: [
    MatToolbarModule,
    MatButtonModule,
    MatIconModule,
    CommonModule,
    MatMenuModule  // Import the entire module instead of just MatMenu
  ],
  templateUrl: "./editor-menu-component.html",
  // Remove the providers array - not needed
})
export class EditorMenuComponent {
  selectedMenuItem = output<Record<number, string>>();

  protected items: Record<number, string>[] = [
    { 1: 'File' },
    { 2: 'Editor' }
  ];

  protected itemMap: Record<string, number> = {
    'New scene': 1,
    'Load scene': 2,
    'Save scene': 3,
    'Launch scene': 4,
    'Add actor': 5,
    'Remove actor': 6,
    'Modify actor': 7
  };

  handleMenuItemClick(action: string) {
    console.log("handleSelected: " + action);
    const itemId = this.itemMap[action];
    this.selectedMenuItem.emit({ [itemId]: action });
  }
}
