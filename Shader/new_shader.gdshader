shader_type canvas_item;

uniform sampler2D image_a : source_color;
uniform sampler2D image_b : source_color;
uniform vec3 user_color :source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 reference_color :source_color = vec3(0.0, 0.0, 1.0);
uniform vec3 correct_color :source_color = vec3(1.0, 0.0, 1.0);

void fragment() {
    vec4 color_a = texture(image_a, UV);
    vec4 color_b = texture(image_b, UV);

    // Determine if the pixel is part of a drawn line (non-white)
    bool is_drawn_a = length(color_a.rgb) < 1.732; // White has length ~1.732 (sqrt(3))
    bool is_drawn_b = length(color_b.rgb) < 1.732;

    // Default to white background
    vec3 result = vec3(1.0);

    // Apply colors only to drawn areas
    if (is_drawn_a && !is_drawn_b) {
        result = user_color; // Red: User drew here, reference didn't
    } else if (!is_drawn_a && is_drawn_b) {
        result = reference_color; // Blue: Reference has a line, user missed
    } else if (is_drawn_a && is_drawn_b) {
        result = correct_color; // Purple: Both have lines
    }

    COLOR = vec4(result, 1.0);
}