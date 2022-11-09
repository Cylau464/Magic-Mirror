using UnityEngine;

public class PathUpdater : MonoBehaviour
{
    [SerializeField] private AstarPath _pathfinder;

    private MirrorController[] _mirrors;

    public void Initialize(MirrorController[] mirrors)
    {
        _mirrors = mirrors;

        foreach(MirrorController mirror in _mirrors)
        {
            mirror.OnEndMove += ScanPath;
        }

        ScanPath();
    }

    private void OnDestroy()
    {
        foreach (MirrorController mirror in _mirrors)
        {
            if (mirror == null) continue;

            mirror.OnEndMove -= ScanPath;
        }
    }

    private void ScanPath()
    {
        this.DoAfterNextFixedFrameCoroutine(() => _pathfinder.Scan());
    }
}
