#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 overlayColor;
    vec4 focusColor;
    vec4 dimensions;
    vec4 cornerRadii;
    vec4 rippleData;
    vec4 opacityData;
};

float roundedBoxDistance(vec2 pixel, vec2 size, vec4 radii)
{
    vec2 centered = pixel - size * 0.5;
    float radius;
    if (centered.x < 0.0) {
        radius = centered.y < 0.0 ? radii.x : radii.w;
    } else {
        radius = centered.y < 0.0 ? radii.y : radii.z;
    }
    radius = clamp(radius, 0.0, min(size.x, size.y) * 0.5);
    vec2 edgeDistance = abs(centered) - size * 0.5 + vec2(radius);
    return min(max(edgeDistance.x, edgeDistance.y), 0.0)
        + length(max(edgeDistance, vec2(0.0))) - radius;
}

float shapeCoverage(vec2 pixel, vec2 size, vec4 radii, float feather)
{
    float distanceToEdge = roundedBoxDistance(pixel, size, radii);
    return 1.0 - smoothstep(-feather, feather, distanceToEdge);
}

void main()
{
    vec2 size = max(dimensions.xy, vec2(1.0));
    float maskFeather = max(dimensions.z, 0.001);
    vec2 pixel = qt_TexCoord0 * size;
    float outerCoverage = shapeCoverage(pixel, size, cornerRadii, maskFeather);

    float baseOpacity = clamp(opacityData.x, 0.0, 1.0);
    float rippleOpacity = clamp(opacityData.y, 0.0, 1.0);
    float rippleRadius = max(rippleData.z, 0.0);
    float rippleFeather = max(rippleData.w, 0.001);
    float rippleDistance = distance(pixel, rippleData.xy);
    float rippleCoverage = 1.0 - smoothstep(rippleRadius - rippleFeather,
                                           rippleRadius + rippleFeather,
                                           rippleDistance);
    float overlayCoverage = 1.0 - (1.0 - baseOpacity)
                                  * (1.0 - rippleOpacity * rippleCoverage);
    float overlayAlpha = overlayColor.a * overlayCoverage * outerCoverage;

    float focusOpacity = clamp(opacityData.z, 0.0, 1.0);
    float focusWidth = max(opacityData.w, 0.0);
    float innerCoverage = 0.0;
    if (focusWidth > 0.0 && size.x > focusWidth * 2.0 && size.y > focusWidth * 2.0) {
        vec2 innerSize = size - vec2(focusWidth * 2.0);
        vec4 innerRadii = max(cornerRadii - vec4(focusWidth), vec4(0.0));
        innerCoverage = shapeCoverage(pixel - vec2(focusWidth), innerSize,
                                      innerRadii, maskFeather);
    }
    float focusCoverage = max(outerCoverage - innerCoverage, 0.0);
    float focusAlpha = focusColor.a * focusOpacity * focusCoverage;

    vec3 premultiplied = overlayColor.rgb * overlayAlpha * (1.0 - focusAlpha)
                       + focusColor.rgb * focusAlpha;
    float alpha = overlayAlpha * (1.0 - focusAlpha) + focusAlpha;
    fragColor = vec4(premultiplied, alpha) * qt_Opacity;
}
