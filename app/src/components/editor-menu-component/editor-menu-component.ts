import { Component, output, ViewChild } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatRadioModule } from '@angular/material/radio';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { CommonModule } from '@angular/common';
import { MatMenuModule, MatMenuTrigger } from '@angular/material/menu';
import { DialogLoaderDirective } from '../../helpers/dialog-loader-directive';
import { DialogLoaderInlineDirective } from '../../helpers/dialog-loader-inline-directive'

@Component({
  selector: 'editor-menu',
  imports: [
    MatToolbarModule,
    MatButtonModule,
    MatRadioModule,
    MatCheckboxModule,
    MatIconModule,
    CommonModule,
    MatMenuModule,
    DialogLoaderDirective,
    DialogLoaderInlineDirective
  ],
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
