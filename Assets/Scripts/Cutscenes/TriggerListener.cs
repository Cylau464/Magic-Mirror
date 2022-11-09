using UnityEngine;

namespace Cutscenes
{
    public abstract class TriggerListener : MonoBehaviour
    {
        [SerializeField] private CutsceneTrigger _trigger;

        protected void OnEnable()
        {
            _trigger.OnTriggered += OnTriggered;
        }

        protected void OnDisable()
        {
            _trigger.OnTriggered -= OnTriggered;
        }

        protected abstract void OnTriggered(PlayerController pc);
    }
}