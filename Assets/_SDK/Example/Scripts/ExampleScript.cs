using apps;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class ExampleScript : MonoBehaviour
{
    public InputField inputField;

    #region rewards
    public void ShowRewardedVideo()
    {
        ADSManager.ShowRewardedVideo("Coins3X", OnCompletedRewardedVideo);
    }

    void OnCompletedRewardedVideo()
    {
        inputField.text = "OnCompletedRewardedVideo";
    }
    #endregion

    public void LoadScene(int index)
    {
        SceneManager.LoadScene(index);
    }

    public void ShowInterstitial()
    {
        ADSManager.ShowInterstitial("OnFinished");
    }

    public void ShowBanner()
    {
        ADSManager.DisplayBanner();
    }

    public void HideBanner()
    {
        ADSManager.HideBanner();
    }

    public void SendEvent()
    {
        EventsLogger.CustomEvent(inputField.text);
    }

    public void SendEvent(string eventName)
    {
        EventsLogger.ProgressEvent(ProgressionStatus.Complete, eventName);
    }
}