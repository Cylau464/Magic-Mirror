using System.Reflection;
using UnityEngine;

public static class ComponentExtensions
{
    public static Component CopyComponent(this GameObject destination, Component original)
    {
        System.Type type = original.GetType();
        Component copy = destination.AddComponent(type);

        // Copied fields can be restricted with BindingFlags
        BindingFlags flags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Default | BindingFlags.DeclaredOnly;
        PropertyInfo[] properties = type.GetProperties(flags);

        foreach (PropertyInfo property in properties)
        {
            property.SetValue(copy, property.GetValue(original));
        }

        FieldInfo[] finfos = type.GetFields(flags);

        foreach (var finfo in finfos)
        {
            finfo.SetValue(copy, finfo.GetValue(original));
        }

        return copy;
    }
}
