using engine.senser;
using UnityEngine;
using UnityEngine.UI;

namespace main.ui
{
    public class SettingsView : MonoBehaviour, IPanel
    {
        #region variables
        [Header("Info")]
        [SerializeField] private SenserInfo _audioInfo;
        [SerializeField] private SenserInfo _vibrationInfo;

        [Header("Buttons")]
        [SerializeField] private Button _openBtn;
        [SerializeField] private Button[] _closeBtns;

        [Header("Panels")]
        [SerializeField] private GameObject _settingPanel;

        [Header("Toggles")]
        [SerializeField] private Toggle _audioToggle;
        [SerializeField] private Toggle _vibrateToggle;

        [Header("Animators")]
        [SerializeField] private Animator _audioAnimator;
        [SerializeField] private Animator _vibrateAnimator;

        private int _enabledParamID;

        #endregion

        protected void Start()
        {
            _audioToggle.onValueChanged.AddListener(SwitchAudio);
            _vibrateToggle.onValueChanged.AddListener(SwitchVibrate);
            _openBtn.onClick.AddListener(Show);

            foreach (Button btn in _closeBtns)
                btn.onClick.AddListener(Hide);

            Hide();
            _enabledParamID = Animator.StringToHash("enabled");
        }

        #region panel

        public void Show()
        {
            _settingPanel.SetActive(true);

            SwitchAudio(_audioInfo.isEnable);
            SwitchVibrate(_vibrationInfo.isEnable);
        }

        public void Hide()
        {
            _settingPanel.SetActive(false);
        }

        #endregion

        #region switchs
        public void SwitchAudio(bool enable)
        {
            _audioInfo.SetEnable(enable);
            _audioAnimator.SetBool(_enabledParamID, enable);
        }

        public void SwitchVibrate(bool enable)
        {
            _vibrationInfo.SetEnable(enable);
            _vibrateAnimator.SetBool(_enabledParamID, enable);
        }
        #endregion
    }
}
