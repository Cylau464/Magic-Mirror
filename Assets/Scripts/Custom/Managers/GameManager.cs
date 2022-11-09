using core;
using input;
using engine;
using UnityEngine;
using main.level;
using System;
using Cutscenes;

public class GameManager : CoreManager
{
    #region statues
    public static bool isStarted { get; private set; }
    public static bool isCompleted { get; private set; }
    public static bool isFailed { get; private set; }

    public static bool isFinished { get { return isFailed || isCompleted; } }
    public static bool isPlaying { get { return !isFinished && isStarted && _isOpeningEnded; } }
    
    private static bool _isOpeningEnded;
    #endregion

    [Header("Levels data")]
    [SerializeField] private LevelsData _levelsData;

    public LevelsData levelsData => _levelsData;

    private IGameStatue _startStatue = new LevelStatueStarted();
    private IGameStatue _failedStatue = new LevelStatueFailed();
    private IGameStatue _completedStatue = new LevelStatueCompleted();

    public static GameManager Instance;

    public static Action OnStartPlay;
    public static Action OnFinishPlay;
    public static Action OnCompleted;
    public static Action OnFailed;

    private void OnEnable()
    {
        CutscenesHandler.OnEnd += OnCutsceneEnd;
        CutscenesHandler.OnSkipped += OnCutsceneSkipped;
    }

    private void OnDisable()
    {
        CutscenesHandler.OnEnd -= OnCutsceneEnd;
        CutscenesHandler.OnSkipped -= OnCutsceneSkipped;
    }

    protected override void OnInitialize()
    {
        if(Instance != null && Instance != this)
        {
            Destroy(this);
            return;
        }

        Instance = this;
        isStarted = false;
        isCompleted = false;
        isFailed = false;
        _isOpeningEnded = false;

#if Support_SDK
        apps.ADSManager.DisplayBanner();
#endif
    }

    #region desitions
    public void MakeStarted()
    {
        isStarted = true;

#if Support_SDK
        apps.ProgressEvents.OnLevelStarted(_levelsData.playerLevel);
#endif

        SwitchToStatue(_startStatue);
        OnStartPlay?.Invoke();
    }

    public void MakeFinish()
    {
        if (isFinished)
            return;

        OnFinishPlay?.Invoke();
    }

    public void MakeFailed()
    {
        if (isFinished)
            return;

        isFailed = true;

        ControllerInputs.s_EnableInputs = false;

        _levelsData.OnLost();

#if Support_SDK
        apps.ProgressEvents.OnLevelFieled(_levelsData.playerLevel);
#endif

        SwitchToStatue(_failedStatue);
        OnFailed?.Invoke();
    }

    public void MakeCompleted()
    {
        if (isFinished)
            return;

        isCompleted = true;

        ControllerInputs.s_EnableInputs = false;

        int playerLevel = _levelsData.playerLevel;
        _levelsData.OnWin();

#if Support_SDK
        apps.ProgressEvents.OnLevelCompleted(playerLevel);
#endif

        SwitchToStatue(_completedStatue);
        OnCompleted?.Invoke();
    }
    #endregion

    private void OnCutsceneEnd(Cutscene cutscene)
    {
        if (cutscene.Type == CutsceneType.Opening)
            _isOpeningEnded = true;
        else
            MakeCompleted();
    }

    private void OnCutsceneSkipped(Cutscene cutscene, Cutscene.Step step)
    {
        if (cutscene.Type == CutsceneType.Opening)
            _isOpeningEnded = true;
        else
            MakeCompleted();
    }
}