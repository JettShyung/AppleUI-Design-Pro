#version 460 core
#include <flutter/runtime_effect.glsl>

// ImageFilter.shader reserves size (float 0,1) and sampler 0 for the engine.
uniform vec2 u_size;
uniform sampler2D u_texture;
uniform float u_radiusFraction;   // float index 2
uniform float u_bandFraction;     // float index 3
uniform float u_strengthFraction; // float index 4
out vec4 fragColor;

float roundedSDF(vec2 p, vec2 halfSize, float radius) {
    vec2 q = abs(p) - halfSize + radius;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

void main() {
    vec2 size = max(u_size, vec2(1.0));
    float extent = min(size.x, size.y);
    float radius = clamp(u_radiusFraction, 0.0, 0.5) * extent;
    float band = max(u_bandFraction * extent, 0.001);
    float strength = clamp(u_strengthFraction, 0.0, 0.1) * extent;
    vec2 p = FlutterFragCoord().xy - size * 0.5;
    float distance = roundedSDF(p, size * 0.5, radius);
    float weight = 1.0 - smoothstep(0.0, band, max(-distance, 0.0));
    vec2 gradient = vec2(
        roundedSDF(p + vec2(0.5, 0.0), size * 0.5, radius) -
        roundedSDF(p - vec2(0.5, 0.0), size * 0.5, radius),
        roundedSDF(p + vec2(0.0, 0.5), size * 0.5, radius) -
        roundedSDF(p - vec2(0.0, 0.5), size * 0.5, radius));
    vec2 normal = gradient / max(length(gradient), 0.0001);
    vec2 samplePosition = FlutterFragCoord().xy - normal * strength * weight;
    vec2 uv = clamp(samplePosition / size, 0.5 / size, 1.0 - 0.5 / size);
#ifdef IMPELLER_TARGET_OPENGLES
    uv.y = 1.0 - uv.y;
#endif
    // Preserve sampled premultiplied color/alpha. Compose tint and labels above it.
    fragColor = texture(u_texture, uv);
}
