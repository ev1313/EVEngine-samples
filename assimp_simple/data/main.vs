#version 130

uniform mat4 mvpMatrix;
uniform mat3 nmMatrix;

in vec3 inVertex; 
in vec3 inNormal;

out vec3 outNormal;

void main(void)
{
  outNormal = (nmMatrix * inNormal);
  gl_Position = mvpMatrix * vec4(inVertex, 1.0);
}
