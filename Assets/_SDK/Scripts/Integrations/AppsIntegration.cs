using System.Collections.Generic;
using UnityEngine;

namespace apps
{
    public static class AppsIntegration
    {
        public readonly static string appSettingsName = "AppsSettings";
        private static List<IApplication> _applications = new List<IApplication>();
        private static bool _isInited;

        [RuntimeInitializeOnLoadMethod]
        public static void AutoInitialize()
        {
            AppsSettings settings = Resources.Load<AppsSettings>(appSettingsName);
            if (settings.autoInitialize) Initialize(settings);
        }

        public static void Initialize()
        {
            Initialize(Resources.Load<AppsSettings>(appSettingsName));
        }

        public static void Initialize(AppsSettings settings)
        {
            if (_isInited == true)
                return;

            if (settings == null)
                throw new System.NullReferenceException("AppsSettings not found in resource folder!");

#if UNITY_IOS
            RequestAuthorizations.RequestAuthorizationsIOS();
#endif

            if (settings.integrateFacebook)
            {
                _applications.Add(new FacebookApp());
            }

            if (settings.integrateADS)
            {
                #region choice key
#if UNITY_ANDROID
                string appKey = settings.androidKey;
#elif UNITY_IPHONE
                string appKey = settings.iosKey;
#else
            string appKey = "unexpected_platform";
#endif
                #endregion

                #region create ad maker
                IADS adsMaker = null;
#if UNITY_EDITOR
                if (settings.showADSType == ShowADSType.Simulator)
                    adsMaker =
                        new ADSSimulator(
                        appKey,
                        settings.adsInfo.useBanner,
                        settings.adsInfo.useInterstitial,
                        settings.adsInfo.useRewardedVideo
                        );
                else
                if (settings.showADSType == ShowADSType.Debug)
                    adsMaker = new ADSDebugger(appKey);

#elif (UNITY_ANDROID || UNITY_IPHONE) && Support_ADS
                adsMaker = new IronSourceADS(appKey, settings.adsInfo);
#endif
                #endregion

                ADSManager.Initialize(adsMaker, true, settings.adsInfo.showInterstitialEvery);
                _applications.Add(adsMaker);
            }

            if (settings.integrateGameAnalytics)
            {
                GameAnalyticsEvents GA = new GameAnalyticsEvents();
                EventsLogger.AddEvent(GA);

                _applications.Add(GA);
            }

            if (settings.debugMode)
            {
                EventsDebug debug = new EventsDebug();
                EventsLogger.AddEvent(debug);
                _applications.Add(debug);
            }

            Debug.Log("The apps is initialized...");
            _isInited = true;
        }
    }
}
