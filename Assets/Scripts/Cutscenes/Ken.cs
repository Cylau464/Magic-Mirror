using UnityEngine;

namespace Cutscenes
{
    public class Ken : TriggerListener
    {
        [SerializeField] private Animator _animator;
        [SerializeField] private float _rotationOffset = -30f;

        private int _kissParamID;

        protected new void OnEnable()
        {
            base.OnEnable();
            CutscenesHandler.OnNextStep += OnNextStep;
        }

        private new void OnDisable()
        {
            base.OnDisable();
            CutscenesHandler.OnNextStep -= OnNextStep;
        }

        private void Start()
        {
            _kissParamID = Animator.StringToHash("kiss");
        }

        protected override void OnTriggered(PlayerController pc)
        {
            _animator.SetTrigger(_kissParamID);
        }

        private void OnNextStep(Cutscene.Step step)
        {
            if(step.Action.Type == CharacterActionType.Rotate)
            {
                float duration;
                if (step.Action.ActionBy == ActionBy.Duration)
                {
                    duration = step.Action.Duration;
                }
                else
                {
                    duration = Vector3.SignedAngle(transform.position, step.Action.Trigger.transform.position, Vector3.up);
                    duration /= step.Action.Speed;
                }

                Vector3 forward = (step.Action.Trigger.transform.position - transform.position).normalized;
                forward.y = 0f;
                Quaternion targetRot = Quaternion.LookRotation(forward, Vector3.up) * Quaternion.Euler(0f, _rotationOffset, 0f);
                this.LerpCoroutine(
                    time: duration,
                    from: transform.rotation,
                    to: targetRot,
                    action: a => transform.rotation = a
                );
            }
        }
    }
}