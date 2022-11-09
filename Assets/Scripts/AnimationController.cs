using Cutscenes;
using System;
using System.Linq;
using UnityEngine;

public class AnimationController : MonoBehaviour
{
    [SerializeField] private SkinnedMeshRenderer _renderer;
    public SkinnedMeshRenderer Renderer => _renderer;
    [SerializeField] private Animator _animator;
    [SerializeField] private float _idleTransitionTime = 20f;
    [SerializeField] private float _idleTransitionLimit = 2f;

    [Header("Pivot Points")]
    [SerializeField] private Pivot[] _pivots;
    public Pivot[] Pivots => _pivots;

    private InteractableObject _bindedObject;

    private float _idleTransition;

    private int _speedParamID;
    private int _idleTransitionParamID;
    private int _animSpeedParamID;
    private int _fallingParamID;

    public Action OnLanded;
    public Action OnActivateNextStep;

    public void Init()
    {
        _speedParamID = Animator.StringToHash("speed");
        _idleTransitionParamID = Animator.StringToHash("idle_transition");
        _animSpeedParamID = Animator.StringToHash("anim_speed");
        _fallingParamID = Animator.StringToHash("falling");
        _animator.SetFloat(_animSpeedParamID, 1f);
    }

    public void UpdateAnim(float speed, bool isFalling)
    {
        UpdateAnim(speed);
        _animator.SetBool(_fallingParamID, isFalling);
    }

    public void UpdateAnim(float speed)
    {
        _animator.SetFloat(_speedParamID, speed);
        _idleTransition += Time.deltaTime / _idleTransitionTime;
        _animator.SetFloat(_animSpeedParamID, Mathf.Max(1f, speed));
        _animator.SetFloat(_idleTransitionParamID, Mathf.Lerp(0f, _idleTransitionLimit, Mathf.PingPong(_idleTransition, 1f)));
    }

    private void Landed()
    {
        OnLanded?.Invoke();
    }

    public void SetAnimation(string name)
    {
        if (name.Length <= 0)
        {
            throw new ArgumentException("Try to set animation with empty string parameter");
        }
        else
        {
            bool hasParameter = false;

            foreach(AnimatorControllerParameter param in _animator.parameters)
            {
                if (param.name == name)
                {
                    hasParameter = true;
                    break;
                }
            }

            if(hasParameter == false)
                throw new NullReferenceException("Try to set not existing animator parameter");
        }

        _animator.SetTrigger(name);
    }

    private void ActivateCutsceneNextStep()
    {
        OnActivateNextStep?.Invoke();
    }

    private void PickUp()
    {
        if (_bindedObject != null)
        {
            _bindedObject.BindToObject(
                _pivots.FirstOrDefault(x => x.Type == _bindedObject.PivotPoint).Point);
        }
    }

    private void ThrowBoard()
    {
        _bindedObject.Activate();
    }

    public void BindObject(InteractableObject io)
    {
        _bindedObject = io;
    }
}

public enum PivotPoint { Board, Head, LeftHand, RightHand, Body }

[Serializable]
public class Pivot
{
    [SerializeField] private PivotPoint _type;
    [SerializeField] private Transform _point;
    public PivotPoint Type => _type;
    public Transform Point => _point;
}