using UnityEngine;

public class Bounce : MonoBehaviour
{
    [SerializeField] private Material material;

    [Header("Bounce params")]

    [SerializeField] private float bounceAmplitude = 0.5f;
    [SerializeField] private float bounceFrequency = 20f;
    [SerializeField] private float maxContactDistance = 2f;
    [SerializeField] private float maxContactTime = 0.6f;

    private void OnCollisionEnter(Collision collision)
    {

        if (material == null)
            return;
        
        if (collision.contactCount < 1)
            return;

        Vector3 contactPoint = collision.contacts[0].point;
        Vector3 contactDirection = collision.contacts[0].normal;

        material.SetFloat("_ContactTime", Time.time);
        material.SetVector("_ContactPoint", contactPoint);

        material.SetVector("_ContactPointLocal", transform.InverseTransformPoint(contactPoint));
        material.SetVector("_ContactDirectionLocal", transform.InverseTransformDirection(contactDirection));

        material.SetFloat("_BounceFrequency", bounceFrequency);
        material.SetFloat("_BounceAmplitude", bounceAmplitude);
        material.SetFloat("_MaxContactDistance", maxContactDistance);
        material.SetFloat("_MaxContactTime", maxContactTime);

    }
}
