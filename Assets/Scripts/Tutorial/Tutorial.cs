using System;
using Cutscenes;
using UnityEngine;

public class Tutorial : MonoBehaviour
{
    [SerializeField] private TutorialData _data;
    [Space]
    [SerializeField] private Animator[] _fingers;
    [SerializeField] private MirrorPositions[] _targetMirrorPositions;

    private Camera _camera;

    private MirrorController[] _mirrors;
    public MirrorController[] Mirrors
    {
        get { return _mirrors; }
        set
        {
            for(int i = 0; i < value.Length; i++)
            {
                int index = i;
                value[i].OnStartMove += () => BeginDrag(index);
                value[i].OnEndMove += () => EndDrag(index);
                _fingers[i].gameObject.SetActive(true);
            }

            _mirrors = value;
        }
    }
    public FinishTrigger Finish;

    private int _levelID => GameManager.Instance.levelsData.idLevel;

    public static Tutorial Instance;

    public static Action<MirrorController> OnMirrorDisable;

    private void Awake()
    {
        if(Instance != null && Instance != this)
        {
            Destroy(this);
            return;
        }

        Instance = this;

        foreach (Animator finger in _fingers)
            finger.gameObject.SetActive(false);

        _camera = Camera.main;
    }

    private void Start()
    {
        if(_levelID >= _data.Data.LevelCompleted.Length || _data.Data.LevelCompleted[_levelID] == true)
        {
            for (int i = 0; i < _fingers.Length; i++)
                Destroy(_fingers[i].gameObject);

            Destroy(this);
            return;
        }

        GameManager.OnFinishPlay += HideLastFinger;
    }

    private void Update()
    {
        if(_mirrors != null)
        {
            for (int i = 0; i < _mirrors.Length; i++)
            {
                if (i > _fingers.Length)
                    break;

                _fingers[i].transform.position = _camera.WorldToScreenPoint(_mirrors[i].transform.GetChild(0).position);
            }
        }

        if(Finish != null)
        {
            _fingers[_fingers.Length - 1].transform.position = _camera.WorldToScreenPoint(Finish.transform.position);
        }
    }

    private void OnDestroy()
    {
        GameManager.OnFinishPlay -= HideLastFinger;
    }

    private void BeginDrag(int index)
    {
        if (Instance == null) return;

        if (index < _fingers.Length)
            _fingers[index].SetBool("drag", true);
    }

    private void EndDrag(int index)
    {
        if (Instance == null) return;

        if (index < _fingers.Length)
        {
            if(_mirrors[index].transform.GetChild(0).localPosition == _targetMirrorPositions[_levelID].Positions[index])
            {
                _fingers[index].gameObject.SetActive(false);
                OnMirrorDisable?.Invoke(_mirrors[index]);

                if (index == _targetMirrorPositions[_levelID].Positions.Length - 1)
                    _fingers[_fingers.Length - 1].gameObject.SetActive(true);
            }
            else
            {
                _fingers[index].SetBool("drag", false);
            }
        }
    }

    private void HideLastFinger()
    {
        _fingers[_fingers.Length - 1].gameObject.SetActive(false);
        _data.Data.LevelCompleted[_levelID] = true;
        _data.SaveData();
    }

    [Serializable]
    private struct MirrorPositions
    {
        public Vector3[] Positions;
    }
}
