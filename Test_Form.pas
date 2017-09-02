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
//блокировка полей вывода лога боя и статов бойцов
  Self.mBattleLog.Enabled:= true;
  Self.mFi1Stats.Enabled:= false;
  Self.mFi2Stats.Enabled:= false;
//блокировка кнопки хода
  Self.btnTurn.Enabled:= false;
//инициализация массива данных для заполнения боевого лога
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
//инициализация базы данных
  Data:= TStorage.initialize;
//если до нажатия на кнопку новая игра был начат бой
  if (Self.btnNewGame.Caption = 'Новый бой') then
  begin
    fight.Free; //очистить память боя
    bots[0].Free; //очистить память бота 1
    bots[1].Free; //очистить память бота 2
  //очистить экраны параметров ботов
    Self.mFi1Stats.Lines.Clear;
    Self.mFi2Stats.Lines.Clear;
  end;
//выполняемые всегда действия
  Self.btnTurn.Enabled:= true; //разблокировка кнопки хода
  if (Self.btnNewGame.Caption = 'Новая игра') then
    Self.btnNewGame.Caption:= 'Новый бой'; //смена названия кнопки при первом нажатии
  bots[0]:= TCharacter.create('Адам',true); //создание первого бота
  bots[1]:= TCharacter.create('Каин',true); //создание второго бота
  fight:= TFight.create(0,1,bots);
  Self.lblLogName.Caption:= 'Журнал боя';
//Вывод имен ботов на экран
  Self.lblName1.Caption:= bots[0].name;
  Self.lblName2.Caption:= bots[1].name;
//Вывод сгенерированных параметров ботов на экран
//Первый бот
  Self.mFi1Stats.Lines.Add('Параметры персонажа ' + bots[0].name + ':'); //имя
  //параметры
  for i:=0 to 3 do
  begin
    Self.mFi1Stats.Lines.Add(Data.consts.StatNames[i]+': '+ inttostr(bots[0].stats[i]));
  end;
  //ОД
  for i:=0 to 1 do
  begin
    Self.mFi1Stats.Lines.Add(Data.consts.APNames[i] + ': ' + inttostr(bots[0].AP[i][0]));
  end;
  //инициатива
  Self.mFi1Stats.Lines.Add('Инициатива: ' + inttostr(bots[0].initiative[0]));
  //хелсбары
  //установка границ хелсбаров
    Self.pbFi1Head.Min:= 0; Self.pbFi1Head.Max:= bots[0].body[bz_head].hp[0]; Self.pbFi1Head.Step:= 1; //Голова
    Self.pbFi1Body.Min:= 0; Self.pbFi1Body.Max:= bots[0].body[bz_body].hp[0]; Self.pbFi1Body.Step:= 1; //Торс
    Self.pbFi1SArm.Min:= 0; Self.pbFi1SArm.Max:= bots[0].body[bz_sarm].hp[0]; Self.pbFi1SArm.Step:= 1; //Левая рука
    Self.pbFi1MArm.Min:= 0; Self.pbFi1MArm.Max:= bots[0].body[bz_marm].hp[0]; Self.pbFi1MArm.Step:= 1; //Правая рука
    Self.pbFi1Leg1.Min:= 0; Self.pbFi1Leg1.Max:= bots[0].body[bz_leg1].hp[0]; Self.pbFi1Leg1.Step:= 1; //Левая нога
    Self.pbFi1Leg2.Min:= 0; Self.pbFi1Leg2.Max:= bots[0].body[bz_leg2].hp[0]; Self.pbFi1Leg2.Step:= 1; //Правая нога
  //установка текущего положения хелсбаров
    Self.pbFi1Head.Position:= bots[0].body[bz_head].hp[1]; //Голова
    Self.pbFi1Body.Position:= bots[0].body[bz_body].hp[1]; //Торс
    Self.pbFi1SArm.Position:= bots[0].body[bz_sarm].hp[1]; //Левая рука
    Self.pbFi1MArm.Position:= bots[0].body[bz_marm].hp[1]; //Правая рука
    Self.pbFi1Leg1.Position:= bots[0].body[bz_leg1].hp[1]; //Левая нога
    Self.pbFi1Leg2.Position:= bots[0].body[bz_leg2].hp[1]; //Правая нога
  //завершение инициализации первого бота
  Self.mBattleLog.Lines.Add('Персонаж '+ bots[0].name +' инициализирован.');
