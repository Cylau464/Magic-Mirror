using System;
using UnityEngine;

namespace Cutscenes
{
    public class CutsceneListener : MonoBehaviour
    {
        [SerializeField] private CutsceneType _type;
        [SerializeField] private int _stepIndex;

        private bool _isListening;

        public Action OnActivate;

        private void OnEnable()
        {
            CutscenesHandler.OnStart += OnStart;
            CutscenesHandler.OnNextStep += OnNextStep;
            CutscenesHandler.OnEnd += OnEnd;
        }

        private void OnDisable()
        {
            CutscenesHandler.OnStart -= OnStart;
            CutscenesHandler.OnNextStep -= OnNextStep;
            CutscenesHandler.OnEnd -= OnEnd;
        }

        private void OnStart(Cutscene cutscene)
        {
            if (cutscene.Type == _type)
                _isListening = true;
        }

        private void OnNextStep(Cutscene.Step step)
        {
            if (_isListening == true && step.Index == _stepIndex)
                OnActivate?.Invoke();
        }

        private void OnEnd(Cutscene cutscene)
        {
            if (_isListening == true)
                _isListening = false;
        }
    }
}