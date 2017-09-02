//главный модуль механики боя для ролевых игр ver.0.0.1//
//        написано Кириллом Черкасовым aka kvche       //

unit core;

interface

uses SysUtils, Classes, Windows, Math, ShareMem, typelib;

//объявление типов данных
type

//перечисление зон тела (голова торс основная рука, вторая рука, ноги х2
  TZones = (bz_head, bz_body, bz_marm, bz_sarm, bz_leg1, bz_leg2);

//массив параметров персонажа
//0-Сила 1-Ловкость 2-Реакция 3-Выносливость
  TStats = array [0..3] of byte;

//массив очков действий
//0-очки мощи 1-очки проворства
//субиндексы 0-максимальное 1-текущее
  TActPoints = array [0..1] of TBytePair;

//тип данных атаки
  TStrikeData = record
      name: TNameStr;//название приема
      cost: TBytePair; //стоимость навыка в ОД: 0-ОМ, 1-ОП
      bmdg: TBytePair; //бонусный урон: 0-тип кубика (число по которому пойдет рандом) 1-число кубиков
      bchn: array [TZones] of ShortInt; //бонусный шанс попадания (массив бонусов по зонам)
  end;

//перечисление зон экипировки
//dz_head-голова, dz_chest-торс, dz_hands-руки, dz_legs-ноги, dz_mwep-осн.оружие, dz_owep-доп.оружие
  TDollZones = (dz_head, dz_chest, dz_hands, dz_legs, dz_mwep, dz_owep);

//Кукла персонажа
  TDoll = array [TDollZones] of integer;

//структура зоны тела
  TBodyZone = record
      hp: TBytePair; //"запас прочности" зоны - текущий и максимальный
      chance: ShortInt; //шанс попадания по зоне
  end;

//тип сведений о предмете экипировки
  TItemData = record
      stat: byte; //для брони - защита, для оружия - мощь
      suits: array [TDollZones] of boolean; //слот экипировки, к которому подходит вещь (фактически, тип предмета)
      cost: integer; //цена предмета
  end;

//тип хранилища констант
  TConstBank = record
      ZoneNames: array [TZones] of TNameStr; //массив названий зон
      SlotNames: array [TDollZones] of TNameStr; //массив названий слотов снаряжения
      StatNames: array [0..3] of TNameStr; //массив названий параметров
      APNames: array [0..1] of TNameStr; //массив названий ОД
      StrikeStatsNames: array [0..2] of TNameStr;  //массив названий параметров атаки(0-Точность 1-Сила Атаки 2-Урон)
  end;

//тип выходных данных атаки (для вывода в логи)
  TStrOutro = record
    zone: TNameStr; //пораженная зона
    dmg: integer; //нанесенный дамаг
    att: TNameStr; //имя атакующего
    def: TNameStr; //имя цели
    ifwin: boolean; //стала ли атака добивающей
  end;

//динамический массив выходных данных атак
  TStrOutroArr = array of TStrOutro;

//тип хранилища данных (позднее переписать под загрузку данных из файлов)
  TDataBank = record
    Strikes: array [0..3] of TStrikeData; //массив данных по атакам (для ver.0.0.1 - одномерный из 4 атак, затем переделать в двумерный - первый индекс = стиль, второй = прием)
  end;

//карта тела объекта
  TBody = array [TZones] of TBodyZone;

//класс персонажей
  TCharacter = class
      name: TNameStr; //Имя
      Stats: TStats; //Параметры
      AP: TActPoints; //ОД
      body: TBody;//Карта тела
      initiative: TBytePair; //Инициатива (макс., текущая)
      isbot: boolean; //флажок бота (нужен для включения ИИ)
      constructor create (nm: TNameStr; ib: boolean); //создание персонажа
      function ifdead: boolean; //проверка, жив ли боец
  //дописать булев массив, отвечающий за изученность стилей и приемов (когда будет готова сама эта штука)
  end;

//тип массива из 2 персонажей
  TDuel = array [0..1] of TCharacter;

//класс дата-хранилища
  TStorage = class
    Consts: TConstBank; //хранилище констант
    Skills: TDataBank; //хранилище приемов
    constructor initialize; //создание дата-хранилища
  end;

