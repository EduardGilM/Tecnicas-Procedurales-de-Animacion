using UnityEngine;

public class TerrainImpactController : MonoBehaviour
{
    [SerializeField] private Material terrainMaterial;
    [SerializeField] private float impactRadius = 2f;
    [SerializeField] private float bounceHeight = 0.5f;
    [SerializeField] private float waveSpeed = 5f;
    [SerializeField] private float decayTime = 2f;

    private static readonly int ImpactPositionID = Shader.PropertyToID("_ImpactPosition");
    private static readonly int ImpactTimeID = Shader.PropertyToID("_ImpactTime");
    private static readonly int ImpactRadiusID = Shader.PropertyToID("_ImpactRadius");
    private static readonly int BounceHeightID = Shader.PropertyToID("_BounceHeight");
    private static readonly int WaveSpeedID = Shader.PropertyToID("_WaveSpeed");
    private static readonly int DecayID = Shader.PropertyToID("_Decay");

    private void Start()
    {
        if (terrainMaterial == null)
        {
            Renderer renderer = GetComponent<Renderer>();
            if (renderer != null)
                terrainMaterial = renderer.sharedMaterial;
        }

        UpdateMaterialProperties();
        terrainMaterial.SetFloat(ImpactTimeID, -100f);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (terrainMaterial == null) return;

        ContactPoint contact = collision.GetContact(0);
        TriggerImpact(contact.point);
    }

    public void TriggerImpact(Vector3 position)
    {
        if (terrainMaterial == null) return;

        terrainMaterial.SetVector(ImpactPositionID, position);
        terrainMaterial.SetFloat(ImpactTimeID, Time.time);
        UpdateMaterialProperties();
    }

    private void UpdateMaterialProperties()
    {
        terrainMaterial.SetFloat(ImpactRadiusID, impactRadius);
        terrainMaterial.SetFloat(BounceHeightID, bounceHeight);
        terrainMaterial.SetFloat(WaveSpeedID, waveSpeed);
        terrainMaterial.SetFloat(DecayID, decayTime);
    }
}
