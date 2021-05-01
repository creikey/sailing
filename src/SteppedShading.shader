shader_type spatial;

const float PI = 3.14159;

uniform sampler2D tex;
uniform vec4 albedo: hint_color = vec4(1.0);
uniform bool use_texture = false;
uniform float period = 0.145;
const int bayer_n = 4;
const float bayer_r = 2.0;


/*const mat4 bayer_matrix_4x4 = mat4(
    vec4(    -0.5,       0,  -0.375,   0.125 ),
    vec4(    0.25,   -0.25,   0.375, - 0.125 ),
    vec4( -0.3125,  0.1875, -0.4375,  0.0625 ),
    vec4(  0.4375, -0.0625,  0.3125, -0.1875 )
);*/

float index(mat4 m, int x, int y) {
	vec4 subd;
  // No indexing on variables in Godot (as of 3.1)
  if (x == 0) {
    subd = m[0];
  } else if (x == 1) {
    subd = m[1];
  } else if (x == 2) {
    subd = m[2];
  } else if (x == 3) {
    subd = m[3];
  }

  if (y == 0) {
    return subd[0];
  } else if (y == 1) {
    return subd[1];
  } else if (y == 2) {
    return subd[2];
  } else if (y == 3) {
    return subd[3];
  }

}

float triangle(float n) {
	float a = 1.0;
	return ((2.0*a)/PI) * asin(sin( ((2.0*PI)/period) * n ));
}

void light() {
	//DIFFUSE_LIGHT = ;
	//DIFFUSE_LIGHT = ATTENUATION;
	// LIGHT - vector to the current light
	//float brightness = length(ATTENUATION);
	float brightness = dot(NORMAL, LIGHT) * (ATTENUATION.x+0.1);
	vec3 color_result;
	if(use_texture) {
		color_result = texture(tex, UV).rgb;
	} else {
		color_result = albedo.rgb;
	}
	color_result *= clamp(LIGHT_COLOR, vec3(0.0), vec3(1.0));
	/*if(brightness > 0.8) {
		DIFFUSE_LIGHT += color_result;
		return;
	}*/
	mat4 bayer_matrix_4x4 = mat4(
    vec4(    -0.5,       0,  -0.375,   0.125 ),
    vec4(    0.25,   -0.25,   0.375, - 0.125 ),
    vec4( -0.3125,  0.1875, -0.4375,  0.0625 ),
    vec4(  0.4375, -0.0625,  0.3125, -0.1875 )
);

	int sx = int(FRAGCOORD.x);
	int sy = int(FRAGCOORD.y);
    
    float bayer_value = index(bayer_matrix_4x4,sy % bayer_n,sx % bayer_n);
    float output_color = brightness + (bayer_r * bayer_value);
    // Color screen blue to white
    if (output_color < (2.0 / 2.0)) {
        color_result = vec3(0.0);
    }
    //*PIXEL_PTR((&screen), sx, sy, 1) = color_result;
	DIFFUSE_LIGHT += color_result;

	/*
	if(brightness > 0.6) {
		DIFFUSE_LIGHT = vec3(1.0);
	} else if(brightness > 0.5 && brightness < 0.6) {
		//DIFFUSE_LIGHT = vec3(1.0)*sin(LIGHT.z*1000.0);
		//DIFFUSE_LIGHT = vec3(triangle((CAMERA_MATRIX*vec4(NORMAL, 1.0)).x*1.0));
		//DIFFUSE_LIGHT = vec3(ATTENUATION.x*5.0 - 3.2);
		//DIFFUSE_LIGHT = vec3(triangle(ATTENUATION.z*5.0 - 3.2));
	} else {
		DIFFUSE_LIGHT = vec3(0.0);
	}*/
	/*for(float i = 0.0; i < 1.0; i += 0.1) {
		//DIFFUSE_LIGHT = vec3(mix(0.0, 1.0, 1.0 - pow(max(brightness - i, 0.0), 2.0)));
		if(brightness > i) {
			DIFFUSE_LIGHT = vec3(i);
		}
	}*/

}