using UnityEngine;
using Pathfinding;
using Cutscenes;
using main.level;
using System.Linq;

public class PlayerController : MonoBehaviour, ICutsceneMonitoring
{
    [SerializeField] private AIPath _AIPath;
    [SerializeField] private AIDestinationSetter _setter;
    [SerializeField] private Transform _startPoint;
    [SerializeField] private Rigidbody _rigidBody;
    [SerializeField] private Collider _collider;

    [SerializeField] private float _fallingDuration = 1f;
    [SerializeField] private float _respawnHeight = 4f;
    
    [Header("Ground Check")]
    [SerializeField] private LayerMask _platformLayers;
    [SerializeField] private Vector3 _rayOffset = new Vector3(0f, 1f, 0f);
    [SerializeField] private float _rayLength = 2f;

    [Header("Cameras")]
    [SerializeField] private CameraInitializer[] _cameras;

    private MirrorController[] _mirrors;
    private AnimationController _animController;
    private Clothes[] _clothes;

    private bool _canMove;
    private bool canMove 
    {
        get { return _canMove && _AIPath.canMove && !_isFalling; }
        set { _canMove = value; }
    }
    private bool _isFalling;
    private bool _checkGround = true;

    private Cutscene _curCutscene;

    private void OnEnable()
    {
        CutscenesHandler.OnStart += OnCutsceneStart;
        CutscenesHandler.OnEnd += OnCutsceneEnd;
        CutscenesHandler.OnSkipped += OnCutsceneSkipped;
        CutscenesHandler.OnNextStep += OnNextStep;
    }

    private void OnDisable()
    {
        CutscenesHandler.OnStart -= OnCutsceneStart;
        CutscenesHandler.OnEnd -= OnCutsceneEnd;
        CutscenesHandler.OnSkipped -= OnCutsceneSkipped;
        CutscenesHandler.OnNextStep -= OnNextStep;
    }

    private void Start()
    {
        MovePoint.OnClick += MoveTo;
        GameManager.OnStartPlay += MoveEnable;
        transform.rotation = _startPoint.rotation;
        _AIPath.Teleport(_startPoint.position);
        MoveDisable();
    }

    private void OnDestroy()
    {
        MovePoint.OnClick -= MoveTo;
        GameManager.OnStartPlay -= MoveEnable;

        foreach (MirrorController mirror in _mirrors)
        {
            if (mirror == null) continue;

            mirror.OnStartMove -= MoveDisable;
            mirror.OnEndMove -= MoveEnable;
        }

        if(_animController != null)
        {
            _animController.OnLanded -= OnLanded;
            _animController.OnActivateNextStep -= OnActivateNextStep;
        }
    }

    private void FixedUpdate()
    {
        if (_canMove == true && _checkGround == true)
        {
            bool isGrounded = Physics.Raycast(transform.position + _rayOffset, Vector3.down, _rayLength, _platformLayers);

            if (isGrounded == false && _isFalling == false)
            {
                _isFalling = true;
                _collider.enabled = false;
                CancelInvoke(nameof(Respawn));
                Invoke(nameof(Respawn), _fallingDuration);
            }

            _animController.UpdateAnim(Mathf.Min(_AIPath.maxSpeed, _AIPath.velocity.magnitude), !isGrounded);
        }
        else
        {
            _animController.UpdateAnim(Mathf.Min(_AIPath.maxSpeed, _AIPath.velocity.magnitude));
        }
    }

    private void Respawn()
    {
        _collider.enabled = true;
        _rigidBody.velocity = Vector3.zero;
        transform.position = _startPoint.position + Vector3.up * _respawnHeight;
        transform.rotation = _startPoint.rotation;
        _AIPath.destination = _startPoint.position;
        _AIPath.SearchPath();
    }

    private void OnLanded()
    {
        _isFalling = false;
    }

    private void MoveTo(Vector3 position)
    {
        if (canMove == true)
        {
            GraphNode startNode = AstarPath.active.GetNearest(transform.position).node;
            GraphNode targetNode = AstarPath.active.GetNearest(position).node;

            if(PathUtilities.IsPathPossible(startNode, targetNode) == true)
                _AIPath.destination = (Vector3)targetNode.position;
            else
                _AIPath.destination = transform.position;

            _AIPath.SearchPath();
        }
    }

