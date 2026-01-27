// src/app/shared/material.imports.ts
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatMenuModule } from '@angular/material/menu';
import { MatCardModule } from '@angular/material/card';
// ... add all the ones you use frequently across the app

export const MATERIAL_IMPORTS = [
  MatButtonModule,
  MatIconModule,
  MatToolbarModule,
  MatMenuModule,
  MatCardModule,
  // MatFormFieldModule,
  // MatInputModule,
  // etc.
] as const;
