using Cutscenes;
using StylizedWater2;
using UnityEngine;

public class WaterWave : MonoBehaviour
{
    [SerializeField] private CutsceneListener _listener;
    [SerializeField] private Renderer _renderer;
    [SerializeField] private WaterObject _waterObject;
    [SerializeField] private Vector3 _targetPosition;
    [SerializeField] private float _toTargetTime = 1f;

    private static readonly int WaveHeightID = Shader.PropertyToID("_WaveHeight");

    private void OnEnable()
    {
        _listener.OnActivate += Move;
    }

    private void OnDisable()
    {
        _listener.OnActivate -= Move;
    }

    private void Start()
    {
        _renderer.enabled = false;
    }

    private void Move()
    {
        Vector3 startPos = transform.localPosition;
        _renderer.enabled = true;

        this.LerpCoroutine(
            time: _toTargetTime,
            from: 0f,
            to: 1f,
            action: a => transform.localPosition = Vector3.Lerp(startPos, _targetPosition, a)
        );
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.TryGetComponent(out SurfingBoard board) == true)
        {
            board.BindToWater(_waterObject);
        }
    }
}