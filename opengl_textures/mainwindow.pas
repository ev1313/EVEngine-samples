unit mainwindow;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  dglOpenGL,
  SDL2,
  EVMain,
  EVOpenGLUtils,
  EVMath,
  EVTextures,
  SDL2_net;

type

  TEVWindow1 = class(TEVWindow)
    private
      testvbo: TEVOpenGLBufferObject;
      testvao: TEVOpenGLVertexArrayObject;
      testtex: TEVTexture2D;
      testshader: TEVOpenGLShader;
      mvpuniform,
      texuniform: TEVOpenGLUniform;
      mvpmatrix: TEVMatrix4f;
    protected

    public
      constructor Create(settings: TEVWindowSettings); override;
      destructor Destroy; override;
      procedure HandleEvent(event: TSDL_Event); override;
      procedure InitializeOpenGL;
      procedure ResizeOpenGL;
      procedure Render;
  end;

var
  EVWindow1: TEVWindow1;
  EVWindow1Settings: TEVWindowSettings;
  EVOpenGLContext1Settings: TEVOpenGLContextSettings;

implementation

constructor TEVWindow1.Create(settings: TEVWindowSettings);
begin
  inherited;
end;

destructor TEVWindow1.Destroy;
begin
  testvbo.Free;
  testvao.Free;
  testtex.Free;
  testshader.Free;
  mvpuniform.Free;
  texuniform.Free;
  inherited;
end;

procedure TEVWindow1.HandleEvent(event: TSDL_Event);
begin
  case event.window.event of
    SDL_WINDOWEVENT_EV_INITIALIZED_CONTEXT:
    begin
      InitializeOpenGL;
    end;
    SDL_WINDOWEVENT_EV_MAINLOOP:
    begin
      if InitializedOpenGL then
        Render;
    end;
    SDL_WINDOWEVENT_RESIZED:
      ResizeOpenGL;
  else
    inherited;
  end;
end;

procedure TEVWindow1.InitializeOpenGL;
var
  datavbo: array[0..19] of GLFloat;
begin
  //init vbo&data
  datavbo[00] := 100.0; datavbo[01] := 100.0; datavbo[02] :=-2.0;
  datavbo[03] := 164.0; datavbo[04] := 100.0; datavbo[05] :=-2.0;
  datavbo[06] := 164.0; datavbo[07] := 164.0; datavbo[08] :=-2.0;
  datavbo[09] := 100.0; datavbo[10] := 164.0; datavbo[11] :=-2.0;
  datavbo[12] :=   0.0; datavbo[13] :=   0.0;
  datavbo[14] :=   1.0; datavbo[15] :=   0.0;
  datavbo[16] :=   1.0; datavbo[17] :=   1.0;
  datavbo[18] :=   0.0; datavbo[19] :=   1.0;

  testvbo := TEVOpenGLBufferObject.Create(GL_ARRAY_BUFFER);
  testvbo.Fill(GL_STATIC_DRAW, SizeOf(datavbo), @datavbo);

  //init vao
  testvao := TEVOpenGLVertexArrayObject.Create;
  testvao.Fill(0, 3, GL_FLOAT, FALSE, 0, nil);
  testvao.Fill(1, 2, GL_FLOAT, FALSE, 0, Pointer(3*4*SizeOf(GLFloat)));

  //load texture
  testtex := TEVTexture2D.Create('data/texture1.png');
  testtex.GenTexture;
  testtex.Bind;

  //init mainshaderprogram
  testshader := TEVOpenGLShader.Create;
  testshader.LoadFromFile(GL_VERTEX_SHADER, 'data/main.vs');
  testshader.LoadFromFile(GL_FRAGMENT_SHADER, 'data/main.fs');
  testshader.Link;

  //init uniforms
  mvpuniform := TEVOpenGLUniform.Create;
  mvpuniform.AddLocation('MVPMatrix',testshader);

  texuniform := TEVOpenGLUniform.Create;
  texuniform.AddLocation('tex0',testshader);

  ResizeOpenGL;
end;

procedure TEVWindow1.ResizeOpenGL;
begin
  glViewport(0,0,Width,Height);
  mvpmatrix := OrthogonalProjectionMatrix4f(0,Width,0,Height,1,128);
end;

procedure TEVWindow1.Render;
var
  sampler: Integer;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  testtex.Bind;
  testshader.Bind;
  mvpuniform.uData := @mvpmatrix;
  sampler := 0;
  texuniform.uData := @sampler;
  testvao.Bind;
  glDrawArrays(GL_QUADS, 0, 4);
  EVApplication.BoundContext.SwapWindow;
end;

initialization
  EVWindow1Settings := EVWindowDefaultSettings;
  EVWindow1Settings.resizable := true;
  EVOpenGLContext1Settings := EVOpenGLContextDebugSettings;
  EVOpenGLContext1Settings.major_version := 3;
  EVOpenGLContext1Settings.minor_version := 0;
end.
