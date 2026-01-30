import { createAction, props } from "@ngrx/store";
import { Actor, ActorsState } from "../../models/actor.model";
import { Update } from "@ngrx/entity"

export const loadActors = createAction('[Scene Editor] Load Actors', props<{ actors: Actor[] }>());
export const addActor = createAction('[Scene Editor] Add Actor', props<{ actor: Actor }>());
export const updateActor = createAction('[Scene Editor] Update Actor', props<{ actorUpdate: Update<Actor> }>());
export const removeActor = createAction('[Scene Editor] Remove Actor', props<{id: string}>());
export const selectActor = createAction('[Scene Editor] Select Actor', props<{ id: string | null}>());
export const clearScene = createAction('[Scene Editor] Clear Scene')
