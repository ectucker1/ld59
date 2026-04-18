shader_type canvas_item;

const int EDGE_SAMPLE_RADIUS = 5;

uniform float air_luminance;
uniform float dirt_luminance;
uniform float hard_dirt_luminance;
uniform float stone_luminance;
uniform float hard_stone_luminance;

uniform sampler2D dirt_texture : repeat_enable;
uniform sampler2D hard_dirt_texture : repeat_enable;
uniform sampler2D stone_texture : repeat_enable;
uniform sampler2D hard_stone_texture : repeat_enable;

int determineMaterial(vec4 color) {
	if (abs(color.r - air_luminance) < 0.01) {
		return 0;
	} else if (abs(color.r - dirt_luminance) < 0.01) {
		return 1;
	} else if (abs(color.r - hard_dirt_luminance) < 0.01) {
		return 2;
	} else if (abs(color.r - stone_luminance) < 0.01) {
		return 3;
	} else if (abs(color.r - hard_stone_luminance) < 0.01) {
		return 4;
	} else {
		return 0;
	}
}

vec4 sampleMaterialTexture(int material, vec2 globalUV) {
	switch (material) {
		case 0:
			return vec4(0, 0, 0, 0);
		case 1:
			return texture(dirt_texture, globalUV / vec2(textureSize(dirt_texture, 0)));
		case 2:
			return texture(hard_dirt_texture, globalUV / vec2(textureSize(hard_dirt_texture, 0)));
		case 3:
			return texture(stone_texture, globalUV / vec2(textureSize(stone_texture, 0)));
		case 4:
			return texture(hard_stone_texture, globalUV / vec2(textureSize(hard_stone_texture, 0)));
	}
}

float getEdgeCoverage(sampler2D sourceTexture, vec2 texturePixelSize, vec2 globalUV, int material) {
	int numOthers = 0;
	int numSamples = 0;
	int radiusSquared = EDGE_SAMPLE_RADIUS * EDGE_SAMPLE_RADIUS;
	for (int y = -EDGE_SAMPLE_RADIUS; y <= EDGE_SAMPLE_RADIUS; y++) {
		for (int x = -EDGE_SAMPLE_RADIUS; x <= EDGE_SAMPLE_RADIUS; x++) {
			if (x * x + y * y > radiusSquared) {
				continue;
			}
			numSamples += 1;
			vec4 sample = texture(sourceTexture, (globalUV + vec2(float(x), float(y))) * texturePixelSize);
			if (determineMaterial(sample) != material) {
				numOthers += 1;
			}
		}
	}
	return float(numOthers) / float(numSamples);
}

void fragment() {
	vec4 sampledColor = texture(TEXTURE, UV);
	int material = determineMaterial(sampledColor);
	if (material == 0) {
		discard;
	}
	
	vec2 globalUV = UV * 1.0 / TEXTURE_PIXEL_SIZE;
	
	vec4 materialColor = sampleMaterialTexture(material, globalUV);
	
	float edgePercent = getEdgeCoverage(TEXTURE, TEXTURE_PIXEL_SIZE, globalUV, material);
	float interp = smoothstep(0.3, 1.0, 1.0 - edgePercent);
	COLOR = mix(materialColor, vec4(0, 0, 0, 1), 1.0 - interp);
}
