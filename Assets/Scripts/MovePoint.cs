using System;
using UnityEngine;
using Cutscenes;

public class MovePoint : MonoBehaviour, ICutsceneMain
{
    [SerializeField] private Transform _pathPoint;
    [SerializeField] private ParticleSystem _tapVFX;

    private bool _isActive = true;

    public static Action<Vector3> OnClick;

    private void OnEnable()
    {
        CutscenesHandler.OnStart += OnCutsceneStart;
        CutscenesHandler.OnEnd += OnCutsceneEnd;
        CutscenesHandler.OnSkipped += OnCutsceneSkipped;
    }

    private void OnDisable()
    {
        CutscenesHandler.OnStart -= OnCutsceneStart;
        CutscenesHandler.OnEnd -= OnCutsceneEnd;
        CutscenesHandler.OnSkipped -= OnCutsceneSkipped;
    }

    public void Click()
    {
        if (GameManager.isPlaying == false || _isActive == false) return;

        _tapVFX.Play();
        OnClick?.Invoke(_pathPoint.transform.position);
    }

    public void OnCutsceneStart(Cutscene cutscene)
    {
        _isActive = false;
    }

    public void OnCutsceneSkipped(Cutscene cutscene, Cutscene.Step step)
    {
        if (cutscene.Type == CutsceneType.Opening)
            _isActive = true;
    }

    public void OnCutsceneEnd(Cutscene cutscene)
    {
        if (cutscene.Type == CutsceneType.Opening)
            _isActive = true;
    }
}