//Второй бот
  Self.mFi2Stats.Lines.Add('Параметры персонажа ' + bots[1].name + ':'); //имя
  //параметры
  for i:=0 to 3 do
  begin
    Self.mFi2Stats.Lines.Add(Data.consts.StatNames[i] + ': ' + inttostr(bots[1].stats[i]));
  end;
  //ОД
  for i:=0 to 1 do
  begin
    Self.mFi2Stats.Lines.Add(Data.consts.APNames[i] + ': ' + inttostr(bots[1].AP[i][0]));
  end;
  //инициатива
  Self.mFi2Stats.Lines.Add('Инициатива: ' + inttostr(bots[1].initiative[1]));
  //хелсбары
  //установка границ хелсбаров
    Self.pbFi2Head.Min:= 0; Self.pbFi2Head.Max:= bots[1].body[bz_head].hp[0]; Self.pbFi2Head.Step:= 1; //Голова
    Self.pbFi2Body.Min:= 0; Self.pbFi2Body.Max:= bots[1].body[bz_body].hp[0]; Self.pbFi2Body.Step:= 1; //Торс
    Self.pbFi2SArm.Min:= 0; Self.pbFi2SArm.Max:= bots[1].body[bz_sarm].hp[0]; Self.pbFi2SArm.Step:= 1; //Левая рука
    Self.pbFi2MArm.Min:= 0; Self.pbFi2MArm.Max:= bots[1].body[bz_marm].hp[0]; Self.pbFi2MArm.Step:= 1; //Правая рука
    Self.pbFi2Leg1.Min:= 0; Self.pbFi2Leg1.Max:= bots[1].body[bz_leg1].hp[0]; Self.pbFi2Leg1.Step:= 1; //Левая нога
    Self.pbFi2Leg2.Min:= 0; Self.pbFi2Leg2.Max:= bots[1].body[bz_leg2].hp[0]; Self.pbFi2Leg2.Step:= 1; //Правая нога
  //установка текущего положения хелсбаров
    Self.pbFi2Head.Position:= bots[1].body[bz_head].hp[1]; //Голова
    Self.pbFi2Body.Position:= bots[1].body[bz_body].hp[1]; //Торс
    Self.pbFi2SArm.Position:= bots[1].body[bz_sarm].hp[1]; //Левая рука
    Self.pbFi2MArm.Position:= bots[1].body[bz_marm].hp[1]; //Правая рука
    Self.pbFi2Leg1.Position:= bots[1].body[bz_leg1].hp[1]; //Левая нога
    Self.pbFi2Leg2.Position:= bots[1].body[bz_leg2].hp[1]; //Правая нога
  //завершение инициализации второго бота
  Self.mBattleLog.Lines.Add('Персонаж '+ bots[1].name +' инициализирован.');

end;

procedure TfrmTest.btnTurnClick(Sender: TObject);
var
  i: byte;
begin
  if (bots[0] = nil) or (bots[1] = nil) or (Data = nil) then
  begin
    Self.mBattleLog.Lines.Add('Ошибка, как минимум один из персонажей был удален. Прерывание боя');
    Self.btnTurn.Enabled:= false;
    exit;
  end;
  Self.mBattleLog.Lines.Add('Новый ход начат');
//блокировка управления (периодически вызывает Access Violation - разобраться)
  Self.btnNewGame.Enabled:= false;
  Self.btnTurn.Enabled:= false;
  Self.btnExit.Enabled:= false;
