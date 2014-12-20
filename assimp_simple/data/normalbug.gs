#version 330

layout(triangles) in;
layout(line_strip, max_vertices = 2) out;
 
in vec3 outNormal[];

//uniform float nLength;
uniform mat4 mvpMatrix;
uniform mat3 nmMatrix;

void createNormal( vec3 V, vec3 N )
{
    gl_Position = mvpMatrix * vec4(V, 1.0f);
    EmitVertex();
 
    gl_Position = mvpMatrix * vec4(V + N * 1 /*nLength*/, 1.0f);
    EmitVertex();
 
    EndPrimitive();
}
 
void main()
{
    for ( int i = 0; i < 3; ++i )
    {
        createNormal(gl_in[i].gl_Position.xyz, outNormal[i]);
    }
}
