program Fencing;

uses
  Forms,
  Windows,
  ShareMem,
  SysUtils,
  core in 'core.pas',
  Test_Form in 'Test_Form.pas' {frmTest},
  typelib in 'typelib.pas',
  Test_form1 in 'Test_form1.pas' {frmTest1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Test version of RPG battle mechanics by kvche. ver.0.1';
  Application.CreateForm(TfrmTest1, frmTest1);
  Application.Run;
  //Application.OnException:= nil;
  //FreeAndNil(Application);
  //frmTest.Show;
  //frmTest.SetFocus;
end.
