using UnityEngine;

namespace apps
{
    public enum ShowADSType { Simulator, Debug, Non }

    [CreateAssetMenu(fileName = "AppsSettings", menuName = "AppsSettings", order = 1)]
    public class AppsSettings : ScriptableObject
    {
        public readonly static string globalDirectoryPath = "Assets/_SDK/Resources/";

        public bool autoInitialize = true;

        public bool integrateFacebook = true;
        public string appLabels = "";
        public string appFacebookID = "Entry Facebook ID...";
        public string clientTokens = "";

        public bool integrateADS = false;
        public ShowADSType showADSType = ShowADSType.Simulator;
        public ADSInfo adsInfo;
        public string androidKey = "Entry Android Key";
        public string iosKey = "Entry IOS Key";

        public bool integrateGameAnalytics = true;

        public bool debugMode = true;
    }
}
