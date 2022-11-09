namespace apps
{
    public enum ProgressionStatus
    {
        Undefined = 0,
        Start = 1,
        Complete = 2,
        Fail = 3
    }

    public enum BannerPosition
    {
        TOP = 1,
        BOTTOM = 2
    };

    public enum AdType
    {
        Undefined = 0,
        RewardedVideo = 2,
        Interstitial = 4,
        OfferWall = 5,
        Banner = 6
    }

    public enum ErrorSeverity
    {
        Undefined = 0,
        Debug = 1,
        Info = 2,
        Warning = 3,
        Error = 4,
        Critical = 5
    }

}
