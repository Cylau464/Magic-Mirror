using UnityEngine;

public static class Vector3Extensions
{
    public static Vector3 Abs(Vector3 vector)
    {
        vector.x = Mathf.Abs(vector.x);
        vector.y = Mathf.Abs(vector.y);
        vector.z = Mathf.Abs(vector.z);

        return vector;
    }

    public static Vector3 ClampByDirection(Vector3 vector, Vector3 min, Vector3 max, Vector3 direction)
    {
        vector.x = direction.x != 0f ? Mathf.Lerp(min.x, max.x, (vector.x - min.x) / (max.x - min.x)) : vector.x;
        vector.y = direction.y != 0f ? Mathf.Lerp(min.y, max.y, (vector.y - min.y) / (max.y - min.y)) : vector.y;
        vector.z = direction.z != 0f ? Mathf.Lerp(min.z, max.z, (vector.z - min.z) / (max.z - min.z)) : vector.z;

        return vector;
    }
}