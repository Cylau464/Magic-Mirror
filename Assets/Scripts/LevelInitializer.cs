using core;
using main.level;
using UnityEngine;

public class LevelInitializer : MonoBehaviour, IValidate
{
    [SerializeField] private MirrorController[] _mirrors;
    [SerializeField] private Platform[] _platforms;
    [SerializeField] private PlayerController _player;
    [SerializeField] private PathUpdater _pathUpdater;

    private void Start()
    {
        Camera camera = Camera.main;

        foreach(Platform platform in _platforms)
        {
            platform.Initialize(_mirrors, camera);
        }

        _player.Initialize(_mirrors, LevelsManager.currentLevel.levelInfo);
        _pathUpdater.Initialize(_mirrors);
        Tutorial.Instance.Mirrors = _mirrors;
    }

    public void Validate()
    {
#if UNITY_EDITOR
        _platforms = editor.EditorManager.FindScenesComponents<Platform>();
        _mirrors = editor.EditorManager.FindScenesComponents<MirrorController>();
        _player = editor.EditorManager.FindScenesComponent<PlayerController>();
        _pathUpdater = editor.EditorManager.FindScenesComponent<PathUpdater>();
#endif
    }
}