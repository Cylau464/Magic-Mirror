using UnityEngine;
using System.Collections.Generic;
using System;

public class Platform : MonoBehaviour
{
    [SerializeField] protected Collider _collider;
    [SerializeField] private GameObject _pathPoint;
    [SerializeField] private LayerMask _ignoredMask;
    [SerializeField] private LayerMask _platfromsLayers;

    private List<MirrorController> _mirrors;
    private Transform _camera;

    public Action<Collider> OnDisabled;

    public void Initialize(MirrorController[] mirror, Camera camera)
    {
        _mirrors = new List<MirrorController>(mirror);
        _camera = CameraController.Instance.GameCamera.transform;
        
        foreach (MirrorController m in _mirrors)
            m.OnMove += CheckVisibility;

        this.DoAfterNextFrameCoroutine(() => CheckVisibility());
    }

    private void CheckVisibility()
    {
        _collider.enabled = true;
        Ray ray = new Ray(_camera.position, (transform.position - _camera.position).normalized);
        RaycastHit[] hits = Physics.RaycastAll(ray, 1000f);
        bool visible = CheckRaycasts(ray, hits, true);
        _collider.enabled = visible;
        _pathPoint.SetActive(visible);

        if (visible == false)
            OnDisabled?.Invoke(_collider);
    }

    private bool CheckRaycasts(Ray ray, RaycastHit[] hits, bool recursive)
    {
        bool visible = false;

        foreach (RaycastHit hit in hits)
        {
            if ((1 << hit.collider.gameObject.layer & _ignoredMask) != 0)
            {
#if UNITY_EDITOR
                Debug.DrawRay(ray.origin, ray.direction * hit.distance, Color.cyan, 1f);
#endif
                continue;
            }
            else if ((1 << hit.collider.gameObject.layer & _platfromsLayers) != 0)
            {
#if UNITY_EDITOR
                Debug.DrawRay(ray.origin, ray.direction * hit.distance, Color.green, 1f);
#endif
                visible = true;
            }
            else if (Vector3.Distance(_camera.position, transform.position)
                    >= hit.distance)
            {
#if UNITY_EDITOR
                Debug.DrawRay(ray.origin, ray.direction * hit.distance, Color.red, 1f);
#endif
                if (recursive == true)
                {
                    Vector3[] vertices = GetColliderVertexPositions();
                    Ray extraRay;
                    RaycastHit[] extraHits;
                    int hittedRays = 0;

                    foreach (Vector3 vertex in vertices)
                    {
                        extraRay = new Ray(_camera.position, (vertex - _camera.position).normalized);
                        extraHits = Physics.RaycastAll(extraRay, 1000f);

                        if (CheckRaycasts(extraRay, extraHits, false) == true)
                            hittedRays++;
                    }

                    if (hittedRays >= 2)
                    {
                        visible = true;
                    }
                    else
                    {
                        visible = false;
                        break;
                    }
                }
                else
                {
                    visible = false;
                    break;
                }
            }
        }

        return visible;
    }

    private Vector3[] GetColliderVertexPositions()
    {
        Vector3[] vertices = new Vector3[8];
        Matrix4x4 thisMatrix = transform.localToWorldMatrix;
        Quaternion storedRotation = transform.rotation;
        transform.rotation = Quaternion.identity;

        Vector3 extents = _collider.bounds.extents;
        Vector3 offset = Vector3.up * _collider.bounds.center.y;
        vertices[0] = thisMatrix.MultiplyPoint3x4(extents + offset);
        vertices[1] = thisMatrix.MultiplyPoint3x4(new Vector3(-extents.x, extents.y, extents.z) + offset);
        vertices[2] = thisMatrix.MultiplyPoint3x4(new Vector3(extents.x, extents.y, -extents.z) + offset);
        vertices[3] = thisMatrix.MultiplyPoint3x4(new Vector3(-extents.x, extents.y, -extents.z) + offset);
        vertices[4] = thisMatrix.MultiplyPoint3x4(new Vector3(extents.x, -extents.y, extents.z) + offset);
        vertices[5] = thisMatrix.MultiplyPoint3x4(new Vector3(-extents.x, -extents.y, extents.z) + offset);
        vertices[6] = thisMatrix.MultiplyPoint3x4(new Vector3(extents.x, -extents.y, -extents.z) + offset);
        vertices[7] = thisMatrix.MultiplyPoint3x4(-extents + offset);

        transform.rotation = storedRotation;

        return vertices;
    }

    private void OnDestroy()
    {
        foreach (MirrorController m in _mirrors)
        {
            if(m != null)
                m.OnMove -= CheckVisibility;
        }
    }
}
