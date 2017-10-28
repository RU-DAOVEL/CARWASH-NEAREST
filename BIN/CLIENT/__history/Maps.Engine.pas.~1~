unit Maps.Engine;

// author: ZuBy
// e-mail: rzaripov1990@gmail.com
// Delphi XE10

interface

uses StrUtils, SysUtils, Classes, FMX.Dialogs, FMX.Types,

  System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, IdURI,

  FMX.Maps
{$IFDEF ANDROID}, FMX.Helpers.Android, Androidapi.JNI.GraphicsContentViewText,
  System.Sensors,
  Androidapi.JNI.Location, Androidapi.JNIBridge, Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Os, Androidapi.Helpers {$ENDIF};

type
  TMapsEngineType = (mtNone, mtGoogle, mtYandex, mtHere);

  TMapsEngineGeoData = record
    CountryCode: string;
    Country: string;
    AdministrativeArea: string;
    City: string;
    Address: string;
    HouseNum: string;
    Kind: string;
    FormattedAddress: string;
  end;

  TMapsEngineRouteInfo = record
    DistanceInMeter: Integer;
    DistanceAsString: String;
    DurationInSec: Integer;
    DurationAsString: string;
  end;

{$IFDEF ANDROID}

  TLocationListener = class(TJavaLocal, JLocationListener)
  private
    [weak]
    FParent: TFmxObject;
  public
    constructor Create(AParent: TFmxObject);
    procedure OnLocationChanged(Location: JLocation); cdecl;
    procedure OnProviderDisabled(provider: JString); cdecl;
    procedure OnProviderEnabled(provider: JString); cdecl;
    procedure OnStatusChanged(provider: JString; status: Integer;
      extras: JBundle); cdecl;
  end;

  TLocationChange = procedure(Sender: TObject;
    const OldLocation, NewLocation: TLocationCoord2D) of object;
{$ENDIF}

  TMapsEngine = class(TFmxObject)
  private
    aMapsType: TMapsEngineType;
    aYandexKey: string;
    aGoogleKey: string;
    aGoogleDistanceKey: string;
    aHereID, aHereAppCode: string;
{$IFDEF ANDROID}
    fLocationChange: TLocationChange;
    fActive: Boolean;
    fLocationManager: JLocationManager;
    locationListener: TLocationListener;
    fCoordinate: TMapCoordinate;
{$ENDIF}
  private
    function Parse(const Tag1, Tag2, source: string): string;
    function GetFormattedString(const aData: TMapsEngineGeoData;
      OnlyAddress: Boolean = false; CropString: Boolean = true): string;
    function DecoderPolyline(const aStr: String): String;
    function EncoderPolyline(const aValue: double): String;

{$IFDEF ANDROID}
    procedure SetActive(Value: Boolean);
{$ENDIF}

  const
    // for GET request for Geocoding
    GoogleURLGeo =
      'https://maps.googleapis.com/maps/api/geocode/xml?latlng=%s,%s&key=%s';
    YandexURLGeo = 'https://geocode-maps.yandex.ru/1.x/?geocode=%s,%s&result=1';
    HereURLGeo =
      'http://geocoder.cit.api.here.com/6.2/search.xml?searchtext=%s,%s&app_id=%s&app_code=%s&gen=1';

    // for GET request for ReverseGeocoding
    // YandexURLGeoReverseLoc = 'https://geocode-maps.yandex.ru/1.x/?geocode=%s&ll=%s,%s&spn=1,1&rspn=1&results=1';
    GoogleURLGeoReverse =
      'https://maps.googleapis.com/maps/api/geocode/xml?address=%s&key=%s';
    YandexURLGeoReverse =
      'https://geocode-maps.yandex.ru/1.x/?geocode=%s&result=1';
    HereURLGeoReverse =
      'http://geocoder.cit.api.here.com/6.2/search.xml?searchtext=%s&app_id=%s&app_code=%s&gen=1';

    RouteURL =
      'https://maps.googleapis.com/maps/api/directions/xml?origin=%s,%s&destination=%s,%s&mode=driving&key=%s';
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetOptionsNull;
    procedure SetOptionsGoogleRoute(const api_key: string); overload;
    procedure SetOptionsGoogle(const api_key: string); overload;
    procedure SetOptionsYandex(const api_key: string); overload;
    procedure SetOptionsHere(const api_id, app_code: string); overload;

    property MapsType: TMapsEngineType read aMapsType;

