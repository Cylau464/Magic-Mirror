using UnityEngine.SceneManagement;

public static class GameScenes
{
    private readonly static string s_MainScene = "Main";

    public static void LoadMainScene()
    {
        LoadScene(s_MainScene);
    }

    public static void ReloadScene(bool async = false)
    {
        LoadScene(SceneManager.GetActiveScene().name, async);
    }

    private static void LoadScene(string sceneName, bool async = false)
    {
        if (async)
            SceneManager.LoadSceneAsync(sceneName);
        else
            SceneManager.LoadScene(sceneName);
    }
}
