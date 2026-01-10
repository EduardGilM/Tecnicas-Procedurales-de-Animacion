using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.Threading.Tasks;
using System.IO;
using System.Net;

public class CreateTerrainBase : EditorWindow
{
    Vector2 scrollPos;
    string assetName = "TerrainTexture";

    Texture2D terrainTexture;
    Terrain terrain;

    float scaleFactor = 1.0f;
    int N = 5;
    float A = 1.0f;
    int seed = 0;
    float H = 1.0f;
    
    // Multifractal parameters
    int fbmOctaves = 8;
    float fbmLacunarity = 2.0f; // dF
    float fbmGain = 0.5f;       // dA
    float fbmAmplitude = 0.5f;  // A
    float fbmFrequency = 1.0f;  // F
    bool isHybrid = false;

    // Erosion parameters
    float erosionThreshold = 0.5f; // T
    float erosionCoefficient = 0.1f; // c
    int erosionIterations = 10;

    GameObject[] plantPrefabs;
    int plantCount = 100;
    float plantMinScale = 0.8f;
    float plantMaxScale = 1.2f;
    float plantMinTerrainHeight = 0.0f;

    GameObject[] rockPrefabs;
    int rockCount = 100;
    float rockMinScale = 0.8f;
    float rockMaxScale = 1.2f;
    float rockMinTerrainHeight = 0.0f;


    // Add menu item to show the window
    [MenuItem ("TPA/Create terrain base")]
    private static void ShowWindow() {
        var window = GetWindow<CreateTerrainBase>();
        window.titleContent = new GUIContent("Create Terrain Base");
        window.Show();
    }