{$IFDEF ANDROID}
    property CurrentCoordinate: TMapCoordinate read fCoordinate;
{$ENDIF}
    function GetDistance(const aStart, aEnd: TMapCoordinate): Real;
    procedure Geocoding(const aLocation: TMapCoordinate;
      out aData: TMapsEngineGeoData);
    procedure GeocodingReverse(const aData: TMapsEngineGeoData;
      out aLocation: TMapCoordinate);
    procedure Route(const aOrigin, aDestination: TMapCoordinate;
      out Points: TArray<TMapCoordinate>; out RouteInfo: TMapsEngineRouteInfo);
{$IFDEF ANDROID}
    property Active: Boolean read fActive write SetActive;
    property OnLocationChanged: TLocationChange read fLocationChange
      write fLocationChange;
{$ENDIF}
  end;

implementation

{ TMapsEngine }
uses Math;

function TMapsEngine.EncoderPolyline(const aValue: double): String;
var
  v: Cardinal;
  b: Byte;
begin
  v := Round(aValue * 100000) shl 1;
  if aValue < 0 then
    v := not v;
  Result := '';
  repeat
    b := v and $1F;
    v := v shr 5;
    if v <> 0 then
      b := b or $20;
    Result := Result + Chr(b + 63);
  until v = 0;
end;

function TMapsEngine.DecoderPolyline(const aStr: String): String;
var
  i, k: Integer;
  Last: Boolean;
  c, b: Cardinal;
  Negativ: Boolean;
begin
  c := 0;
  k := 0;
  Result := '';
  for i := {$IFDEF MSWINDOWS}1{$ELSE}0{$ENDIF} to Length(aStr) do
  begin
    b := Ord(aStr[i]) - 63;
    Last := b < $20;
    b := b and $1F;
    c := c or (b shl k);
    if Last then
    begin
      Negativ := c and 1 <> 0;
      c := c shr 1;
      if Negativ then
        c := not c;
      Result := Result + FloatToStrF(Integer(c) / 100000, ffFixed, 12, 5) + ' ';
      c := 0;
      k := 0;
    end
    else
      Inc(k, 5);
  end;
end;

function TMapsEngine.Parse(const Tag1, Tag2, source: string): string;
var
  p, p2: Integer;
begin
  Result := '';
  p := StrUtils.PosEx(Tag1, source);

  p2 := StrUtils.PosEx(Tag2, source, p + Tag1.Length + 1);
  if (p = 0) or (p2 = 0) then
    exit;
  if p2 > p then
    Result := (Copy(source, p + Tag1.Length, p2 - p - Tag1.Length));
end;

procedure TMapsEngine.Route(const aOrigin, aDestination: TMapCoordinate;
  out Points: TArray<TMapCoordinate>; out RouteInfo: TMapsEngineRouteInfo);
var
  Return, Str, SubStr: String;
  StrMem: TStringStream;
  OrigLatitude, OrigLongitude: string;
  DestLatitude, DestLongitude: string;
  lastLat, lastLon, pointLat, pointLon: string;
  PosCounter: Integer;
  Buff: TFormatSettings;
  NetHTTPClient: TNetHTTPClient;
  i: Integer;
