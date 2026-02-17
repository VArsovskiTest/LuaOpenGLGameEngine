import { inject, Injectable } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { map, tap, take } from 'rxjs';
import * as SceneActions from '../scenes/scenes.actions';
import { Scene } from '../../models/scene.model';
import { select, Store } from '@ngrx/store';

@Injectable()
export class SceneEffects {

  constructor(private actions$: Actions) {}

  createNewScene$ = createEffect(() => {
    const actions$ = inject(Actions);
    const store = inject(Store);

    return actions$.pipe(
      ofType(SceneActions.startNewScene),
      tap(() => {
        store.pipe(
          select(state => state.scenes),
          take(1)
        ).subscribe(s => console.log("Scenes state BEFORE:", s));
      }),
      map(({ size, name }) => {
        const newScene: Scene = { name: name ?? `New Scene (${size})`, size };
        return SceneActions.setCurrentScene({ scene: newScene });
      }),
      tap(() => {
        setTimeout(() => {  // small delay to let reducer run
          store.pipe(select(state => state.scenes), take(1)).subscribe(s => {
            console.log("Scenes state AFTER:", s);
          });
        }, 0);
      })
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
