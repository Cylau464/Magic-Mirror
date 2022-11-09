using System.Collections.Generic;
using UnityEngine;

public class Clothes : MonoBehaviour
{
    [SerializeField] private Renderer[] _renderers;
    [SerializeField] private float _dissolveTime = 1f;
    [SerializeField] private bool _changeOnce = true;

    private SkinnedMeshRenderer _characterRenderer;
    private bool _isActive;
    private bool _changed;

    private MaterialPropertyBlock _propertyBlock;
    private float _lastTargetDissolve;

    private const string dissolveValueProperty = "_DissolveValue";


    private void Start()
    {
        Dictionary<string, Transform> boneMap = new Dictionary<string, Transform>();

        foreach (Transform bone in _characterRenderer.bones)
            boneMap[bone.gameObject.name] = bone;

        foreach (SkinnedMeshRenderer renderer in _renderers)
        {
            Transform[] newBones = new Transform[renderer.bones.Length];

            for (int i = 0; i < renderer.bones.Length; ++i)
            {
                GameObject bone = renderer.bones[i].gameObject;

                if (!boneMap.TryGetValue(bone.name, out newBones[i]))
                {
                    Debug.Log("Unable to map bone \"" + bone.name + "\" to target skeleton.");
                    break;
                }
            }

            renderer.bones = newBones;
        }
    }

    public void Init(bool isActive, SkinnedMeshRenderer characterRenderer)
    {
        _characterRenderer = characterRenderer;
        _propertyBlock = new MaterialPropertyBlock();

        foreach(Renderer renderer in _renderers)
        {
            renderer.GetPropertyBlock(_propertyBlock);

            if (isActive == true)
            {
                _lastTargetDissolve = 0f;
                _propertyBlock.SetFloat(dissolveValueProperty, _lastTargetDissolve);
            }
            else
            {
                _lastTargetDissolve = 1f;
                _propertyBlock.SetFloat(dissolveValueProperty, _lastTargetDissolve);
            }

            renderer.SetPropertyBlock(_propertyBlock);
        }

        _isActive = isActive;
    }

    public void Change()
    {
        if (_changeOnce == true && _changed == true) return;

        _changed = true;
        
        _isActive = !_isActive;
        _lastTargetDissolve = Mathf.Abs(_lastTargetDissolve - 1f);
        StopAllCoroutines();

        foreach (Renderer renderer in _renderers)
        {
            renderer.GetPropertyBlock(_propertyBlock);
            float startDissolve = _propertyBlock.GetFloat(dissolveValueProperty);
            renderer.SetPropertyBlock(_propertyBlock);

            this.LerpCoroutine(
                time: _dissolveTime,
                from: startDissolve,
                to: _lastTargetDissolve,
                action: a =>
                {
                    renderer.GetPropertyBlock(_propertyBlock);
                    _propertyBlock.SetFloat(dissolveValueProperty, a);
                    renderer.SetPropertyBlock(_propertyBlock);
                }
            );
        }
    }
}
