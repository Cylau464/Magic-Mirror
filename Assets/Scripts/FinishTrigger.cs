using UnityEngine;

public class FinishTrigger : MonoBehaviour
{
    [SerializeField] private LayerMask _playerLayer;
    [SerializeField] private ParticleSystem[] _particles;

    private bool _triggered;

    private void Start()
    {
        Tutorial.Instance.Finish = this;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(_triggered == false && (1 << other.gameObject.layer & _playerLayer) != 0)
        {
            GameManager.Instance.MakeFinish();
            ParticleSystem.MainModule main;

            foreach(ParticleSystem ps in _particles)
            {
                main = ps.main;
                main.loop = false;
            }

            _triggered = true;
        }
    }
}
