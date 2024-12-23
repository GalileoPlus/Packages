unit fbConnection;

interface

uses
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.FMXUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.Phys.FB;

type
  TConnection = class
    private
    public
      class function GetConnection: TFDConnection;
      class procedure Execute(const SQL: string); overload;
      class function Execute(const SQL: string; Table: TFDMemTable): TFDMemTable; overload;
  end;

implementation

uses
  Constants, 
  System.SysUtils,
  Loggers, FireDAC.Comp.DataSet;

{ TConnection }

class function TConnection.GetConnection: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  try
    Result.DriverName := 'FB';
    Result.Params.Add('Server=localhost');
    Result.Params.Add(DB_PORT);
    Result.Params.Database := DB_PATH;
    Result.Params.UserName := DB_USER;
    Result.Params.Password := DB_PASS;
    Result.Connected := True;
  except
    on E: Exception do
    begin
      raise Exception.Create('Falha de conexão com o banco de dados: ' + E.Message);
    end;
  end;
end;

class procedure TConnection.Execute(const SQL: string);
var
  Query: TFDQuery;
  Conexao: TFDConnection;
begin
  Conexao := GetConnection;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := Conexao;
    Query.SQL.Text := SQL; 
    try
      if not Conexao.InTransaction then
        Conexao.StartTransaction;
      Query.ExecSQL; 
      Conexao.Commit;
    except on E: Exception do
      begin
        Conexao.Rollback;
        raise Exception.Create('Erro ao executar comando SQL: ' + E.Message);
      end;
    end;
  finally
    Query.Free;
    Conexao.Free;
  end;
end;

class function TConnection.Execute(const SQL: string; Table: TFDMemTable): TFDMemTable;
var
  Query: TFDQuery;
  Conexao: TFDConnection;
begin
  Conexao := GetConnection;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := Conexao;
    Query.SQL.Text := SQL; 
    try
      if not Conexao.InTransaction then
        Conexao.StartTransaction;
      Query.Open; 
      Table.CopyDataSet(Query, [coStructure, coRestart, coAppend]);
      Conexao.Commit;
    except on E: Exception do
      Conexao.Rollback;
    end;
  finally
    Query.Free;
    Conexao.Free;
  end;
end;

end.
