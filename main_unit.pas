{ YARS is Yet Another Robotic Simulator
  It is very very simple graphical interface that compares VW with V1,V2

  Copyright (C) 2020 Armando Sousa asousa@fe.up.pt

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
  Boston, MA 02110-1335, USA.
}


unit main_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls;

type

  { TRobotWorld }

  TRobotWorld = class(TForm)
    ReStart: TButton;
    v2: TLabel;
    velocity: TLabel;
    StatusBar1: TStatusBar;
    TBV2: TTrackBar;
    Timer: TTimer;
    TBVel: TTrackBar;
    TBOmega: TTrackBar;
    TBV1: TTrackBar;
    Omega: TLabel;
    v1: TLabel;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure ReStartClick(Sender: TObject);
    procedure TBVelChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TBV1Change(Sender: TObject);
    procedure UpdateStatusBar();
  end;



  TRobot = Object
  public
    x, y, Theta : double;
    Vel, Omega, v1, v2 : double;
    procedure DrawRobot(col: Tcolor=clBlack);
  end;

var
  WorldCanvas : TCanvas;


var
  RobotWorld: TRobotWorld;

implementation

{$R *.lfm}

uses math;

{ TRobotWorld }

const RadiusOfRobot=20; // pix
      b = RadiusOfRobot;
      dt=1; // sec


var
  //RobotTimeLine : array[0..10] of TRobot ;
  Robot, OldRobot : TRobot ;

// Wrong YY Axis direction...

procedure TRobot.DrawRobot(col : Tcolor = clBlack);  // pix, pix, radian
begin
  if WorldCanvas = nil then exit;
  with self do begin
    WorldCanvas.Pen.Color := col;
    WorldCanvas.EllipseC(round(x*2),round(y*2),RadiusOfRobot,RadiusOfRobot);
    WorldCanvas.Line(round(x*2),round(y*2), round(x*2+cos(Theta)*RadiusOfRobot),round(y*2 - sin(Theta)*RadiusOfRobot));
    WorldCanvas.Pen.Color := clGreen;
    WorldCanvas.Pen.Width := 5;
    WorldCanvas.Line(50,150, RobotWorld.Width-50,150);
    WorldCanvas.Pen.Width := 1;
    WorldCanvas.Pen.Color := clBlack;
  end;
end;




procedure TRobotWorld.TimerTimer(Sender: TObject);
begin
  with Robot do begin
    if WorldCanvas=nil then begin WorldCanvas:=RobotWorld.Canvas; end;
    if Robot.x=0 then begin Robot.x:=150; Robot.y:=150; end;
    x := x + cos(Theta) * Vel * dt;
    y := y - sin(Theta) * Vel * dt;
    Theta := Theta + Omega * dt;
  end;

  RobotWorld.Invalidate;

end;

procedure TRobotWorld.TBV1Change(Sender: TObject);
begin
  with Robot do begin
    v1:=TBV1.Position;
    v2:=TBV2.Position;
    Vel   := (v1+v2)/2;
    Omega := (v1-v2)/b;
    UpdateStatusBar();
  end;
end;

procedure TRobotWorld.ReStartClick(Sender: TObject);
begin
  Timer.Enabled:=False;
  with Robot do begin
    x:=150; y:=150; Theta:=0;
    Vel :=0; Omega:=0;
    v1:=0; v2:=0;
    TBVel.Position:=0;
    TBOmega.Position:=0;
    TBV1.Position:=0;
    TBV2.Position:=0;
    RobotWorld.Repaint();
    Sleep(1);
    Application.ProcessMessages;
    Timer.Enabled:=True;
    UpdateStatusBar();
  end;
end;

procedure TRobotWorld.FormPaint(Sender: TObject);
begin
  RobotWorld.BeginFormUpdate;

  //Canvas.Brush.Color := clRed;
  //Canvas.Brush.Style := bsSolid;
  //Canvas.Pen.Color := clBlue;
  //Canvas.Pen.Width := 5;
  //Canvas.Pen.Style := psSolid;

  if OldRobot.x>0 then begin
    Canvas.Brush.Color := clDefault;
    with WorldCanvas do FillRect(0,90, Width, Height);
    OldRobot.DrawRobot(clLime);
  end;
  Robot.DrawRobot(clBlue);
  OldRobot := Robot;
  UpdateStatusBar();
  RobotWorld.EndFormUpdate;

end;

var PenDown_X,PenDown_y : integer;
procedure TRobotWorld.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  PenDown_X := X;
  PenDown_y := Y;
end;

procedure TRobotWorld.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Robot.X     := PenDown_X div 2;
  Robot.Y     := PenDown_Y div 2;
  Robot.theta := ArcTan2(-Y+PenDown_Y,x-PenDown_X)

end;

procedure TRobotWorld.TBVelChange(Sender: TObject);
begin
  with Robot do begin
    Vel    :=TBVel.  Position*2;
    Omega:=TBOmega.Position/10;

    // example: https://core.ac.uk/download/pdf/153415731.pdf
    //2v=v1+v2 ; bw=v1-v2
    //v1=2v-v2  ; bw=2v-2v2
    //v2=(bw-2v)/2 ; v1=2v-v2
    v1:=Vel+Omega*b/2;
    v2:=Vel-Omega*b/2;

    UpdateStatusBar();
  end;
end;


procedure TRobotWorld.UpdateStatusBar();
begin
  with Robot do begin
    RobotWorld.StatusBar1.Panels[0].Text := Format('x,y,t=(%2.1f,%2.1f,%2.1f)',[x,y,Theta]);
    RobotWorld.StatusBar1.Panels[1].Text := Format('v,w=(%2.1f,%2.1f)',[Vel,Omega]);
    RobotWorld.StatusBar1.Panels[2].Text := Format('v1,v2=(%2.1f,%2.1f)',[v1,v2]);
  end;
end;

end.

