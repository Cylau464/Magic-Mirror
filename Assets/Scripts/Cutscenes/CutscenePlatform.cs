using Cinemachine;
using UnityEngine;

namespace Cutscenes
{
    public class CutscenePlatform : MonoBehaviour
    {
        [SerializeField] private CutsceneType _type;
        [SerializeField] private Cutscene _cutscene;
        [SerializeField] private CinemachineTargetGroup _targetGroup;
        [SerializeField] private CutsceneTrigger[] _cutsceneTriggers;

        private void OnEnable()
        {
            if (_type == CutsceneType.Opening)
                GameManager.OnStartPlay += Activate;
            else
                GameManager.OnFinishPlay += Activate;
        }

        private void OnDisable()
        {
            if (_type == CutsceneType.Opening)
                GameManager.OnStartPlay -= Activate;
            else
                GameManager.OnFinishPlay -= Activate;
        }

        private void Start()
        {
            _cutscene.CameraTargetGroup = _targetGroup;
            _cutscene.Triggers = _cutsceneTriggers;
        }

        private void Activate()
        {
            CutscenesHandler.Instance.StartCutscene(_cutscene);
        }
    }
}