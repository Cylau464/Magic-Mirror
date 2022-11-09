namespace Cutscenes
{
    public interface ICutsceneSkipped
    {
        public void OnCutsceneSkipped(Cutscene cutscene, Cutscene.Step step);
    }
}