    public void Initialize(MirrorController[] mirrors, LevelInfoSO levelInfo)
    {
        _mirrors = mirrors;

        foreach (MirrorController mirror in _mirrors)
        {
            mirror.OnStartMove += MoveDisable;
            mirror.OnEndMove += MoveEnable;
        }

        _animController = Instantiate(levelInfo.Character, transform.position, transform.rotation, transform);
        _clothes = new Clothes[2];
        _clothes[0] = Instantiate(levelInfo.StartClothes, transform.position, transform.rotation, transform);
        _clothes[1] = Instantiate(levelInfo.ClothesToChange, transform.position, transform.rotation, transform);
        _clothes[0].Init(true, _animController.Renderer);
        _clothes[1].Init(false, _animController.Renderer);

        _animController.Init();
        _animController.OnLanded += OnLanded;
        _animController.OnActivateNextStep += OnActivateNextStep;

        foreach(CameraInitializer camera in _cameras)
        {
            Transform target = _animController.Pivots.First(x => x.Type == camera.PivotPoint)?.Point;

            if (target == null) continue;

            camera.SetTarget(target);
        }
    }

    public void ChangeClothes()
    {
        foreach (Clothes c in _clothes)
            c.Change();
    }

    private void MoveEnable()
    {
        canMove = true;
        _rigidBody.useGravity = true;
    }

    private void MoveDisable()
    {
        if (_isFalling == false)
        {
            _rigidBody.useGravity = false;
            _AIPath.destination = transform.position + transform.forward * .1f;
            _AIPath.SearchPath();
        }

        canMove = false;
    }

    public void CutsceneTriggerActivated()
    {
        if (_curCutscene.CurStep.Action.AnimationMode == AnimationMode.OnlyTrigger
            || _curCutscene.CurStep.Action.AnimationMode == AnimationMode.Both)
            _animController.SetAnimation(_curCutscene.CurStep.Action.AnimationByTriggerParameter);
    }

    public void OnCutsceneStart(Cutscene cutscene)
    {
        _curCutscene = cutscene;
        _checkGround = false;
    }

    public void OnCutsceneEnd(Cutscene cutscene)
    {
        _curCutscene = null;

        if (cutscene.Type == CutsceneType.Opening)
            _checkGround = true;
    }

    public void OnCutsceneSkipped(Cutscene cutscene, Cutscene.Step step)
    {
        _curCutscene = null;

        if (cutscene.Type == CutsceneType.Opening)
            _checkGround = true;

        OnNextStep(step);
    }

    public void OnNextStep(Cutscene.Step step)
    {
        if (step.Action.AnimationMode == AnimationMode.OnlyStart
            || step.Action.AnimationMode == AnimationMode.Both)
            _animController.SetAnimation(step.Action.StartAnimationParameter);

        switch (step.Action.Type)
        {
            case CharacterActionType.Move:
                _rigidBody.useGravity = false;
                MoveTo(step.Action.Trigger.transform.position);
                this.DoAfterNextFrameCoroutine(() =>
                {
                    if (step.Action.ActionBy == ActionBy.Duration)
                        _AIPath.maxSpeed = _AIPath.remainingDistance / step.Action.Duration;
                    else
                        _AIPath.maxSpeed = step.Action.Speed;
                });
                break;
            case CharacterActionType.Rotate:
                float duration;

                if(step.Action.ActionBy == ActionBy.Duration)
                {
                    duration = step.Action.Duration;
                }
                else
                {
                    duration = Vector3.SignedAngle(transform.position, step.Action.Trigger.transform.position, Vector3.up);
                    duration /= step.Action.Speed;
                }

                Vector3 forward = (step.Action.Trigger.transform.position - transform.position).normalized;
                forward.y = 0f;
                Quaternion targetRot = Quaternion.LookRotation(forward, Vector3.up);
                this.LerpCoroutine(
                    time: duration,
                    from: transform.rotation,
                    to: targetRot,
                    action: a => transform.rotation = a
                );
                break;
            case CharacterActionType.Animation:

                break;
            case CharacterActionType.None:
                _rigidBody.useGravity = true;
                break;
            default:
                return;
        }
    }

    private void OnActivateNextStep()
    {
        if (_curCutscene == null) return;

        if (_curCutscene.StepSwitch == StepSwitch.Auto
            || _curCutscene.CurStep.NextStepBy != NextStepBy.Animation)
            throw new System.Exception("Can't switch to next step of cutscene by animation method" +
                " because the cutsene settings imply auto switching of steps");

        _curCutscene.NextStep();
    }

    public void PickedUp(InteractableObject io)
    {
        _animController.BindObject(io);
    }

    public void FixOnObject(Transform parent)
    {
        transform.parent = parent;
        _rigidBody.isKinematic = true;

        this.MoveTo(Vector3.zero, .2f, space: Space.Self);
    }
}
