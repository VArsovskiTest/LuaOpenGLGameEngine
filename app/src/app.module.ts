// app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { MainComponent } from './components/main-component/main-component';

// State imports
import { SceneState } from './models/scene.model';

// NgRx imports
import { StoreModule } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';
import { sceneReducer } from './store/scenes/scenes.reducer';
import { SceneEffects } from './store/scenes/scenes.effects';
import { SceneEditorComponent } from './components/scene-editor-component/scene-editor-component';
import { EditorMenuComponent } from './components/editor-menu-component/editor-menu-component';
import { DialogLoaderDirective } from './helpers/dialog-loader-directive';
import { DialogLoaderInlineDirective } from './helpers/dialog-loader-inline-directive';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatRadioModule } from '@angular/material/radio';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { StoreDevtoolsModule } from '@ngrx/store-devtools';
import { actorsReducer } from './store/actors/actors.reducer';
import { ActorsEffects } from './store/actors/actors.effects';

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
    SceneEditorComponent,
    DialogLoaderDirective,
    DialogLoaderInlineDirective,
    // ... ALL other components, directives, pipes
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    RouterModule.forRoot(routes),          // ← routing here
    StoreModule.forRoot({}),               // global reducers if any
    StoreModule.forFeature('scenes', sceneReducer),
    StoreModule.forFeature('actors', actorsReducer),
    EffectsModule.forRoot([]),
    EffectsModule.forFeature([SceneEffects]),
    EffectsModule.forFeature([ActorsEffects]),
    MatToolbarModule,
    MatButtonModule,
    MatRadioModule,
    MatCheckboxModule,
    MatIconModule,
    MatMenuModule,
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
  bootstrap: [AppComponent]                // ← crucial! Tells Angular to start with this component
})
export class AppModule { }
