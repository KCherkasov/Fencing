unit Test_Form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, core, ShareMem;

type
  TfrmTest = class(TForm)
    imgIcon1: TImage;
    imgIcon2: TImage;
    lblName1: TLabel;
    lblName2: TLabel;
    lblLogName: TLabel;
    mBattleLog: TMemo;
    mFi1Stats: TMemo;
    mFi2Stats: TMemo;
    pbFi1Head: TProgressBar;
    pbFi1Body: TProgressBar;
    pbFi1SArm: TProgressBar;
    pbFi1MArm: TProgressBar;
    pbFi1Leg1: TProgressBar;
    pbFi1Leg2: TProgressBar;
    pbFi2Leg1: TProgressBar;
    pbFi2Leg2: TProgressBar;
    pbFi2MArm: TProgressBar;
    pbFi2SArm: TProgressBar;
    pbFi2Body: TProgressBar;
    pbFi2Head: TProgressBar;
    lblFi1Head: TLabel;
    lblFiBody: TLabel;
    lblFi1SArm: TLabel;
    lblFi1MArm: TLabel;
    lblFi1Leg1: TLabel;
    lblFi1Leg2: TLabel;
    lblFi2Leg2: TLabel;
    lblFi2Leg1: TLabel;
    lblFi2MArm: TLabel;
    lblFi2SArm: TLabel;
    lblFi2Body: TLabel;
    lblFi2Head: TLabel;
    btnNewGame: TButton;
    btnTurn: TButton;
    btnExit: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnNewGameClick(Sender: TObject);
    procedure btnTurnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTest: TfrmTest;
  bots: TDuel;
  fight: TFight;
  Data: TStorage;
  //outro: TStrOutroArr;
implementation

{$R *.dfm}

procedure TfrmTest.FormCreate(Sender: TObject);
begin
//���������� ����� ������ ���� ��� � ������ ������
  Self.mBattleLog.Enabled:= true;
  Self.mFi1Stats.Enabled:= false;
  Self.mFi2Stats.Enabled:= false;
//���������� ������ ����
  Self.btnTurn.Enabled:= false;
//������������� ������� ������ ��� ���������� ������� ����
  //setlength(outro, 0);
end;

procedure TfrmTest.btnExitClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmTest.btnNewGameClick(Sender: TObject);
var
  i: byte;
begin
//������������� ���� ������
  Data:= TStorage.initialize;
//���� �� ������� �� ������ ����� ���� ��� ����� ���
  if (Self.btnNewGame.Caption = '����� ���') then
  begin
    fight.Free; //�������� ������ ���
    bots[0].Free; //�������� ������ ���� 1
    bots[1].Free; //�������� ������ ���� 2
  //�������� ������ ���������� �����
    Self.mFi1Stats.Lines.Clear;
    Self.mFi2Stats.Lines.Clear;
  end;
//����������� ������ ��������
  Self.btnTurn.Enabled:= true; //������������� ������ ����
  if (Self.btnNewGame.Caption = '����� ����') then
    Self.btnNewGame.Caption:= '����� ���'; //����� �������� ������ ��� ������ �������
  bots[0]:= TCharacter.create('����',true); //�������� ������� ����
  bots[1]:= TCharacter.create('����',true); //�������� ������� ����
  fight:= TFight.create(0,1,bots);
  Self.lblLogName.Caption:= '������ ���';
//����� ���� ����� �� �����
  Self.lblName1.Caption:= bots[0].name;
  Self.lblName2.Caption:= bots[1].name;
//����� ��������������� ���������� ����� �� �����
//������ ���
  Self.mFi1Stats.Lines.Add('��������� ��������� ' + bots[0].name + ':'); //���
  //���������
  for i:=0 to 3 do
  begin
    Self.mFi1Stats.Lines.Add(Data.consts.StatNames[i]+': '+ inttostr(bots[0].stats[i]));
  end;
  //��
  for i:=0 to 1 do
  begin
    Self.mFi1Stats.Lines.Add(Data.consts.APNames[i] + ': ' + inttostr(bots[0].AP[i][0]));
  end;
  //����������
  Self.mFi1Stats.Lines.Add('����������: ' + inttostr(bots[0].initiative[0]));
  //��������
  //��������� ������ ���������
    Self.pbFi1Head.Min:= 0; Self.pbFi1Head.Max:= bots[0].body[bz_head].hp[0]; Self.pbFi1Head.Step:= 1; //������
    Self.pbFi1Body.Min:= 0; Self.pbFi1Body.Max:= bots[0].body[bz_body].hp[0]; Self.pbFi1Body.Step:= 1; //����
    Self.pbFi1SArm.Min:= 0; Self.pbFi1SArm.Max:= bots[0].body[bz_sarm].hp[0]; Self.pbFi1SArm.Step:= 1; //����� ����
    Self.pbFi1MArm.Min:= 0; Self.pbFi1MArm.Max:= bots[0].body[bz_marm].hp[0]; Self.pbFi1MArm.Step:= 1; //������ ����
    Self.pbFi1Leg1.Min:= 0; Self.pbFi1Leg1.Max:= bots[0].body[bz_leg1].hp[0]; Self.pbFi1Leg1.Step:= 1; //����� ����
    Self.pbFi1Leg2.Min:= 0; Self.pbFi1Leg2.Max:= bots[0].body[bz_leg2].hp[0]; Self.pbFi1Leg2.Step:= 1; //������ ����
  //��������� �������� ��������� ���������
    Self.pbFi1Head.Position:= bots[0].body[bz_head].hp[1]; //������
    Self.pbFi1Body.Position:= bots[0].body[bz_body].hp[1]; //����
    Self.pbFi1SArm.Position:= bots[0].body[bz_sarm].hp[1]; //����� ����
    Self.pbFi1MArm.Position:= bots[0].body[bz_marm].hp[1]; //������ ����
    Self.pbFi1Leg1.Position:= bots[0].body[bz_leg1].hp[1]; //����� ����
    Self.pbFi1Leg2.Position:= bots[0].body[bz_leg2].hp[1]; //������ ����
  //���������� ������������� ������� ����
  Self.mBattleLog.Lines.Add('�������� '+ bots[0].name +' ���������������.');