//класс атак
  TAttack = class
    damager: byte; //идентификатор атакующего
    target: byte; //идентификатор цели
    ini: byte; //инициатива
    std: integer; //идентификатор
    constructor create(att, tgt: byte; sid: integer; patt: TCharacter); //инициализация атаки
    procedure implement(St: TStorage; pChArr: TDuel); //отыгрыш атаки
  end;

//тип хода в бою
  TTurn = array of TAttack;

//класс боя
  TFight = class
    fighters: array [0..1] of  byte; //указатели на бойцов
    turn: TTurn; //последовательность атак
    iswon: boolean; //окончен ли бой
    constructor create(fi1, fi2: byte; pChArr: TDuel); //инициализация боя
    procedure Turn_Sort; //Сортировка атак в ходу
    procedure Turn_Start(St: TStorage; PChArr: TDuel); //Отработка хода
    procedure Add_Attack(dmg,tgt: byte; sid: integer;  patt: TCharacter); //процедура добавления атаки
    procedure AI_attschoice(att,def: byte; St: TStorage; patt: TCharacter); //Процедура хода ИИ
    destructor destroy;
  end;

implementation

//конструктор дата-хранилища
  constructor TStorage.initialize;
  var
    i: byte;
    b: TZones;
  begin
    inherited create;
  //названия зон тела
    Self.Consts.ZoneNames[bz_head]:= 'Голова';      Self.Consts.ZoneNames[bz_body]:= 'Торс';
    Self.Consts.ZoneNames[bz_marm]:= 'Правая рука'; Self.Consts.ZoneNames[bz_sarm]:= 'Левая рука';
    Self.Consts.ZoneNames[bz_leg1]:= 'Правая нога'; Self.Consts.ZoneNames[bz_leg2]:= 'Левая нога';
  //названия слотов инвентаря
    Self.Consts.SlotNames[dz_head]:= 'Голова';          Self.Consts.SlotNames[dz_chest]:= 'Тело';
    Self.Consts.SlotNames[dz_hands]:= 'Руки';           Self.Consts.SlotNames[dz_legs]:= 'Ноги';
    Self.Consts.SlotNames[dz_mwep]:= 'Основное оружие'; Self.Consts.SlotNames[dz_owep]:= 'Дополнительное оружие';
  //названия параметров
    Self.Consts.StatNames[0]:= 'Сила';    Self.Consts.StatNames[1]:= 'Ловкость';
    Self.Consts.StatNames[2]:= 'Реакция'; Self.Consts.StatNames[3]:= 'Выносливость';
  //названия типов очков действий
    Self.Consts.APNames[0]:= 'Очки Мощи'; Self.Consts.APNames[1]:= 'Очки Проворства';
  //названия параметров атаки
    Self.Consts.StrikeStatsNames[0]:= 'Точность'; Self.Consts.StrikeStatsNames[1]:= 'Сила Атаки';
    Self.Consts.StrikeStatsNames[2]:= 'Урон';
  //инициализация массива приемов
  //названия приемов
    Self.Skills.Strikes[0].name:= 'Точный удар рукой'; Self.Skills.Strikes[1].name:= 'Точный удар ногой';
    Self.Skills.Strikes[2].name:= 'Мощный удар рукой'; Self.Skills.Strikes[3].name:= 'Мощный удар ногой';
  //стоимость приемов в ОД
  //стоимость в ОМ
    Self.Skills.Strikes[0].cost[0]:= 0; Self.Skills.Strikes[1].cost[0]:= 0;
    Self.Skills.Strikes[2].cost[0]:= 3; Self.Skills.Strikes[3].cost[0]:= 6;
  //стоимость в ОП
    Self.Skills.Strikes[0].cost[1]:= 3; Self.Skills.Strikes[1].cost[1]:= 6;
    Self.Skills.Strikes[2].cost[1]:= 0; Self.Skills.Strikes[3].cost[1]:= 0;
  //урон от навыков
  //урон от навыков: типы кубиков
    Self.Skills.Strikes[0].bmdg[0]:= 4; Self.Skills.Strikes[1].bmdg[0]:= 6;
    Self.Skills.Strikes[2].bmdg[0]:= 4; Self.Skills.Strikes[3].bmdg[0]:= 6;
  //урон от навыков: число кубиков
    Self.Skills.Strikes[0].bmdg[1]:= 3; Self.Skills.Strikes[1].bmdg[1]:= 3;
    Self.Skills.Strikes[2].bmdg[1]:= 5; Self.Skills.Strikes[3].bmdg[1]:= 5;
  //бонус к точности от навыков
    for i:=0 to 3 do
    begin
      for b:= bz_head to bz_leg2 do
      begin
        if (i < 2) then
          Self.Skills.Strikes[i].bchn[b]:=0 //у "точных" атак бонус +5% по всем зонам
        else
          Self.Skills.Strikes[i].bchn[b]:=0; //у "мощных" атак такого бонуса нет
      end;
    end;
  end;

