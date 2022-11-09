namespace InspectorProgramming
{
    public class ComponentDebugger : ComponentAction
    {
        public override void Invoke()
        {
            UnityEngine.Debug.Log("The function of game object " + gameObject.name + " is executed.");
        }
    }
}
