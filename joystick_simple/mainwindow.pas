unit mainwindow;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  dglOpenGL,
  SDL2,
  EVLog,
  EVMain,
  EVOpenGLUtils,
  EVMath;

type

  {
    This is the TEVWindow ancestor for the sample.
  }
  TEVWindow1 = class(TEVWindow)
    private
      testvbo: TEVOpenGLBufferObject;
      testvao: TEVOpenGLVertexArrayObject;
      testshader: TEVOpenGLShader;
      mvpmatrix: TEVMatrix4f;
      mvpuniform: TEVOpenGLUniform;
      clr: TEVColor3f;
      clruniform: TEVOpenGLUniform;
      joystick: PSDL_Joystick;
    protected

    public
      constructor Create(settings: TEVWindowSettings); override;
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

procedure TEVWindow1.HandleEvent(event: TSDL_Event);
begin
  case event.type_ of
    SDL_CONTROLLERBUTTONUP:
    begin
      clr.R := 0.0;
    end;
    SDL_CONTROLLERBUTTONDOWN:
    begin
      clr.R := 1.0;
    end;
    SDL_CONTROLLERDEVICEADDED:
    begin
      clr.G := 1.0;
    end;
    SDL_CONTROLLERDEVICEREMOVED:
    begin
      clr.G := 0.0;
    end;

    SDL_WINDOWEVENT:
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
  else
    inherited;
  end;
end;

procedure TEVWindow1.InitializeOpenGL;
var
  datavbo: array[0..11] of GLFloat;
begin
  //init vbo&data
  datavbo[00] := 0.0; datavbo[01] := 0.0; datavbo[02] :=-2.0;
  datavbo[03] := 200.0; datavbo[04] := 0.0; datavbo[05] :=-2.0;
  datavbo[06] := 200.0; datavbo[07] := 200.0; datavbo[08] :=-2.0;
  datavbo[09] := 0.0; datavbo[10] := 200.0; datavbo[11] :=-2.0;

  testvbo := TEVOpenGLBufferObject.Create(GL_ARRAY_BUFFER);
  testvbo.Fill(GL_STATIC_DRAW, SizeOf(datavbo), @datavbo);

  //init vao
  testvao := TEVOpenGLVertexArrayObject.Create;
  testvao.Fill(0, 3, GL_FLOAT, FALSE, 0, nil);

  clr.R := 0.5;
  clr.G := 0.5;
  clr.B := 0.5;

  //init mainshaderprogram
  testshader := TEVOpenGLShader.Create;
  testshader.LoadFromFile(GL_VERTEX_SHADER, 'data/main.vs');
  testshader.LoadFromFile(GL_FRAGMENT_SHADER, 'data/main.fs');
  testshader.Link;

  //init mvp uniform
  mvpuniform := TEVOpenGLUniform.Create;
  mvpuniform.AddLocation('mvpMatrix',testshader);
  mvpuniform.uTranspose:=true;

  //init color uniform
  clruniform := TEVOpenGLUniform.Create;
  clruniform.AddLocation('clr',testshader);

  ResizeOpenGL;
end;

procedure TEVWindow1.ResizeOpenGL;
begin
  glViewport(0,0,Width,Height);
  mvpmatrix := OrthogonalProjectionMatrix4f(0,Width,0,Height,1,128);
end;

procedure TEVWindow1.Render;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  testshader.Bind;

  if SDL_NumJoysticks < 1 then
  begin
    WarnLog('Couldn''t find Joystick.');
    clr.R := 0.5;
    clr.G := 0.5;
    clr.B := 0.5;
  end
  else
  begin
    clr.B := 1.0;
    Log('Opened Joystick.');
    joystick := SDL_JoystickOpen(0);
  end;

  clruniform.uData := @clr;
  mvpuniform.uData := @mvpmatrix;
  testvao.Bind;
  glDrawArrays(GL_QUADS, 0, 4);
  EVApplication.BoundContext.SwapWindow;
end;

initialization
  EVWindow1Settings := EVWindowDefaultSettings;
  EVWindow1Settings.resizable := true;
  EVOpenGLContext1Settings := EVOpenGLContextDefaultSettings;
  EVOpenGLContext1Settings.major_version := 2;
  EVOpenGLContext1Settings.minor_version := 0;
end.
