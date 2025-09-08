shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded;

const float wavelength = 0.443;     // world units per cycle (mesh-relative)
instance uniform float amplitude = 0.4;     // wave height (in UV units vertically)
const float speed = 10.0;          // animation speed

instance uniform vec4 wave_color      : source_color = vec4(1.0, 1.0, 0.0, 1.0); // sine wave
instance uniform vec4 connector_color : source_color = vec4(1.0, 0.75, 0.0, 1.0); // vertical connectors
instance uniform vec4 axis_color      : source_color = vec4(1.0, 0.75, 0.0, 1.0); // horizontal axis

const float pixel_thickness = 0.5; // thickness in screen pixels
const int connector_n = 4;         // number of connectors per wavelength

varying vec3 vertex_local;

void vertex() {
    vertex_local = VERTEX;
}

void fragment() {
    // --- Sine wave ---
    float wave = 0.5 + amplitude * sin((vertex_local.x / wavelength) * 2.0 * PI + TIME * speed);

    float dist_curve = abs(UV.y - wave);
    float pixel_size_y = fwidth(UV.y);
    float uv_thickness = pixel_thickness * pixel_size_y;
    float mask_curve = 1.0 - step(uv_thickness, dist_curve);

    // --- Vertical connector lines ---
    float interval = wavelength / float(connector_n);
    float mod_x = abs(mod(vertex_local.x, interval));
    float dist_interval = min(mod_x, interval - mod_x);
    float pixel_size_x = fwidth(vertex_local.x);
    float x_thickness = pixel_thickness * pixel_size_x;
    float mask_xline = 1.0 - step(x_thickness, dist_interval);

    float y_min = min(0.5, wave);
    float y_max = max(0.5, wave);
    float in_band = step(y_min, UV.y) * step(UV.y, y_max);
    float mask_connectors = mask_xline * in_band;

    // --- Horizontal axis line at y = 0.5 ---
    float dist_axis = abs(UV.y - 0.5);
    float mask_axis = 1.0 - step(uv_thickness, dist_axis);

    // --- Base color: connector layer ---
    vec4 col = connector_color * mask_connectors;

    // wave overrides connectors
    col = mix(col, wave_color, mask_curve);

    // axis overrides wave
    col = mix(col, axis_color, mask_axis);

    ALBEDO = col.rgb;
    ALPHA  = col.a;
}
