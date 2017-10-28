program WASHCLIENT;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainUnit in 'MainUnit.pas' {Form3},
  ClientModuleUnit in 'ClientModuleUnit.pas' {dmClient: TDataModule},
  ClientClassesUnit in 'ClientClassesUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TdmClient, dmClient);
  Application.Run;

end.
