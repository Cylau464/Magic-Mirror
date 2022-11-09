namespace apps
{
    [System.Serializable]
    public class ADSInfo
    {
        [UnityEngine.Header("Banner")]
        public bool useBanner = true;
        public BannerPosition bannerPosition = BannerPosition.BOTTOM;


        [UnityEngine.Header("interstitial")]
        public bool useInterstitial = true;
        public float showInterstitialEvery = 45;

        [UnityEngine.Header("rewardedVideo")]
        public bool useRewardedVideo = true;
    }
}