//конструктор персонажа
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
    self.isbot:= ib; //определение, является ли чар ботом (при создании игрока передавать на вход false)
    self.name:= nm; //присвоение персонажу имени (либо рандомно сгенерированного, либо введенного игроком)
  //случайная генерация параметров (для мобов оставить, для игрока потом переписать)
    randomize;
    for i:= 0 to 3 do
    begin
      self.Stats[i]:= seed + (random(11) - 5); //расчет значения параметра производится по формуле 10 + СлЧ, СлЧ - случайное число = -5..5
    end;
  //расчет модификатора шанса попадания по зоне
    cmod:= ((Self.Stats[1] - 10) div 4) + ((Self.Stats[2] - 10) div 4); //формула: Модификатор = (Ловкость - 10)/4 + (Реакция - 10)/4
  //инициализация хелсбаров тела и модификация хп за чсчет бонуса Выносливости
    for b:= bz_head to bz_leg2 do
    begin
      Self.body[b].hp[0]:= base_hp + ((self.Stats[3] - 10) div 2) * 10; //расчет максимального хп для зоны. Формула: 100 + (ВынМод * 10), ВынМод - модификатор Выносливости персонажа ВынМод = (Выносливость - 10) / 2.
      Self.body[b].hp[1]:= Self.body[b].hp[0]; //текущее xп зоны вначале равно максимальному
  //инициализация шансов попадания
      case b of
        bz_head: Self.body[b].chance:= 6;
        bz_body: Self.body[b].chance:= 40;
        bz_marm: Self.body[b].chance:= 15;
        bz_sarm: Self.body[b].chance:= 15;
        bz_leg1: Self.body[b].chance:= 12;
        bz_leg2: Self.body[b].chance:= 12;
      else
      end;
  //модификация шансов попадания бонусами Реакции и Ловкости
      Self.body[b].chance:= Self.body[b].chance - cmod;
    end;
  //инициализация ОД
    for i:=0 to 1 do
    begin
        Self.AP[i][0]:= seed + ((Self.Stats[i] - 10) div 2);
        Self.AP[i][1]:= Self.AP[i][0];
    end;
  //расчет инициативы
    Self.initiative[0]:= 5 + ((Self.Stats[2] - 10) div 2) + 1;
    Self.initiative[1]:= Self.initiative[0];
  end;

//конструктор атак
  constructor TAttack.create(att,tgt: byte; sid: integer; patt: TCharacter);
  begin
    Self.damager:= att; //записывваем атакующего
    Self.target:= tgt; //записываем таргет
    Self.ini:= patt.initiative[1]; //записываем инициативу этой атаки (текущая инициатива атакующего)
    patt.initiative[1]:= patt.initiative[1] - 1; //снижаем текущую инициативу атакующего на 1
    Self.std:= sid; //записываем идентификатор приема в дата-хранилище
  end;

//конструктор класса боя
  constructor TFight.create(fi1, fi2: byte; pChArr: TDuel);
  begin
    Self.fighters[0]:= fi1; //записываем адрес бойца 1
    Self.fighters[1]:= fi2; //записываем адрес бойца 2
    Self.iswon:= false; //по умолчанию бой не выигран
    setlength(self.turn, (pChArr[fi1].initiative[0]+pChArr[fi2].initiative[0])); //инициализируем пустой массив атак
  end;

