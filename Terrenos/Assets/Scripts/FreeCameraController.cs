using UnityEngine;

public class FreeCameraController : MonoBehaviour
{
    [Header("Movement Settings")]
    public float lookSensitivity = 2f;
    public float panSpeed = 0.5f;
    public float zoomSpeed = 5f;

    [Header("Material Property Control")]
    public Material material;

    public string snowInflateProperty = "SnowInflate";

    public float snowInflateSpeed = 0.25f;

    public bool clampSnowInflate = false;

    public float snowInflateMin = 0f;
    public float snowInflateMax = 1f;

    private int snowInflatePropertyId;
    private float snowInflateCurrent;

    private Vector3 lastMousePosition;

    private void Awake()
    {
        snowInflatePropertyId = Shader.PropertyToID(snowInflateProperty);

        if (material != null)
            snowInflateCurrent = material.GetFloat(snowInflatePropertyId);
    }

    void Update()
    {
        HandleRotation();
        HandlePanning();
        HandleZoom();
        HandleSnowInflate();
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

    private void HandleSnowInflate()
    {
        if (material == null)
            return;

        float delta = 0f;
        if (Input.GetKey(KeyCode.UpArrow))
            delta += snowInflateSpeed * Time.deltaTime;
        if (Input.GetKey(KeyCode.DownArrow))
            delta -= snowInflateSpeed * Time.deltaTime;

        if (Mathf.Approximately(delta, 0f))
            return;

        snowInflateCurrent += delta;
        if (clampSnowInflate)
            snowInflateCurrent = Mathf.Clamp(snowInflateCurrent, snowInflateMin, snowInflateMax);

        material.SetFloat(snowInflatePropertyId, snowInflateCurrent);
    }
}
