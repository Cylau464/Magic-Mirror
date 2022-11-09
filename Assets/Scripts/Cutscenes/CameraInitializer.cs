using engine.camera;
using UnityEngine;

namespace Cutscenes
{
    public class CameraInitializer : MonoBehaviour
    {
        [SerializeField] private VirtualCamerasManager _camerasManager;
        [SerializeField] private CameraView _cameraView;
        [SerializeField] private PivotPoint _pivotPoint;
        public PivotPoint PivotPoint => _pivotPoint;

        private void Start()
        {
            _camerasManager.AddCameraView(_cameraView);
        }

        public void SetTarget(Transform target)
        {
            _cameraView.virtualCamera.Follow = target;
            _cameraView.virtualCamera.LookAt = target;
        }
    }
}