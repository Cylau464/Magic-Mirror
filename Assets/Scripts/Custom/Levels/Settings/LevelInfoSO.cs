using Cutscenes;
using UnityEngine;

namespace main.level
{
    [CreateAssetMenu(fileName = "LevelInfo", menuName = "Add/LevelInfo", order = 1)]
    public class LevelInfoSO : ScriptableObject
    {
        public AnimationController Character;
        public Clothes StartClothes;
        public Clothes ClothesToChange;

        [Header("Platforms")]
        public CutscenePlatform StartPlatform;
        public CutscenePlatform FinishPlatform;
    }
}
