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
    // Solo permitimos nieve si la normal apunta hacia arriba (Y > 0)
    // Usamos un step o un saturate fuerte para eliminar las paredes
    float upwardFacing = saturate(WorldNormal.y);
    
    // Mascara de altura
    float heightMask = (WorldPos.y - SnowHeight) / max(SnowFade, 0.0001);
    
    // Combinamos: Solo si esta arriba de la altura Y mira hacia arriba
    // Elevamos la normal a una potencia fija para que el corte en las paredes sea limpio
    SnowMask = saturate(heightMask) * pow(upwardFacing, 10.0);
}

void ApplySnowColor_float(
    float4 InputColor,          
    UnityTexture2D SnowTexture,
    float3 WorldPos,
    float Scale, // Usamos la misma escala que el triplanar
    float SnowMask,
    out float4 OutColor
)
{
    float4 cSnow = tex2D(SnowTexture, WorldPos.xz * Scale);
    OutColor = lerp(InputColor, cSnow, SnowMask);
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

void ApplyImpactBounce_float(
    float3 WorldPos,
    float Time,
    float3 ImpactPosition,
    float ImpactTime,
    float ImpactRadius,
    float BounceHeight,
    float WaveSpeed,
    float Decay,
    out float3 OutPosition
)
{
    float timeSinceImpact = Time - ImpactTime;
    
    if (timeSinceImpact < 0.0 || timeSinceImpact > Decay)
    {
        OutPosition = WorldPos;
        return;
    }
    
    float dist = distance(WorldPos.xz, ImpactPosition.xz);
    float decayFactor = 1.0 - (timeSinceImpact / Decay);
    
    float waveRadius = timeSinceImpact * WaveSpeed;
    float waveDist = abs(dist - waveRadius);
    
    float waveEffect = 0.0;
    if (waveDist < ImpactRadius)
    {
        waveEffect = 1.0 - (waveDist / ImpactRadius);
        waveEffect *= sin(waveDist * 3.14159);
    }
    
    float centerEffect = 0.0;
    if (dist < ImpactRadius)
    {
        centerEffect = 1.0 - (dist / ImpactRadius);
        centerEffect *= sin(timeSinceImpact * 15.0) * exp(-timeSinceImpact * 3.0);
    }
    
    float bounce = (waveEffect + centerEffect) * BounceHeight * decayFactor;
    
    OutPosition = WorldPos;
    OutPosition.y += bounce;
}

#endif