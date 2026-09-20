// SDF-based sampling offset for SwiftUI distortionEffect on owned source content.
// Pass .boundingRect, radius/band/strength as fractions of the shorter dimension.
// The foreground label must be rendered separately, after the distorted source.
#include <metal_stdlib>
using namespace metal;

static float roundedSDF(float2 p, float2 halfSize, float radius) {
    float2 q = abs(p) - halfSize + radius;
    return length(max(q, 0.0f)) + min(max(q.x, q.y), 0.0f) - radius;
}

[[ stitchable ]] float2 appleUILens(float2 position, float4 bounds,
                                   float radiusFraction, float bandFraction,
                                   float strengthFraction) {
    float2 size = max(bounds.zw, float2(1.0f));
    float extent = min(size.x, size.y);
    float radius = clamp(radiusFraction, 0.0f, 0.5f) * extent;
    float band = max(bandFraction * extent, 0.001f);
    float strength = clamp(strengthFraction, 0.0f, 0.1f) * extent;
    float2 p = position - bounds.xy - size * 0.5f;
    float distance = roundedSDF(p, size * 0.5f, radius);
    float weight = 1.0f - smoothstep(0.0f, band, max(-distance, 0.0f));
    float2 gradient = float2(
        roundedSDF(p + float2(0.5f, 0), size * 0.5f, radius) -
        roundedSDF(p - float2(0.5f, 0), size * 0.5f, radius),
        roundedSDF(p + float2(0, 0.5f), size * 0.5f, radius) -
        roundedSDF(p - float2(0, 0.5f), size * 0.5f, radius));
    float2 normal = gradient / max(length(gradient), 0.0001f);
    return position - normal * strength * weight;
}
