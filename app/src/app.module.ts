// app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { MainComponent } from './components/main-component/main-component';
import { MatTableModule } from '@angular/material/table';
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator } from '@angular/material/paginator';

// State imports
import { SceneState } from './models/scene.model';

// NgRx imports
import { StoreModule } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';
import { sceneReducer } from './store/scenes/scenes.reducer';
import { SceneEffects } from './store/scenes/scenes.effects';

// MatUI
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatRadioModule } from '@angular/material/radio';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { MatFormFieldModule, MatLabel } from '@angular/material/form-field';
import { MatDialogContent } from '@angular/material/dialog';
import { MatInputModule } from '@angular/material/input';
import { MatCard } from '@angular/material/card';
import { ColorPickerModule } from 'primeng/colorpicker';

// Components & Directives
import { SceneEditorComponent } from './components/scene-editor-component/scene-editor-component';
import { EditorMenuComponent } from './components/editor-menu-component/editor-menu-component';
import { DialogLoaderDirective } from './shared/dialog-loader-directive';
import { DialogLoaderInlineDirective } from './shared/dialog-loader-inline-directive';
import { StoreDevtoolsModule } from '@ngrx/store-devtools';
import { actorsReducer } from './store/actors/actors.reducer';
import { ActorsEffects } from './store/actors/actors.effects';
import { CustomInputComponent } from './custom-components/custom-input-component';
import { CustomSwitchComponent } from './custom-components/custom-switch-component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';
import { LoadSceneListComponent } from './components/load-scene-list-component/load-scene-list-component';
import { CustomColorPickerComponent } from './custom-components/custom-color-picker-component/custom-color-picker-component';
import { ActorMenuComponent } from './components/actor-menu-component/actor-menu-component';

const routes: Routes = [
  { path: '', redirectTo: 'main', pathMatch: 'full' },
  { path: 'main', component: MainComponent },  // eager load
  { path: '**', redirectTo: 'main' }
];

@NgModule({
  declarations: [
    AppComponent,
    MainComponent,
    EditorMenuComponent,
    ActorMenuComponent,
    SceneEditorComponent,
    LoadSceneListComponent,
    DialogLoaderDirective,
    DialogLoaderInlineDirective,
    CustomInputComponent,
    // CustomRadioGroupComponent,
    CustomSwitchComponent,
    // MatTableDataSource,

    // ... ALL other components, directives, pipes
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    RouterModule.forRoot(routes),          // ← routing here
    StoreModule.forRoot({}),               // global reducers if any
    StoreModule.forFeature('scenes', sceneReducer),
    StoreModule.forFeature('actors', actorsReducer),
    EffectsModule.forRoot([]),
    EffectsModule.forFeature([SceneEffects]),
    EffectsModule.forFeature([ActorsEffects]),
    MatToolbarModule,
    MatButtonModule,
    MatDialogContent,
    MatFormFieldModule,
    MatInputModule,
    MatRadioModule,
    MatCheckboxModule,
    MatIconModule,
    MatMenuModule,
    MatTableModule,
    MatPaginator,
    MatLabel,
    MatCard,
    ColorPickerModule,
    CustomColorPickerComponent,
    FormsModule,
    ReactiveFormsModule,
    StoreDevtoolsModule.instrument({
      maxAge: 25,  // Keeps last 25 states
      logOnly: false,  // false for full inspect mode
      trace: true,     // Stack traces for actions
    }),
    // NgxsModule.forRoot([SceneState], {
    //   developmentMode: !environment.production
    // }),
    // FormsModule, ReactiveFormsModule, etc. if needed
  ],
  providers: [
    provideHttpClient(withInterceptorsFromDi()),
    // provideAnimationsAsync(), // enables smooth animations (CSS-based in v21+)
    // providePrimeNG({
    //   theme: {
    //     preset: Aura,
    //     options: {
    //       prefix: 'p',           // optional: CSS var prefix, default 'p'
    //       darkModeSelector: 'system', // or 'light', 'dark', or false
    //       cssLayer: false        // set to true if using CSS layers
    //     }
    //   },
    //   ripple: true // optional: enables ripple effect on buttons/clicks
    // })
  ],
  bootstrap: [AppComponent]                // ← crucial! Tells Angular to start with this component
})
export class AppModule { }
