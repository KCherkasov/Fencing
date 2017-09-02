//модуль системных подпрограмм и типов данных
//

unit sysfun;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;


//<-------------------------------------------------------------------------->\\
//<-------------------------------ТИПЫ ДАННЫХ-------------------------------->\\
//<-------------------------------------------------------------------------->\\

type

TGameState = (gs_MainMenu, gs_Pause, gs_IngameMenu, gs_GameOver, gs_Shutdown, gs_Editor); //тип возможных состояний игры: Главное меню, Пауза, Внутриигровое меню, Конец игры, Выход, Редактор

//<-------------------------------------------------------------------------->\\
//<------------------------------ПОДПРОГРАММЫ-------------------------------->\\
//<-------------------------------------------------------------------------->\\

procedure GameLoop (gs: TGameState); //основая подпрограмма игрового цикла

implementation

//процедура основного игрового цикла
  procedure GameLoop (gs: TGameState);
  begin
  case gs of
    gs_MainMenu:   begin
                     {place Main Menu state code here}
                   end;
    gs_Pause:      begin
                     {place Pause state code here}
                   end;
    gs_IngameMenu: begin
                     {place In-game Menu state code here}
                   end;
    gs_GameOver:   begin
                     {place Game Over state code here}
                   end;
    gs_Shutdown:   begin
                     {place Shutdown state code here}
                   end;
    gs_Editor:     begin
                     {place Editor state code here}
                   end;
    else
    end;
  end;

end.
