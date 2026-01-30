import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BrowserModule } from '@angular/platform-browser';
import { AppComponent } from './app.component';
import { StoreModule } from '@ngrx/store';
import { sceneReducer } from './store/scenes/scenes.reducer';
import { EffectsModule } from '@ngrx/effects';
import { SceneEffects } from './store/scenes/scenes.effects';

@NgModule({
  declarations: [
    // AppComponent,
    // EditorMenuComponent,
  ],
  imports: [
    BrowserModule, CommonModule,
    StoreModule.forFeature('scenes', sceneReducer),
    EffectsModule.forFeature([SceneEffects])
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
