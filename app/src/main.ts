// src/main.ts  (this file should exist; if not, create it)
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app.module';  // adjust path if needed

platformBrowserDynamic().bootstrapModule(AppModule)
  .catch((err: any) => console.error(err));
