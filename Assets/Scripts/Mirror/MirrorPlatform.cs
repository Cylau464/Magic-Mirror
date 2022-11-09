using UnityEngine;
using System.Reflection;

public class MirrorPlatform : MonoBehaviour
{
    private Collider _collider;
    public Collider Collider => _collider;

    public void Activate(Collider collider, Vector3 localPos)
    {
        gameObject.SetActive(true);
        transform.localPosition = localPos;
        _collider = gameObject.CopyComponent(collider) as Collider;
    }

    public void Deactivate()
    {
        gameObject.SetActive(false);
        Destroy(_collider);
    }
}