    private void OnGUI() {
        // Scroll view for the GUI
        scrollPos = GUILayout.BeginScrollView(scrollPos, false, false);

        // GUI elements
        GUILayout.Label("1.Terrain texture configuration", EditorStyles.boldLabel);
        terrainTexture = EditorGUILayout.ObjectField("Texture", terrainTexture, typeof(Texture2D), false) as Texture2D;
        
        terrain  = EditorGUILayout.ObjectField("Terrain", terrain, typeof(Terrain), true) as Terrain;
        if (GUILayout.Button("Apply texture to terrain")) {
            
            if (terrainTexture == null) {
                Debug.LogError("Texture is null");
                return;
            }

            if (terrain == null) {
                Debug.LogError("Terrain is null");
                return;
            }
            
            Debug.Log("Applying texture to terrain...");
        }

        GUILayout.Label("2. Scale factor", EditorStyles.boldLabel);
        scaleFactor = EditorGUILayout.FloatField("Scale factor", scaleFactor);
        if (GUILayout.Button("Apply Scale Factor")){
            DivideHeights(terrain);
        }
        //EditorGUILayout.Space(); 
        GUILayout.Label("3. Terrain Configuration", EditorStyles.boldLabel);
        N = EditorGUILayout.IntSlider("Number of divisions (N)", N, 5, 10);
        A = EditorGUILayout.Slider("Amplitude (A)", A, 0f, 1f);
        seed = EditorGUILayout.IntField("Seed", seed);
        H = EditorGUILayout.Slider("Amplitude Falloff (H)", H, 0f, 1.5f);
        if (GUILayout.Button("Generate Middle Point Terrain")){
            GenerateTerrainMiddlePoint3D(terrain, N, A, seed, H);
        }
        if (GUILayout.Button("Generate Diamond Square")) {
            DiamondSquare(terrain, N, A, seed, H);
        }

        GUILayout.Label("4. Fractal Brownian Motion", EditorStyles.boldLabel);
        fbmAmplitude = EditorGUILayout.FloatField("FBM amplitude (A)", fbmAmplitude);
        fbmFrequency = EditorGUILayout.FloatField("FBM frequency (F)", fbmFrequency);
        fbmGain = EditorGUILayout.FloatField("FBM amplitude delta (gain)", fbmGain);
        fbmLacunarity = EditorGUILayout.FloatField("FBM frequency delta (lacunarity)", fbmLacunarity);
        fbmOctaves = EditorGUILayout.IntSlider("FBM octaves", fbmOctaves, 1, 10);
        seed = EditorGUILayout.IntField("Random seed", seed);
        isHybrid = EditorGUILayout.Toggle("Hybrid Multifractal", isHybrid);
        
        if (GUILayout.Button("Generate FBM")) {
            GenerateMultifractal(terrain, fbmOctaves, fbmLacunarity, fbmGain, fbmAmplitude, fbmFrequency, isHybrid);
        }

        GUILayout.Label("5. Thermal Erosion", EditorStyles.boldLabel);
        erosionThreshold = EditorGUILayout.Slider("Slope Threshold (T)", erosionThreshold, 0.0f, 0.01f);
        erosionCoefficient = EditorGUILayout.Slider("Erosion Coefficient (c)", erosionCoefficient, 0.0f, 1.0f);
        erosionIterations = EditorGUILayout.IntSlider("Erosion Iterations", erosionIterations, 1, 50);
        
        if (GUILayout.Button("Apply Thermal Erosion")) {
            ApplyThermalErosion(terrain, erosionThreshold, erosionCoefficient, erosionIterations);
        }

        GUILayout.Label("6. Plant Prefabs", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        plantPrefabs = EditorGUILayout.ObjectField("Prefab", plantPrefabs != null && plantPrefabs.Length > 0 ? plantPrefabs[0] : null, typeof(GameObject), false) is GameObject p && p != null
            ? new[] { p }
            : Array.Empty<GameObject>();
        EditorGUI.indentLevel--;

        plantCount = EditorGUILayout.IntField("Count", plantCount);
        plantMinScale = EditorGUILayout.FloatField("Min Scale Mult", plantMinScale);
        plantMaxScale = EditorGUILayout.FloatField("Max Scale Mult", plantMaxScale);
        plantMinTerrainHeight = EditorGUILayout.FloatField("Min Spawn Height (World Y)", plantMinTerrainHeight);
        
        var occupancy = new HashSet<Vector2Int>();

        if (GUILayout.Button("Plant Prefabs On Terrain"))
        {
            var cellSize = Mathf.Max(0.01f, plantMinScale);
            PlantPrefabsOnTerrain(terrain, plantPrefabs, plantCount, plantMinScale, plantMaxScale, plantMinTerrainHeight, seed, "_Plant", alignToNormal: false, minDistance: cellSize, occupiedCells: occupancy, cellSize: cellSize, undoLabel: "Plant Prefab");
        }

        GUILayout.Label("7. Rock Prefabs", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        rockPrefabs = EditorGUILayout.ObjectField("Prefab", rockPrefabs != null && rockPrefabs.Length > 0 ? rockPrefabs[0] : null, typeof(GameObject), false) is GameObject r && r != null
            ? new[] { r }
            : Array.Empty<GameObject>();
        EditorGUI.indentLevel--;

        rockCount = EditorGUILayout.IntField("Count", rockCount);
        rockMinScale = EditorGUILayout.FloatField("Min Scale Mult", rockMinScale);
        rockMaxScale = EditorGUILayout.FloatField("Max Scale Mult", rockMaxScale);
        rockMinTerrainHeight = EditorGUILayout.FloatField("Min Spawn Height (World Y)", rockMinTerrainHeight);

        if (GUILayout.Button("Place Rocks On Terrain"))
        {
            var cellSize = Mathf.Max(0.01f, rockMinScale);
            PlantPrefabsOnTerrain(terrain, rockPrefabs, rockCount, rockMinScale, rockMaxScale, rockMinTerrainHeight, seed, "_Rocks", alignToNormal: true, minDistance: cellSize, occupiedCells: occupancy, cellSize: cellSize, undoLabel: "Place Rock");
        }

        //End scroll view
        GUILayout.EndScrollView();
    }

    void GenerateTerrainMiddlePoint3D(Terrain terrain, int N, float A, int seed, float H)
    {
        int nVert = (int)Mathf.Pow(2, N) + 1;
        float[,] vertex = new float[nVert, nVert];

        UnityEngine.Random.InitState(seed);

        // Corners
        vertex[0, 0] = 0.5f + zValue(0, A, H);
        vertex[0, nVert - 1] = 0.5f + zValue(0, A, H);
        vertex[nVert - 1, 0] = 0.5f + zValue(0, A, H);
        vertex[nVert - 1, nVert - 1] = 0.5f + zValue(0, A, H);

        for (int n = 0; n < N; n++)
        {
            int d = (int)Mathf.Pow(2, N - n);
            int halfD = d / 2;

             // North and South
            for (int j = 0; j < nVert; j+=d)
            {
                for (int i = 0; i+d < nVert; i+=d)
                {
                    vertex[i + halfD, j] = (vertex[i, j] + vertex[i + d, j]) * 0.5f + zValue(n, A, H);
                }
            }

            // East and West
            for (int i = 0; i < nVert; i+=d)
            {
                for (int j = 0; j + d < nVert; j+=d)
                {
                    vertex[i, j + halfD] = (vertex[i, j] + vertex[i, j + d]) * 0.5f + zValue(n, A, H);
                }
            }

            // Centers
            for (int i = 0; i + d < nVert; i+=d)
            {
                for (int j = 0; j + d < nVert; j+=d)
                {
                    vertex[i + halfD, j + halfD] = (vertex[i + halfD, j] + vertex[i + halfD, j + d] + vertex[i, j + halfD] + vertex[i + d, j + halfD]) * 0.25f + zValue(n, A, H);
                }
            }
        }
        ApplyHeightMap(vertex, terrain);
    }

    void DiamondSquare(Terrain terrain, int N, float A, int seed, float H)
    {
        int nVert = (int)Mathf.Pow(2, N) + 1;
        float[,] vertices = new float[nVert, nVert];

        UnityEngine.Random.InitState(seed);

        // Initialize corners
        vertices[0, 0] = 0.5f + zValue(0, A, H);
        vertices[0, nVert - 1] = 0.5f + zValue(0, A, H);
        vertices[nVert - 1, 0] = 0.5f + zValue(0, A, H);
        vertices[nVert - 1, nVert - 1] = 0.5f + zValue(0, A, H);

        for (int n = 0; n < N; n++)
        {
            int d = (int)Mathf.Pow(2, N - n);
            int d2 = d / 2;

            // Diamond Step (Centers)
            for (int i = 0; i < nVert - 1; i += d)
            {
                for (int j = 0; j < nVert - 1; j += d)
                {
                    vertices[i + d2, j + d2] = (vertices[i, j] + vertices[i + d, j] + vertices[i, j + d] + vertices[i + d, j + d]) * 0.25f + zValue(n, A, H);
                }
            }

            // Square Step (Rows: North & South)
            for (int j = 0; j < nVert; j += d)
            {
                for (int i = 0; i + d < nVert; i += d)
                {
                    if (j == 0) // North edge
                    {
                        vertices[i + d2, j] = (vertices[i, j] + vertices[i + d, j] + vertices[i + d2, j + d2]) / 3.0f + zValue(n, A, H);
                    }
                    else if (j == nVert - 1) // South edge
                    {
                        vertices[i + d2, j] = (vertices[i, j] + vertices[i + d, j] + vertices[i + d2, j - d2]) / 3.0f + zValue(n, A, H);
                    }
                    else // Inner
                    {
                        vertices[i + d2, j] = (vertices[i, j] + vertices[i + d, j] + vertices[i + d2, j + d2] + vertices[i + d2, j - d2]) * 0.25f + zValue(n, A, H);
                    }
                }
            }

            // Square Step (Cols: West & East)
            for (int i = 0; i < nVert; i += d)
            {
                for (int j = 0; j + d < nVert; j += d)
                {
                    if (i == 0) // West edge
                    {
                        vertices[i, j + d2] = (vertices[i, j] + vertices[i, j + d] + vertices[i + d2, j + d2]) / 3.0f + zValue(n, A, H);
                    }
                    else if (i == nVert - 1) // East edge
                    {
                        vertices[i, j + d2] = (vertices[i, j] + vertices[i, j + d] + vertices[i - d2, j + d2]) / 3.0f + zValue(n, A, H);
                    }
                    else // Inner
                    {
                        vertices[i, j + d2] = (vertices[i, j] + vertices[i, j + d] + vertices[i + d2, j + d2] + vertices[i - d2, j + d2]) * 0.25f + zValue(n, A, H);
                    }
                }
            }
        }

        ApplyHeightMap(vertices, terrain);
    }

    void GenerateMultifractal(Terrain terrain, int octaves, float lacunarity, float gain, float amplitude, float frequency, bool isHybrid)
    {
        TerrainData data = terrain.terrainData;
        int w = data.heightmapResolution;
        float[,] heights = new float[w, w];

        UnityEngine.Random.InitState(seed);
        Vector2 offset = new Vector2(UnityEngine.Random.Range(0f, 1000f), UnityEngine.Random.Range(0f, 1000f));

        for (int i = 0; i < w; i++)
        {
            for (int j = 0; j < w; j++)
            {
                float x = (float)i / w;
                float z = (float)j / w;
                
                float heightVal = 0;

                if (isHybrid)
                {
                    // Hybrid Multifractal (User's simplified formula)
                    float currentA = amplitude;
                    float currentF = frequency;
                    
                    // Initial weight
                    float weight = currentA * Mathf.PerlinNoise((x * currentF) + offset.x, (z * currentF) + offset.y);
                    
                    for (int k = 0; k < octaves; k++)
                    {
                        float noiseVal = Mathf.PerlinNoise((x * currentF) + offset.x, (z * currentF) + offset.y);
                        heightVal += weight * currentA * noiseVal;
                        
                        currentF *= lacunarity;
                        currentA *= gain;
                        weight = heightVal;
                    }
                }
                else
                {
                    // Standard FBM (User's request)
                    float currentA = amplitude;
                    float currentF = frequency;
                    
                    for (int k = 0; k < octaves; k++)
                    {
                        heightVal += currentA * Mathf.PerlinNoise((x * currentF) + offset.x, (z * currentF) + offset.y);
                        currentF *= lacunarity;
                        currentA *= gain;
                    }
                }

                heights[i, j] = heightVal;
            }
        }
        
        NormalizeHeights(heights);
        ApplyHeightMap(heights, terrain);
    }

    void NormalizeHeights(float[,] heights)
    {
        int w = heights.GetLength(0);
        float min = float.MaxValue;
        float max = float.MinValue;
        
        for (int i = 0; i < w; i++)
            for (int j = 0; j < w; j++)
            {
                if (heights[i, j] < min) min = heights[i, j];
                if (heights[i, j] > max) max = heights[i, j];
            }
            
        float range = max - min;
        if (range < 0.0001f) range = 1.0f;
        
        for (int i = 0; i < w; i++)
            for (int j = 0; j < w; j++)
            {
                heights[i, j] = (heights[i, j] - min) / range;
            }
    }

    void ApplyHeightMap(float[,] h, Terrain terrain)
    {
        TerrainData data = terrain.terrainData;
        
        Vector3 tam = data.size;
        data.heightmapResolution = h.GetLength(0);
        data.SetHeights(0, 0, h);
        data.size = tam;
        terrain.terrainData = data;
    }

    float zValue(int n, float A, float H)
    {
        return UnityEngine.Random.Range(-1.0f, 1.0f) * A * Mathf.Pow(2, -n * H);
    }

    void DivideHeights(Terrain terrain)
    {
        // Get terrain data
        TerrainData data = terrain.terrainData;
        // Register data for undo option
        Undo.RegisterCompleteObjectUndo(data, "Divide Heights");
        // Get resolution
        int w = data.heightmapResolution;
        // Get height data
        float[,] rawHeights = data.GetHeights(0, 0, w, w);
        // Divide every height value
        for (int i = 0; i < w; i++)
            for (int j = 0; j < w; j++)
                rawHeights[i, j] = rawHeights[i, j] * scaleFactor;
        // Set the new height data
        Vector3 tam = data.size;
        data.SetHeights(0, 0, rawHeights);
        data.size = tam;
        terrain.terrainData = data;
    }

    void ApplyThermalErosion(Terrain terrain, float threshold, float coefficient, int iterations)
    {
        TerrainData data = terrain.terrainData;
        Undo.RegisterCompleteObjectUndo(data, "Thermal Erosion");
        
        int w = data.heightmapResolution;
        float[,] heights = data.GetHeights(0, 0, w, w);
        
        for (int iter = 0; iter < iterations; iter++)
        {
            float[,] newHeights = (float[,])heights.Clone();
            
            for (int i = 1; i < w - 1; i++)
            {
                for (int j = 1; j < w - 1; j++)
                {
                    float h = heights[i, j];
                    
                    float h1 = heights[i - 1, j];
                    float h2 = heights[i + 1, j];
                    float h3 = heights[i, j - 1];
                    float h4 = heights[i, j + 1];
                    
                    float d1 = h - h1;
                    float d2 = h - h2;
                    float d3 = h - h3;
                    float d4 = h - h4;
                    
                    float[] differences = { d1, d2, d3, d4 };
                    int[] neighborIndices = { 0, 1, 2, 3 };
                    
                    float dTotal = 0f;
                    for (int k = 0; k < 4; k++)
                    {
                        if (differences[k] > threshold)
                            dTotal += differences[k];
                    }
                    
                    if (dTotal > 0)
                    {
                        float dMax = 0f;
                        for (int k = 0; k < 4; k++)
                        {
                            if (differences[k] > dMax)
                                dMax = differences[k];
                        }
                        
                        float erosionAmount = coefficient * (dMax - threshold);
                        newHeights[i, j] -= erosionAmount;
                        
                        for (int k = 0; k < 4; k++)
                        {
                            if (differences[k] > threshold)
                            {
                                float materialTransfer = erosionAmount * (differences[k] / dTotal);
                                
                                if (k == 0) newHeights[i - 1, j] += materialTransfer;
                                else if (k == 1) newHeights[i + 1, j] += materialTransfer;
                                else if (k == 2) newHeights[i, j - 1] += materialTransfer;
                                else if (k == 3) newHeights[i, j + 1] += materialTransfer;
                            }
                        }
                    }
                }
            }
            
            heights = newHeights;
        }
        
        Vector3 tam = data.size;
        data.SetHeights(0, 0, heights);
        data.size = tam;
        terrain.terrainData = data;
        
        Debug.Log("Thermal erosion applied with " + iterations + " iterations");
    }

    void PlantPrefabsOnTerrain(
        Terrain terrain,
        GameObject[] prefabs,
        int count,
        float minScaleMult,
        float maxScaleMult,
        float minTerrainHeight,
        int seed,
        string parentName,
        bool alignToNormal,
        float minDistance,
        HashSet<Vector2Int> occupiedCells,
        float cellSize,
        string undoLabel
    )
    {
        if (terrain == null)
        {
            Debug.LogError("Terrain is null");
            return;
        }

        if (occupiedCells == null)
        {
            Debug.LogError("occupiedCells is null");
            return;
        }

        if (cellSize <= 0f)
        {
            Debug.LogError("cellSize must be > 0");
            return;
        }

        if (prefabs == null || prefabs.Length == 0)
        {
            Debug.LogError("Prefabs list is null/empty");
            return;
        }

        var validPrefabs = new List<GameObject>(prefabs.Length);
        for (int i = 0; i < prefabs.Length; i++)
        {
            if (prefabs[i] != null)
                validPrefabs.Add(prefabs[i]);
        }

        if (validPrefabs.Count == 0)
        {
            Debug.LogError("Prefabs list contains only null entries");
            return;
        }

        if (count <= 0)
            return;

        if (minScaleMult <= 0f || maxScaleMult <= 0f)
        {
            Debug.LogError("Scale multiplier must be > 0");
            return;
        }

        if (maxScaleMult < minScaleMult)
        {
            float tmp = minScaleMult;
            minScaleMult = maxScaleMult;
            maxScaleMult = tmp;
        }

        UnityEngine.Random.InitState(seed);
        if (minDistance < 0f)
            minDistance = 0f;

        TerrainData data = terrain.terrainData;
        Vector3 terrainPos = terrain.transform.position;
        Vector3 terrainSize = data.size;

        GameObject parent = GameObject.Find(parentName) ?? new GameObject(parentName);

        int planted = 0;
        int attempts = 0;
        int maxAttempts = count * 20;

        while (planted < count && attempts < maxAttempts)
        {
            attempts++;

            float x = UnityEngine.Random.Range(0f, terrainSize.x);
            float z = UnityEngine.Random.Range(0f, terrainSize.z);

            float y = terrain.SampleHeight(new Vector3(terrainPos.x + x, 0f, terrainPos.z + z)) + terrainPos.y;
            if (y < minTerrainHeight)
                continue;

            var cell = new Vector2Int(
                Mathf.FloorToInt((terrainPos.x + x) / cellSize),
                Mathf.FloorToInt((terrainPos.z + z) / cellSize)
            );

            if (occupiedCells.Contains(cell))
                continue;

            Vector3 groundPos = new Vector3(terrainPos.x + x, y, terrainPos.z + z);

            GameObject prefab = validPrefabs[UnityEngine.Random.Range(0, validPrefabs.Count)];

            GameObject go = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
            if (go == null)
                go = Instantiate(prefab);

            Undo.RegisterCreatedObjectUndo(go, undoLabel);

            Transform t = go.transform;
            Vector3 baseScale = t.localScale;

            t.position = groundPos;
            t.SetParent(parent.transform);

            if (alignToNormal)
            {
                var normal01 = data.GetInterpolatedNormal(x / terrainSize.x, z / terrainSize.z);
                var worldNormal = terrain.transform.TransformDirection(normal01);
                t.rotation = Quaternion.FromToRotation(Vector3.up, worldNormal) * t.rotation;

                var yaw = UnityEngine.Random.Range(0f, 360f);
                t.rotation = Quaternion.AngleAxis(yaw, worldNormal) * t.rotation;
            }

            float mult = UnityEngine.Random.Range(minScaleMult, maxScaleMult);
            t.localScale = baseScale * mult;

            Renderer[] renderers = go.GetComponentsInChildren<Renderer>();
            if (renderers.Length > 0)
            {
                Bounds b = renderers[0].bounds;
                for (int r = 1; r < renderers.Length; r++)
                    b.Encapsulate(renderers[r].bounds);

                float deltaY = groundPos.y - b.min.y;
                t.position = new Vector3(t.position.x, t.position.y + deltaY, t.position.z);
            }

            occupiedCells.Add(cell);
            planted++;
        }

        if (planted < count)
        {
            Debug.LogWarning($"Planted {planted}/{count}. Terrain height filter may be too strict (Min Spawn Height: {minTerrainHeight}), or max attempts reached ({maxAttempts}).");
        }
    }
 
 }