begin

  OrigLatitude := aOrigin.Latitude.ToString.Replace(',', '.');
  OrigLongitude := aOrigin.Longitude.ToString.Replace(',', '.');

  DestLatitude := aDestination.Latitude.ToString.Replace(',', '.');
  DestLongitude := aDestination.Longitude.ToString.Replace(',', '.');

  NetHTTPClient := TNetHTTPClient.Create(nil);
  NetHTTPClient.AllowCookies := true;
  NetHTTPClient.AcceptLanguage := 'ru-RU;q=0.8,en-US;q=0.5,en;q=0.3';
  try
    StrMem := TStringStream.Create('', TEncoding.UTF8);
    Str := (Format(RouteURL, [OrigLatitude, OrigLongitude, DestLatitude,
      DestLongitude, aGoogleDistanceKey]));
    StrMem.WriteString(Str);

    NetHTTPClient.Get(Str, StrMem);
    Return := StrMem.DataString;

    FreeAndNil(StrMem);
    FreeAndNil(NetHTTPClient);
  except
{$IFNDEF DEBUG}
    on e: exception do
    begin
      ShowMessage(e.Message);
    end;
{$ENDIF}
  end;
  Free;

  Buff := FormatSettings;
  FormatSettings.DecimalSeparator := '.';

  // запускаем счетчик символов
  PosCounter := pos('<step>', Return);
  while pos('<step>', Return) > 0 do
  begin
    // получаем блок step
    Str := Parse('<step>', '</step>', Return);

    // прибавляем все блоки step + 2 символа после замены
    PosCounter := PosCounter + Str.Length + 2;

    // получаем блок start_location
    SubStr := Parse('<start_location>', '</start_location>', Str);
    pointLat := Parse('<lat>', '</lat>', SubStr);
    pointLon := Parse('<lng>', '</lng>', SubStr);

    if (not pointLat.IsEmpty) and (not pointLon.IsEmpty) then
    begin
      SetLength(Points, Length(Points) + 1);
      with Points[Length(Points) - 1] do
      begin
        Latitude := pointLat.ToDouble;
        Longitude := pointLon.ToDouble;
      end;
    end;
    // ...

    // получаем блок points
    SubStr := Parse('<points>', '</points>', Str);
    if not SubStr.IsEmpty then
    begin
      SubStr := DecoderPolyline(SubStr);
      with TStringList.Create do
      begin
        // разделяем текст
        Delimiter := ' ';
        DelimitedText := SubStr;
        lastLat := Strings[0]; // нач. точка latitude
        lastLon := Strings[1]; // нач. точка longitude
        i := 2;
        while i < Count - 2 do
        begin
          pointLat := Strings[i]; // смещение latitude
          pointLon := Strings[i + 1]; // смещение longitude
          SetLength(Points, Length(Points) + 1);
          with Points[Length(Points) - 1] do
          begin
            Latitude := lastLat.ToDouble + pointLat.ToDouble;
            Longitude := lastLon.ToDouble + pointLon.ToDouble;
            lastLat := Latitude.ToString;
            // запоминаем последнее значение latitude
            lastLon := Longitude.ToString;
            // запоминаем последнее значение longitude
          end;
          Inc(i, 2);
        end;
        Free;
      end;
    end;
    // ...

    // получаем блок end_location
    SubStr := Parse('<end_location>', '</end_location>', Str);
    pointLat := Parse('<lat>', '</lat>', SubStr);
    pointLon := Parse('<lng>', '</lng>', SubStr);

    if (not pointLat.IsEmpty) and (not pointLon.IsEmpty) then
    begin
      SetLength(Points, Length(Points) + 1);
      with Points[Length(Points) - 1] do
      begin
        Latitude := pointLat.ToDouble;
        Longitude := pointLon.ToDouble;
      end;
    end;

    Return := StringReplace(Return, '<step>', '<step_>', []);
    Return := StringReplace(Return, '</step>', '</step_>', []);
  end;

  FormatSettings := Buff;

  // отсекаем всё лишнее
  Str := Copy(Return, PosCounter, MaxInt);
  if pos('</step_>', Str) > 0 then
  begin
    Delete(Str, 1, pos('</step_>', Str) + 8);
  end;
  // получаем блок duration
  SubStr := Parse('<duration>', '</duration>', Str);
  pointLat := Parse('<value>', '</value>', SubStr);
  pointLon := Parse('<text>', '</text>', SubStr);
  if (not pointLat.IsEmpty) and (not pointLon.IsEmpty) then
  begin
    RouteInfo.DurationInSec := pointLat.ToInteger;
    RouteInfo.DurationAsString := pointLon;
  end;

  // получаем блок distance
  SubStr := Parse('<distance>', '</distance>', Str);
  pointLat := Parse('<value>', '</value>', SubStr);
  pointLon := Parse('<text>', '</text>', SubStr);
  if (not pointLat.IsEmpty) and (not pointLon.IsEmpty) then
  begin
    RouteInfo.DistanceInMeter := pointLat.ToInteger;
    RouteInfo.DistanceAsString := pointLon;
  end;
