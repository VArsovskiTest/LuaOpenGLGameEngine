import { inject, Injectable } from "@angular/core";
import { Actions, createEffect, ofType } from "@ngrx/effects";
import { BehaviorSubject, map, take, tap } from "rxjs";
import * as ActorActions from './actors.actions';
import { Actor } from "../../models/actor.model";
import { select, Store } from "@ngrx/store";

@Injectable()
export class ActorsEffects {
    constructor(private actions$: Actions) {
        const addActor$ = createEffect(() => { // TODO: why is Const required here ??
            const actions$ = inject(Actions); // Make sure not null here..
            const store = inject(Store);

            const actorsState$ = store.pipe(select(state => state.actors));
            const actorsState = new BehaviorSubject<Actor[]>([]);
            actorsState$.subscribe((actors: Actor[]) => actorsState.next(actors));

            return actions$.pipe(ofType(ActorActions.addActor),
            tap(() => {
                store.pipe(
                    select(state => state.actors),
                    take(1)).subscribe(s => console.log("Actors state BEFORE add: " + s));
            }),
            map(() => {
                return ActorActions.loadActors({ actors: actorsState.getValue() })
            }),
            tap(() => {
                setTimeout(() => {
                    store.pipe(select(state => state.actors),
                    take(1)
                ).subscribe(s => console.log("Actors state AFTER add:" + s))
                }, 0);
            }))
        });
    }
}