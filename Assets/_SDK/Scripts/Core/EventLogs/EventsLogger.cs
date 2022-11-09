using apps.exception;
using System.Collections.Generic;

namespace apps
{
    public enum SessionStatue { Started, Completed }
    public static class EventsLogger
    {
        #region variables
        private static Stack<IEvent> m_EventLoggers = new Stack<IEvent>();
        public static bool isHasLoggers => m_EventLoggers.Count != 0;
        public static int totalLoggers => m_EventLoggers.Count;
        #endregion

        #region manage
        /// <summary>
        /// To add some event loggers.
        /// </summary>
        /// <param name="eventLogger"> Is object of type IEvent. </param>
        public static void AddEvent(IEvent eventLogger)
        {
            if (eventLogger == null)
                throw new System.ArgumentNullException();

            m_EventLoggers.Push(eventLogger);
        }

        /// <summary>
        /// To add array of events logger.
        /// </summary>
        public static void AddEvents(IEvent[] eventLoggers)
        {
            if (eventLoggers == null)
                throw new System.ArgumentNullException();
            
            for (int i = 0; i < eventLoggers.Length; i++)
            {
                if (eventLoggers[i] == null)
                    throw new ArrayHasObjectNullException();

                m_EventLoggers.Push(eventLoggers[i]);
            }
        }

        /// <summary>
        /// Clear all events.
        /// </summary>
        public static void ClearEvents()
        {
            m_EventLoggers.Clear();
        }
        #endregion

        #region sending
        /// <summary>
        /// To send a custom event.
        /// </summary>
        /// <param name="eventName"> The event name that we will send. </param>
        /// <param name="value"> The value of event, example: The score.</param>
        public static void CustomEvent(string eventName, float value = 1.0f)
        {
            foreach (IEvent logger in m_EventLoggers)
            {
                logger.CustomEvent(eventName, value);
            }
        }

        /// <summary>
        /// To send a session event.
        /// </summary>
        /// <param name="sessionName"> The session name that we will send. </param>
        /// <param name="statue"> The session statue that we will send it can be started or completed. </param>
        public static void SessionEvent(string sessionName, SessionStatue statue)
        {
            foreach (IEvent logger in m_EventLoggers)
            {
                logger.SessionEvent(sessionName, statue);
            }
        }

        /// <summary>
        /// To send a ProgressEvent event.
        /// </summary>
        /// <param name="status"> The statue of progression </param>
        /// <param name="progression"> Progression name event </param>
        /// <param name="score"> The value of progression. </param>
        public static void ProgressEvent(ProgressionStatus status, string progression, int score = 1)
        {
            foreach (IEvent logger in m_EventLoggers)
            {
                logger.ProgressEvent(status, progression, score);
            }
        }

        /// <summary>
        /// To send some error events.
        /// </summary>
        /// <param name="severity"> The error type. </param>
        /// <param name="message"> The message content in the error. </param>
        public static void ErrorEvent(ErrorSeverity severity, string message)
        {
            foreach (IEvent logger in m_EventLoggers)
            {
                logger.ErrorEvent(severity, message);
            }
        }

        /// <summary>
        /// To send some products buying in the game.
        /// </summary>
        /// <param name="productIAPID"> product ID of the IAP. </param>
        /// <param name="price"> The price that spended on this product. </param>
        public static void IAPEvent(string productIAPID, float value)
        {
            foreach (IEvent logger in m_EventLoggers)
            {
                logger.IAPEvent(productIAPID, value);
            }
        }

        /// <summary>
        /// Send events on show some ADS.
        /// </summary>
        /// <param name="adType"> The ads type example Rewardedvideo. </param>
        /// <param name="placementName"> The placement name of this ad. </param>
        public static void AdEvent(AdType adType, string placementName)
        {
            foreach (IEvent logger in m_EventLoggers)
            {
                logger.AdEvent(adType, placementName);
            }
        }
        #endregion
    }
}