end;
{$IFDEF ANDROID}

procedure TMapsEngine.SetActive(Value: Boolean);
var
  LocationManagerService: JObject;
  GPSLocation, NetowrkLocation: JLocation;
  New: TLocationCoord2D;
begin
  if Value = fActive then
    exit;
  fActive := Value;

  if Value then
  begin
    if not Assigned(fLocationManager) then
    begin
      LocationManagerService := SharedActivityContext.getSystemService
        (TJContext.JavaClass.LOCATION_SERVICE);
      fLocationManager := TJLocationManager.Wrap
        ((LocationManagerService as ILocalObject).GetObjectID);
      if not Assigned(locationListener) then
        locationListener := TLocationListener.Create(self);
      fLocationManager.requestLocationUpdates
        (TJLocationManager.JavaClass.GPS_PROVIDER, 10000, 10, locationListener,
        TJLooper.JavaClass.getMainLooper);
      fLocationManager.requestLocationUpdates
        (TJLocationManager.JavaClass.NETWORK_PROVIDER, 10000, 10,
        locationListener, TJLooper.JavaClass.getMainLooper);
    end;

    GPSLocation := fLocationManager.getLastKnownLocation
      (TJLocationManager.JavaClass.GPS_PROVIDER);
    NetowrkLocation := fLocationManager.getLastKnownLocation
      (TJLocationManager.JavaClass.NETWORK_PROVIDER);

    if Assigned(fLocationChange) then
    begin
      if Assigned(NetowrkLocation) then
      begin
        fCoordinate.Latitude := NetowrkLocation.getLatitude;
        fCoordinate.Longitude := NetowrkLocation.getLongitude;

        New.Latitude := NetowrkLocation.getLatitude;
        New.Longitude := NetowrkLocation.getLongitude;
      end;
      if Assigned(GPSLocation) then
      begin
        fCoordinate.Latitude := GPSLocation.getLatitude;
        fCoordinate.Longitude := GPSLocation.getLongitude;

        New.Latitude := GPSLocation.getLatitude;
        New.Longitude := GPSLocation.getLongitude;
      end;
    end;
  end
  else
  begin
    if Assigned(locationListener) then
      fLocationManager.removeUpdates(locationListener);
    if Assigned(fLocationManager) then
      fLocationManager := nil;
  end;
end;
{$ENDIF}

constructor TMapsEngine.Create;
begin
  aMapsType := TMapsEngineType.mtNone;
{$IFDEF ANDROID}
  fActive := false;
{$ENDIF}
end;

destructor TMapsEngine.Destroy;
begin
{$IFDEF ANDROID}
  SetActive(false);
{$ENDIF}
  inherited;
end;

procedure TMapsEngine.Geocoding(const aLocation: TMapCoordinate;
  out aData: TMapsEngineGeoData);
var
  Return, Str, SubStr: String;
  StrMem: TStringStream;
  aLatitude, aLongitude: string;
  // idSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  NetHTTPClient: TNetHTTPClient;
