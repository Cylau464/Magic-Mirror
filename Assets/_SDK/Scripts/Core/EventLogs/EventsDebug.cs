using UnityEngine;

namespace apps
{
    public class EventsDebug : IEvent
    {
        public EventsDebug()
        {
            Initialize();
        }

        protected void Initialize()
        {
            Debug.Log("Events is initialized");
        }

        public void CustomEvent(string eventName, float value)
        {
            Debug.Log("Design-Event, Event name: " + eventName.Replace(':', '/') + ", value: " + value);
        }

        public void SessionEvent(string sessionName, SessionStatue statue)
        {
            Debug.Log("Session-Event, session name: " + sessionName.Replace(':', '/') + ", statue: " + statue);
        }

        public void AdEvent(AdType adType, string placementName)
        {
            Debug.Log("Ads-Event, Type: " + adType + ", Placement: " + placementName);
        }

        public void ErrorEvent(ErrorSeverity severity, string message)
        {
            Debug.Log("Error-Event, Severity: " + severity + ", message: " + message);
        }

        public void IAPEvent(string productIAPID, float price)
        {
            Debug.Log("IAP-Event, productIAPID: " + productIAPID.Replace(':', '/') + ", price: " + price);
        }

        public void ProgressEvent(ProgressionStatus status, string progression, int score)
        {
            Debug.Log("Progress-Event, ProgressionStatus: " + status + ", progression: " + progression.Replace(':', '/') + ", score: " + score);
        }

    }
}