using core;
using data;
using System;
using UnityEngine;

[CreateAssetMenu(fileName = "Tutorial Data", menuName = "Add/Tutorial Data", order = 3)]
public class TutorialData : ScriptableObject, IData
{
    [SerializeField] private Data _data;
    public Data Data => _data;

    public void Awake()
    {
        LoadData();
    }

    public string GetKey()
    {
        return "Tutorial." + GetInstanceID();
    }

    [NaughtyAttributes.Button("Reset Data")]
    public void ResetData()
    {
        for (int i = 0; i < _data.LevelCompleted.Length; i++)
            _data.LevelCompleted[i] = false;
    }

    private void LoadData()
    {
        ES3.Load(GetKey(), ObjectSaver.GetSavingPathFile<Data>(GetKey()), _data);
    }

    public void SaveData()
    {
        ES3.Save(GetKey(), _data, ObjectSaver.GetSavingPathFile<Data>(GetKey()));
    }
}

[Serializable]
public struct Data
{
    public bool[] LevelCompleted;
}