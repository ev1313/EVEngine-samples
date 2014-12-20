#version 330

in vec3 outNormal;

out vec4 outColor;

void main()
{
  //outColor = vec4(abs(outNormal.x), abs(outNormal.y), abs(outNormal.z), 0.0); 
  outColor = vec4(1.0, 0.0, 0.0, 0.0);
}
