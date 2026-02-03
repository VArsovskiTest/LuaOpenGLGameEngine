import { Component, output } from '@angular/core';

@Component({
  selector: 'editor-menu',
  standalone: false,
  templateUrl: "./editor-menu-component.html",
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
    const itemId = this.itemMap[action];
    this.selectedMenuItem.emit({ [itemId]: action });
  }
}
