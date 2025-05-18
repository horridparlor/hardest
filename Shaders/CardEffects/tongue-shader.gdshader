shader_type canvas_item;
uniform float time:hint_range(0,10);
uniform float glossiness:hint_range(0.0,1.0)=1.0;
uniform float shine_speed:hint_range(0.1,5.0)=2.7;
uniform float noise_strength:hint_range(0.0,1.0)=0.0;
uniform float highlight_amplitude:hint_range(0.0,1.0)=0.37;
uniform vec4 base_color:source_color=vec4(1.0,0.6,0.7,1.0);

void fragment(){
	vec2 uv=UV;
	float wave=sin((uv.y+TIME*shine_speed)*20.0)*0.01;
	uv.x+=wave;
	vec3 color=base_color.rgb;
	float swing_wave=sin(uv.y*10.0+TIME*shine_speed);
	float swing_offset=highlight_amplitude*swing_wave;
	float highlight=smoothstep(0.0,0.05,sin((uv.x+swing_offset)*10.0+TIME*shine_speed));
	highlight=pow(highlight,10.0);
	vec3 specular=vec3(1.0)*highlight*glossiness;
	float noise=fract(sin(dot(uv*100.0,vec2(12.9898,78.233)))*43758.5453);
	float noise_min=1.0-noise_strength;
	float noise_max=1.0+noise_strength;
	noise=mix(noise_min,noise_max,noise);
	color*=noise;
	color+=specular;
	COLOR=vec4(color,base_color.a);
}