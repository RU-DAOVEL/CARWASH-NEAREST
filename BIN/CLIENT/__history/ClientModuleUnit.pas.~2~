unit ClientModuleUnit;

interface

uses
  System.SysUtils, System.Classes, Data.DBXDataSnap, ClientClassesUnit, Data.DBXCommon,
  IPPeerClient, Data.DB, Datasnap.DBClient, Datasnap.DSConnect, Data.SqlExpr;

type
  TdmClient = class(TDataModule)
    SQLConnection1: TSQLConnection;
    DSProvider: TDSProviderConnection;
    cds_Services: TClientDataSet;
    ds_1: TDataSource;
    cds_Class: TClientDataSet;
    ds_2: TDataSource;
    cds_Wash: TClientDataSet;
    cds_ServicesID: TLongWordField;
    cds_ServicesWASH_ID: TLongWordField;
    cds_ServicesTYPE_ID: TLongWordField;
    cds_ServicesTYPE_NAME: TWideStringField;
    cds_ServicesSERVICE_ID: TLongWordField;
    cds_ServicesSERVICE_NAME: TWideStringField;
    cds_ServicesWS_PRICE: TSingleField;
    cds_ServicesWS_DEL: TBooleanField;
    cds_ServicesPRICE_CREATE: TDateField;
  private
    FInstanceOwner: Boolean;
    FServerMethodsClient: TServerMethodsClient;
    function GetServerMethodsClient: TServerMethodsClient;
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property InstanceOwner: Boolean read FInstanceOwner write FInstanceOwner;
    property ServerMethodsClient: TServerMethodsClient read GetServerMethodsClient write FServerMethodsClient;
  end;

var
  dmClient: TdmClient;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

constructor TdmClient.Create(AOwner: TComponent);
begin
  inherited;
  FInstanceOwner := True;
end;

destructor TdmClient.Destroy;
begin
  FServerMethodsClient.Free;
  inherited;
end;

function TdmClient.GetServerMethodsClient: TServerMethodsClient;
begin
  if FServerMethodsClient = nil then
  begin
    SQLConnection1.Open;
    FServerMethodsClient := TServerMethodsClient.Create(SQLConnection1.DBXConnection, FInstanceOwner);
  end;
  Result := FServerMethodsClient;
end;

end.

