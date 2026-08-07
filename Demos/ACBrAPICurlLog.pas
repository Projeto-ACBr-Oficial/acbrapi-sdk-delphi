unit ACBrAPICurlLog;

{ Captura a requisicao HTTP montada pelo SDK Delphi da ACBr API e devolve
  um comando curl pronto para reproduzir a chamada (para envio ao suporte).

  Nao usa o endpoint /debug: engancha no evento OnClientCreated da fabrica de
  requisicoes (OpenApiHttp), que recebe a IHTTPRequest ja com URL, headers e
  body definidos, imediatamente antes do envio. }

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  OpenApiRest, OpenApiHttp;

type
  TACBrAPICurlProc = reference to procedure(const Curl: string);

  TACBrAPICurlLog = class
  strict private
    FFactoryRef: IRestRequestFactory;
    FOnCurl: TACBrAPICurlProc;
    FMascararToken: Boolean;
    procedure ClientCreated(Client: THttpClient; Request: IHTTPRequest);
    function LerBody(Request: IHTTPRequest): string;
    function MontarCurl(Request: IHTTPRequest): string;
  public
    constructor Create(AOnCurl: TACBrAPICurlProc; AMascararToken: Boolean = True);
    { Instala o hook no Config do cliente. O objeto retornado precisa continuar
      vivo enquanto o cliente for usado (guarde num campo do form/servico). }
    class function Instalar(Config: IRestConfig; AOnCurl: TACBrAPICurlProc;
      AMascararToken: Boolean = True): TACBrAPICurlLog;
  end;

implementation

{ Escapa para shell estilo bash: 'texto' com '\'' no lugar de aspa simples. }
function AspasSimples(const Value: string): string;
begin
  Result := '''' + StringReplace(Value, '''', '''\''''', [rfReplaceAll]) + '''';
end;

{ TACBrAPICurlLog }

constructor TACBrAPICurlLog.Create(AOnCurl: TACBrAPICurlProc; AMascararToken: Boolean);
begin
  inherited Create;
  if not Assigned(AOnCurl) then
    raise EArgumentException.Create('AOnCurl nao pode ser nil');
  FOnCurl := AOnCurl;
  FMascararToken := AMascararToken;
end;

class function TACBrAPICurlLog.Instalar(Config: IRestConfig;
  AOnCurl: TACBrAPICurlProc; AMascararToken: Boolean): TACBrAPICurlLog;
var
  Factory: THttpRestRequestFactory;
begin
  Result := TACBrAPICurlLog.Create(AOnCurl, AMascararToken);
  Factory := THttpRestRequestFactory.Create;
  Factory.OnClientCreated := Result.ClientCreated;
  Result.FFactoryRef := Factory;       // mantem a fabrica viva por refcount
  Config.RequestFactory := Result.FFactoryRef;
end;

procedure TACBrAPICurlLog.ClientCreated(Client: THttpClient; Request: IHTTPRequest);
begin
  FOnCurl(MontarCurl(Request));
end;

function TACBrAPICurlLog.LerBody(Request: IHTTPRequest): string;
var
  Origem: TStream;
  Copia: TStringStream;
  Pos: Int64;
begin
  Result := '';
  Origem := Request.SourceStream;
  if Origem = nil then
    Exit;

  Pos := Origem.Position;
  Copia := TStringStream.Create('', TEncoding.UTF8);
  try
    Origem.Position := 0;
    Copia.CopyFrom(Origem, 0);
    Result := Copia.DataString;
  finally
    Copia.Free;
    Origem.Position := Pos;            // obrigatorio: o envio le o stream depois
  end;
end;

function TACBrAPICurlLog.MontarCurl(Request: IHTTPRequest): string;
var
  Linhas: TStringList;
  Par: TNameValuePair;
  Valor, Body: string;
begin
  Linhas := TStringList.Create;
  try
    Linhas.Add('curl -X ' + Request.MethodString + ' ' +
      AspasSimples(Request.URL.ToString));

    for Par in Request.Headers do
    begin
      Valor := Par.Value;
      if FMascararToken and SameText(Par.Name, 'Authorization') then
        Valor := Copy(Valor, 1, Pos(' ', Valor + ' ')) + '***';
      Linhas.Add('  -H ' + AspasSimples(Par.Name + ': ' + Valor));
    end;

    Body := LerBody(Request);
    if Body <> '' then
      Linhas.Add('  --data-binary ' + AspasSimples(Body));

    Result := ''.Join(' \'#13#10, Linhas.ToStringArray);
  finally
    Linhas.Free;
  end;
end;

end.
