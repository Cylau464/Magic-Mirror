using main.level;
using UnityEngine;
using UnityEngine.UI;

namespace main.ui
{
    public class PanelPlay : Panel
    {
        [Header("Text Level")]
        [SerializeField] private LevelsData _levelsData;
        [SerializeField] private Text _textLevel;

        protected void Start()
        {
            InitializedTextLevel();
        }

        private void InitializedTextLevel()
        {
            int clevel = _levelsData.playerLevel;
            if (clevel < 10)
            {
                _textLevel.text = "LEVEL 0" + clevel;
            }
            else
            {
                _textLevel.text = "LEVEL " + clevel;
            }
        }

        public void ReloadScene()
        {
            GameScenes.ReloadScene();
        }
    }
}
