//������� ������ �������� ��� ��� ������� ��� ver.0.0.1//
//        �������� �������� ���������� aka kvche       //

unit core;

interface

uses SysUtils, Classes, Windows, Math, ShareMem, typelib;

//���������� ����� ������
type

//������������ ��� ���� (������ ���� �������� ����, ������ ����, ���� �2
  TZones = (bz_head, bz_body, bz_marm, bz_sarm, bz_leg1, bz_leg2);

//������ ���������� ���������
//0-���� 1-�������� 2-������� 3-������������
  TStats = array [0..3] of byte;

//������ ����� ��������
//0-���� ���� 1-���� ����������
//���������� 0-������������ 1-�������
  TActPoints = array [0..1] of TBytePair;

//��� ������ �����
  TStrikeData = record
      name: TNameStr;//�������� ������
      cost: TBytePair; //��������� ������ � ��: 0-��, 1-��
      bmdg: TBytePair; //�������� ����: 0-��� ������ (����� �� �������� ������ ������) 1-����� �������
      bchn: array [TZones] of ShortInt; //�������� ���� ��������� (������ ������� �� �����)
  end;

//������������ ��� ����������
//dz_head-������, dz_chest-����, dz_hands-����, dz_legs-����, dz_mwep-���.������, dz_owep-���.������
  TDollZones = (dz_head, dz_chest, dz_hands, dz_legs, dz_mwep, dz_owep);

//����� ���������
  TDoll = array [TDollZones] of integer;

//��������� ���� ����
  TBodyZone = record
      hp: TBytePair; //"����� ���������" ���� - ������� � ������������
      chance: ShortInt; //���� ��������� �� ����
  end;

//��� �������� � �������� ����������
  TItemData = record
      stat: byte; //��� ����� - ������, ��� ������ - ����
      suits: array [TDollZones] of boolean; //���� ����������, � �������� �������� ���� (����������, ��� ��������)
      cost: integer; //���� ��������
  end;

//��� ��������� ��������
  TConstBank = record
      ZoneNames: array [TZones] of TNameStr; //������ �������� ���
      SlotNames: array [TDollZones] of TNameStr; //������ �������� ������ ����������
      StatNames: array [0..3] of TNameStr; //������ �������� ����������
      APNames: array [0..1] of TNameStr; //������ �������� ��
      StrikeStatsNames: array [0..2] of TNameStr;  //������ �������� ���������� �����(0-�������� 1-���� ����� 2-����)
  end;

//��� �������� ������ ����� (��� ������ � ����)
  TStrOutro = record
    zone: TNameStr; //���������� ����
    dmg: integer; //���������� �����
    att: TNameStr; //��� ����������
    def: TNameStr; //��� ����
    ifwin: boolean; //����� �� ����� ����������
  end;

//������������ ������ �������� ������ ����
  TStrOutroArr = array of TStrOutro;

//��� ��������� ������ (������� ���������� ��� �������� ������ �� ������)
  TDataBank = record
    Strikes: array [0..3] of TStrikeData; //������ ������ �� ������ (��� ver.0.0.1 - ���������� �� 4 ����, ����� ���������� � ��������� - ������ ������ = �����, ������ = �����)
  end;

//����� ���� �������
  TBody = array [TZones] of TBodyZone;

//����� ����������
  TCharacter = class
      name: TNameStr; //���
      Stats: TStats; //���������
      AP: TActPoints; //��
      body: TBody;//����� ����
      initiative: TBytePair; //���������� (����., �������)
      isbot: boolean; //������ ���� (����� ��� ��������� ��)
      constructor create (nm: TNameStr; ib: boolean); //�������� ���������
      function ifdead: boolean; //��������, ��� �� ����
  //�������� ����� ������, ���������� �� ����������� ������ � ������� (����� ����� ������ ���� ��� �����)
  end;

//��� ������� �� 2 ����������
  TDuel = array [0..1] of TCharacter;

//����� ����-���������
  TStorage = class
    Consts: TConstBank; //��������� ��������
    Skills: TDataBank; //��������� �������
    constructor initialize; //�������� ����-���������
  end;

//����� ����
  TAttack = class
    damager: byte; //������������� ����������
    target: byte; //������������� ����
    ini: byte; //����������
    std: integer; //�������������
    constructor create(att, tgt: byte; sid: integer; patt: TCharacter); //������������� �����
    procedure implement(St: TStorage; pChArr: TDuel); //������� �����
  end;

