using System.Collections;
using UnityEngine;

namespace Cutscenes
{
    public class InteractableObject : MonoBehaviour
    {
        [SerializeField] private CutsceneTrigger _trigger;
        [SerializeField] private InteractableType _type;
        public InteractableType Type => _type;
        [ConditionalHide(nameof(_type), true, ((int)InteractableType.PickUp))]
        [SerializeField] private PivotPoint _pivotPoint;
        public PivotPoint PivotPoint => _pivotPoint;

        [Space]
        [SerializeField] private float _bindingDuration = .8f;
        [SerializeField] protected Transform _targetPoint;
        [SerializeField] protected Vector3 _targetRotation;

        private void OnEnable()
        {
            _trigger.OnTriggered += OnTriggered;
        }

        private void OnDisable()
        {
            _trigger.OnTriggered -= OnTriggered;
        }

        private void OnTriggered(PlayerController pc)
        {
            switch(_type)
            {
                case InteractableType.PickUp:
                    pc.PickedUp(this);
                    break;
            }
        }

        public void BindToObject(Transform t)
        {
            transform.SetParent(t);
            Vector3 startLocalPos = transform.localPosition;
            Quaternion startLocalRot = transform.localRotation;

            this.LerpCoroutine(
                time: _bindingDuration,
                from: 0f,
                to: 1f,
                action: a =>
                {
                    transform.localPosition = Vector3.Lerp(startLocalPos, Vector3.zero, a);
                    transform.localRotation = Quaternion.Lerp(startLocalRot, Quaternion.identity, a);
                }
            );
        }

        public virtual void Activate()
        {

        }
    }

    public enum InteractableType { PickUp, Activate }
}