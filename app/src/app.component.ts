// app.component.ts
import { Component } from '@angular/core';
import { provideRouter, RouterOutlet } from '@angular/router';
import { CommonModule } from '@angular/common'; // if needed
import { FormsModule } from '@angular/forms';
import { routes } from './app.routes';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    RouterOutlet,
    CommonModule, FormsModule,
  ],
  // providers: [ provideRouter(routes), ],
  template: `<router-outlet></router-outlet>`,
})
export class AppComponent {}
