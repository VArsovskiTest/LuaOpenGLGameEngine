import { createFeatureSelector, createSelector  } from "@ngrx/store";
import { ActorStoreState } from "../../models/actor.model";
import { adapter } from './actors.adapter'

export const selectActorsState = createFeatureSelector<ActorStoreState>('actors');

export const {
    selectIds,
    selectEntities,
    selectAll: selectAllActors,
    selectTotal
} = adapter.getSelectors(selectActorsState);

export const selectSelectedActorId = createSelector(selectActorsState, (state) => state.selectedId)
export const selectSelectedActor = createSelector(selectEntities, selectSelectedActorId, (entities, id) => (id ? entities[id]: null))
