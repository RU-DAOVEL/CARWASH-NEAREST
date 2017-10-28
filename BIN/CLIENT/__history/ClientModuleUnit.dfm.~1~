object dmClient: TdmClient
  OldCreateOrder = False
  Height = 271
  Width = 415
  object SQLConnection1: TSQLConnection
    DriverName = 'DataSnap'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXDataSnap'
      
        'DriverAssemblyLoader=Borland.Data.TDBXClientDriverLoader,Borland' +
        '.Data.DbxClientDriver,Version=24.0.0.0,Culture=neutral,PublicKey' +
        'Token=91d62ebb5b0d1b1b'
      'Port=7777777'
      'HostName=192.168.0.10'
      'CommunicationProtocol=tcp/ip'
      'DSAuthenticationPassword=password'
      'DSAuthenticationUser=login'
      'DatasnapContext=datasnap/'
      'Filters={}')
    Connected = True
    Left = 48
    Top = 40
    UniqueId = '{46257349-69CA-4BAD-9880-1FCA01CB7B66}'
  end
  object DSProvider: TDSProviderConnection
    ServerClassName = 'TServerMethods'
    Connected = True
    SQLConnection = SQLConnection1
    Left = 136
    Top = 88
  end
  object cds_Services: TClientDataSet
    Active = True
    Aggregates = <>
    IndexFieldNames = 'WASH_ID;TYPE_ID'
    MasterFields = 'wash_id;id'
    MasterSource = ds_2
    PacketRecords = 0
    Params = <>
    ProviderName = 'VIEW_WASH_SERVICE'
    ReadOnly = True
    RemoteServer = DSProvider
    Left = 352
    Top = 112
    object cds_ServicesID: TLongWordField
      FieldName = 'ID'
      Origin = 'ID'
    end
    object cds_ServicesWASH_ID: TLongWordField
      FieldName = 'WASH_ID'
      Origin = 'WASH_ID'
      Required = True
    end
    object cds_ServicesTYPE_ID: TLongWordField
      FieldName = 'TYPE_ID'
      Origin = 'TYPE_ID'
    end
    object cds_ServicesTYPE_NAME: TWideStringField
      FieldName = 'TYPE_NAME'
      Origin = 'TYPE_NAME'
      Size = 255
    end
    object cds_ServicesSERVICE_ID: TLongWordField
      FieldName = 'SERVICE_ID'
      Origin = 'SERVICE_ID'
    end
    object cds_ServicesSERVICE_NAME: TWideStringField
      FieldName = 'SERVICE_NAME'
      Origin = 'SERVICE_NAME'
      Size = 255
    end
    object cds_ServicesWS_PRICE: TSingleField
      FieldName = 'WS_PRICE'
      Origin = 'WS_PRICE'
    end
    object cds_ServicesWS_DEL: TBooleanField
      FieldName = 'WS_DEL'
      Origin = 'WS_DEL'
    end
    object cds_ServicesPRICE_CREATE: TDateField
      FieldName = 'PRICE_CREATE'
      Origin = 'PRICE_CREATE'
    end
  end
  object ds_1: TDataSource
    DataSet = cds_Wash
    Left = 248
    Top = 56
  end
  object cds_Class: TClientDataSet
    Active = True
    Aggregates = <>
    IndexFieldNames = 'wash_id'
    MasterFields = 'ID'
    MasterSource = ds_1
    PacketRecords = 0
    Params = <
      item
        DataType = ftAutoInc
        Name = 'WASH_ID'
        ParamType = ptInput
        Value = 1
      end>
    ProviderName = 'CLASSAVTO'
    ReadOnly = True
    RemoteServer = DSProvider
    Left = 248
    Top = 112
  end
  object ds_2: TDataSource
    DataSet = cds_Class
    Left = 296
    Top = 112
  end
  object cds_Wash: TClientDataSet
    Active = True
    Aggregates = <>
    IndexFieldNames = 'id'
    Params = <>
    ProviderName = 'VIEW_WASH'
    ReadOnly = True
    RemoteServer = DSProvider
    Left = 248
    Top = 8
  end
end