//��� ���� � ���
  TTurn = array of TAttack;

//����� ���
  TFight = class
    fighters: array [0..1] of  byte; //��������� �� ������
    turn: TTurn; //������������������ ����
    iswon: boolean; //������� �� ���
    constructor create(fi1, fi2: byte; pChArr: TDuel); //������������� ���
    procedure Turn_Sort; //���������� ���� � ����
    procedure Turn_Start(St: TStorage; PChArr: TDuel); //��������� ����
    procedure Add_Attack(dmg,tgt: byte; sid: integer;  patt: TCharacter); //��������� ���������� �����
    procedure AI_attschoice(att,def: byte; St: TStorage; patt: TCharacter); //��������� ���� ��
    destructor destroy;
  end;

implementation

//����������� ����-���������
  constructor TStorage.initialize;
  var
    i: byte;
    b: TZones;
  begin
    inherited create;
  //�������� ��� ����
    Self.Consts.ZoneNames[bz_head]:= '������';      Self.Consts.ZoneNames[bz_body]:= '����';
    Self.Consts.ZoneNames[bz_marm]:= '������ ����'; Self.Consts.ZoneNames[bz_sarm]:= '����� ����';
    Self.Consts.ZoneNames[bz_leg1]:= '������ ����'; Self.Consts.ZoneNames[bz_leg2]:= '����� ����';
  //�������� ������ ���������
    Self.Consts.SlotNames[dz_head]:= '������';          Self.Consts.SlotNames[dz_chest]:= '����';
    Self.Consts.SlotNames[dz_hands]:= '����';           Self.Consts.SlotNames[dz_legs]:= '����';
    Self.Consts.SlotNames[dz_mwep]:= '�������� ������'; Self.Consts.SlotNames[dz_owep]:= '�������������� ������';
  //�������� ����������
    Self.Consts.StatNames[0]:= '����';    Self.Consts.StatNames[1]:= '��������';
    Self.Consts.StatNames[2]:= '�������'; Self.Consts.StatNames[3]:= '������������';
  //�������� ����� ����� ��������
    Self.Consts.APNames[0]:= '���� ����'; Self.Consts.APNames[1]:= '���� ����������';
  //�������� ���������� �����
    Self.Consts.StrikeStatsNames[0]:= '��������'; Self.Consts.StrikeStatsNames[1]:= '���� �����';
    Self.Consts.StrikeStatsNames[2]:= '����';
  //������������� ������� �������
  //�������� �������
    Self.Skills.Strikes[0].name:= '������ ���� �����'; Self.Skills.Strikes[1].name:= '������ ���� �����';
    Self.Skills.Strikes[2].name:= '������ ���� �����'; Self.Skills.Strikes[3].name:= '������ ���� �����';
  //��������� ������� � ��
  //��������� � ��
    Self.Skills.Strikes[0].cost[0]:= 0; Self.Skills.Strikes[1].cost[0]:= 0;
    Self.Skills.Strikes[2].cost[0]:= 3; Self.Skills.Strikes[3].cost[0]:= 6;
  //��������� � ��
    Self.Skills.Strikes[0].cost[1]:= 3; Self.Skills.Strikes[1].cost[1]:= 6;
    Self.Skills.Strikes[2].cost[1]:= 0; Self.Skills.Strikes[3].cost[1]:= 0;
  //���� �� �������
  //���� �� �������: ���� �������
    Self.Skills.Strikes[0].bmdg[0]:= 4; Self.Skills.Strikes[1].bmdg[0]:= 6;
    Self.Skills.Strikes[2].bmdg[0]:= 4; Self.Skills.Strikes[3].bmdg[0]:= 6;
  //���� �� �������: ����� �������
    Self.Skills.Strikes[0].bmdg[1]:= 3; Self.Skills.Strikes[1].bmdg[1]:= 3;
    Self.Skills.Strikes[2].bmdg[1]:= 5; Self.Skills.Strikes[3].bmdg[1]:= 5;
  //����� � �������� �� �������
    for i:=0 to 3 do
    begin
      for b:= bz_head to bz_leg2 do
      begin
        if (i < 2) then
          Self.Skills.Strikes[i].bchn[b]:=0 //� "������" ���� ����� +5% �� ���� �����
        else
          Self.Skills.Strikes[i].bchn[b]:=0; //� "������" ���� ������ ������ ���
      end;
    end;
  end;

