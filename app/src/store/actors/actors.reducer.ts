import { createReducer, on } from "@ngrx/store";
import { adapter } from '../actors/actors.adapter'
import * as ActorActions from './actors.actions';
import { ActorsState } from "../../models/actor.model";
import { Update } from "@ngrx/entity";

export const initialState: ActorsState = adapter.getInitialState({selectedId: null})

export const actorsReducer = createReducer(initialState
    , on(ActorActions.loadActors,
        (state, { actors }) => adapter.setAll(actors, { ...state, selectedId: null }))
    , on(ActorActions.addActor,
        (state, { actor }) => adapter.addOne(actor, state))
    , on(ActorActions.updateActor,
        (state, { actorUpdate }) => adapter.updateOne(actorUpdate, state))
    , on(ActorActions.removeActor,
        (state, {id}) => adapter.removeOne(id, state))
    , on(ActorActions.selectActor, (state, {id}) => ({...state, selectedId: id}))
    , on(ActorActions.clearScene, () => initialState)
);
