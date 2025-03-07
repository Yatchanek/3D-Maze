shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_back, shadows_disabled;

uniform sampler2D text : source_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec3 outline_color: source_color;
uniform float outline_width : hint_range(0.0, 200.0, 0.1) = 1.0;

void fragment() {
	vec4 main_texture = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec2 pixel_size = 1.0 / VIEWPORT_SIZE;
	ALBEDO = main_texture.rgb;
	ALPHA_SCISSOR_THRESHOLD = 0.999;

	for (int y = -1 * int(outline_width); y <= 1 * int(outline_width); y++) {
		for (int x = -1 * int(outline_width); x <= 1 * int(outline_width); x++) {
			vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x), float(y)) * pixel_size);

			if (tex.a == 0.0 && SCREEN_UV.x + float(x) * pixel_size.x < 1.0 && SCREEN_UV.x + float(x) * pixel_size.x > 0.0 &&
			SCREEN_UV.y + float(y) * pixel_size.y < 1.0 && SCREEN_UV.y + float(y) * pixel_size.y > 0.0) {
				//if (UV.x < 0.05 || UV.x > 0.95) {
					ALBEDO = outline_color.rgb;
				//}

			}
		}
	}

}