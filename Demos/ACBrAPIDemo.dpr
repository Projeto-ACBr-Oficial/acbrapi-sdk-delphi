program ACBrAPIDemo;

uses
  Vcl.Forms,
  Forms.Principal in 'Forms.Principal.pas' {fmMain},
  Forms.Empresa in 'Forms.Empresa.pas' {fmEmpresa},
  Forms.Certificado in 'Forms.Certificado.pas' {fmCertificado},
  Forms.DetalhesNfse in 'Forms.DetalhesNfse.pas' {fmDetalhesNfse},
  Forms.ConfigNFSe in 'Forms.ConfigNFSe.pas' {fmConfigNfse},
  Forms.EmitirNfse in 'Forms.EmitirNfse.pas' {fmEmitirNfse},
  Forms.ConfigNfce in 'Forms.ConfigNfce.pas' {fmConfigNfce},
  Forms.DetalhesNfce in 'Forms.DetalhesNfce.pas' {fmDetalhesNfce},
  Forms.EmitirNfce in 'Forms.EmitirNfce.pas' {fmEmitirNfce},
  ACBrAPIClient in '..\Source\ACBrAPIClient.pas',
  ACBrAPIDtos in '..\Source\ACBrAPIDtos.pas',
  ACBrAPIJson in '..\Source\ACBrAPIJson.pas',
  OpenApiHttp in '..\Source\OpenApiHttp.pas',
  OpenApiJson in '..\Source\OpenApiJson.pas',
  OpenApiRest in '..\Source\OpenApiRest.pas',
  OpenApiUtils in '..\Source\OpenApiUtils.pas',
  Forms.EmitirNfcom in 'Forms.EmitirNfcom.pas' {fmEmitirNfcom},
  Forms.DetalhesNfcom in 'Forms.DetalhesNfcom.pas' {fmDetalhesNFCom};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmEmitirNfcom, fmEmitirNfcom);
  Application.CreateForm(TfmDetalhesNFCom, fmDetalhesNFCom);
  Application.Run;
end.
