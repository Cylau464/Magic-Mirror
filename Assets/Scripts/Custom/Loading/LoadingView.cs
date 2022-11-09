using UnityEngine;

namespace loading
{
    public class LoadingView : MonoBehaviour
    {
        protected void Start()
        {
            GameScenes.LoadMainScene();
        }
    }
}
