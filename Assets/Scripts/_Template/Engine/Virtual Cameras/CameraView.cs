using Cinemachine;
using UnityEngine;

namespace engine.camera
{
    [System.Serializable]
    public class CameraView
    {
        [SerializeField] protected string _tag;
        [SerializeField] protected CinemachineVirtualCamera _virtualCamera;

        public CinemachineVirtualCamera virtualCamera => _virtualCamera;
        public string tag => _tag;
        public bool isEnable => _virtualCamera != null;

        public CameraView(CinemachineVirtualCamera virtualCamera)
        {
            if (virtualCamera == null)
            {
                Debug.LogError("CinemachineVirtualCamera parameter equal null!.");
                return;
            }

            this._virtualCamera = virtualCamera;
            Off();
        }

        public CameraView(string tag, CinemachineVirtualCamera virtualCamera) : this(virtualCamera)
        {
            _tag = tag;
        }

        public void Off()
        {
            _virtualCamera.gameObject.SetActive(false);
        }

        public void On()
        {
            _virtualCamera.gameObject.SetActive(true);
        }

        public void SetFollow(Transform follow)
        {
            _virtualCamera.Follow = follow;
        }

        public void SetLookAt(Transform lookAt)
        {
            _virtualCamera.LookAt = lookAt;
        }
    }
}