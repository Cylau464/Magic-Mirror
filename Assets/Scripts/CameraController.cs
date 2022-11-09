using engine.camera;
using UnityEngine;
using Cinemachine;
using Cutscenes;

public class CameraController : MonoBehaviour, ICutsceneNextStep, ICutsceneSkipped
{
    [SerializeField] private VirtualCamerasManager _camerasManager;
    [SerializeField] private CinemachineVirtualCamera _startVCam;
    [SerializeField] private CinemachineVirtualCamera _targetVCam;
    [SerializeField] private CinemachineVirtualCamera _finishVCam;
    [SerializeField] private CinemachineVirtualCamera _gameVCam;
    [SerializeField] private string _startTag = "Start";
    [SerializeField] private string _targetTag = "Target";
    [SerializeField] private string _finishTag = "Finish";
    [SerializeField] private string _gameTag = "Game";

    private CameraView _startCamera;
    private CameraView _targetCamera;
    private CameraView _finishCamera;
    private CameraView _gameCamera;

    private float _prevCameraFOV;

    private CinemachineOrbitalTransposer _targetTransposer;

    public CinemachineVirtualCamera GameCamera => _gameCamera.virtualCamera;

    public static CameraController Instance;

    private void Awake()
    {
        if(Instance != null && Instance != this)
        {
            Destroy(this);
            return;
        }

        Instance = this;

        _startCamera = new CameraView(_startTag, _startVCam);
        _targetCamera = new CameraView(_targetTag, _targetVCam);
        _finishCamera = new CameraView(_finishTag, _finishVCam);
        _gameCamera = new CameraView(_gameTag, _gameVCam);
        _camerasManager.AddCameraView(
            new CameraView[] { _startCamera, _targetCamera, _finishCamera, _gameCamera }
        );
        _camerasManager.SwitchTo(_startCamera);
        _prevCameraFOV = _startVCam.m_Lens.FieldOfView;

        _targetTransposer = _targetVCam.GetCinemachineComponent<CinemachineOrbitalTransposer>();
    }

    private void OnEnable()
    {
        CutscenesHandler.OnNextStep += OnNextStep;
        CutscenesHandler.OnSkipped += OnCutsceneSkipped;
    }

    private void OnDisable()
    {
        CutscenesHandler.OnNextStep -= OnNextStep;
        CutscenesHandler.OnSkipped -= OnCutsceneSkipped;
    }

    private void ChangeTargetInGroup(CinemachineTargetGroup group, int index, float weight)
    {
        for (int i = 0; i < group.m_Targets.Length; i++)
        {
            if (i == index)
                group.m_Targets[i].weight = weight;
            else
                group.m_Targets[i].weight = Mathf.Max(0f, 1f - weight);
        }
    }

    private void SkipStep(Cutscene.Step step)
    {
        if (step.CameraSwitcher.Enabled == true)
            _camerasManager.SwitchTo(step.CameraSwitcher.Tag);

        CinemachineVirtualCamera camera = _camerasManager.GetVirtualCamera();

        if (camera == _targetVCam)
            this.DoAfterNextFrameCoroutine(() => _targetTransposer.m_XAxis.m_InputAxisValue = 1f);

        if (step.Zoom.Enabled == true)
            camera.m_Lens.FieldOfView = step.Zoom.FOV;

        if (step.TargetGroup.Enabled == true)
            ChangeTargetInGroup(step.TargetGroup.Group, step.TargetGroup.TargetIndex, 1f);
    }

    public void OnCutsceneSkipped(Cutscene cutscene, Cutscene.Step step)
    {
        StopAllCoroutines();
        SkipStep(step);
    }

    public void OnNextStep(Cutscene.Step step)
    {
        StopAllCoroutines();

        CinemachineVirtualCamera camera = _camerasManager.GetVirtualCamera();

        if (step.CameraSwitcher.Enabled == true)
        {
            //camera.m_Lens.FieldOfView = _prevCameraFOV;
            _camerasManager.SwitchTo(step.CameraSwitcher.Tag);
        }

        camera = _camerasManager.GetVirtualCamera();
        _prevCameraFOV = camera.m_Lens.FieldOfView;

        if (step.TargetGroup.Enabled == true)
        {
            camera.LookAt = step.TargetGroup.Group.transform;
            camera.Follow = step.TargetGroup.Group.transform;
            ChangeTargetInGroup(step.TargetGroup.Group, step.TargetGroup.TargetIndex, 1f);
        }

        if (step.Duration > 0f)
        {
            if (camera == _targetVCam)
                this.DoAfterNextFrameCoroutine(() => _targetTransposer.m_XAxis.m_InputAxisValue = 1f);

            if (step.Zoom.Enabled == true)
            {
                this.LerpCoroutine(
                    time: step.Zoom.Duration,
                    from: 0f,
                    to: 1f,
                    action: a => camera.m_Lens.FieldOfView = Mathf.Lerp(
                        _prevCameraFOV,
                        step.Zoom.FOV,
                        step.Zoom.PingPong == true
                            ? step.Zoom.Curve.Evaluate(Mathf.PingPong(a, .5f))
                            : step.Zoom.Curve.Evaluate(a)
                    )
                );
            }

            //if (step.TargetGroup.Enabled == true)
            //    ChangeTargetInGroup(step.TargetGroup.Group, step.TargetGroup.TargetIndex, 1f);

            //if (step.TargetGroup.Enabled == true)
            //{
            //    if (step.TargetGroup.WeightChangeTime > 0f)
            //    {
            //        this.LerpCoroutine(
            //            time: step.TargetGroup.WeightChangeTime,
            //            from: 0f,
            //            to: 1f,
            //            action: a => ChangeTargetInGroup(step.TargetGroup.Group, step.TargetGroup.TargetIndex, a)
            //        );
            //    }
            //    else
            //    {
            //        ChangeTargetInGroup(step.TargetGroup.Group, step.TargetGroup.TargetIndex, 1f);
            //    }
            //}
        }
        else
        {
            SkipStep(step);
        }
    }
}
