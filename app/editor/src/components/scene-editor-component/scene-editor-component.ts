import { Component, inject } from '@angular/core';
import { Store } from '@ngrx/store';
import * as ActorActions from '../../store/actors/actors.actions'
import { Actor } from '../../models/actor.model'
import { selectAllActors, selectSelectedActor } from '../../store/actors/actors.selectors';

@Component({
  selector: 'scene-editor-component',
  imports: [],
  standalone: true,
  templateUrl: './scene-editor-component.html',
  styleUrl: './scene-editor-component.scss',
})

export class SceneEditorComponent {
  private store = inject(Store);

  actors$ = this.store.select(selectAllActors);
  selectedActor$ = this.store.select(selectSelectedActor);

  addRectangle() {
    const newActor: Actor = {
      id: crypto.randomUUID(),
      type: "rectangle",
      x: 200,
      y: 150,
      width: 120,
      height: 80,
      color: '#e74c3c'
    };
    this.store.dispatch(ActorActions.addActor({ actor: newActor }))
  }

  onActorMoved(id: string, newX: number, newY: number) {
    this.store.dispatch(ActorActions.updateActor({
      actorUpdate: { id, changes: { x: newX, y: newY} }
    }))
  }

  saveScene() {
    // TODO: later: serialize selectAllActors() to JSON and save to backend/file
  }

  loadScene(json: any) {
    const actors = json.actors as Actor[];
    this.store.dispatch(ActorActions.loadScene({ actors }))
  }
}
