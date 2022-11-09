using System.Collections.Generic;
using UnityEngine;

namespace apps.adsview
{
    internal class Window
    {
        internal bool isEnable { get; private set; }

        private GUIText _text;
        private GameObject _windowGameObject;


        internal Window(GameObject windowGameObject)
        {
            _windowGameObject = windowGameObject ?? throw new System.ArgumentNullException("The GameObject is has null value.");
            Object.DontDestroyOnLoad(_windowGameObject);

            _text = (GUIText)_windowGameObject.AddComponent(typeof(GUIText));
            _text.Initialize(new GUIContent(),
                new Rect(
                    Screen.width / 2,
                    Screen.height / 2,
                    0,
                    0
                )
                );

            HideWindow();
        }

        internal void ShowWindow(string placementName = "")
        {
            _text.SetText(placementName);
            isEnable = true;
            _windowGameObject.SetActive(true);
        }

        internal void HideWindow()
        {
            _text.SetText("");
            isEnable = false;
            _windowGameObject.SetActive(false);
        }
    }
}
