using UnityEngine;
using input;

public class MovementHandler : MonoBehaviour, IMouseDown, IMouseUp
{
    [SerializeField] private LayerMask _platformsLayer;

    private MovePoint _movePoint;
    private Camera _camera;

    public static MovementHandler Instance;

    private void Awake()
    {
        if(Instance != null && Instance != this)
        {
            Destroy(this);
            return;
        }

        Instance = this;
    }

    private void Start()
    {
        _camera = Camera.main;
    }

    private void OnEnable()
    {
        InputEvents.SubscribeMouseDown(this);
        InputEvents.SubscribeMouseUp(this);
    }

    private void OnDisable()
    {
        InputEvents.UnsubscribeMouseDown(this);
        InputEvents.UnsubscribeMouseUp(this);
    }

    public void OnMouseDownInfo(InputInfo data)
    {
        Ray ray = _camera.ScreenPointToRay(data.currentPosition);

        if(Physics.Raycast(ray, out RaycastHit hit, 1000f, _platformsLayer) == true)
        {
            if (hit.collider.TryGetComponent(out MovePoint mp) == true)
                _movePoint = mp;
        }
    }

    public void OnMouseUpInfo(InputInfo data)
    {
        Ray ray = _camera.ScreenPointToRay(data.currentPosition);

        if (Physics.Raycast(ray, out RaycastHit hit, 1000f, _platformsLayer) == true)
        {
            if (hit.collider.TryGetComponent(out MovePoint mp) == true && _movePoint == mp)
                _movePoint.Click();
        }

        _movePoint = null;
    }
}
