#ifndef _TRIPLANA_CUSTOM_FUNCTIONS_HLSL
#define _TRIPLANA_CUSTOM_FUNCTIONS_HLSL

void TriplanarBase_float(
    UnityTexture2D WallTexture,
    UnityTexture2D GroundTexture,
    float3 WorldPos,
    float3 WorldNormal,
    float Scale,
    float BlendFactor,
    out float4 OutColor
)
{ 
    float3 normal = pow(abs(WorldNormal), BlendFactor);
    normal = normal / (normal.x + normal.y + normal.z);

    float4 cGround = tex2D(GroundTexture, WorldPos.xz * Scale);
    float4 cWall1 = tex2D(WallTexture, WorldPos.xy * Scale);
    float4 cWall2 = tex2D(WallTexture, WorldPos.zy * Scale);

    OutColor = (cGround * normal.y) + (cWall1 * normal.z) + (cWall2 * normal.x);
}

void GetSnowMask_float(
    float3 WorldPos,
    float3 WorldNormal,
    float SnowHeight,
    float SnowFade,
    out float SnowMask
)
{
    float upwardFacing = saturate(WorldNormal.y);
    
    float heightMask = (WorldPos.y - SnowHeight) / max(SnowFade, 0.0001);
    
   SnowMask = saturate(heightMask) * pow(upwardFacing, 10.0);
}

void ApplySnowColor_float(
    float4 InputColor,          
    UnityTexture2D SnowTexture,
    float3 WorldPos,
    float Scale,
    float SnowMask,
    float Snow,
    out float4 OutColor
)
{
    float snowAmount = saturate(SnowMask * saturate(Snow));
    float4 cSnow = tex2D(SnowTexture, WorldPos.xz * Scale);
    OutColor = lerp(InputColor, cSnow, snowAmount);
}

void AddWater_float(
    float4 InputColor,
    float4 WaterColor,
    float3 WorldPos,
    float WaterLevel,
    float WaterEdge,
    out float4 OutColor
)
{
    float waterIntensity = (WaterLevel - WorldPos.y) / max(WaterEdge, 0.0001);
    waterIntensity = saturate(waterIntensity);

    float4 backgroundInWater = InputColor * (1.0 - (waterIntensity * 0.5));
    OutColor = backgroundInWater + (WaterColor * waterIntensity);
}

void FortniteBounce_float(
    float3 ObjectPosition,
    float Time,
    float ContactTime,
    float3 ContactPointLocal,
    float3 ContactDirectionLocal,
    float BounceFrequency,
    float BounceAmplitude,
    float MaxContactDistance,
    float MaxContactTime,
    out float3 OutObjectPosition
)
{
    float timeSinceContact = Time - ContactTime;
    if (timeSinceContact < 0.0 || timeSinceContact > MaxContactTime)
    {
        OutObjectPosition = ObjectPosition;
        return;
    }

    float bounce = sin(timeSinceContact * BounceFrequency) * BounceAmplitude;

    float dist = length(ObjectPosition - ContactPointLocal);
    float normalizedDist = dist / max(MaxContactDistance, 1e-5);

    float normalizedTime = timeSinceContact / max(MaxContactTime, 1e-5);

    float bounceAttenuation = 1.0;
    bounceAttenuation -= normalizedDist;
    bounceAttenuation -= normalizedTime;
    bounceAttenuation = saturate(bounceAttenuation);

    OutObjectPosition = ObjectPosition + (bounce * bounceAttenuation * ContactDirectionLocal);
}

#endif