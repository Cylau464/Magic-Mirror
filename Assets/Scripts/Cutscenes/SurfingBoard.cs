using StylizedWater2;
using UnityEngine;

namespace Cutscenes
{
    public class SurfingBoard : InteractableObject
    {
        [SerializeField] private Collider _collider;
        [SerializeField] private float _throwingDuration = .5f;
        [SerializeField] private FloatingTransform _floatingT;
        [SerializeField] private float _heightOffset = -1.55f;

        private Transform _startParent;
        private bool _isActivated;

        private void Start()
        {
            _floatingT.enabled = false;
            _collider.enabled = false;
            _startParent = transform.parent;
        }

        public override void Activate()
        {
            base.Activate();

            transform.parent = _startParent;
            Vector3 startPos = transform.position;
            Quaternion startRot = transform.localRotation;
            StopAllCoroutines();

            this.LerpCoroutine(
                time: _throwingDuration,
                from: 0f,
                to: 1f,
                action: a =>
                {
                    transform.position = Vector3.Lerp(startPos, _targetPoint.position, a);
                    transform.localRotation = Quaternion.Lerp(startRot, Quaternion.Euler(_targetRotation), a);
                },
                onEnd: () =>
                {
                    _floatingT.enabled = true;
                    _isActivated = true;
                    _collider.enabled = true;
                }
            );
        }

        private void OnCollisionEnter(Collision collision)
        {
            if (_isActivated == true && collision.gameObject.TryGetComponent(out PlayerController pc) == true)
            {
                pc.FixOnObject(transform);
            }
        }

        public void BindToWater(WaterObject wo)
        {
            _floatingT.waterObject = wo;
            _floatingT.heightOffset = _heightOffset;
        }
    }
}