unit Forms.EmitirNfcom;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  ACBrAPIClient, ACBrAPIDtos, OpenApiRest;

type
  TfmEmitirNfcom = class(TForm)
    PageControl1: TPageControl;
    tsDados: TTabSheet;
    pnCertificado: TPanel;
    Label11: TLabel;
    cbAmbiente: TComboBox;
    GroupBox2: TGroupBox;
    Label42: TLabel;
    Label41: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    edCProd: TEdit;
    edXProd: TEdit;
    edCFOP: TEdit;
    edVProd: TEdit;
    GroupBox3: TGroupBox;
    Label3: TLabel;
    edEmitenteCpfCnpj: TEdit;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    edSerie: TEdit;
    edNumeroNota: TEdit;
    edCodigoMunicipioFatoGerador: TEdit;
    tsLog: TTabSheet;
    memoLog: TMemo;
    btOk: TButton;
    btCancelar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btOkClick(Sender: TObject);
  private
    Client: IACBrAPIClient;
    procedure EmitirNfcom;
  public
    class procedure Emitir(Client: IACBrAPIClient; Ambiente: string = '');
  end;

var
  fmEmitirNfcom: TfmEmitirNfcom;

implementation

uses System.DateUtils;

{$R *.dfm}

procedure TfmEmitirNfcom.btOkClick(Sender: TObject);
begin
  try
    EmitirNfcom;
    ModalResult := mrOk;
  except
    ModalResult := mrNone;
    raise;
  end;
end;

class procedure TfmEmitirNfcom.Emitir(Client: IACBrAPIClient; Ambiente: string);
var
  Form: TfmEmitirNfcom;
begin
  Form := TfmEmitirNfcom.Create(nil);
  try
    Form.cbAmbiente.ItemIndex := Form.cbAmbiente.Items.IndexOf(Ambiente);
    Form.Client := Client;
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfmEmitirNfcom.EmitirNfcom;
var
  PedidoEmissao: TNfcomPedidoEmissao;
  InfNFcom: TNfcomSefazInfNFCom;
  Det: TNfcomSefazDet;
  Nfcom: TDfe;
begin
  PedidoEmissao := TNfcomPedidoEmissao.Create;
  try
    PedidoEmissao.ambiente := cbAmbiente.Text;
    PedidoEmissao.InfNFcom := TNfcomSefazInfNFCom.Create;

    InfNFcom := PedidoEmissao.InfNFcom;
    InfNFcom.versao := '4.00';

    InfNFcom.ide := TNfcomSefazIde.Create;
    InfNFcom.ide.cUF := 35;
    InfNFcom.ide.&mod := 62;
    InfNFcom.ide.serie := StrToInt(edSerie.Text);
    InfNFcom.ide.nNF := StrToInt(edNumeroNota.Text);;
    InfNFcom.ide.dhEmi := Now;
    InfNFcom.ide.cMunFG := edCodigoMunicipioFatoGerador.Text;
    InfNFcom.ide.tpEmis := 1;
    InfNFcom.ide.verProc := 'nfcom-sdk-delphi';

    InfNFcom.emit := TNfcomSefazEmit.Create;

    if Length(edEmitenteCpfCnpj.Text) = 14 then
      InfNFcom.emit.CNPJ := edEmitenteCpfCnpj.Text
    else
      raise Exception.Create('CPF ou CNPJ do emitente inválido');

    InfNFcom.emit.enderEmit := TNfcomSefazEndeEmi.Create;
    InfNFcom.emit.EnderEmit.xLgr := '';
    InfNFcom.emit.EnderEmit.Nro := '';
    InfNFcom.emit.EnderEmit.xCpl := '';
    InfNFcom.emit.EnderEmit.xBairro := '';
    InfNFcom.emit.EnderEmit.cMun := '';
    InfNFcom.emit.EnderEmit.xMun := '';
    InfNFcom.emit.EnderEmit.CEP := '';
    InfNFcom.emit.EnderEmit.UF := '';
    InfNFcom.emit.EnderEmit.fone := '';
    InfNFcom.emit.enderEmit.email := 'endereco@provedor.com.br';

    Det := TNfcomSefazDet.Create;
    InfNFcom.det.Add(det);

    Det.nItem := 1;
    Det.prod := TNfcomSefazProd.Create;
    Det.prod.cProd := edCProd.Text;
    Det.prod.xProd := edXProd.Text;
    Det.prod.CFOP := edCFOP.Text;
    Det.prod.vProd := 1;

    Det.imposto := TNfcomSefazImposto.Create;
    Det.imposto.ICMS00 := TNfcomSefazICMS00.Create;
    Det.imposto.ICMS00.CST := '00';
    Det.imposto.ICMS00.vBC := 1;
    Det.imposto.ICMS00.pICMS := 10;
    Det.imposto.ICMS00.vICMS := 0.10;

    InfNFcom.total := TNfcomSefazTotal.Create;
    InfNFcom.total.ICMSTot := TNfcomSefazICMSTot.Create;
    InfNFcom.total.ICMSTot.vBC := Det.imposto.ICMS00.vBC;
    InfNFcom.total.ICMSTot.vICMS := Det.imposto.ICMS00.vICMS;

    InfNFcom.gFat := TNfcomSefazGFat.Create;
    InfNFcom.gFat.CompetFat := '01/2025';
    InfNFcom.gFat.dVencFat := StrToDate('01/02/2025');
    InfNFcom.gFat.dPerUsoIni := StrToDate('01/12/2025');
    InfNFcom.gFat.dPerUsoFim := StrToDate('31/12/2025');
    InfNFcom.gFat.codBarras := '123456789012345678901234567890123456789012345678';
    InfNFcom.gFat.codDebAuto := '12345678';
    InfNFcom.gFat.codBanco := '';
    InfNFcom.gFat.codAgencia := '';

    {InfNFcom.gFat.enderCorresp := TNfcomSefazEndeEmi.Create;
    InfNFcom.gFat.enderCorresp.xLgr := 'Endereco';
    InfNFcom.gFat.enderCorresp.Nro := '123';
    InfNFcom.gFat.enderCorresp.xCpl := '';
    InfNFcom.gFat.enderCorresp.xBairro := 'Centro';
    InfNFcom.gFat.enderCorresp.cMun := '';
    InfNFcom.gFat.enderCorresp.xMun := 'Cidade';
    InfNFcom.gFat.enderCorresp.CEP := '';
    InfNFcom.gFat.enderCorresp.UF := 'SP';
    InfNFcom.gFat.enderCorresp.fone := '33445566';
    InfNFcom.gFat.enderCorresp.email := 'endereco@provedor.com.br';

    InfNFcom.gFat.gPIX.urlQRCodePIX := '';}

    try
      Nfcom := Client.Nfcom.EmitirNfcom(PedidoEmissao);
      try
        ShowMessage(Format('Nota %s', [Nfcom.id]));
      finally
        Nfcom.Free;
      end;
    except
      on E: EOpenApiClientException do
      begin
        memoLog.Lines.Clear;
        memoLog.Lines.Add(E.ClassName);
        memoLog.Lines.Add(Format('HTTP Status Code: %d', [E.Response.StatusCode]));
        memoLog.Lines.Add(E.Response.ContentAsString);
        PageControl1.ActivePage := tsLog;
        raise;
      end;
    end;
  finally
    PedidoEmissao.Free;
  end;
end;

procedure TfmEmitirNfcom.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
end;

end.
