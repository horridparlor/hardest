shader_type particles;

render_mode keep_data;

float hash(float x) {
    return fract(sin(x) * 43758.5453123);
}

void process() {
    float seed = TRANSFORM[3].x + TRANSFORM[3].y * 57.0;
    float random_flip = hash(seed);
    float t = floor(TIME);
    float flip = step(0.5, fract(random_flip + t * 0.1234)) * 2.0 - 1.0;
    CUSTOM.x = flip;
}