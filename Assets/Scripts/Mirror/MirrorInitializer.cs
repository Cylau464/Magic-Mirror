using UnityEngine;
using AkilliMum.SRP.Mirror;
using System.Collections.Generic;

public class MirrorInitializer : MonoBehaviour
{
    [SerializeField] private Renderer _renderer;

    private void Start()
    {
        Camera camera = Camera.main;

        if(camera.TryGetComponent(out CameraShade cs))
        {
            if(cs.Shades != null && cs.Shades.Count <= 0)
            {
                cs.AddShadeObject(_renderer.gameObject, _renderer.material, _renderer);
            }
            else
            {
                CameraShade csNew = camera.gameObject.CopyComponent(cs) as CameraShade;
                csNew.Shades = new List<Shade>();
                csNew.AddShadeObject(_renderer.gameObject, _renderer.material, _renderer);
            }

        }
        else
        {
            Debug.LogError("Cant find CameraShade component on Main Camera");
        }
    }
}
