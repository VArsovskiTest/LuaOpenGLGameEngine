import { createEntityAdapter, EntityAdapter } from '@ngrx/entity'
import { Actor } from './actor.model';

export const adapter: EntityAdapter<Actor> = createEntityAdapter<Actor>({
    selectId: (actor: Actor) => actor.id,
})

export const { selectIds, selectEntities, selectAll, selectTotal } = adapter.getSelectors();
