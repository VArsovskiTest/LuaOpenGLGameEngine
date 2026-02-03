import { Routes } from '@angular/router';
import { sceneReducer } from './store/scenes/scenes.reducer';
import { SceneEffects } from './store/scenes/scenes.effects';
import { provideState } from '@ngrx/store';
import { provideEffects } from '@ngrx/effects';

// app-routing.module.ts (or inside AppModule)
export const routes: Routes = [
  { path: '', redirectTo: 'main', pathMatch: 'full' },
  {
    path: 'main',
    loadChildren: () =>
      import('./components/main-component/main.module').then(m => m.MainModule),
      providers: [
        provideState('scenes', sceneReducer),
        provideEffects(SceneEffects)
      ]
  },
];
