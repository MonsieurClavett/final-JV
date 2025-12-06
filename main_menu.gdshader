shader_type canvas_item;

// couleur et intensité du shine
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float shine_width = 0.2;   // largeur de la bande
uniform float shine_speed = 1.5;   // vitesse du shine
uniform float shine_strength = 0.8; // intensité

// angle du shine en radians (0 = horizontal, PI/4 = diagonale, PI/2 = vertical)
uniform float shine_angle = 0.785398; // ~ PI/4, diagonale

void fragment() {
    // couleur de base (respecte la font color / modulate)
    vec4 base = texture(TEXTURE, UV) * COLOR;

    // si le pixel est totalement transparent → on ne fait rien
    if (base.a <= 0.0) {
        COLOR = base;
    }

    // on recentre les UV autour de (0,0) pour mieux contrôler l'angle
    vec2 uv = UV - vec2(0.5);

    // rotation des UV selon shine_angle
    float s = sin(shine_angle);
    float c = cos(shine_angle);
    vec2 rotated = vec2(
        uv.x * c - uv.y * s,
        uv.x * s + uv.y * c
    );

    // ligne qui se déplace dans le temps (0..1 grâce à fract)
    float line = fract(rotated.x + TIME * shine_speed);

    // on crée une bande douce autour de 0.5
    float band = smoothstep(0.5 - shine_width, 0.5, line) *
                 (1.0 - smoothstep(0.5, 0.5 + shine_width, line));

    // contribution du shine
    vec3 shine = glow_color.rgb * band * shine_strength;

    vec3 final_rgb = base.rgb + shine;

    COLOR = vec4(final_rgb, base.a);
}
