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
  EVMath,
  EVAssimp;

type

  {
    This is the TEVWindow ancestor for the sample.
  }
  TEVWindow1 = class(TEVWindow)
    private
      mainshader,
      geoshader: TEVOpenGLShader;
      pmatrix,
      tmatrix,
      rmatrix,
      smatrix: TEVMatrix4f;
      mvpmatrix: TEVMatrix4f;
      nmmatrix: TEVMatrix3f;
      mvpuniform: TEVOpenGLUniform;
      nmuniform: TEVOpenGLUniform;
      testscene: TEVScene;
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
  tmatrix := TranslationMatrix4f(Width div 2,Height div 2,-128);
	rmatrix := IdentityMatrix4f;
	smatrix := IdentityMatrix4f;
end;

destructor TEVWindow1.Destroy;
begin
  nmuniform.Free;
  mvpuniform.Free;
  mainshader.Free;
  //geoshader.Free;
  testscene.Free;
  inherited;
end;

procedure TEVWindow1.HandleEvent(event: TSDL_Event);
begin
  case event.type_ of
    //Windowevent
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
    //keyboard handling
    SDL_KEYDOWN:
      case event.key.keysym.sym of
        TSDL_KeyCode(SDLK_R):
        begin
          tmatrix := TranslationMatrix4f(Width div 2,Height div 2,-64);
          rmatrix := IdentityMatrix4f;
          smatrix := IdentityMatrix4f;
          glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
				end;

        TSDL_KeyCode(SDLK_P):
          glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);

        TSDL_KeyCode(SDLK_L):
          glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

        TSDL_KeyCode(SDLK_F):
          glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

        TSDL_KeyCode(SDLK_Q):
          Log(IntToStr(EVApplication.FPS));
			end;
		//mouse handling
    SDL_MOUSEMOTION:
    begin
      if Boolean(event.motion.state and SDL_Button(SDL_BUTTON_LEFT)) then
      begin
        tmatrix *= TranslationMatrix4f(event.motion.xrel,event.motion.yrel,0);
			end;
      if Boolean(event.motion.state and SDL_Button(SDL_BUTTON_RIGHT)) then
      begin
        rmatrix *= RotationMatrix4fY((event.motion.xrel)/50*pi);
        rmatrix *= RotationMatrix4fX((event.motion.yrel)/50*pi);
			end;
		end;
    SDL_MOUSEWHEEL:
    begin
      if event.wheel.y = -1 then
        smatrix *= ScaleMatrix4f(0.2, 0.2, 1);
      if event.wheel.y = 1 then
        smatrix *= ScaleMatrix4f(2,2,1);
		end;
	end;
end;

procedure TEVWindow1.InitializeOpenGL;
begin
  glClearColor(0.0,0.0,0.1,0.0);

  EVApplication.MaxFPS := 60;

  //load assimp scene
  testscene := TEVScene.Create('../data/test.obj');

  //init shaders
  {mainshader.LoadFromFile(GL_VERTEX_SHADER, 'data/main.vs');
  mainshader.LoadFromFile(GL_FRAGMENT_SHADER, 'data/main.fs'); }
  mainshader := TEVOpenGLShader.Create;
  mainshader.LoadFromFile(GL_VERTEX_SHADER, '../data/main.vs');
  mainshader.LoadFromFile(GL_FRAGMENT_SHADER, '../data/main.fs');
  mainshader.Link;
                              {
  geoshader := TEVOpenGLShader.Create;
  geoshader.LoadFromFile(GL_VERTEX_SHADER, '../data/normalbug.vs');
  geoshader.LoadFromFile(GL_FRAGMENT_SHADER, '../data/normalbug.fs');
  geoshader.LoadFromFile(GL_GEOMETRY_SHADER, '../data/normalbug.gs');
  geoshader.Link;

  geoshader.Parameter(GL_GEOMETRY_INPUT_TYPE, GL_TRIANGLES);
  geoshader.Parameter(GL_GEOMETRY_OUTPUT_TYPE, GL_LINE_STRIP);
  geoshader.Parameter(GL_GEOMETRY_VERTICES_OUT, 6);       }

  //init uniform
  mvpuniform := TEVOpenGLUniform.Create('mvpMatrix', mainshader);
  //mvpuniform.AddLocation('mvpMatrix', geoshader);
  nmuniform := TEVOpenGLUniform.Create('nmMatrix', mainshader);
  //nmuniform.AddLocation('nmMatrix', geoshader);

  glEnable(GL_CULL_FACE);

  ResizeOpenGL;
end;

procedure TEVWindow1.ResizeOpenGL;
begin
  glViewport(0,0,Width,Height);
  pmatrix := OrthogonalProjectionMatrix4f(0,Width,Height,0,1,1024);
end;

procedure TEVWindow1.Render;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
                       {
  geoshader.Bind;

  mvpmatrix := pmatrix * tmatrix * smatrix * rmatrix;
  mvpuniform.uData := @mvpmatrix;

  nmmatrix := AffineMatrix4f(tmatrix * smatrix * rmatrix);
  InvertMatrix(nmmatrix);
  TransposeMatrix(nmmatrix);
  nmuniform.uData := @nmmatrix;

  testscene.Render;  }

  mainshader.Bind;

  mvpmatrix := tmatrix * smatrix * rmatrix;

  nmmatrix := AffineMatrix4f(mvpmatrix);
  InvertMatrix(nmmatrix);
  TransposeMatrix(nmmatrix);
  nmuniform.uData := @nmmatrix;

  mvpmatrix := pmatrix * mvpmatrix;
  mvpuniform.uData := @mvpmatrix;

  testscene.Render;

  EVApplication.BoundContext.SwapWindow;
end;

initialization
  EVWindow1Settings := EVWindowDefaultSettings;
  EVWindow1Settings.title := 'Simple Assimp Testcase';
  EVWindow1Settings.resizable := true;
  EVOpenGLContext1Settings := EVOpenGLContextDebugSettings;
  EVOpenGLContext1Settings.major_version := 3;
  EVOpenGLContext1Settings.minor_version := 0;
end.
