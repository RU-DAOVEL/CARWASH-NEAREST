object ServerMethods: TServerMethods
  OldCreateOrder = False
  Height = 557
  Width = 648
  object sqlConnection: TFDConnection
    Params.Strings = (
      'Database=carwash'
      'User_Name=root'
      'Password=root'
      'CharacterSet=utf8'
      'Server=localhost'
      'DriverID=MySQL')
    Connected = True
    LoginPrompt = False
    Left = 38
    Top = 15
  end
  object t_WashService: TFDQuery
    MasterSource = ds_Service
    MasterFields = 'id'
    Connection = sqlConnection
    SQL.Strings = (
      
        'SELECT * FROM carwash.wash_service  where carwash.wash_service.s' +
        'ervice_id = :SERVICE_ID')
    Left = 351
    Top = 388
    ParamData = <
      item
        Name = 'SERVICE_ID'
        DataType = ftAutoInc
        ParamType = ptInput
        Value = 1
      end>
  end
  object v_WashService: TFDQuery
    Active = True
    IndexFieldNames = 'ID'
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.view_wash_service')
    Left = 287
    Top = 7
  end
  object t_Wash: TFDQuery
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.wash')
    Left = 20
    Top = 217
  end
  object t_Service: TFDQuery
    IndexFieldNames = 'wash_id'
    MasterSource = ds_Wash
    MasterFields = 'id'
    DetailFields = 'wash_id'
    Connection = sqlConnection
    SQL.Strings = (
      
        'SELECT * FROM carwash.service where carwash.service.wash_id = :W' +
        'ASH_ID')
    Left = 259
    Top = 390
    ParamData = <
      item
        Name = 'WASH_ID'
        DataType = ftAutoInc
        ParamType = ptInput
        Value = 1
      end>
  end
  object t_Orders: TFDQuery
    IndexFieldNames = 'id'
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.orders')
    Left = 20
    Top = 389
  end
  object t_OrderItem: TFDQuery
    IndexFieldNames = 'id'
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.orderitem')
    Left = 115
    Top = 390
  end
  object t_JobTime: TFDQuery
    IndexFieldNames = 'wash_id'
    MasterSource = ds_Wash
    MasterFields = 'id'
    DetailFields = 'wash_id'
    Connection = sqlConnection
    SQL.Strings = (
      
        'SELECT * FROM carwash.jobtime where carwash.jobtime.wash_id = :W' +
        'ASH_ID')
    Left = 104
    Top = 213
    ParamData = <
      item
        Name = 'WASH_ID'
        DataType = ftAutoInc
        ParamType = ptInput
        Value = 1
      end>
  end
  object t_Client: TFDQuery
    Active = True
    IndexFieldNames = 'id'
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.client')
    Left = 334
    Top = 208
  end
  object t_ClassAvto: TFDQuery
    IndexFieldNames = 'wash_id'
    MasterSource = ds_Wash
    MasterFields = 'id'
    DetailFields = 'wash_id'
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.classavto '
      'where carwash.classavto.wash_id = :WASH_ID')
    Left = 252
    Top = 213
    ParamData = <
      item
        Name = 'WASH_ID'
        DataType = ftAutoInc
        ParamType = ptInput
        Value = 1
      end>
  end
  object t_Box: TFDQuery
    IndexFieldNames = 'wash_id'
    MasterSource = ds_Wash
    MasterFields = 'id'
    DetailFields = 'wash_id'
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.box where carwash.box.wash_id = :WASH_ID')
    Left = 179
    Top = 212
    ParamData = <
      item
        Name = 'WASH_ID'
        DataType = ftAutoInc
        ParamType = ptInput
        Value = 1
      end>
  end
  object WASH: TDataSetProvider
    DataSet = t_Wash
    Left = 24
    Top = 280
  end
  object JOBTIME: TDataSetProvider
    DataSet = t_JobTime
    Left = 104
    Top = 280
  end
  object BOX: TDataSetProvider
    DataSet = t_Box
    Left = 176
    Top = 280
  end
  object CLASSAVTO: TDataSetProvider
    DataSet = t_ClassAvto
    Left = 256
    Top = 280
  end
  object CLIENT: TDataSetProvider
    DataSet = t_Client
    Left = 336
    Top = 280
  end
  object ORDERS: TDataSetProvider
    DataSet = t_Orders
    Left = 24
    Top = 456
  end
  object ORDERS_ITEM: TDataSetProvider
    DataSet = t_OrderItem
    Left = 112
    Top = 456
  end
  object SERVICE: TDataSetProvider
    DataSet = t_Service
    Left = 264
    Top = 456
  end
  object v_Wash: TFDQuery
    Active = True
    IndexFieldNames = 'ID'
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.view_wash')
    Left = 158
    Top = 12
  end
  object v_OrderItem: TFDQuery
    IndexFieldNames = 'ORDERITEM_ID'
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.view_order_items')
    Left = 503
    Top = 16
  end
  object v_Orders: TFDQuery
    Active = True
    IndexFieldNames = 'ORDERS_ID'
    Connection = sqlConnection
    SQL.Strings = (
      'SELECT * FROM carwash.view_order')
    Left = 393
    Top = 18
  end
  object VIEW_WASH: TDataSetProvider
    DataSet = v_Wash
    Left = 160
    Top = 72
  end
  object VIEW_WASH_SERVICE: TDataSetProvider
    DataSet = v_WashService
    Left = 280
    Top = 72
  end
  object VIEW_ORDERS: TDataSetProvider
    DataSet = v_Orders
    Left = 392
    Top = 80
  end
  object VIEW_ORDERS_ITEM: TDataSetProvider
    DataSet = v_OrderItem
    Left = 504
    Top = 80
  end
  object WASH_SERVICE: TDataSetProvider
    DataSet = t_WashService
    Left = 360
    Top = 456
  end
  object t_WashClient: TFDQuery
    IndexFieldNames = 'wash_id'
    MasterSource = ds_Wash
    MasterFields = 'wash_id'
    DetailFields = 'wash_id'
    Connection = sqlConnection
    SQL.Strings = (
      
        'SELECT * FROM carwash.wash_client  where carwash.wash_client.was' +
        'h_id = :WASH_ID')
    Left = 418
    Top = 212
    ParamData = <
      item
        Name = 'WASH_ID'
        DataType = ftAutoInc
        ParamType = ptInput
        Value = 1
      end>
  end
  object WASH_CLIENT: TDataSetProvider
    DataSet = t_WashClient
    Left = 416
    Top = 280
  end
  object ds_Wash: TDataSource
    DataSet = t_Wash
    Left = 360
    Top = 144
  end
  object t_SQL: TFDQuery
    Connection = sqlConnection
    Left = 432
    Top = 360
  end
  object ds_Service: TDataSource
    DataSet = t_Service
    Left = 416
    Top = 144
  end
end
