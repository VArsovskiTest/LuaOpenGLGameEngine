public class SceneEmpty {}

    internal class GenericScene
    {
        public ModelRGB[] Actors { get; set; }

        public GenericScene(Dictionary<string, ModelRGB> dictionary)
        {
            Actors = dictionary.Select(sceneActor => sceneActor.Value).ToArray();
        }
    }