//������ ���
  Self.mFi2Stats.Lines.Add('��������� ��������� ' + bots[1].name + ':'); //���
  //���������
  for i:=0 to 3 do
  begin
    Self.mFi2Stats.Lines.Add(Data.consts.StatNames[i] + ': ' + inttostr(bots[1].stats[i]));
  end;
  //��
  for i:=0 to 1 do
  begin
    Self.mFi2Stats.Lines.Add(Data.consts.APNames[i] + ': ' + inttostr(bots[1].AP[i][0]));
  end;
  //����������
  Self.mFi2Stats.Lines.Add('����������: ' + inttostr(bots[1].initiative[1]));
  //��������
  //��������� ������ ���������
    Self.pbFi2Head.Min:= 0; Self.pbFi2Head.Max:= bots[1].body[bz_head].hp[0]; Self.pbFi2Head.Step:= 1; //������
    Self.pbFi2Body.Min:= 0; Self.pbFi2Body.Max:= bots[1].body[bz_body].hp[0]; Self.pbFi2Body.Step:= 1; //����
    Self.pbFi2SArm.Min:= 0; Self.pbFi2SArm.Max:= bots[1].body[bz_sarm].hp[0]; Self.pbFi2SArm.Step:= 1; //����� ����
    Self.pbFi2MArm.Min:= 0; Self.pbFi2MArm.Max:= bots[1].body[bz_marm].hp[0]; Self.pbFi2MArm.Step:= 1; //������ ����
    Self.pbFi2Leg1.Min:= 0; Self.pbFi2Leg1.Max:= bots[1].body[bz_leg1].hp[0]; Self.pbFi2Leg1.Step:= 1; //����� ����
    Self.pbFi2Leg2.Min:= 0; Self.pbFi2Leg2.Max:= bots[1].body[bz_leg2].hp[0]; Self.pbFi2Leg2.Step:= 1; //������ ����
  //��������� �������� ��������� ���������
    Self.pbFi2Head.Position:= bots[1].body[bz_head].hp[1]; //������
    Self.pbFi2Body.Position:= bots[1].body[bz_body].hp[1]; //����
    Self.pbFi2SArm.Position:= bots[1].body[bz_sarm].hp[1]; //����� ����
    Self.pbFi2MArm.Position:= bots[1].body[bz_marm].hp[1]; //������ ����
    Self.pbFi2Leg1.Position:= bots[1].body[bz_leg1].hp[1]; //����� ����
    Self.pbFi2Leg2.Position:= bots[1].body[bz_leg2].hp[1]; //������ ����
  //���������� ������������� ������� ����
  Self.mBattleLog.Lines.Add('�������� '+ bots[1].name +' ���������������.');

end;

procedure TfrmTest.btnTurnClick(Sender: TObject);
var
  i: byte;
begin
  if (bots[0] = nil) or (bots[1] = nil) or (Data = nil) then
  begin
    Self.mBattleLog.Lines.Add('������, ��� ������� ���� �� ���������� ��� ������. ���������� ���');
    Self.btnTurn.Enabled:= false;
    exit;
  end;
  Self.mBattleLog.Lines.Add('����� ��� �����');
//���������� ���������� (������������ �������� Access Violation - �����������)
  Self.btnNewGame.Enabled:= false;
  Self.btnTurn.Enabled:= false;
  Self.btnExit.Enabled:= false;
