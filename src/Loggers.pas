unit Loggers;

interface

uses
  Constants;

implementation

uses
  System.SysUtils;

procedure gravarlog(Msg: String);
var
  Arquivo: Textfile;
  NomeArq: String;
  Path: String;
begin
  Path := PATH;
  if not directoryexists(Path + '\logs') then
    forcedirectories(Path + '\logs');

  NomeArq := Path + '\logs\log' + formatdatetime('ddmmyyyy',now) + '.txt';
  sleep(100);
  AssignFile(Arquivo,NomeArq);
  if not fileexists(NomeArq) then
    ReWrite(Arquivo)
  else
    Append(Arquivo);

  WriteLn(Arquivo,formatdatetime('HH:mm:ss', now) + '-' + msg);
  CloseFile(Arquivo);
end;

end.
