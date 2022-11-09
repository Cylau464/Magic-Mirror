using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using input;
using System;
using System.Linq;
using Cutscenes;

public class MirrorController : MonoBehaviour, IMouseDown, IMouseUp, IDrag, IBeginDrag, IEndDrag, ICutsceneMain
{
    [Serializable]
    private struct MoveDirection
    {
        public Vector3 Direction;
        public float Start;
        public float End;
        [HideInInspector] public Vector3 StartPoint { get { return Start * Vector3Extensions.Abs(Direction); } }
        [HideInInspector] public Vector3 EndPoint { get { return End * Vector3Extensions.Abs(Direction); } }
        public float Interval;
        public bool StartingDirection;
    }

    [SerializeField] private Transform _mirror;
    [Header("Move Properties")]
    [SerializeField] private bool _isMovable = true;
    [SerializeField] private MoveDirection[] _moveDirections;
    [SerializeField] private float _moveDuration = .1f;
    [SerializeField] private Rigidbody _rigidBody;
    
    [Header("Move Interface")]
    [SerializeField] private Renderer _pointPrefab;
    [SerializeField] private LineRenderer _linePrefab;
    [SerializeField] private Transform _pointsParent;
    [SerializeField] private Color _activePointColor = Color.green;
    [SerializeField] private float _activePointScale = .4f;
    [SerializeField] private Vector3 _pointsPositionOffset = new Vector3(0f, 2.5f, 0f);
    [SerializeField] private float _toggleVisibilityDuration;
    private Renderer _activePoint;
    private List<Material[]> _directionsMaterials;

    [Header("Input")]
    [SerializeField] private float _minDragDelta = 1f;

    private bool _isActive;
    private bool _isPointsVisible;
    public bool IsDragging { get; private set; }

    private Transform[] _pointsHolders;
    private Camera _camera;
    private Coroutine _visibleCor;
    private Coroutine _moveCor;

    private const string colorProperty = "_Color";

    public Action OnMove;
    public Action OnEndMove;
    public Action OnStartMove;

    private void Start()
    {
#if UNITY_EDITOR
        _minDragDelta /= 3;
#endif

        if (_isMovable == false) return;

        MoveDirection[] startingDirs = _moveDirections.Where(x => x.StartingDirection == true).ToArray();

        if(startingDirs.Length > 0)
        {
            _mirror.localPosition = Vector3.zero;

            foreach(MoveDirection dir in startingDirs)
                _mirror.localPosition += dir.StartPoint;
        }
        else
        {
            _mirror.localPosition = _moveDirections[0].StartPoint;
        }

        _camera = Camera.main;
        _pointsParent.gameObject.SetActive(false);
        CreatePoints();
    }

    private void OnEnable()
    {
        if (_isMovable == false) return;

        InputEvents.SubscribeMouseDown(this);
        InputEvents.SubscribeMouseUp(this);
        InputEvents.SubscribeBegineDrag(this);
        InputEvents.SubscribeDrag(this);
        InputEvents.SubscribeEndDrag(this);

        CutscenesHandler.OnStart += OnCutsceneStart;
        CutscenesHandler.OnEnd += OnCutsceneEnd;
        CutscenesHandler.OnSkipped += OnCutsceneSkipped;

        //Tutorial
        Tutorial.OnMirrorDisable += OnMirrorDisable;
    }

    private void OnDisable()
    {
        if (_isMovable == false) return;

        InputEvents.UnsubscribeMouseDown(this);
        InputEvents.UnsubscribeMouseUp(this);
        InputEvents.UnsubscribeBegineDrag(this);
        InputEvents.UnsubscribeDrag(this);
        InputEvents.UnsubscribeEndDrag(this);

        CutscenesHandler.OnStart -= OnCutsceneStart;
        CutscenesHandler.OnEnd -= OnCutsceneEnd;
        CutscenesHandler.OnSkipped -= OnCutsceneSkipped;

        //Tutorial
        Tutorial.OnMirrorDisable -= OnMirrorDisable;
    }

    private void OnMirrorDisable(MirrorController mirror)
    {
        if (mirror != this) return;

        _isActive = false;
    }

    public void OnMouseDownInfo(InputInfo data)
    {
        if (GameManager.isPlaying == false || _isActive == false || _isMovable == false) return;

        Ray ray = _camera.ScreenPointToRay(data.currentPosition);

        if (Physics.Raycast(ray, out RaycastHit hit, 1000f) == true)
        {
            if (hit.collider.gameObject.layer != gameObject.layer)
                return;
            else if (hit.collider.attachedRigidbody != _rigidBody)
                return;
        }
        else
        {
            return;
        }

        if (_visibleCor != null)
            StopCoroutine(_visibleCor);

        _visibleCor = StartCoroutine(TogglePointVisibility(true));
    }

