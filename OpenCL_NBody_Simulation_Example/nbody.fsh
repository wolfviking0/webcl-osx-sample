/*uniform sampler2D splatTexture;

void main()
{
    //gl_FragColor = texture2D(splatTexture, gl_TexCoord[0].st) * gl_Color;

    gl_FragColor = texture2D(splatTexture,vec);//texture2D(splatTexture, gl_PointCoord);
}
*/

#version 100

uniform sampler2D splatTexture;

void main()
{
    gl_FragColor = texture2D(splatTexture, gl_PointCoord) * gl_Color;
}
