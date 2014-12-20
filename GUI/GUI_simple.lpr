{
  This is a simple program, demonstrating how to draw a quad using EVEngine.

  It shows, how to initializes the engine including SDL and an OpenGL context.
}
program GUI_simple;

{$mode objfpc}{$H+}

uses
  Classes,
  EVMain,
  mainwindow;

begin
  EVApplication := TEVApplication.Create;
  EVApplication.CreateWindow(EVWindow1Settings, TEVWindow1, EVWindow1);
  EVApplication.CreateContext(EVOpenGLContext1Settings);
  EVApplication.MainLoop;
  EVApplication.Free;
end.