//заполнение массива атак поочередно первым и вторым ботами
    Self.mBattleLog.Lines.Add('Персонаж ' + bots[0].name  + ' делает свой ход.');
    fight.AI_attschoice(0,1,Data,bots[0]);
    Self.mBattleLog.Lines.Add('Персонаж ' + bots[1].name  + ' делает свой ход.');
    fight.AI_attschoice(1,0,Data,bots[1]);
  fight.Turn_Sort; //сортировка массива ходов
  Self.mBattleLog.Lines.Add('Атаки отсортированы по инициативе');
  Self.mBattleLog.Lines.Add(inttostr(length(fight.turn)));
  //вывод списка атак в лог
  for i:=0 to (High(fight.turn)) do
  begin
    Self.mBattleLog.Lines.Add('Инициатива: ' + inttostr(fight.turn[i].ini) + '; Атака: ' + Data.Skills.Strikes[fight.turn[i].std].name + '; Атакующий: ' + bots[fight.turn[i].damager].name + '; Цель: ' + bots[fight.turn[i].target].name);
  end;
  //отработка атак
  fight.Turn_Start(Data, bots);
  //вывод уведомления в лог
  Self.mBattleLog.Lines.Add('Результаты всех атак просчитаны и применены.');
  //вывод результатов применения атак
  {for i:=0 to high(outro) do
  begin
    Self.mBattleLog.Lines.Add('Персонаж ' + outro[i].att + ' нанес персонажу ' + outro[i].def + inttostr(outro[i].dmg) + ' урона по зоне ' + outro[i].zone);
    //прервать воспроизведение лога, если атака убила цель
    if (outro[i].ifwin) then
    begin
      Self.mBattleLog.Lines.Add('Персонаж ' + outro[i].def +' убит. Победил персонаж ' + outro[i].att);
      fight.iswon:=true;
      break;
    end;
  end;
  Self.mBattleLog.Lines.Add('Завершение текущего хода.');
  //чистим память данных лога
  setlength(outro,0);}
  //TO DO: переработать Turn_Start так, чтобы после каждой атаки проверялись текущие хп торса и головы таргета:
  //если что-то из них = 0 - таргет мертв, дамагер выиграл бой, остановить просчет атак, заблокировать кнопку нового хода,
  //вычистить массив текущего хода
//перемещение хелсбаров
//первый бот
  Self.pbFi1Head.Position:= bots[0].body[bz_head].hp[1];
  Self.pbFi1Body.Position:= bots[0].body[bz_body].hp[1];
  Self.pbFi1SArm.Position:= bots[0].body[bz_sarm].hp[1];
  Self.pbFi1MArm.Position:= bots[0].body[bz_marm].hp[1];
  Self.pbFi1Leg1.Position:= bots[0].body[bz_leg1].hp[1];
  Self.pbFi1Leg2.Position:= bots[0].body[bz_leg2].hp[1];
//Второй бот
  Self.pbFi2Head.Position:= bots[1].body[bz_head].hp[1];
  Self.pbFi2Body.Position:= bots[1].body[bz_body].hp[1];
  Self.pbFi2SArm.Position:= bots[1].body[bz_sarm].hp[1];
  Self.pbFi2MArm.Position:= bots[1].body[bz_marm].hp[1];
  Self.pbFi2Leg1.Position:= bots[1].body[bz_leg1].hp[1];
  Self.pbFi2Leg2.Position:= bots[1].body[bz_leg2].hp[1];
//восстановление ОД и инициативы первого бота
  bots[0].AP[0][1]:= bots[0].AP[0][0]; //восстановление ОМ
  bots[0].AP[1][1]:= bots[0].AP[1][0]; //восстановление ОП
  bots[0].initiative[1]:= bots[0].initiative[0]; //восстановление инициативы
//восстановление ОД и инициативы второго бота
  bots[1].AP[0][1]:= bots[1].AP[0][0]; //восстановление ОМ
  bots[1].AP[1][1]:= bots[1].AP[1][0]; //восстановление ОП
  bots[1].initiative[1]:= bots[1].initiative[0]; //восстановление инициативы
//снятие блокировки управления
  Self.btnNewGame.Enabled:= true;
//кнопку хода разблокировать только если оба бойца еще живы
  if (fight.iswon = false) then
  begin
    Self.btnTurn.Enabled:= true;
    Self.btnTurn.SetFocus;
  end;
  Self.btnExit.Enabled:= true;
end;

procedure TfrmTest.FormClose(Sender: TObject; var Action: TCloseAction);
var i: byte;
begin//если не был начат бой
//если бой был начат
  if (Self.btnNewGame.Caption = 'Новый бой') then
  begin
    Data.Free; //свернуть базу данных
    bots[0].Free; //высвободить бота 1
    bots[1].Free; //высвободить бота 2
    fight.Destroy; //свернуть бой
  end;
//если массив выходных данных атак не был свернут, высвободить память и свернуть
  {if (length(outro) <> 0) then
    setlength(outro,0);}
//    Application.Terminate; //закрыть окно
end;

procedure TfrmTest.FormShow(Sender: TObject);
begin
  Self.btnNewGame.SetFocus;
end;

end.
