using UnityEngine;

public class Bounce : MonoBehaviour
{
    [SerializeField] private Renderer meshRenderer;

    [Header("Bounce params")]
    [SerializeField] private float bounceAmplitude = 0.5f;
    [SerializeField] private float bounceFrequency = 20f;
    [SerializeField] private float maxContactDistance = 2f;
    [SerializeField] private float maxContactTime = 0.6f;

    private void Reset()
    {
        meshRenderer = GetComponent<Renderer>();
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (meshRenderer == null)
            return;

        if (collision.contactCount < 1)
            return;

        Vector3 contactPoint = collision.contacts[0].point;
        Vector3 contactDirection = collision.contacts[0].normal;

        Material mat = meshRenderer.material;

        mat.SetFloat("_ContactTime", Time.time);
        mat.SetVector("_ContactPoint", contactPoint);

        mat.SetVector("_ContactPointLocal", transform.InverseTransformPoint(contactPoint));
        mat.SetVector("_ContactDirectionLocal", transform.InverseTransformDirection(contactDirection));

        mat.SetFloat("_BounceAmplitude", bounceAmplitude);
        mat.SetFloat("_BounceFrequency", bounceFrequency);
        mat.SetFloat("_MaxContactDistance", maxContactDistance);
        mat.SetFloat("_MaxContactTime", maxContactTime);
    }
}