begin
  if aMapsType = TMapsEngineType.mtNone then
    exit;

  aLatitude := aLocation.Latitude.ToString.Replace(',', '.');
  aLongitude := aLocation.Longitude.ToString.Replace(',', '.');

  NetHTTPClient := TNetHTTPClient.Create(nil);
  NetHTTPClient.AllowCookies := true;
  // Request.AcceptLanguage := 'ru-RU;q=0.8,en-US;q=0.5,en;q=0.3';
  try
    StrMem := TStringStream.Create('', TEncoding.UTF8);
    case aMapsType of
      mtGoogle:
        Str := Format(GoogleURLGeo, [aLatitude, aLongitude, aGoogleKey]);
      mtYandex:
        Str := Format(YandexURLGeo, [aLongitude, aLatitude]);
      mtHere:
        Str := Format(HereURLGeo, [aLatitude, aLongitude, aHereID,
          aHereAppCode]);
    end;
    StrMem.WriteString(Str);

    if aMapsType <> TMapsEngineType.mtHere then
    begin

    end;

    NetHTTPClient.Get(Str, StrMem);
    Return := StrMem.DataString;
    FreeAndNil(StrMem);
    FreeAndNil(NetHTTPClient);
  except
    // on e: exception do
    // begin
    // ShowMessage(e.Message);
    // end;
    Free;
    exit;
  end;
  Free;

  case aMapsType of
    mtGoogle:
      begin
        {
          <type>street_address</type>
          <formatted_address>Bi-Boranbay Street 47, Semey 070000, Kazakhstan</formatted_address>
          <address_component>
          <long_name>47</long_name>
          <short_name>47</short_name>
          <type>street_number</type>
          </address_component>
          <address_component>
          <long_name>Bi-Boranbay Street</long_name>
          <short_name>Bi-Boranbay St</short_name>
          <type>route</type>
          </address_component>
          <address_component>
          <long_name>Semey</long_name>
          <short_name>Semey</short_name>
          <type>locality</type>
          <type>political</type>
          </address_component>
          <address_component>
          <long_name>East Kazakhstan Region</long_name>
          <short_name>ВКО</short_name>
          <type>administrative_area_level_1</type>
          <type>political</type>
          </address_component>
          <address_component>
          <long_name>Kazakhstan</long_name>
          <short_name>KZ</short_name>
          <type>country</type>
          <type>political</type>
          </address_component>
        }

        Str := Parse('<result>', '</result>', Return);
        if not Str.IsEmpty then
        begin
          while pos('<address_component>', Str) > 0 do
          begin
            SubStr := Parse('<address_component>', '</address_component>', Str);

            if pos('>street_number<', SubStr) > 0 then
              aData.HouseNum := Parse('<long_name>', '</long_name>', SubStr)
            else if pos('>route<', SubStr) > 0 then
              aData.Address := Parse('<long_name>', '</long_name>', SubStr)
            else if pos('>locality<', SubStr) > 0 then
              aData.City := Parse('<long_name>', '</long_name>', SubStr)
            else if (pos('>administrative_area_level_1<', SubStr) > 0) or
              (pos('>sublocality<', SubStr) > 0) then
              aData.AdministrativeArea :=
                Parse('<long_name>', '</long_name>', SubStr)
            else if pos('>country<', SubStr) > 0 then
            begin
              aData.Country := Parse('<long_name>', '</long_name>', SubStr);
              aData.CountryCode := Parse('<short_name>',
                '</short_name>', SubStr)
            end;
            aData.Kind := Parse('<type>', '</type>', Str);

            Str := StringReplace(Str, '<address_component>',
              '<address_component_done>', []);
            Str := StringReplace(Str, '</address_component>',
              '</address_component_done>', []);
          end;
          aData.FormattedAddress := GetFormattedString(aData, true);
        end;
      end;
    mtYandex:
      begin
        {
          <kind>house</kind>
          <CountryNameCode>KZ</CountryNameCode>
          <CountryName>Казахстан</CountryName>
          <AdministrativeAreaName>Восточно-Казахстанская область</AdministrativeAreaName>
          <LocalityName>Семей</LocalityName>
          <ThoroughfareName>улица Би Боранбай</ThoroughfareName>
          <PremiseNumber>45</PremiseNumber>
        }
        Str := Parse('<found>', '</found>', Return);
        if Str.ToInteger > 0 then
        begin
          aData.Kind := Parse('<kind>', '</kind>', Return);
          aData.CountryCode := Parse('<CountryNameCode>',
            '</CountryNameCode>', Return);
          aData.Country := Parse('<CountryName>', '</CountryName>', Return);
          aData.City := Parse('<LocalityName>', '</LocalityName>', Return);
          aData.AdministrativeArea := Parse('<AdministrativeAreaName>',
            '</AdministrativeAreaName>', Return);
          if aData.City = aData.AdministrativeArea then
            aData.AdministrativeArea := '';
          aData.Address := Parse('<ThoroughfareName>',
            '</ThoroughfareName>', Return);
          if trim(aData.Address) = '' then
            aData.Address := Parse('<DependentLocalityName>',
              '</DependentLocalityName>', Return);
          aData.HouseNum := Parse('<PremiseNumber>',
            '</PremiseNumber>', Return);

          aData.FormattedAddress := GetFormattedString(aData, true);
        end;
      end;
    mtHere:
      begin
        Str := Parse('<Address>', '</Address>', Return);
        if not Str.IsEmpty then
        begin
          {
            <MatchLevel>houseNumber</MatchLevel>
            <Country>KAZ</Country>
            <County>Астана</County>
            <City>Астана</City>
            <District>Алматы ауданы</District>
            <Street>Күйші Дина көшесі</Street>
            <HouseNumber>12</HouseNumber>
            <PostalCode>010010</PostalCode>
            <AdditionalData key="CountryName">Қазақстан</AdditionalData>
            <AdditionalData key="CountyName">Астана</AdditionalData>

            <MatchLevel>street</MatchLevel>
            <Country>KAZ</Country>
            <County>Шығыс Қазақстан Облысы</County>
            <City>Семей Ауданы</City>
            <District>Семей</District>
            <Street>Би-Боранбай көшесі</Street>
            <AdditionalData key="CountryName">Қазақстан</AdditionalData>
            <AdditionalData key="CountyName">Шығыс Қазақстан Облысы</AdditionalData>
          }
          aData.Kind := Parse('<MatchLevel>', '</MatchLevel>', Return);
          aData.CountryCode := Parse('<Country>', '</Country>', Str);
          aData.Country := Parse('<AdditionalData key="CountryName">',
            '</AdditionalData>', Str);
          aData.AdministrativeArea := Parse('<District>', '</District>', Str);
          aData.City := Parse('<City>', '</City>', Str);
          aData.Address := Parse('<Street>', '</Street>', Str);
          aData.HouseNum := Parse('<HouseNumber>', '</HouseNumber>', Str);

          aData.FormattedAddress := GetFormattedString(aData, true);
        end;
      end;
  end;
