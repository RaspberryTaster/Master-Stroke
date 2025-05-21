shader_type canvas_item;
render_mode unshaded;  // <-- Critical addition

uniform sampler2D image_a : source_color;
uniform sampler2D image_b : source_color;
uniform vec3 user_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 reference_color : source_color = vec3(0.0, 0.0, 1.0);
uniform vec3 correct_color : source_color = vec3(1.0, 0.0, 1.0);

void fragment() {
    vec4 color_a = texture(image_a, UV);
    vec4 color_b = texture(image_b, UV);

    // Improved line detection with alpha consideration
    bool is_drawn_a = color_a.a > 0.1 && length(color_a.rgb) < 1.732;
    bool is_drawn_b = color_b.a > 0.1 && length(color_b.rgb) < 1.732;

    vec3 result = vec3(1.0); // White background

    if (is_drawn_a && !is_drawn_b) {
        result = user_color;
    } else if (!is_drawn_a && is_drawn_b) {
        result = reference_color;
    } else if (is_drawn_a && is_drawn_b) {
        result = correct_color;
    }

    COLOR = vec4(result, 1.0);
}