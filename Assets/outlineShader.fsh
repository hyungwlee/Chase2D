//
//  outlineShader.fsh
//  Chase2D
//
//  Created by James Calder on 12/12/24.
//

void main() {
    vec2 texCoord = v_tex_coord;
    vec4 originalColor = texture2D(u_texture, texCoord);
    
    // If the pixel is fully transparent, check neighbors
    if (originalColor.a == 0.0) {
        float outlineWidth = 0.01; // Thickness of the outline
        vec4 outlineColor = vec4(0.0, 0.0, 0.0, 1.0); // Black color for the outline
        
        // Loop through nearby pixels
        for (float x = -outlineWidth; x <= outlineWidth; x += outlineWidth) {
            for (float y = -outlineWidth; y <= outlineWidth; y += outlineWidth) {
                vec4 neighborColor = texture2D(u_texture, texCoord + vec2(x, y));
                if (neighborColor.a > 0.0) {
                    gl_FragColor = outlineColor; // Draw the outline
                    return;
                }
            }
        }
    }
    
    // Otherwise, render the original pixel
    gl_FragColor = originalColor;
}