end;

function TMapsEngine.GetDistance(const aStart, aEnd: TMapCoordinate): Real;
const
  Radius = 6372795;
  PiDiv180 = Pi / 180;
var
  CosLatStart, SinLatStart, CosLatEnd, SinLatEnd, Delta, CosDelta, SinDelta,
    X, Y: Real;
begin
  try
    CosLatStart := Cos(aStart.Latitude * PiDiv180);
    CosLatEnd := Cos(aEnd.Latitude * PiDiv180);
    SinLatStart := Sin(aStart.Latitude * PiDiv180);
    SinLatEnd := Sin(aEnd.Latitude * PiDiv180);
    Delta := (aEnd.Longitude * PiDiv180) - (aStart.Longitude * PiDiv180);
    CosDelta := Cos(Delta);
    SinDelta := Sin(Delta);
    Y := Sqrt(((CosLatEnd * SinDelta) * (CosLatEnd * SinDelta)) +
      ((CosLatStart * SinLatEnd - SinLatStart * CosLatEnd * CosDelta) *
      (CosLatStart * SinLatEnd - SinLatStart * CosLatEnd * CosDelta)));
    X := SinLatStart * SinLatEnd + CosLatStart * CosLatEnd * CosDelta;
    Result := Round(ArcTan2(Y, X) * Radius);
  except
    Result := MaxSingle; // !!!!
  end;
