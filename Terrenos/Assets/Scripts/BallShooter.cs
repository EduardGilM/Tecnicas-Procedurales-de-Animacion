using UnityEngine;

public class BallShooter : MonoBehaviour
{
    public GameObject ballPrefab;
    public float shootForce = 20f;
    public float destroyDelay = 5f;

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            ShootBall();
        }
    }

    void ShootBall()
    {
        if (ballPrefab == null) return;

        GameObject ball = Instantiate(ballPrefab, transform.position, transform.rotation);
        Rigidbody rb = ball.GetComponent<Rigidbody>();

        if (rb == null)
        {
            rb = ball.AddComponent<Rigidbody>();
        }

        rb.mass = 10f;
        rb.drag = 0.5f;
        rb.angularDrag = 0.5f;
        rb.interpolation = RigidbodyInterpolation.Interpolate;
        rb.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
        rb.constraints = RigidbodyConstraints.None;

        StartCoroutine(ApplyForceNextFrame(rb, ball));
    }

    private System.Collections.IEnumerator ApplyForceNextFrame(Rigidbody rb, GameObject ball)
    {
        yield return new WaitForFixedUpdate();
        rb.AddForce(transform.forward * shootForce, ForceMode.Impulse);
        Destroy(ball, destroyDelay);
    }
}