    public void OnMouseUpInfo(InputInfo data)
    {
        if (_isPointsVisible == false) return;

        if (_visibleCor != null)
        {
            StopCoroutine(_visibleCor);
        }

        _visibleCor = StartCoroutine(TogglePointVisibility(false));
    }

    public void OnBeginDrag(InputInfo data)
    {
        if (GameManager.isPlaying == false || _isActive == false || _isMovable == false) return;

        Ray ray = _camera.ScreenPointToRay(data.currentPosition);

        if (Physics.Raycast(ray, out RaycastHit hit, 1000f) == true)
        {
            if (hit.collider.gameObject.layer != gameObject.layer)
                return;
            else if (hit.collider.attachedRigidbody != _rigidBody)
                return;
        }
        else
        {
            return;
        }

        IsDragging = true;
        OnStartMove?.Invoke();
    }

    public void OnEndDrag(InputInfo data)
    {
        if (IsDragging == false) return;

        IsDragging = false;

        if (_moveCor != null)
            OnMove += EndDrag;
        else
            OnEndMove?.Invoke();
    }

    private void EndDrag()
    {
        OnMove -= EndDrag;
        OnEndMove?.Invoke();
    }

    public void OnDrag(InputInfo data)
    {
        if (_moveCor != null || IsDragging == false) return;

        MoveDirection md;
        Vector3[] dirs = new Vector3[_moveDirections.Length];
        int index = -1;
        float minDotX = float.MaxValue;
        float minDotY = 0;

        for (int i = 0; i < _moveDirections.Length; i++)
        {
            md = _moveDirections[i];
            Vector3 worldDir = _mirror.TransformDirection(md.Direction);
            Vector3 screenDir = _camera.WorldToScreenPoint(worldDir + _mirror.position)
                - _camera.WorldToScreenPoint(_mirror.position);
            screenDir.z = 0f;

            float dot = Vector3.Dot(screenDir, data.lastDaltaDrag);
            float dotX = Mathf.Abs(Vector3.Dot(new Vector3(screenDir.x, 0f), new Vector3(data.lastDaltaDrag.x, 0f)));
            float dotY = Mathf.Abs(Vector3.Dot(new Vector3(screenDir.y, 0f), new Vector3(data.lastDaltaDrag.y, 0f)));
            dirs[i] = md.Direction * Mathf.Sign(dot);

//#if UNITY_EDITOR
//            Debug.Log(md.Direction + " " + screenDir + " " + data.lastDaltaDrag + " " + dot + " " + dotX + " " + dotY);
//#endif
            if (Mathf.Abs(dot) > _minDragDelta)
            {
                if(CanMoveToDirection(dirs[i], md) == false)
                    continue;
                
                if(Mathf.Abs(dotX - dotY) < Mathf.Abs(minDotX - minDotY))
                {
                    minDotX = dotX;
                    minDotY = dotY;
                    index = i;
                }
            }
        }

        if(index >= 0)
        {
            if (_moveCor != null)
                StopCoroutine(_moveCor);

            _moveCor = StartCoroutine(Move(dirs[index], index));
        }
    }

    private bool CanMoveToDirection(Vector3 dirToMove, MoveDirection md)
    {
        Vector3 localPos = Vector3.Scale(Vector3Extensions.Abs(md.Direction), _mirror.localPosition);

        return (dirToMove == md.Direction && (md.EndPoint - localPos).normalized == dirToMove)
            || (dirToMove == (md.Direction * -1f) && (md.StartPoint - localPos).normalized == dirToMove);
    }

    //private bool AreABCOneTheSameLine(Vector3 A, Vector3 B, Vector3 C)
    //{
    //    return Vector3.Distance(A, C) + Vector3.Distance(B, C) == Vector3.Distance(A, B);
    //}

