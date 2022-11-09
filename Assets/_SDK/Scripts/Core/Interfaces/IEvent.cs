namespace apps
{
    public interface IEvent : IApplication
    {
        /// <summary>
        /// To send a custom event.
        /// </summary>
        /// <param name="eventName"> The event name that we will send. </param>
        /// <param name="value"> The value of event, example: The score.</param>
        void CustomEvent(string eventName, float value);

        /// <summary>
        /// To send a session event.
        /// </summary>
        /// <param name="sessionName"> The session name that we will send. </param>
        /// <param name="statue"> The session statue that we will send it can be started or completed. </param>
        void SessionEvent(string sessionName, SessionStatue statue);

        /// <summary>
        /// To send a ProgressEvent event.
        /// </summary>
        /// <param name="status"> The statue of progression </param>
        /// <param name="progression"> Progression name event </param>
        /// <param name="score"> The value of progression. </param>
        void ProgressEvent(ProgressionStatus status, string progression, int score);

        /// <summary>
        /// To send some error events.
        /// </summary>
        /// <param name="severity"> The error type. </param>
        /// <param name="message"> The message content in the error. </param>
        void ErrorEvent(ErrorSeverity severity, string message);

        /// <summary>
        /// To send some products buying in the game.
        /// </summary>
        /// <param name="productIAPID"> product ID of the IAP. </param>
        /// <param name="price"> The price that spended on this product. </param>
        void IAPEvent(string productIAPID, float price);

        /// <summary>
        /// Send events on show some ADS.
        /// </summary>
        /// <param name="adType"> The ads type example Rewardedvideo. </param>
        /// <param name="placementName"> The placement name of this ad. </param>
        void AdEvent(AdType adType, string placementName);
    }
}