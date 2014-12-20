#version 130

uniform mat4 MVPMatrix;

in vec3 vertex;
in vec2 uv;
out vec2 uvcoord;

void main(void)
{
  gl_Position = MVPMatrix * vec4(vertex,1.0);
  uvcoord = uv;
}
