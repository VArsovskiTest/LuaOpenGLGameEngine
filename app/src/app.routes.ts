// app.routes.ts
import { Routes } from '@angular/router';
import { provideState } from '@ngrx/store';
import { provideEffects } from '@ngrx/effects';

import { sceneReducer } from './store/scenes/scenes.reducer';
import { SceneEffects } from './store/scenes/scenes.effects';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'main',
    pathMatch: 'full'
  },
  {
    path: 'main',
    loadComponent: () => import('./components/main-component/main-component').then(m => m.MainComponent),
    providers: [
      provideState('scenes', sceneReducer),
      provideEffects(SceneEffects)
    ]
  },
  // other routes...
];
