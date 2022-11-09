using UnityEngine;

namespace Cutscenes
{
    public class ActivatableByTrigger : TriggerListener
    {
        [SerializeField] private GameObject _activatableObject;

        private void Start()
        {
            _activatableObject.SetActive(false);
        }

        protected override void OnTriggered(PlayerController pc)
        {
            _activatableObject.SetActive(true);
        }
    }
}