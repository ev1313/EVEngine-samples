{
  A simple sample demonstrating how to use textures.
}
program opengl_textures;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
    {$IFDEF UseCThreads}
      cthreads,
    {$ENDIF}
  {$ENDIF}
  Classes,
  dglOpenGL,
  EVMain,
  mainwindow;

begin
  EVApplication := TEVApplication.Create;
  EVApplication.CreateWindow(EVWindow1Settings, TEVWindow1, EVWindow1);
  EVApplication.CreateContext(EVOpenGLContext1Settings);
  EVApplication.MainLoop;
  EVApplication.Free;
end.
