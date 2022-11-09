using UnityEngine;
using System;

namespace Cutscenes
{
    public class CutsceneTrigger : MonoBehaviour
    {
        [SerializeField] private Collider _collider;
        [Space]
        [SerializeField] private int _stepIndex;
        public int StepIndex => _stepIndex;

        private NextStepBy nextStepBy => CutscenesHandler.Instance.CurCutscene.CurStep.NextStepBy;

        public Action<PlayerController> OnTriggered;

        private void Awake()
        {
            Deactivate();
        }

        public void Activate()
        {
            _collider.enabled = true;
        }

        public void Deactivate()
        {
            _collider.enabled = false;
        }

        private void OnTriggerEnter(Collider other)
        {
            if(CutscenesHandler.Instance.CurCutscene != null 
               && other.TryGetComponent(out PlayerController pc) == true)
            {
                if (nextStepBy == NextStepBy.Trigger)
                    CutscenesHandler.Instance.CurCutscene.NextStep();

                pc.CutsceneTriggerActivated();
                OnTriggered?.Invoke(pc);
            }
        }
    }
}