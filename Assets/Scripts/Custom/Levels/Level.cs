using UnityEngine;

namespace main.level
{
    public class Level : MonoBehaviour
    {
        [SerializeField] protected LevelInfoSO m_LevelInfo;

        public LevelInfoSO levelInfo => m_LevelInfo;
        public LevelsManager levelsManager { get; private set; }
        public SceneContainer sceneContainer { get; private set; }

        public virtual void Initialize(LevelsManager levelsManager, SceneContainer sceneContainer)
        {
            this.levelsManager = levelsManager;
            this.sceneContainer = sceneContainer;
        }
    }
}
