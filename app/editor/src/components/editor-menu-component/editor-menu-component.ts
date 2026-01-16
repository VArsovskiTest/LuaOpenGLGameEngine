import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { MATERIAL_IMPORTS } from '../../material.imports';

@Component({
  selector: 'editor-menu',
  standalone: true,
  imports: [CommonModule, MATERIAL_IMPORTS],
  templateUrl: './editor-menu-component.html',
  styleUrl: './editor-menu-component.scss',
})
export class EditorMenuComponent {
protected items: Record<number, string>[] = [
       { 1: 'Explore the Docs' },
       { 2: 'Learn with Tutorials' }
   ];

   addItem(key: number, value: string): void {
       this.items.push({ [key]: value });
   }

   someAction() {
       this.addItem(3, 'CLI Docs');
       this.addItem(4, 'Angular Language Service');
       console.log(this.items);
   }
}