//����������� ���������
  constructor TCharacter.create (nm: TNameStr; ib: boolean);
  const
    seed = 10;
    base_hp = 100;
  var
    i: byte;
    cmod: ShortInt;
    b: TZones;
  begin
    inherited create;
    self.isbot:= ib; //�����������, �������� �� ��� ����� (��� �������� ������ ���������� �� ���� false)
    self.name:= nm; //���������� ��������� ����� (���� �������� ����������������, ���� ���������� �������)
  //��������� ��������� ���������� (��� ����� ��������, ��� ������ ����� ����������)
    randomize;
    for i:= 0 to 3 do
    begin
      self.Stats[i]:= seed + (random(11) - 5); //������ �������� ��������� ������������ �� ������� 10 + ���, ��� - ��������� ����� = -5..5
    end;
  //������ ������������ ����� ��������� �� ����
    cmod:= ((Self.Stats[1] - 10) div 4) + ((Self.Stats[2] - 10) div 4); //�������: ����������� = (�������� - 10)/4 + (������� - 10)/4
  //������������� ��������� ���� � ����������� �� �� ����� ������ ������������
    for b:= bz_head to bz_leg2 do
    begin
      Self.body[b].hp[0]:= base_hp + ((self.Stats[3] - 10) div 2) * 10; //������ ������������� �� ��� ����. �������: 100 + (������ * 10), ������ - ����������� ������������ ��������� ������ = (������������ - 10) / 2.
      Self.body[b].hp[1]:= Self.body[b].hp[0]; //������� x� ���� ������� ����� �������������
  //������������� ������ ���������
      case b of
        bz_head: Self.body[b].chance:= 6;
        bz_body: Self.body[b].chance:= 40;
        bz_marm: Self.body[b].chance:= 15;
        bz_sarm: Self.body[b].chance:= 15;
        bz_leg1: Self.body[b].chance:= 12;
        bz_leg2: Self.body[b].chance:= 12;
      else
      end;
  //����������� ������ ��������� �������� ������� � ��������
      Self.body[b].chance:= Self.body[b].chance - cmod;
    end;
  //������������� ��
    for i:=0 to 1 do
    begin
        Self.AP[i][0]:= seed + ((Self.Stats[i] - 10) div 2);
        Self.AP[i][1]:= Self.AP[i][0];
    end;
  //������ ����������
    Self.initiative[0]:= 5 + ((Self.Stats[2] - 10) div 2) + 1;
    Self.initiative[1]:= Self.initiative[0];
  end;

//����������� ����
  constructor TAttack.create(att,tgt: byte; sid: integer; patt: TCharacter);
  begin
    Self.damager:= att; //����������� ����������
    Self.target:= tgt; //���������� ������
    Self.ini:= patt.initiative[1]; //���������� ���������� ���� ����� (������� ���������� ����������)
    patt.initiative[1]:= patt.initiative[1] - 1; //������� ������� ���������� ���������� �� 1
    Self.std:= sid; //���������� ������������� ������ � ����-���������
  end;

//����������� ������ ���
  constructor TFight.create(fi1, fi2: byte; pChArr: TDuel);
  begin
    Self.fighters[0]:= fi1; //���������� ����� ����� 1
    Self.fighters[1]:= fi2; //���������� ����� ����� 2
    Self.iswon:= false; //�� ��������� ��� �� �������
    setlength(self.turn, (pChArr[fi1].initiative[0]+pChArr[fi2].initiative[0])); //�������������� ������ ������ ����
  end;

//�������� ��� �� ����
  function TCharacter.ifdead: boolean;
  begin
  //���������� true, ���� �� ������ ��� ����� ����� = 0, ����� false
    if (self.body[bz_head].hp[1] = 0) or (self.body[bz_body].hp[1] = 0) then
      result:= true
    else
      result:= false;
  end;

//���������� ������� ���� �� �������� �������� ����������
  procedure TFight.Turn_Sort;
  var
    i,j,lgt: integer;
    buf: TAttack;
  begin
    lgt:= high(self.turn); //���������� ������� ������ ������� �����
  //���������� ��������
    for i:=0 to (lgt - 1) do
      for j:=0 to (lgt - 1) do
      begin
      //������� ������������ ��������� - (����������� �������� i � j) � (���������� i-��� �������� < ���������� j-���)
      if (Self.turn[j+1] <> nil) then
        if (Self.turn[j].ini <= Self.turn[j+1].ini) then
        begin
          buf:= Self.turn[j];
          Self.turn[j]:= Self.turn[j+1];
          Self.turn[j+1]:= buf;
        end;
      end;
  end;

