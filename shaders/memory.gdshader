shader_type canvas_item;

// 0.0 = 原色不变，1.0 = 完全灰度
uniform float desaturate_factor : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    // 先算出灰度值
    float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    // 用 mix 在原色和灰度之间插值
    col.rgb = mix(col.rgb, vec3(grey), desaturate_factor);
    COLOR = col * COLOR;
}
