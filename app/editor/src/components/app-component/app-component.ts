import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { EditorMenuComponent } from '../editor-menu-component/editor-menu-component';
import { MATERIAL_IMPORTS } from '../../material.imports';

@Component({
  selector: 'app',
  standalone: true,
  imports: [RouterOutlet, EditorMenuComponent, MATERIAL_IMPORTS],
  templateUrl: './app-component.html',
  styleUrls: ['./app-component.scss'],
})
export class AppComponent {
  protected readonly title = signal('editor');
}
