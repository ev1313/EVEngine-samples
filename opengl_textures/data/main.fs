#version 130

uniform sampler2D tex0;

in vec2 uvcoord;
out vec4 color;

void main(void)
{
  //color = vec4 (0.2, 0.3, 0.7, 1.0);
  color = texture2D(tex0, uvcoord);
}
