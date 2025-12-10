unit Forms.DetalhesNfcom;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  ACBrAPIDTOs;

type
  TfmDetalhesNFCom = class(TForm)
    PageControl1: TPageControl;
    tsDadosGerais: TTabSheet;
    Panel1: TPanel;
    lbId: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    edId: TEdit;
    edDataEmissao: TEdit;
    edNumeroNota: TEdit;
    edValorTotal: TEdit;
    edSituacao: TEdit;
    edChaveAcesso: TEdit;
    edAmbiente: TEdit;
    edReferencia: TEdit;
    gbAutorizacao: TGroupBox;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    edAutorizacaoSituacao: TEdit;
    edAutorizacaoDataHora: TEdit;
    memoAutorizacaoInfo: TMemo;
    btOk: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btOkClick(Sender: TObject);
  private
    FNfce: TDfe;
  public
    class procedure Visualizar(ANfcom: TDfe);
    procedure SetNfcom(Nfcom: TDfe);
  end;

var
  fmDetalhesNFCom: TfmDetalhesNFCom;

implementation

{$R *.dfm}

procedure TfmDetalhesNFCom.btOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfmDetalhesNFCom.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
end;

procedure TfmDetalhesNFCom.SetNfcom(Nfcom: TDfe);
begin
  FNfce := Nfcom;

  edId.Text := Nfcom.id;
  if Nfcom.data_emissaoHasValue and (Nfcom.data_emissao > 0) then
    edDataEmissao.Text := FormatDateTime('dd/mm/yyyy HH:nn:ss', Nfcom.data_emissao);
  edSituacao.Text := Nfcom.status;
  edNumeroNota.Text := IntToStr(Nfcom.numero);
  edAmbiente.Text := Nfcom.ambiente;
  edReferencia.Text := Nfcom.referencia;
  edValorTotal.Text := FormatFloat('#,0.00', Nfcom.valor_total);
  edChaveAcesso.Text := Nfcom.chave;

  gbAutorizacao.Visible := Nfcom.autorizacao <> nil;
  if Nfcom.autorizacao <> nil then
  begin
    edAutorizacaoSituacao.Text := Nfcom.autorizacao.status;
    if Nfcom.autorizacao.data_eventoHasValue then
      edAutorizacaoDataHora.Text := FormatDateTime('dd/mm/yyyy HH:nn:ss',
        Nfcom.autorizacao.data_evento);

    memoAutorizacaoInfo.Lines.Add(Format('Código Status: %d', [Nfcom.autorizacao.codigo_status]));
    memoAutorizacaoInfo.Lines.Add(Format('Motivo Status: %s', [Nfcom.autorizacao.motivo_status]));
    if Nfcom.autorizacao.digest_value <> '' then
      memoAutorizacaoInfo.Lines.Add(Format('Digest Value: %s', [Nfcom.autorizacao.digest_value]));
  end;
end;

class procedure TfmDetalhesNFCom.Visualizar(ANfcom: TDfe);
var
  Form: TfmDetalhesNfcom;
begin
  Form := TfmDetalhesNfcom.Create(nil);
  try
    Form.SetNfcom(ANfcom);
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

end.
