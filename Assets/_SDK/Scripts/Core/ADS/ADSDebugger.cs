using System;
using UnityEngine;

namespace apps
{

    public class ADSDebugger : IADS
    {
        public bool useBanner { get; set; }
        public bool useInterstitial { get; set; }
        public bool useRewardedVideo { get; set; }

        public ADSDebugger(string key)
        {
            Intialize(key);
        }

        public void Intialize(string key)
        {
            Debug.Log("The ADS is intialized with key: " + key);
        }

        #region banner
        public void LoadBanner()
        {
            Debug.Log("The Banner ad is Loaded.");
        }

        public bool DisplayBanner()
        {
            Debug.Log("The Banner ad is Displayed.");
            return true;
        }

        public void HideBanner()
        {
            Debug.Log("The Banner ads is Hided.");
        }
        #endregion

        #region interstitial
        public void LoadInterstitial()
        {
            Debug.Log("The Interstitial ad is Loaded.");
        }

        public bool IsInterstitialAvailable()
        {
            return true;
        }

        public bool ShowInterstitial(string placementName = null, Action onClose = null)
        {
            Debug.Log("Show Interstitial ad.");
            return true;
        }
        #endregion

        #region rewards video
        public void LoadRewardedVideo()
        {
            Debug.Log("The RewardsVideo ad is Loaded.");
        }

        public bool IsRewardedideoAvailable()
        {
            return true;
        }

        public bool ShowRewardedVideo(string placementName = null, Action onCompleted = null, Action onClose = null)
        {
            Debug.Log("Show RewardsVideo ad.");
            Debug.Log("RewardsVideo ad is completed.");
            return true;
        }
        #endregion
    }
}
