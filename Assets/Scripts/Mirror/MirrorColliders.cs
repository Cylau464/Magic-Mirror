using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class MirrorColliders : MonoBehaviour
{
    [SerializeField] private MirrorController _mirrorController;
    [SerializeField] private Transform _mirror;
    [SerializeField] private MirrorPlatform _mirrorPlatformPrefab;

    [SerializeField] private LayerMask _platformsLayer;
    [SerializeField] private int _collidersPoolCount = 10;

    private List<PlatformsPair> _contactPlatformsPairs;
    private Stack<MirrorPlatform> _mirrorPlatformsPool;

    private void Start()
    {
        _mirrorController.OnMove += OnMove;

        _contactPlatformsPairs = new List<PlatformsPair>();
        _mirrorPlatformsPool = new Stack<MirrorPlatform>(_collidersPoolCount);

        for(int i = 0; i < _collidersPoolCount; i++)
        {
            MirrorPlatform platform = Instantiate(_mirrorPlatformPrefab);
            platform.transform.SetParent(_mirror);
            platform.gameObject.SetActive(false);
            _mirrorPlatformsPool.Push(platform);
        }
    }

    private void OnDestroy()
    {
        _mirrorController.OnMove -= OnMove;
    }

    private void OnTriggerEnter(Collider other)
    {
        if((1 << other.gameObject.layer & _platformsLayer) != 0
            && _contactPlatformsPairs.Any(x => x.Collider == other) == false)
        {
            Platform platform = other.GetComponent<Platform>();
            platform.OnDisabled += OnColliderDisabled;
            MirrorPlatform mirrorPlatform = _mirrorPlatformsPool.Pop();
            Vector3 localPos = _mirror.InverseTransformPoint(other.transform.position);
            localPos += Vector3.Scale(localPos, Vector3.back) * 2f;
            mirrorPlatform.Activate(other, localPos);
            _contactPlatformsPairs.Add(new PlatformsPair(platform, mirrorPlatform, other));
        }
    }

    private void OnTriggerExit(Collider other)
    {
        OnColliderDisabled(other);
    }

    private void OnColliderDisabled(Collider collider)
    {
        if (_contactPlatformsPairs.Any(x => x.Collider == collider) == true)
        {
            PlatformsPair pair = _contactPlatformsPairs.First(x => x.Collider == collider);
            pair.Platform.OnDisabled -= OnColliderDisabled;
            pair.MirrorPlatform.Deactivate();
            _mirrorPlatformsPool.Push(pair.MirrorPlatform);
            _contactPlatformsPairs.Remove(pair);
        }
    }

    private void OnMove()
    {
        Vector3 localPos;

        foreach(PlatformsPair pair in _contactPlatformsPairs)
        {
            localPos = _mirror.InverseTransformPoint(pair.Collider.transform.position);
            pair.MirrorPlatform.transform.localPosition = localPos + Vector3.Scale(localPos, Vector3.back) * 2f;
        }
    }
}

public struct PlatformsPair
{
    public Platform Platform;
    public MirrorPlatform MirrorPlatform;
    public Collider Collider;

    public PlatformsPair(Platform platform, MirrorPlatform mirrorPlatform, Collider collider)
    {
        Platform = platform;
        MirrorPlatform = mirrorPlatform;
        Collider = collider;
    }
}
