using input;
using System;
using UnityEngine;
using Random = UnityEngine.Random;

namespace Cutscenes
{
    public class CutscenesHandler : MonoBehaviour
    {
        private Cutscene _curCutscene;
        public Cutscene CurCutscene => _curCutscene;

        public static Action<Cutscene> OnStart;
        public static Action<Cutscene> OnEnd;
        public static Action<Cutscene.Step> OnNextStep;
        public static Action<Cutscene, Cutscene.Step> OnSkipped;

        public static CutscenesHandler Instance;

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(this);
                return;
            }

            Instance = this;
        }

        private void OnEnable()
        {
            Subscribe();
        }

        private void OnDisable()
        {
            Unsubscribe();
        }

        private void Update()
        {
            if (_curCutscene != null
                && ControllerInputs.IsPointerOverUI() == false
                && ControllerInputs.GetMouseState() == MouseStatue.Down)
            {
                CancelInvoke(nameof(NextStep));
                _curCutscene.Skip();
            }
        }

        private void Subscribe()
        {
            if (_curCutscene != null)
            {
                _curCutscene.OnNextStep += NextStep;
                _curCutscene.OnEnd += End;
                _curCutscene.OnSkip += Skip;
            }
        }

        private void Unsubscribe()
        {
            if (_curCutscene != null)
            {
                _curCutscene.OnNextStep -= NextStep;
                _curCutscene.OnEnd -= End;
                _curCutscene.OnSkip -= Skip;
            }
        }

        public void StartCutscene(Cutscene cutscene)
        {
            _curCutscene = cutscene;
            Subscribe();
            OnStart?.Invoke(_curCutscene);
            _curCutscene.Start();
        }

        private void End()
        {
            CancelInvoke(nameof(NextStep));
            Unsubscribe();
            OnEnd?.Invoke(_curCutscene);
            _curCutscene = null;
        }

        private void Skip(Cutscene.Step step)
        {
            Unsubscribe();
            OnSkipped?.Invoke(_curCutscene, step);
            _curCutscene = null;
        }

        private void NextStep()
        {
            _curCutscene.NextStep();
        }

        private void NextStep(Cutscene.Step step)
        {
            if (_curCutscene.StepSwitch == StepSwitch.Auto || step.NextStepBy == NextStepBy.Duration)
                Invoke(nameof(NextStep), step.Duration);

            OnNextStep?.Invoke(step);
        }
    }
}