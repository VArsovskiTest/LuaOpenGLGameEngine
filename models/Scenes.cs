public class SceneEmpty {}

    internal class GenericScene
    {
        public ModelRGB[] Actors { get; set; }

        public GenericScene(Dictionary<string, ModelRGB> dictionary)
        {
            // Actors = (dictionary?.Select(sceneActor => sceneActor.Value) ?? new List<ModelRGB>()).ToArray();
            try
            {
                Actors = (dictionary?.Select(sceneActor => sceneActor.Value) ?? new List<ModelRGB>()).ToArray();
            }
            catch (Exception ex)
            {
                // Handle or log exception
                Actors = Array.Empty<ModelRGB>(); // Return an empty array if an exception occurs
            }
        }
    }
