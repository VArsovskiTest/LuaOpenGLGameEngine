// main.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';  // or whatever you need
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { MatRadioModule } from '@angular/material/radio';
import { MatCheckboxModule } from '@angular/material/checkbox';

@NgModule({
  declarations: [
    // SceneEditorComponent,  // declare them here if not standalone
  ],
  imports: [
    CommonModule,
    // MatToolbarModule,
    // MatButtonModule,
    // MatRadioModule,
    // MatCheckboxModule,
    // MatIconModule,
    // MatMenuModule,
    // DialogLoaderDirective,
    // DialogLoaderInlineDirective
    // any other shared modules (FormsModule, etc.)
    // RouterModule.forChild([])  ← only if this module has its own child routes
  ],
  // NO exports/providers here usually for lazy feature
})
export class MainModule { }
