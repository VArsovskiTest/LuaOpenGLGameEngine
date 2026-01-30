// src/main.ts
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app.component'; // or MainComponent
import { appConfig } from './app.config';

bootstrapApplication(AppComponent, appConfig)
  .catch((err) => console.error(err));