    private void CreatePoints()
    {
        int points;
        _directionsMaterials = new List<Material[]>(_moveDirections.Length);
        Vector3 point;
        Renderer pointRenderer;
        LineRenderer line;
        Material material;
        Vector3[] positions;
        _pointsHolders = new Transform[_moveDirections.Length];
        _pointsParent.localPosition = _pointsPositionOffset;

        for (int i = 0; i < _moveDirections.Length; i++)
        {
            if((Mathf.Abs(_moveDirections[i].End - _moveDirections[i].Start) / _moveDirections[i].Interval % 1) > 0f)
            {
                Debug.LogError($"The specified interval at the direction[{i}] does not correspond to the specified distance between the start and end");
            }

            _pointsHolders[i] = new GameObject("Points_" + i).transform;
            _pointsHolders[i].SetParent(_pointsParent, false);

            if (_moveDirections[i].StartingDirection == true)
            {
                _pointsHolders[i].localPosition = _mirror.localPosition;
            }
            else
            {
                if(i > 0)
                    _pointsHolders[i].localPosition = _mirror.localPosition + _moveDirections[i].StartPoint;
                else
                    _pointsHolders[i].localPosition = _mirror.localPosition;
            }

            _directionsMaterials.Add(new Material[2]);
            material = new Material(_pointPrefab.sharedMaterial);
            _moveDirections[i].Direction.Normalize();
            points = Mathf.FloorToInt(
                Vector3.Distance(
                    _moveDirections[i].StartPoint, _moveDirections[i].EndPoint
                    )
                / _moveDirections[i].Interval
                ) + 1;

            for(int j = 0; j < points; j++)
            {
                point = _moveDirections[i].Direction * _moveDirections[i].Interval * j;
                pointRenderer = Instantiate(_pointPrefab);
                pointRenderer.sharedMaterial = material;
                pointRenderer.transform.SetParent(_pointsHolders[i]);
                pointRenderer.transform.localPosition = point;
            }

            _directionsMaterials[i][0] = material;

            line = Instantiate(_linePrefab, _pointsParent.position, _pointsParent.rotation, _pointsHolders[i]);
            line.transform.localPosition = -_moveDirections[i].StartPoint;
            positions = new Vector3[] 
            {
                _moveDirections[i].StartPoint,
                _moveDirections[i].EndPoint
            };
            line.positionCount = 2;
            line.SetPositions(positions);
            material = new Material(_linePrefab.sharedMaterial);
            line.sharedMaterial = material;
            _directionsMaterials[i][1] = material;
        }

        _activePoint = Instantiate(_pointPrefab);
        _activePoint.transform.localScale = Vector3.one * _activePointScale;
        _activePoint.transform.SetParent(_pointsParent);
        _activePoint.transform.localPosition = _mirror.localPosition;// _moveDirections[0].StartPoint;
        _activePoint.material.SetColor(colorProperty, _activePointColor);
        _activePoint.material.renderQueue = 3001;
    }

    private IEnumerator TogglePointVisibility(bool visible)
    {
        if (_pointsParent.gameObject.activeSelf == false)
            _pointsParent.gameObject.SetActive(true);

        _isPointsVisible = visible;
        float t = 0f;
        Color color = _directionsMaterials[0][0].GetColor(colorProperty);
        Color color2 = _activePoint.sharedMaterial.GetColor(colorProperty);
        float startAlpha = color.a;
        float targetAlpha = visible == true ? 1f : 0f;
        float alpha;

        while (t < 1f)
        {
            t += Time.unscaledDeltaTime / _toggleVisibilityDuration;
            alpha = Mathf.Lerp(startAlpha, targetAlpha, t);
            color.a = alpha;
            color2.a = alpha;
            _activePoint.material.SetColor(colorProperty, color2);

            foreach(Material[] materials in _directionsMaterials)
                foreach(Material mat in materials)
                    mat.SetColor(colorProperty, color);

            yield return null;
        }

        _visibleCor = null;
    }

    private IEnumerator Move(Vector3 direction, int index)
    {
        float t = 0f;
        Vector3 startPos = _mirror.localPosition;
        Vector3 targetPos = Vector3Extensions.ClampByDirection(
            startPos + direction * _moveDirections[index].Interval,
            _moveDirections[index].StartPoint,
            _moveDirections[index].EndPoint,
            direction
        );
        
        Vector3 position;
        Vector3[] holdersStartPositions = new Vector3[_pointsHolders.Length];
        Vector3[] holdersTargetPositions = new Vector3[_pointsHolders.Length];

        for(int i = 0; i < _pointsHolders.Length; i++)
        {
            if (i == index) continue;

            holdersStartPositions[i] = _pointsHolders[i].localPosition;
            holdersTargetPositions[i] = Vector3Extensions.ClampByDirection(
                _pointsHolders[i].localPosition + direction * _moveDirections[index].Interval,
                _moveDirections[index].StartPoint,
                _moveDirections[index].EndPoint,
                direction
            );
            
        }

        //if (direction == md.Direction && (md.EndPoint - startPos).normalized != direction
        //    || direction != md.Direction && (md.StartPoint - startPos).normalized != direction)
        //    yield break;

        while (t < 1f)
        {
            t += Time.unscaledDeltaTime / _moveDuration;
            position = Vector3.Lerp(startPos, targetPos, t);
            _mirror.localPosition = position;
            _activePoint.transform.localPosition = position;

            for(int i = 0; i < _pointsHolders.Length; i++)
            {
                if (i == index) continue;

                _pointsHolders[i].localPosition = Vector3.Lerp(holdersStartPositions[i], holdersTargetPositions[i], t);
            }

            yield return null;
        }

        _mirror.localPosition = targetPos;
        _moveCor = null;
        OnMove?.Invoke();
    }

    public void OnCutsceneStart(Cutscene cutscene)
    {
        _isActive = false;
    }

    public void OnCutsceneEnd(Cutscene cutscene)
    {
        if (cutscene.Type == CutsceneType.Opening)
            _isActive = true;
    }

    public void OnCutsceneSkipped(Cutscene cutscene, Cutscene.Step step)
    {
        if (cutscene.Type == CutsceneType.Opening)
            _isActive = true;
    }
}