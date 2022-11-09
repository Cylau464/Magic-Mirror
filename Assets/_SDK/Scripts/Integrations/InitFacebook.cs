using Facebook.Unity;

namespace apps
{
    public class FacebookApp : IApplication
    {
        public FacebookApp()
        {
            if (FB.IsInitialized == true)
            {
                CallEvents();
            }
            else
            {
                FB.Init(() =>
                {
                    CallEvents();
                });
            }
        }

        public void CallEvents()
        {
            FB.ActivateApp();
            FB.LogAppEvent(AppEventName.ActivatedApp);
            FB.Mobile.SetAdvertiserIDCollectionEnabled(true);
        }
    }
}
