using main.level;
using UnityEngine;

public class BigPlatform : Platform
{
    [SerializeField] private Type _type;
    [SerializeField] private bool _hideRenderer;
    [SerializeField] private Renderer _renderer;
    private enum Type { Start, Finish }

    private void Start()
    {
        if (_type == Type.Start)
            Instantiate(LevelsManager.currentLevel.levelInfo.StartPlatform, transform.position, transform.rotation, transform);
        else
            Instantiate(LevelsManager.currentLevel.levelInfo.FinishPlatform, transform.position, transform.rotation, transform);

        if (_hideRenderer == true)
        {
            _renderer.enabled = false;
        }
    }
}