end;

function TMapsEngine.GetFormattedString(const aData: TMapsEngineGeoData;
  OnlyAddress: Boolean = false; CropString: Boolean = true): string;

  function addToString(const Str: string; addSeparate: Boolean = true): string;
  var
    S: string;
  begin
    Result := '';
    S := Str;
    if S.IsEmpty then
      exit;
    if CropString then
    begin
      S := StringReplace(S, 'улица', 'ул.', [rfIgnoreCase]);
      S := StringReplace(S, 'переулок', 'пер.', [rfIgnoreCase]);
      S := StringReplace(S, 'проспект', 'пр-т', [rfIgnoreCase]);

      S := StringReplace(S, 'область', 'обл.', [rfIgnoreCase]);
      S := StringReplace(S, 'площадь', 'пл.', [rfIgnoreCase]);
      S := StringReplace(S, 'район', 'р-н', [rfIgnoreCase]);

      S := StringReplace(S, 'город', 'г.', [rfIgnoreCase]);
      S := StringReplace(S, 'поселок', 'пос.', [rfIgnoreCase]);
      S := StringReplace(S, 'шоссе', 'ш.', [rfIgnoreCase]);

      S := StringReplace(S, 'дом', 'д.', [rfIgnoreCase]);
      S := StringReplace(S, 'корпус', 'корп.', [rfIgnoreCase]);
      S := StringReplace(S, 'проезд', 'пр.', [rfIgnoreCase]);

      S := StringReplace(S, 'строение', 'стр.', [rfIgnoreCase]);
      S := StringReplace(S, 'набережная', 'наб.', [rfIgnoreCase]);
      S := StringReplace(S, 'проезд', 'пр.', [rfIgnoreCase]);

      S := StringReplace(S, 'село', 'с.', [rfIgnoreCase]);
      S := StringReplace(S, 'деревня', 'пос.', [rfIgnoreCase]);
    end;

    if addSeparate then
      Result := Result + S + ', '
    else
      Result := Result + S;
  end;

begin
  if OnlyAddress then
    Result := { addToString(aData.City) + } addToString(aData.Address) +
      addToString(aData.HouseNum, false)
  else
    Result := addToString(aData.Country) + addToString(aData.AdministrativeArea)
      + addToString(aData.City) + addToString(aData.Address) +
      addToString(aData.HouseNum, false);

  if Result.EndsWith(', ') then
    Result := Result.Remove(Result.Length - 2);
end;

procedure TMapsEngine.GeocodingReverse(const aData: TMapsEngineGeoData;
  out aLocation: TMapCoordinate);
var
  Return, Str, SubStr: String;
  StrMem: TStringStream;
  NetHTTPClient: TNetHTTPClient;
  // idSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  BuffFormat: TFormatSettings;

