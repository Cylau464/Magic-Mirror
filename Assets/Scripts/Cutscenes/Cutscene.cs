using UnityEngine;
using System;
using System.Linq;
using Cinemachine;

namespace Cutscenes
{
    [CreateAssetMenu(fileName = "Cutscene", menuName = "Add/Cutscenes/Cutscene")]
    public class Cutscene : ScriptableObject
    {
        public string Title;
        public CutsceneType Type;
        public StepSwitch StepSwitch;
        public Step[] Steps;
        public Step CurStep { get; private set; }

        public CinemachineTargetGroup CameraTargetGroup
        {
            set
            {
                foreach (Step step in Steps)
                    step.TargetGroup.Group = value;
            }
        }

        public CutsceneTrigger[] Triggers
        {
            set
            {
                value = value.OrderBy(x => x.StepIndex).ToArray();

                for(int i = 0; i < value.Length && i < Steps.Length; i++)
                    Steps[i].Action.Trigger = value[i];
            }
        }

        [NonSerialized] private int _curStepIndex;

        public Action<Step> OnNextStep;
        public Action OnEnd;
        public Action<Step> OnSkip;

        [Serializable]
        public class Step
        {
            public string Title;
            [HideInInspector] public int Index;
            [ConditionalHide(nameof(StepSwitch), true, enumIndex: (int)StepSwitch.Manual)]
            public NextStepBy NextStepBy;
            [ConditionalHide(ConditionalSourceField = nameof(StepSwitch),
                HideInInspector = true,
                EnumIndex1 = (int)StepSwitch.Auto,
                ConditionalSourceField2 = nameof(NextStepBy),
                EnumIndex2 = (int)NextStepBy.Duration,
                UseOrLogic = true)]
            public float Duration;

            [Header("Camera")]
            public Zoom Zoom;
            public CameraSwitcher CameraSwitcher;
            public TargetGroup TargetGroup;

            [Header("Character")]
            public CharacterAction Action;

        }

        [Serializable]
        public class Zoom
        {
            public bool Enabled;
            public int FOV;
            public AnimationCurve Curve;
            public float Duration;
            public bool PingPong;
        }

        [Serializable]
        public class CameraSwitcher
        {
            public bool Enabled;
            public string Tag;
        }

        [Serializable]
        public class TargetGroup
        {
            public bool Enabled;
            [HideInInspector] public CinemachineTargetGroup Group;
            public int TargetIndex;
        }

        [Serializable]
        public class CharacterAction
        {
            public CharacterActionType Type;
            public AnimationMode AnimationMode;
            [ConditionalHide(ConditionalSourceField = nameof(AnimationMode),
                HideInInspector = true,
                EnumIndex1 = ((int)AnimationMode.OnlyStart),
                ConditionalSourceField2 = nameof(AnimationMode),
                EnumIndex2 = ((int)AnimationMode.Both),
                UseOrLogic = true)]
            public string StartAnimationParameter;
            [ConditionalHide(ConditionalSourceField = nameof(AnimationMode),
                HideInInspector = true,
                EnumIndex1 = ((int)AnimationMode.OnlyTrigger),
                ConditionalSourceField2 = nameof(AnimationMode),
                EnumIndex2 = ((int)AnimationMode.Both),
                UseOrLogic = true)]
            public string AnimationByTriggerParameter;
            public ActionBy ActionBy;
            [ConditionalHide(nameof(ActionBy), true, enumIndex: ((int)ActionBy.Duration))]
            public float Duration;
            [ConditionalHide(nameof(ActionBy), true, enumIndex: ((int)ActionBy.Speed))]
            public float Speed;
            
            [HideInInspector] public CutsceneTrigger Trigger;
        }

        public void Start()
        {
            _curStepIndex = 0;
            CurStep = Steps[_curStepIndex];
            CurStep.Action.Trigger?.Activate();
            CurStep.Index = _curStepIndex;
            OnNextStep?.Invoke(CurStep);
        }

        public void NextStep()
        {
            CurStep.Action.Trigger?.Deactivate();

            if (++_curStepIndex < Steps.Length)
            {
                CurStep = Steps[_curStepIndex];
                CurStep.Action.Trigger?.Activate();
                CurStep.Index = _curStepIndex;
                OnNextStep?.Invoke(CurStep);
            }
            else
            {
                End();
            }
        }

        public void End()
        {
            OnEnd?.Invoke();
        }

        public void Skip()
        {
            OnSkip?.Invoke(Steps[Steps.Length - 1]);
        }
    }

    public enum AnimationMode
    {
        Off,
        OnlyStart,
        OnlyTrigger,
        Both
    }

    public enum CutsceneType
    {
        Opening,
        Ending
    }

    public enum StepSwitch
    {
        Auto,
        Manual
    }

    public enum CharacterActionType
    {
        None,
        Move,
        Rotate,
        Animation
    }

    public enum ActionBy
    {
        Duration,
        Speed
    }

    public enum NextStepBy
    {
        Animation,
        Duration,
        Trigger
    }
}