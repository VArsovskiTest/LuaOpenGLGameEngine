import { inject, Injectable } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { map, catchError, of } from 'rxjs';
import * as SceneActions from '../scenes/scenes.actions';
import { Scene } from '../../models/scene.model';

@Injectable()
export class SceneEffects {

  constructor(private actions$: Actions) {}

  createNewScene$ = createEffect(() => {
    const actions$ = inject(Actions);   // ← safe here, runs in injection context

    return actions$.pipe(
      ofType(SceneActions.startNewScene),
      map(({ size, name }) => {
        const newScene: Scene = {
          id: crypto.randomUUID(),
          name: name ?? `New Scene (${size})`,
          size,
          // ... defaults
        };
        return SceneActions.setCurrentScene({ scene: newScene });
      })
      // catchError(err => of(SceneActions.createFailure({ error: err.message })))
    );
  });

  // Later you can replace the map(...) with:
  // switchMap(({ size, name }) =>
  //   this.sceneService.create({ size, name }).pipe(
  //     map(scene => SceneActions.setCurrentScene({ scene })),
  //     catchError(...)
  //   )
  // )
}