begin
  if (GetFormattedString(aData) = '') or (aMapsType = TMapsEngineType.mtNone)
  then
    exit;

  NetHTTPClient := TNetHTTPClient.Create(nil);
  NetHTTPClient.AllowCookies := true;
  // Request.AcceptLanguage := 'ru-RU;q=0.8,en-US;q=0.5,en;q=0.3';
  try
    StrMem := TStringStream.Create('', TEncoding.UTF8);
    case aMapsType of
      mtGoogle:
        Str := TIdURI.URLEncode(Format(GoogleURLGeoReverse,
          [GetFormattedString(aData), aGoogleKey]));
      mtYandex:
        Str := TIdURI.URLEncode(Format(YandexURLGeoReverse,
          [GetFormattedString(aData)]));
      mtHere:
        Str := TIdURI.URLEncode(Format(HereURLGeoReverse,
          [GetFormattedString(aData), aHereID, aHereAppCode]));
    end;
    StrMem.WriteString(Str);

    if aMapsType <> TMapsEngineType.mtHere then
    begin

    end;

    NetHTTPClient.Get(Str, StrMem);
    Return := StrMem.DataString;
    FreeAndNil(StrMem);
    FreeAndNil(NetHTTPClient);
  except
    Free;
    exit;
    // on e: exception do
    // begin
    // ShowMessage(e.Message);
    // end;
  end;
  Free;

  BuffFormat := FormatSettings;
  FormatSettings.DecimalSeparator := '.';
  case aMapsType of
    mtGoogle:
      begin
        Str := Parse('<location>', '</location>', Return);
        if not Str.IsEmpty then
          aLocation := TMapCoordinate.Create(Parse('<lat>', '</lat>', Str)
            .ToDouble, Parse('<lng>', '</lng>', Str).ToDouble);
      end;
    mtYandex:
      begin
        Str := Parse('<pos>', '</pos>', Return);
        if not Str.IsEmpty then
        begin
          SubStr := trim(Copy(Str,
{$IFDEF MSWINDOWS}1{$ELSE}0{$ENDIF}, StrUtils.PosEx(' ', Str) - 1));
          Delete(Str, 1, SubStr.Length + 1);
          aLocation := TMapCoordinate.Create(trim(Str).ToDouble,
            SubStr.ToDouble);
        end;
      end;
    mtHere:
      begin
        Str := Parse('<DisplayPosition>', '</DisplayPosition>', Return);
        if not Str.IsEmpty then
          aLocation := TMapCoordinate.Create(Parse('<Latitude>', '</Latitude>',
            Str).ToDouble, Parse('<Longitude>', '</Longitude>', Str).ToDouble);
      end;
  end;
  FormatSettings := BuffFormat;
end;

procedure TMapsEngine.SetOptionsGoogle(const api_key: string);
begin
  aGoogleKey := api_key;
  aMapsType := TMapsEngineType.mtGoogle;
end;

procedure TMapsEngine.SetOptionsGoogleRoute(const api_key: string);
begin
  aGoogleDistanceKey := api_key;
  aMapsType := TMapsEngineType.mtGoogle;
end;

procedure TMapsEngine.SetOptionsHere(const api_id, app_code: string);
begin
  aHereID := api_id;
  aHereAppCode := app_code;
  aMapsType := TMapsEngineType.mtHere;
end;

procedure TMapsEngine.SetOptionsNull;
begin
  aMapsType := TMapsEngineType.mtNone;
end;

procedure TMapsEngine.SetOptionsYandex(const api_key: string);
begin
  aYandexKey := '';
  aMapsType := TMapsEngineType.mtYandex;
end;

{ TLocationListener }
{$IFDEF ANDROID}

constructor TLocationListener.Create(AParent: TFmxObject);
begin
  inherited Create;
  FParent := (AParent as TMapsEngine);
end;

procedure TLocationListener.OnLocationChanged(Location: JLocation);
var
  New: TLocationCoord2D;
begin
  if (Assigned((FParent as TMapsEngine).OnLocationChanged)) and
    (Assigned(Location)) then
  begin
    New.Latitude := Location.getLatitude;
    New.Longitude := Location.getLongitude;
    (FParent as TMapsEngine).fCoordinate.Latitude := New.Latitude;
    (FParent as TMapsEngine).fCoordinate.Longitude := New.Longitude;

    (FParent as TMapsEngine).OnLocationChanged(FParent, New, New);
  end;
end;

procedure TLocationListener.OnProviderDisabled(provider: JString);
begin

end;

procedure TLocationListener.OnProviderEnabled(provider: JString);
begin

end;

procedure TLocationListener.OnStatusChanged(provider: JString; status: Integer;
  extras: JBundle);
begin

end;
{$ENDIF}

end.
