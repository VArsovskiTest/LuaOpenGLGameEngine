import { createEntityAdapter, EntityAdapter } from "@ngrx/entity";
import { Scene } from '../../models/scene.model';

export const adapter: EntityAdapter<Scene> = createEntityAdapter<Scene>({
    selectId: (scene: Scene) => scene.id,
})

export const { selectIds, selectEntities, selectAll, selectTotal } = adapter.getSelectors();
