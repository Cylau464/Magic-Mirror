namespace apps
{
    public static class ProgressEvents
    {
        /// <summary>
        /// Send events about progress levels when player start the level.
        /// </summary>
        /// <param name="playerLevel"> The level what player see it in the game. </param>
        public static void OnLevelStarted(int playerLevel)
        {
            EventsLogger.ProgressEvent(ProgressionStatus.Start, "Level_" + playerLevel);
        }

        /// <summary>
        /// Send events about progress levels when player fieled the level.
        /// </summary>
        /// <param name="playerLevel"> The level what player see it in the game. </param>
        public static void OnLevelFieled(int playerLevel)
        {
            EventsLogger.ProgressEvent(ProgressionStatus.Fail, "Level_" + playerLevel);
        }

        /// <summary>
        /// Send events about progress levels when player Completed the level.
        /// </summary>
        /// <param name="playerLevel"> The level what player see it in the game. </param>
        public static void OnLevelCompleted(int playerLevel)
        {
            EventsLogger.ProgressEvent(ProgressionStatus.Complete, "Level_" + playerLevel);
        }
    }
}