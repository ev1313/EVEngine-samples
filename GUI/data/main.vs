#version 120

uniform mat4 mvpMatrix;

void main(void)
{
  gl_Position = mvpMatrix*gl_Vertex;
}