//���������� ������� ���� ���������� ������ � ������ ������
    Self.mBattleLog.Lines.Add('�������� ' + bots[0].name  + ' ������ ���� ���.');
    fight.AI_attschoice(0,1,Data,bots[0]);
    Self.mBattleLog.Lines.Add('�������� ' + bots[1].name  + ' ������ ���� ���.');
    fight.AI_attschoice(1,0,Data,bots[1]);
  fight.Turn_Sort; //���������� ������� �����
  Self.mBattleLog.Lines.Add('����� ������������� �� ����������');
  Self.mBattleLog.Lines.Add(inttostr(length(fight.turn)));
  //����� ������ ���� � ���
  for i:=0 to (High(fight.turn)) do
  begin
    Self.mBattleLog.Lines.Add('����������: ' + inttostr(fight.turn[i].ini) + '; �����: ' + Data.Skills.Strikes[fight.turn[i].std].name + '; ���������: ' + bots[fight.turn[i].damager].name + '; ����: ' + bots[fight.turn[i].target].name);
  end;
  //��������� ����
  fight.Turn_Start(Data, bots);
  //����� ����������� � ���
  Self.mBattleLog.Lines.Add('���������� ���� ���� ���������� � ���������.');
  //����� ����������� ���������� ����
  {for i:=0 to high(outro) do
  begin
    Self.mBattleLog.Lines.Add('�������� ' + outro[i].att + ' ����� ��������� ' + outro[i].def + inttostr(outro[i].dmg) + ' ����� �� ���� ' + outro[i].zone);
    //�������� ��������������� ����, ���� ����� ����� ����
    if (outro[i].ifwin) then
    begin
      Self.mBattleLog.Lines.Add('�������� ' + outro[i].def +' ����. ������� �������� ' + outro[i].att);
      fight.iswon:=true;
      break;
    end;
  end;
  Self.mBattleLog.Lines.Add('���������� �������� ����.');
  //������ ������ ������ ����
  setlength(outro,0);}
  //TO DO: ������������ Turn_Start ���, ����� ����� ������ ����� ����������� ������� �� ����� � ������ �������:
  //���� ���-�� �� ��� = 0 - ������ �����, ������� ������� ���, ���������� ������� ����, ������������� ������ ������ ����,
  //��������� ������ �������� ����
//����������� ���������
//������ ���
  Self.pbFi1Head.Position:= bots[0].body[bz_head].hp[1];
  Self.pbFi1Body.Position:= bots[0].body[bz_body].hp[1];
  Self.pbFi1SArm.Position:= bots[0].body[bz_sarm].hp[1];
  Self.pbFi1MArm.Position:= bots[0].body[bz_marm].hp[1];
  Self.pbFi1Leg1.Position:= bots[0].body[bz_leg1].hp[1];
  Self.pbFi1Leg2.Position:= bots[0].body[bz_leg2].hp[1];
//������ ���
  Self.pbFi2Head.Position:= bots[1].body[bz_head].hp[1];
  Self.pbFi2Body.Position:= bots[1].body[bz_body].hp[1];
  Self.pbFi2SArm.Position:= bots[1].body[bz_sarm].hp[1];
  Self.pbFi2MArm.Position:= bots[1].body[bz_marm].hp[1];
  Self.pbFi2Leg1.Position:= bots[1].body[bz_leg1].hp[1];
  Self.pbFi2Leg2.Position:= bots[1].body[bz_leg2].hp[1];
//�������������� �� � ���������� ������� ����
  bots[0].AP[0][1]:= bots[0].AP[0][0]; //�������������� ��
  bots[0].AP[1][1]:= bots[0].AP[1][0]; //�������������� ��
  bots[0].initiative[1]:= bots[0].initiative[0]; //�������������� ����������
//�������������� �� � ���������� ������� ����
  bots[1].AP[0][1]:= bots[1].AP[0][0]; //�������������� ��
  bots[1].AP[1][1]:= bots[1].AP[1][0]; //�������������� ��
  bots[1].initiative[1]:= bots[1].initiative[0]; //�������������� ����������
//������ ���������� ����������
  Self.btnNewGame.Enabled:= true;
//������ ���� �������������� ������ ���� ��� ����� ��� ����
  if (fight.iswon = false) then
  begin
    Self.btnTurn.Enabled:= true;
    Self.btnTurn.SetFocus;
  end;
  Self.btnExit.Enabled:= true;
end;

procedure TfrmTest.FormClose(Sender: TObject; var Action: TCloseAction);
var i: byte;
begin//���� �� ��� ����� ���
//���� ��� ��� �����
  if (Self.btnNewGame.Caption = '����� ���') then
  begin
    Data.Free; //�������� ���� ������
    bots[0].Free; //����������� ���� 1
    bots[1].Free; //����������� ���� 2
    fight.Destroy; //�������� ���
  end;
//���� ������ �������� ������ ���� �� ��� �������, ����������� ������ � ��������
  {if (length(outro) <> 0) then
    setlength(outro,0);}
//    Application.Terminate; //������� ����
end;

procedure TfrmTest.FormShow(Sender: TObject);
begin
  Self.btnNewGame.SetFocus;
end;

end.