//��������� ���������� ����� ����� � ������ ����
  procedure TFight.Add_Attack(dmg,tgt: byte; sid: integer; patt: TCharacter);
  var
    i: byte;
  begin
    for i:= 0 to High(Self.turn) do
    begin
      if (Self.turn[i] = nil) then
      begin
        Self.turn[i]:= TAttack.create(dmg,tgt,sid,patt); //�������� ����� �����
        break;
      end;
    end;
  end;

//��������� ������������� �����
  procedure TAttack.implement(St: TStorage; pChArr: TDuel);
  var
    zc: array [0..5] of TZones; //������� ��� ����
    zchn: array [TZones] of ShortInt; //������ ������ ��������� �� �����
    i,j,k: byte; //��������� �������� ��������
    buf: TZones; //������� ��� ������� ������ ���������
    dmg: byte; //���� �� �����
  begin
    dmg:= 0;
  //
      zc[0]:= bz_head; zc[1]:=bz_body; zc[2]:=bz_sarm; zc[3]:=bz_marm; zc[4]:=bz_leg1; zc[5]:=bz_leg2;
  //������������� ��������� ������� (��������� ����� �� ����� �� ������� � ������� ������������ ������)
    for buf:= bz_head to bz_leg2 do
      zchn[buf]:= pChArr[Self.target].Body[buf].chance + St.Skills.Strikes[Self.std].bchn[buf];
  //����������� ���������� ��������� ������� �� ����������� ����������� ��������� �� ����
    for i:= 0 to 4 do
      for j:= 0 to 4 do
        if (zchn[zc[j]] > zchn[zc[j+1]]) then
        begin
          buf:= zc[j];
          zc[j]:= zc[j+1];
          zc[j+1]:= buf;
        end;
    randomize;
    j:= random(2000) mod 101; //���������� ��������� ������� �� 1 �� 100 � �������� ������ �� � ���� ���� �� ����������� ����� ������� - ���� ������� <= �����, ������������� ���� � ��������� ����� �� ����
    for i:= 0 to High(zc) do
      if (j <= zchn[zc[i]]) then
      begin
        buf:= zc[i]; //����������� ����, �� ������� ������ ��������� ������
        //������� �����
        dmg:= 0; //������������� ���������� �������� ������
        //���� �� ����� "��������� �������"
        for k:=1 to St.Skills.Strikes[Self.std].bmdg[1] do
          dmg:= dmg + random(St.Skills.Strikes[Self.std].bmdg[0]) + 1; //����������� ��������� ����� �� "��������" ��������
        if(pChArr[Self.target].body[buf].hp[1] <= dmg) then
          pChArr[Self.target].body[buf].hp[1]:= 0 //���� ����� ���� �������� �� ���� - ������ �������� ��
        else
          pChArr[Self.target].body[buf].hp[1]:= pChArr[Self.target].body[buf].hp[1] - dmg; //���� ��� � ����� - �������� ����� �� �������� ��
        break; //������� �� ������������ �����
      end;
    //���������� �������� ���������� �� �����
      {outro.zone:= St.consts.ZoneNames[buf];
      outro.dmg:= dmg;
      outro.att:= damager.name;
      outro.def:= target.name;
      outro.ifwin:= target.ifdead;}
  end;

