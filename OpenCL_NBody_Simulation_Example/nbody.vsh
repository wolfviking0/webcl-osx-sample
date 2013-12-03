
/*
uniform sampler2D splatTexture;
uniform float pointSize;
void main()
{
    gl_Position = gl_Vertex;
    gl_PointSize = 0.05 * pointSize;
    //gl_FrontColor = gl_Color;
}
*/

#version 100

precision mediump float;

uniform float pointSize;

void main() {

	gl_PointSize = 0.05 * pointSize;
	gl_Position = gl_Vertex;
    gl_FrontColor = gl_Color;
}
