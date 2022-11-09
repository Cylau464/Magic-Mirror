using System.Collections;
using UnityEngine;

public class MirrorCollision : MonoBehaviour
{
    [SerializeField] private LayerMask _collisionLayer;
    [SerializeField] private float _waveDuration = .5f;
    [SerializeField] private Renderer _renderer;
    [SerializeField] private MirrorController _controller;

    private float _progress;
    private MaterialPropertyBlock _propertyBlock;

    private const string progressProperty = "_Progress";

    private void Start()
    {
        _propertyBlock = new MaterialPropertyBlock();
    }

    //private void Update()
    //{
    //    _progress += Time.deltaTime / _waveDuration;
    //    _renderer.GetPropertyBlock(_propertyBlock);
    //    _propertyBlock.SetFloat(progressProperty, _progress);
    //    _renderer.SetPropertyBlock(_propertyBlock);

    //    if (_progress >= 1f)
    //        _progress = 0f;
    //}

    private void OnTriggerEnter(Collider other)
    {
        if(_controller.IsDragging == false && (1 << other.gameObject.layer & _collisionLayer) != 0)
        {
            if (other.TryGetComponent(out PlayerController player))
                player.ChangeClothes();
            else if(other.transform.parent.TryGetComponent(out player))
                player.ChangeClothes();

            StopAllCoroutines();
            StartCoroutine(Shockwave());
        }
    }

    private IEnumerator Shockwave()
    {
        float t = 0f;
        float startProgress = 0f;
        float targetProgress = 1f;

        while(t < 1f)
        {
            t += Time.deltaTime / _waveDuration;
            _renderer.GetPropertyBlock(_propertyBlock);
            _propertyBlock.SetFloat(progressProperty, Mathf.Lerp(startProgress, targetProgress, t));
            _renderer.SetPropertyBlock(_propertyBlock);

            yield return null;
        }
    }
}