//проверка жив ли боец
  function TCharacter.ifdead: boolean;
  begin
  //возвращает true, если хп головы или торса бойца = 0, иначе false
    if (self.body[bz_head].hp[1] = 0) or (self.body[bz_body].hp[1] = 0) then
      result:= true
    else
      result:= false;
  end;

//сортировка массива атак по убыванию значения инициативы
  procedure TFight.Turn_Sort;
  var
    i,j,lgt: integer;
    buf: TAttack;
  begin
    lgt:= high(self.turn); //записываем верхний индекс массива ходов
  //сортировка масссива
    for i:=0 to (lgt - 1) do
      for j:=0 to (lgt - 1) do
      begin
      //условие перестановки элементов - (неравенство индексов i и j) И (инициатива i-ого элемента < инициативы j-ого)
      if (Self.turn[j+1] <> nil) then
        if (Self.turn[j].ini <= Self.turn[j+1].ini) then
        begin
          buf:= Self.turn[j];
          Self.turn[j]:= Self.turn[j+1];
          Self.turn[j+1]:= buf;
        end;
      end;
  end;

//процедура добавления новой атаки в список хода
  procedure TFight.Add_Attack(dmg,tgt: byte; sid: integer; patt: TCharacter);
  var
    i: byte;
  begin
    for i:= 0 to High(Self.turn) do
    begin
      if (Self.turn[i] = nil) then
      begin
        Self.turn[i]:= TAttack.create(dmg,tgt,sid,patt); //создание новой атаки
        break;
      end;
    end;
  end;

//процедура отрабатывания атаки
  procedure TAttack.implement(St: TStorage; pChArr: TDuel);
  var
    zc: array [0..5] of TZones; //счётчик зон тела
    zchn: array [TZones] of ShortInt; //массив шансов попадания по зонам
    i,j,k: byte; //служебные байтовые счетчики
    buf: TZones; //счетчик для массива шансов попадания
    dmg: byte; //урон от атаки
  begin
    dmg:= 0;
  //
      zc[0]:= bz_head; zc[1]:=bz_body; zc[2]:=bz_sarm; zc[3]:=bz_marm; zc[4]:=bz_leg1; zc[5]:=bz_leg2;
  //инициализация буферного массива (загружаем шансы по зонам из таргета и плюсуем модификаторы приема)
    for buf:= bz_head to bz_leg2 do
      zchn[buf]:= pChArr[Self.target].Body[buf].chance + St.Skills.Strikes[Self.std].bchn[buf];
  //пузырьковая сортировка буферного массива по возрастанию вероятности попадания по зоне
    for i:= 0 to 4 do
      for j:= 0 to 4 do
        if (zchn[zc[j]] > zchn[zc[j+1]]) then
        begin
          buf:= zc[j];
          zc[j]:= zc[j+1];
          zc[j+1]:= buf;
        end;
    randomize;
    j:= random(2000) mod 101; //генерируем случайный процент от 1 до 100 и начинаем тыкать им в зоны тела по возрастанию шанса попасть - если процент <= шанса, останавливаем цикл и пробиваем дамаг по зоне
    for i:= 0 to High(zc) do
      if (j <= zchn[zc[i]]) then
      begin
        buf:= zc[i]; //записывааем зону, по которой пойдет отработка дамага
        //считаем дамаг
        dmg:= 0; //инициализация начального значения дамага
        //цикл по числу "бросаемых кубиков"
        for k:=1 to St.Skills.Strikes[Self.std].bmdg[1] do
          dmg:= dmg + random(St.Skills.Strikes[Self.std].bmdg[0]) + 1; //увеличиваем суммарный дамаг на "выпавшее" значение
        if(pChArr[Self.target].body[buf].hp[1] <= dmg) then
          pChArr[Self.target].body[buf].hp[1]:= 0 //если дамаг выше текущего хп зоны - просто обнуляем хп
        else
          pChArr[Self.target].body[buf].hp[1]:= pChArr[Self.target].body[buf].hp[1] - dmg; //если все в норме - вычитаем дамаг из текущего хп
        break; //выходим из проверочного цикла
      end;
    //сохранение выходной информации по атаке
      {outro.zone:= St.consts.ZoneNames[buf];
      outro.dmg:= dmg;
      outro.att:= damager.name;
      outro.def:= target.name;
      outro.ifwin:= target.ifdead;}
  end;

