using UnityEngine;

public class FreeCameraController : MonoBehaviour
{
    [Header("Movement Settings")]
    public float lookSensitivity = 2f;
    public float panSpeed = 0.5f;
    public float zoomSpeed = 5f;

    private Vector3 lastMousePosition;

    void Update()
    {
        HandleRotation();
        HandlePanning();
        HandleZoom();
    }

    private void HandleRotation()
    {
        if (Input.GetMouseButton(1))
        {
            float mouseX = Input.GetAxis("Mouse X") * lookSensitivity;
            float mouseY = Input.GetAxis("Mouse Y") * lookSensitivity;

            transform.eulerAngles += new Vector3(-mouseY, mouseX, 0);
        }
    }

    private void HandlePanning()
    {
        if (Input.GetMouseButton(2))
        {
            float mouseX = Input.GetAxis("Mouse X") * panSpeed;
            float mouseY = Input.GetAxis("Mouse Y") * panSpeed;

            transform.Translate(-mouseX, -mouseY, 0);
        }
    }

    private void HandleZoom()
    {
        float scroll = Input.GetAxis("Mouse ScrollWheel");
        transform.Translate(0, 0, scroll * zoomSpeed, Space.Self);
    }
}