//��������� ���� �� (���� ������� ��� ���� ��� ������ ������������ ���� - � ���������� �������� ��� ����� ������ �����)
  procedure TFight.AI_attschoice(att,def: byte; St: TStorage; patt: TCharacter);
  var
      j,k: byte;
      hasAP: array [0..3] of boolean;
      tmp, fhasAP: boolean;
  begin
    fhasAP:= true; //
  //���� �������� ����������� ������, ������ ��� �� �����������
    if patt.isbot then
    begin
    //���������, ���� � ��������� �� �������� �� ��� ����������
      while (patt.initiative[1] > 0) and fhasAP do
      begin
      //������������� ������� ����������� ����
        for j:= 0 to 3 do
        begin
        //��������������� ������������� �������� (�� ��������� - ����)
          hasAP[j]:= true;
        //�������� ������� �� ����������: ���� �� >= ��������� ������ - �� ����� ��������
          for k:= 0 to 1 do
          begin
            if (patt.AP[k][1] >= St.Skills.Strikes[j].cost[k]) then
            begin
              tmp:= true;
              hasAP[j]:= hasAP[j] and tmp;
            end
            else
            begin
              tmp:= false;
              hasAP[j]:= hasAP[j] and tmp;
            end;
          end;
        end;
        //����� ������������� ������� �����������
        //�������� ������� ���� ����, ��� ��������� ��������� ������ - ������ ����� = ������� �����, �������� - ���������� ������� ������� ���, ���� �� �������� ���� ����-��
        tmp:= true;
        while (tmp) do
        begin
          randomize;
          j:= random(1000) mod 4; //����� ���������� ������ �� ���� ����
        //������� �������� ����� � ������ ���� - �� ��� ������� �� � � ������� "0 ��� 1" ������ 1
          if hasAP[j] and (random(100) <= 50) then
          begin
            tmp:= false; //��������� ������
            Self.Add_Attack(att,def,j,patt); //������ ����� � ������ ����
            for k:= 0 to 1 do
              patt.AP[k][1]:= patt.AP[k][1] - St.Skills.Strikes[j].cost[k]; //������� ��������� ������ �� ������ ��
          end;
        end;
        //������������� ������� ����������� ����
        for j:= 0 to 3 do
        begin
        //��������������� ������������� �������� (�� ��������� - ����)
          hasAP[j]:= true;
        //�������� ������� �� ����������: ���� �� >= ��������� ������ - �� ����� ��������
          for k:= 0 to 1 do
          begin
            if (patt.AP[k][1] >= St.Skills.Strikes[j].cost[k]) then
            begin
              tmp:= true;
              hasAP[j]:= hasAP[j] and tmp;
            end
            else
            begin
              tmp:= false;
              hasAP[j]:= hasAP[j] and tmp;
            end;
          end;
        end;
        fhasAP:= false;//
        //����� ������������� ������� �����������
        //�������� ������� ����������� � ����� ���������� - ������, ���� ������� �� ���� �� �����-�� �����
        for j:= 0 to 3 do
          fhasAP:= fhasAP or hasAP[j];
      end;
    end;
  end;

//��������� ����
  procedure TFight.Turn_Start(St: TStorage; pChArr: TDuel);
  var i: byte;
  begin
  //������������ ���� ����� ����
    for i:=0 to (High(Self.turn)) do
    begin
    //����� ��������������, ���� ��� �� �������, ����� ��� ������ ��������
      if (Self.iswon = false) and (Self.turn[i] <> nil) then
      begin
        Self.turn[i].implement(St, pChArr); //��������� �����
    //���� ����� ������ ����, ������ ����� ��������� ���
        if (PChArr[Self.turn[i].target].ifdead) then
          Self.iswon:= true; //������ �����, ��� ��� �������
      end;
      if (Self.turn[i] <> nil) then
      begin
        Finalize(Self.turn[i].damager); //����� ��������� ����� ������ ������
        Finalize(Self.turn[i].target);
        Finalize(Self.turn[i].ini);
        Finalize(Self.turn[i].std);
        Self.turn[i].Destroy;
      end;
    end;
  //����������� ������ ����
    finalize(Self.turn);
    Setlength(Self.turn,(pChArr[0].initiative[0] + pChArr[1].initiative[0]));
  //��������������� ������ �� � ���������� ��� ������ ����
    {for i:=0 to 1 do
    begin
      PChArr[Self.fighters[i]].AP[0][1]:= PChArr[Self.fighters[i]].AP[0][0]; //�������������� ��
      PChArr[Self.fighters[i]].AP[1][1]:= PChArr[Self.fighters[i]].AP[1][0]; //�������������� ��
      PChArr[Self.fighters[i]].initiative[1]:= PChArr[Self.fighters[i]].initiative[0]; //�������������� ����������
    end;}
  end;

  destructor TFight.destroy;
  var i: integer;
  begin
    if (length(Self.turn) = 0) then
    begin
      setlength(Self.turn,1);
      Finalize(Self.turn);
    end
    else
    begin
      {for i:= 0 to High(Self.turn) do
      begin
        Finalize(Self.turn[i]);
      end;}
      Finalize(Self.turn);
    end;
    Finalize(Self.fighters);
    Finalize(Self.iswon);
    inherited destroy;
  end;



end.
