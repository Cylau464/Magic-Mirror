using UnityEngine;
using UnityEngine.UI;
using apps;

public class ExampleProgress : MonoBehaviour
{
    public int currentLevel;
    public Text textLevel;

    protected void OnEnable()
    {
        currentLevel = PlayerPrefs.GetInt("level id");
    }

    public void MakeStart()
    {
        ProgressEvents.OnLevelStarted(currentLevel);
        ADSManager.AutoShowInterstitial("MakeStart");
    }

    public void MakeWin()
    {
        ProgressEvents.OnLevelCompleted(currentLevel);
        ADSManager.AutoShowInterstitial("MakeWin");
        currentLevel++;
        PlayerPrefs.SetInt("level id", currentLevel);
    }

    public void MakeLose()
    {
        ProgressEvents.OnLevelFieled(currentLevel);
        ADSManager.AutoShowInterstitial("MakeLose");
    }
}
