using GameAnalyticsSDK;

namespace apps
{
    public class GameAnalyticsEvents : IEvent
    {
        public GameAnalyticsEvents()
        {
            Initialize();
        }

        protected void Initialize()
        {
            GameAnalytics.Initialize();
        }

        public void CustomEvent(string eventName, float value)
        {
            GameAnalytics.NewDesignEvent(eventName, value);
        }

        public void SessionEvent(string sessionName, SessionStatue statue)
        {
            GameAnalytics.NewDesignEvent(sessionName + ":" + statue);
        }

        public void IAPEvent(string productIAPID, float price)
        {
            GameAnalytics.NewDesignEvent("IAP:" + productIAPID, price);
        }

        public void ProgressEvent(ProgressionStatus status, string progression, int score)
        {
            GameAnalytics.NewProgressionEvent(ConvertToGAProgressionStatus(status), progression, score);
        }

        public void ErrorEvent(ErrorSeverity severity, string message)
        {
            GameAnalytics.NewErrorEvent(ConvertToGAErrorSeverity(severity), message);
        }

        public void AdEvent(AdType adType, string placementName)
        {
            GameAnalytics.NewAdEvent(GAAdAction.Show, ConvertToGAAdType(adType), "IronSource", placementName);
        }

        #region converts
        private GAProgressionStatus ConvertToGAProgressionStatus(ProgressionStatus status)
        {
            switch (status)
            {
                case ProgressionStatus.Start:
                    return GAProgressionStatus.Start;
                case ProgressionStatus.Fail:
                    return GAProgressionStatus.Fail;
                case ProgressionStatus.Complete:
                    return GAProgressionStatus.Complete;
                default:
                    return GAProgressionStatus.Undefined;
            }
        }

        private GAAdType ConvertToGAAdType(AdType adType)
        {
            switch (adType)
            {
                case AdType.Banner:
                    return GAAdType.Banner;
                case AdType.Interstitial:
                    return GAAdType.Interstitial;
                case AdType.OfferWall:
                    return GAAdType.OfferWall;
                case AdType.RewardedVideo:
                    return GAAdType.RewardedVideo;
                default:
                    return GAAdType.Undefined;
            }
        }

        private GAErrorSeverity ConvertToGAErrorSeverity(ErrorSeverity severity)
        {
            switch (severity)
            {
                case ErrorSeverity.Error:
                    return GAErrorSeverity.Error;

                case ErrorSeverity.Warning:
                    return GAErrorSeverity.Warning;

                case ErrorSeverity.Info:
                    return GAErrorSeverity.Info;

                case ErrorSeverity.Critical:
                    return GAErrorSeverity.Critical;

                case ErrorSeverity.Debug:
                    return GAErrorSeverity.Debug;

                default:
                    return GAErrorSeverity.Undefined;
            }
        }
        #endregion
    }
}