//процедура хода ИИ (пока написан код лишь для самого примитивного типа - в дальнейшем оставить для самых мелких мобов)
  procedure TFight.AI_attschoice(att,def: byte; St: TStorage; patt: TCharacter);
  var
      j,k: byte;
      hasAP: array [0..3] of boolean;
      tmp, fhasAP: boolean;
  begin
    fhasAP:= true; //
  //если персонаж принадлежит игроку, данный код не выполняется
    if patt.isbot then
    begin
    //повторяем, пока у персонажа не кончатся ОД или Инициатива
      while (patt.initiative[1] > 0) and fhasAP do
      begin
      //инициализации матрицы доступности атак
        for j:= 0 to 3 do
        begin
        //предварительная инициализация элемента (по умолчанию - ложь)
          hasAP[j]:= true;
        //проверка запасов ОД атакующего: если ОД >= стоимости навыка - то навык доступен
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
        //конец инициализации матрицы доступности
        //начинаем перебор базы атак, для доступных выполняем рандом - четное число = кастуем навык, нечетное - продолжаем перебор столько раз, пока не скастуем хоть чего-то
        tmp:= true;
        while (tmp) do
        begin
          randomize;
          j:= random(1000) mod 4; //выбор случайного навыка из базы атак
        //условия внесения атаки в список хода - на нее хватает ОД и в рандоме "0 или 1" выпало 1
          if hasAP[j] and (random(100) <= 50) then
          begin
            tmp:= false; //выключаем флажок
            Self.Add_Attack(att,def,j,patt); //вносим атаку в список хода
            for k:= 0 to 1 do
              patt.AP[k][1]:= patt.AP[k][1] - St.Skills.Strikes[j].cost[k]; //снимаем стоимость навыка из запаса ОД
          end;
        end;
        //инициализация матрицы доступности атак
        for j:= 0 to 3 do
        begin
        //предварительная инициализация элемента (по умолчанию - ложь)
          hasAP[j]:= true;
        //проверка запасов ОД атакующего: если ОД >= стоимости навыка - то навык доступен
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
        //конец инициализации матрицы доступности
        //сведение матрицы доступности к одной переменной - истина, если хватает ОД хоть на какой-то навык
        for j:= 0 to 3 do
          fhasAP:= fhasAP or hasAP[j];
      end;
    end;
  end;

//отработка хода
  procedure TFight.Turn_Start(St: TStorage; pChArr: TDuel);
  var i: byte;
  begin
  //отрабатываем весь набор атак
    for i:=0 to (High(Self.turn)) do
    begin
    //атака отрабатывается, если бой не окончен, иначе она просто чистится
      if (Self.iswon = false) and (Self.turn[i] <> nil) then
      begin
        Self.turn[i].implement(St, pChArr); //отработка атаки
    //если атака добила цель, ставим метку окончания боя
        if (PChArr[Self.turn[i].target].ifdead) then
          Self.iswon:= true; //ставим метку, что бой окончен
      end;
      if (Self.turn[i] <> nil) then
      begin
        Finalize(Self.turn[i].damager); //после отработки сразу чистим память
        Finalize(Self.turn[i].target);
        Finalize(Self.turn[i].ini);
        Finalize(Self.turn[i].std);
        Self.turn[i].Destroy;
      end;
    end;
  //сворачиваем массив атак
    finalize(Self.turn);
    Setlength(Self.turn,(pChArr[0].initiative[0] + pChArr[1].initiative[0]));
  //восстанавливаем бойцам ОД и инициативу для нового хода
    {for i:=0 to 1 do
    begin
      PChArr[Self.fighters[i]].AP[0][1]:= PChArr[Self.fighters[i]].AP[0][0]; //восстановление ОМ
      PChArr[Self.fighters[i]].AP[1][1]:= PChArr[Self.fighters[i]].AP[1][0]; //восстановление ОП
      PChArr[Self.fighters[i]].initiative[1]:= PChArr[Self.fighters[i]].initiative[0]; //восстановление инициативы
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
