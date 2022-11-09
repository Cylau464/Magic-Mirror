using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.PackageManager;
using UnityEditor.PackageManager.Requests;
using UnityEngine;

namespace AkilliMum.SRP.Mirror
{
    public static class Menu
    {
        static AddRequest Request;
        const string define = "_AKILLIMUM_WATER";

        [MenuItem("Akıllı Mum / Enable Water")]
        static void LoadWaterPackagesAndEnableWater()
        {
            // Add burst a package to the Project
            Request = Client.Add("com.unity.burst");
            EditorApplication.update += ProgressBurst;

        }

        static void ProgressBurst()
        {
            if (Request.IsCompleted)
            {
                if (Request.Status == StatusCode.Success)
                    Debug.Log("Installed: " + Request.Result.packageId);
                else if (Request.Status >= StatusCode.Failure)
                    Debug.Log(Request.Error.message);

                EditorApplication.update -= ProgressBurst;

                // Add mathematics a package to the Project
                Request = Client.Add("com.unity.mathematics");
                EditorApplication.update += ProgressMathematics;
            }
            else
            {
                Debug.Log("Installing Burst...");
            }
        }

        static void ProgressMathematics()
        {
            if (Request.IsCompleted)
            {
                if (Request.Status == StatusCode.Success)
                    Debug.Log("Installed: " + Request.Result.packageId);
                else if (Request.Status >= StatusCode.Failure)
                    Debug.Log(Request.Error.message);

                EditorApplication.update -= ProgressMathematics;

                EnableWater();
            }
            else
            {
                Debug.Log("Installing Mathematics...");
            }
        }

        static void EnableWater()
        {
            Debug.Log("Enabling Water...");

            // Get defines.
            BuildTargetGroup buildTargetGroup = EditorUserBuildSettings.selectedBuildTargetGroup;
            string defines = PlayerSettings.GetScriptingDefineSymbolsForGroup(buildTargetGroup);

            // Append only if not defined already.
            if (defines.Contains(define))
            {
                Debug.LogWarning("Selected build target (" + EditorUserBuildSettings.activeBuildTarget.ToString() + ") already contains <b>" + define + "</b> <i>Scripting Define Symbol</i>.");
                return;
            }

            // Append.
            PlayerSettings.SetScriptingDefineSymbolsForGroup(buildTargetGroup, (defines + ";" + define));
            Debug.LogWarning("<b>" + define + "</b> added to <i>Scripting Define Symbols</i> for selected build target (" + EditorUserBuildSettings.activeBuildTarget.ToString() + ").");

            Debug.Log("Enabled Water. Please open the water sample scene!");
        }
    }
}
