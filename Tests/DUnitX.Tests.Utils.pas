{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Originally part of DUnitX, by Vincent Parrett & Contributors    }
{           Modified (C) 2026 Ian Branch (GITLAK Software) - gllDUnitX fork }
{                                                                           }
{           Licensed under the Apache License, Version 2.0                  }
{           http://www.apache.org/licenses/LICENSE-2.0                      }
{                                                                           }
{***************************************************************************}

unit DUnitX.Tests.Utils;

{$I DUnitX.inc}

interface

uses
  DUnitX.TestFramework,
{$IFDEF USE_NS}
  System.SysUtils,
  System.UITypes;
{$ELSE}
  SysUtils,
  UITypes;
{$ENDIF}

type
  /// <summary>
  ///   Tests for the TValue helper in <c>DUnitX.Utils</c>: the string-to-value conversion behind [TestCase]
  ///   arguments (dates, times, colours, numbers, enums, sets) across locales, range checking, and ToVarRec.
  /// </summary>
  [TestFixture('TValueHelper')]
  [Category('Utils')]
  TValueHelperTests = class
  private var
{$IFDEF DELPHI_XE_UP}
    /// <summary>The process FormatSettings captured at construction, restored by revertFormatSettings.</summary>
    originalFormatSettings : TFormatSettings;
{$ELSE}
    /// <summary>The thread locale captured at construction, restored by revertFormatSettings.</summary>
    originalLCID : Integer;
{$ENDIF}
  protected var
    /// <summary>The date every date test case must convert to: 2020-06-22.</summary>
    expectedDate : TDate;
    /// <summary>The time every time test case must convert to: 18:36:00.</summary>
    expectedTime : TTime;
  protected
    /// <summary>
    ///   Switches the global FormatSettings to the named locale, so conversions run as they would on that machine.
    /// </summary>
    /// <param name="locale">
    ///   A locale name such as 'EN-US', 'EN-GB' or 'DE'.
    /// </param>
    procedure setFormatSettings(const locale : string);
    /// <summary>
    ///   Restores the FormatSettings (or thread locale) captured at construction.
    /// </summary>
    procedure revertFormatSettings();
{$IFDEF DELPHI_2010}
    /// <summary>
    ///   Maps the three supported locale names to hard-coded LCIDs, for Delphi 2010 which lacks a name lookup.
    /// </summary>
    /// <param name="locale">
    ///   'EN-US', 'EN-GB' or 'DE'.
    /// </param>
    /// <returns>
    ///   The locale's LCID.
    /// </returns>
    /// <exception cref="Exception">
    ///   Raised for any other locale name.
    /// </exception>
    function GetLCIDFromLocale(const locale : string) : integer;
{$ENDIF}
  public
{$IFDEF DELPHI_XE_UP}
    /// <summary>
    ///   Captures the current format settings and sets the expected date and time. (Delphi 2010 did not call the
    ///   constructor, hence the AfterConstruction alternative.)
    /// </summary>
    constructor Create;
{$ELSE}
    /// <summary>
    ///   Captures the current thread locale and sets the expected date and time, on compilers that do not call the
    ///   fixture's constructor.
    /// </summary>
    procedure AfterConstruction; override;
{$ENDIF}
    /// <summary>
    ///   Restores the original format settings so the locale switches do not outlive the fixture.
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///   Proves a date string in the locale's own short format, or in ISO 8601, converts to TDate 2020-06-22 -
    ///   including German dates without leading zeroes or century.
    /// </summary>
    /// <param name="locale">
    ///   Locale to switch to before converting.
    /// </param>
    /// <param name="text">
    ///   The date text to convert.
    /// </param>
    [Test]
    [TestCase('EN-US local format', 'EN-US,06/22/2020')]
    [TestCase('EN-US iso8601 format', 'EN-US,2020-06-22')]
    [TestCase('EN-GB local format', 'EN-GB,22/06/2020')]
    [TestCase('EN-GB iso8601 format', 'EN-GB,2020-06-22')]
    [TestCase('DE local format', 'DE,22.06.2020')]
    [TestCase('DE local format, no leading zeroes', 'DE,22.6.2020')]
    [TestCase('DE local format, no explicit century', 'DE,22.06.20')]
    [TestCase('DE iso8601 format', 'DE,2020-06-22')]
    procedure TestDateConversion(const locale : string; const text : string);

    /// <summary>
    ///   Proves a time string in 12- or 24-hour form, with or without seconds or milliseconds, converts to TTime
    ///   18:36:00 under each locale.
    /// </summary>
    /// <param name="locale">
    ///   Locale to switch to before converting.
    /// </param>
    /// <param name="text">
    ///   The time text to convert.
    /// </param>
    [Test]
    [TestCase('EN-US local format, no leading zero, no seconds', 'EN-US,6:36 pm')]
    [TestCase('EN-US local format, with seconds', 'EN-US,06:36:00 PM')]
    [TestCase('DE local format, no seconds', 'DE,18:36')]
    [TestCase('DE local format, with seconds', 'DE,18:36:00')]
    [TestCase('DE iso8601 format', 'DE,18:36:00.000')]
    [TestCase('EN-GB local 12 h format', 'EN-GB,06:36 pm')]
    [TestCase('EN-GB local 24 h format', 'EN-GB,18:36')]
    procedure TestTimeConversion(const locale : string; const text : string);

    /// <summary>
    ///   Proves a date-time string in local or ISO 8601 form (T separator, Z, offset) converts through
    ///   TValue.TryConvert to 2020-06-22 18:36:00 under each locale.
    /// </summary>
    /// <param name="locale">
    ///   Locale to switch to before converting.
    /// </param>
    /// <param name="text">
    ///   The date-time text to convert.
    /// </param>
    [Test]
    [TestCase('EN-US local format, verbose', 'EN-US,06/22/2020 06:36:00 pm')]
    [TestCase('EN-US local format short', 'EN-US,6/22/2020 6:36 pm')]
    [TestCase('EN-US iso 8601 format', 'EN-US,2020-06-22 18:36:00')]
    [TestCase('EN-US iso 8601 format, verbose', 'EN-US,2020-06-22T18:36:00.000Z')]
    [TestCase('EN-GB local format, 24 h, verbose', 'EN-GB,22/06/2020 18:36:00')]
    [TestCase('EN-GB local format, 12 h, verbose', 'EN-GB,22/06/2020 06:36:00 pm')]
    [TestCase('EN-GB iso8601 format', 'EN-GB,2020-06-22 18:36')]
    [TestCase('EN-GB iso8601 format, verbose', 'EN-GB,2020-06-22T18:36:00+00')]
    [TestCase('DE local format, verbose', 'DE,22.06.2020 18:36:00.000')]
    [TestCase('DE local format, short', 'DE,22.6.20 18:36')]
    [TestCase('DE iso8601 format', 'DE,2020-06-22 18:36:00')]
    procedure TestDateTimeConversion(const locale : string; const text : string);

    /// <summary>
    ///   Proves the RTL's StrToDateTime parses the same local-format strings to 2020-06-22 18:36:00, as a baseline
    ///   for the TValue conversion.
    /// </summary>
    /// <param name="locale">
    ///   Locale to switch to before converting.
    /// </param>
    /// <param name="text">
    ///   The date-time text to convert.
    /// </param>
    /// <remarks>
    ///   ISO 8601 cases belong on TestDateTimeConversion (TValue.TryConvert): the RTL's StrToDateTime does not parse
    ///   those strings (Delphi 13.1, EN-US/EN-GB/DE). The previous {$IFDEF DELPHI_X8_UP} around them never compiled,
    ///   because DUnitX.inc defines DELPHI_XE8_UP.
    /// </remarks>
    [Test]
    [TestCase('EN-US local format, verbose', 'EN-US,06/22/2020 06:36:00 pm')]
    [TestCase('EN-US local format short', 'EN-US,6/22/2020 6:36 pm')]
    [TestCase('EN-GB local format, 24 h, verbose', 'EN-GB,22/06/2020 18:36:00')]
    [TestCase('EN-GB local format, 12 h, verbose', 'EN-GB,22/06/2020 06:36:00 pm')]
    [TestCase('DE local format, verbose', 'DE,22.06.2020 18:36:00.000')]
    [TestCase('DE local format, short', 'DE,22.6.20 18:36')]
    procedure TestDateTimeConversion2(const locale : string; const text : string);

    /// <summary>
    ///   Proves a TAlphaColor argument converts from an 'cla' name, a bare name in any case, a '$' hex literal or an
    ///   'x' hex literal, all to the same value.
    /// </summary>
    /// <param name="AColor">
    ///   The converted colour.
    /// </param>
    /// <param name="AColorOrd">
    ///   The colour's expected ordinal value.
    /// </param>
    [Test]
    [TestCase('claRed = xFFFF0000', 'claRed,xFFFF0000')]
    [TestCase('Red = xFFFF0000', 'Red,xFFFF0000')]
    [TestCase('red = xFFFF0000', 'red,xFFFF0000')]
    [TestCase('$FFFF0000 = xFFFF0000', '$FFFF0000,xFFFF0000')]
    [TestCase('xFFFF0000 = xFFFF0000', 'xFFFF0000,xFFFF0000')]
    procedure TestAlphaColorTestCase(const AColor : TAlphaColor; const AColorOrd : Cardinal);

    /// <summary>
    ///   Proves a VCL TColor argument converts from a 'cl' name in any case or a '$' hex literal.
    /// </summary>
    /// <param name="AColor">
    ///   The converted colour.
    /// </param>
    /// <param name="AColorOrd">
    ///   The colour's expected ordinal value.
    /// </param>
    [Test]
    [TestCase('clRed = 255', 'clRed,255')]
    [TestCase('clred = 255', 'clred,255')]
    [TestCase('clRed = $000000FF', 'clRed,$000000FF')]
    [TestCase('clBlue = $00FF0000', 'clBlue,$00FF0000')]
    [TestCase('$00FF0000 = $00FF0000', '$00FF0000,$00FF0000')]
    [TestCase('$000000FF = $000000FF', '$000000FF,$000000FF')]
    procedure TestColorTestCase(const AColor : TColor; const AColorOrd : Integer);

    /// <summary>
    ///   Proves a [TestCase] value that does not parse fails the conversion, not become 0 / a default: bad text,
    ///   empty text, out-of-range ordinals, an ambiguous thousands-or-decimal comma, unknown enum or set members,
    ///   and unknown colour, date or time names all return False without raising.
    /// </summary>
    [Test]
    procedure TryConvert_Fails_For_Values_That_Do_Not_Parse;

    /// <summary>
    ///   Proves valid values still convert, whatever the machine's decimal separator (run under DE); a decimal comma
    ///   is accepted where it cannot be read as a thousands separator.
    /// </summary>
    [Test]
    procedure TryConvert_Accepts_Valid_Values_In_Any_Locale;

    /// <summary>
    ///   Proves an ordinal or float value converts to a smaller ordinal type only when it fits, as a string value
    ///   already must: Integer 300 does not become Byte 44, -1 does not become a Cardinal, 2.5 does not become 2.
    /// </summary>
    [Test]
    procedure TryConvert_Ordinal_Fails_When_Out_Of_Range;

    /// <summary>
    ///   Proves an ambiguous numeric date has the same meaning on every machine (ISO 8601 / invariant first):
    ///   '01/02/2020' is 2 January 2020 under both EN-GB and EN-US.
    /// </summary>
    [Test]
    procedure TryConvert_Date_Meaning_Does_Not_Depend_On_Locale;

    /// <summary>
    ///   Proves ToVarRec gives a TVarRec whose VType matches the value and whose pointers read back the value: Int64
    ///   is handled, a float other than Extended is not read as 10 bytes, and strings point into the caller's
    ///   storage, not at a freed temporary. Issue #398 item 2.
    /// </summary>
    [Test]
    procedure ToVarRec_Reads_Back_The_Value;
  end;

  /// <summary>
  ///   Tests for <c>TDUnitXList&lt;T&gt;</c>, the framework's interfaced list.
  /// </summary>
  [TestFixture('TDUnitXList')]
  [Category('Utils')]
  TDUnitXListTests = class
  public
    /// <summary>
    ///   Proves ToArray returns the items in order, not nil. Issue #398 item 2.
    /// </summary>
    [Test]
    procedure ToArray_Returns_The_Items;

    /// <summary>
    ///   Proves the non-generic IEnumerable enumerator exists and yields the objects of a list of objects, then
    ///   stops. Issue #398 item 2.
    /// </summary>
    [Test]
    procedure NonGeneric_Enumerator_Yields_Objects;
  end;



implementation

uses

{$IFDEF USE_NS}
  System.DateUtils,
  System.Rtti,
  System.TypInfo,
  WinApi.Windows,
{$ELSE}
  DateUtils,
  Rtti,
  TypInfo,
  Windows,
{$ENDIF}
  DUnitX.Generics,
  DUnitX.Utils;

{ TValueHelperTests }

{$IFDEF DELPHI_XE_UP}
constructor TValueHelperTests.Create;

{$ELSE}
procedure TValueHelperTests.AfterConstruction;
{$ENDIF}
begin
  inherited;
{$IFDEF DELPHI_XE_UP}
  originalFormatSettings := {$IFDEF USE_NS}System.{$ENDIF}SysUtils.FormatSettings;
{$ELSE}
  originalLCID := GetThreadLocale;
{$ENDIF}

  expectedDate := EncodeDate(2020, 06, 22);
  expectedTime := EncodeTime(18, 36, 00, 000);
end;

destructor TValueHelperTests.Destroy;
begin
  revertFormatSettings();
  inherited;
end;

procedure TValueHelperTests.revertFormatSettings();
begin
{$IFDEF DELPHI_XE_UP}
{$IFDEF USE_NS}System.{$ENDIF}SysUtils.FormatSettings := originalFormatSettings;
{$ELSE}
  SetThreadLocale(originalLCID);
  GetFormatSettings;
{$ENDIF}
end;

{$IFDEF DELPHI_2010}
// I could not find a better way than hardcode them for D2010..
// Full list: https://docs.microsoft.com/en-us/openspecs/office_standards/ms-oe376/6c085406-a698-4e12-9d4d-c3b0ee3dbc4a
function TValueHelperTests.GetLCIDFromLocale(const locale : string) : integer;
begin
  if locale = 'EN-US' then
    result := 1033
  else if locale = 'EN-GB' then
    result := 2057
  else if locale = 'DE' then
    result := 1031
  else
    raise Exception.Create('Unsupported locale passed to GetLCIDFromLocale function');
end;
{$ENDIF}

procedure TValueHelperTests.setFormatSettings(const locale : string);
{$IFNDEF DELPHI_XE3_UP}
var
  _lcid : LCID;
{$ENDIF}
begin
{$IFNDEF DELPHI_XE3_UP}
{$IFDEF DELPHI_2010}
  _lcid := GetLCIDFromLocale(locale);
  SetThreadLocale(_lcid);
  GetFormatSettings;
{$ELSE}
  _lcid := LocaleNameToLCID(PChar(locale), 0);
  GetLocaleFormatSettings(_lcid, FormatSettings);
{$ENDIF}
{$ELSE}
  FormatSettings := TFormatSettings.Create(locale);
{$ENDIF}
end;

procedure TValueHelperTests.TestAlphaColorTestCase(const AColor : TAlphaColor;
  const AColorOrd : Cardinal);
begin
  Assert.AreEqual(AColorOrd, AColor);
end;

procedure TValueHelperTests.TestColorTestCase(const AColor : TColor;
  const AColorOrd : Integer);
begin
  Assert.AreEqual(AColorOrd, AColor);
end;

type
  TConvTestEnum = (cteOne, cteTwo, cteThree);
  TConvTestSet = set of TConvTestEnum;

procedure TValueHelperTests.TryConvert_Fails_For_Values_That_Do_Not_Parse;

  procedure CheckFails(const text : string; const target : PTypeInfo);
  var
    converted : TValue;
    ok : Boolean;
  begin
    try
      ok := TValue.From(text).TryConvert(target, converted);
    except
      on E : Exception do
      begin
        Assert.Fail(Format('[%s] -> %s raised %s: %s', [text, string(target.Name), E.ClassName, E.Message]));
        Exit;
      end;
    end;
    Assert.IsFalse(ok, Format('[%s] -> %s should not convert (got %s)', [text, string(target.Name), converted.ToString]));
  end;

begin
  CheckFails('abc', TypeInfo(Integer));
  CheckFails('', TypeInfo(Integer));
  CheckFails('300', TypeInfo(Byte));
  CheckFails('-1', TypeInfo(Cardinal));
  CheckFails('abc', TypeInfo(Int64));
  CheckFails('-1', TypeInfo(UInt64));
  CheckFails('1.5x', TypeInfo(Double));
  //A comma before exactly three digits is a thousands group in one locale and a decimal in another: ambiguous.
  CheckFails('1,000', TypeInfo(Double));
  CheckFails('-12,500', TypeInfo(Double));
  CheckFails('abc', TypeInfo(Single));
  CheckFails('Bogus', TypeInfo(TConvTestEnum));
  CheckFails('[cteOne,Bogus]', TypeInfo(TConvTestSet));
  CheckFails('notacolour', TypeInfo(TColor));
  CheckFails('notacolour', TypeInfo(TAlphaColor));
  CheckFails('notadate', TypeInfo(TDateTime));
  CheckFails('notadate', TypeInfo(TDate));
  CheckFails('notatime', TypeInfo(TTime));
end;

procedure TValueHelperTests.TryConvert_Ordinal_Fails_When_Out_Of_Range;
var
  converted : TValue;
begin
  Assert.IsFalse(TValue.From<Integer>(300).TryConvert(TypeInfo(Byte), converted), 'Integer 300 -> Byte');
  Assert.IsFalse(TValue.From<Integer>(-1).TryConvert(TypeInfo(Cardinal), converted), 'Integer -1 -> Cardinal');
  Assert.IsFalse(TValue.From<Int64>(5000000000).TryConvert(TypeInfo(Integer), converted), 'Int64 5e9 -> Integer');
  Assert.IsFalse(TValue.From<Integer>(7).TryConvert(TypeInfo(TConvTestEnum), converted), 'Integer 7 -> enum');
  Assert.IsFalse(TValue.From<Double>(300).TryConvert(TypeInfo(Byte), converted), 'Double 300 -> Byte');
  Assert.IsFalse(TValue.From<Double>(2.5).TryConvert(TypeInfo(Integer), converted), 'Double 2.5 -> Integer');
  Assert.IsFalse(TValue.From<Double>(1E30).TryConvert(TypeInfo(Int64), converted), 'Double 1E30 -> Int64');

  Assert.IsTrue(TValue.From<Integer>(200).TryConvert(TypeInfo(Byte), converted), 'Integer 200 -> Byte');
  Assert.AreEqual<Int64>(200, converted.AsOrdinal);
  Assert.IsTrue(TValue.From<Integer>(2).TryConvert(TypeInfo(TConvTestEnum), converted), 'Integer 2 -> enum');
  Assert.IsTrue(TValue.From<Double>(255).TryConvert(TypeInfo(Byte), converted), 'Double 255 -> Byte');
  Assert.AreEqual<Int64>(255, converted.AsOrdinal);
end;

procedure TValueHelperTests.TryConvert_Accepts_Valid_Values_In_Any_Locale;
var
  converted : TValue;
begin
  setFormatSettings('DE');
  Assert.IsTrue(TValue.From('255').TryConvert(TypeInfo(Byte), converted), 'Byte');
  Assert.AreEqual<Int64>(255, converted.AsOrdinal);
  Assert.IsTrue(TValue.From('-5').TryConvert(TypeInfo(Integer), converted), 'Integer');
  Assert.AreEqual(-5, converted.AsInteger);
  Assert.IsTrue(TValue.From('4294967295').TryConvert(TypeInfo(Cardinal), converted), 'Cardinal');
  Assert.AreEqual<Int64>(4294967295, converted.AsOrdinal);
  Assert.IsTrue(TValue.From('1.5').TryConvert(TypeInfo(Double), converted), 'Double 1.5');
  Assert.AreEqual(1.5, converted.AsExtended, 0);
  Assert.IsTrue(TValue.From('2,5').TryConvert(TypeInfo(Double), converted), 'Double 2,5');
  Assert.AreEqual(2.5, converted.AsExtended, 0);
  //A leading zero cannot start a thousands group, so this decimal comma is unambiguous.
  Assert.IsTrue(TValue.From('0,125').TryConvert(TypeInfo(Double), converted), 'Double 0,125');
  Assert.AreEqual(0.125, converted.AsExtended, 0);
  Assert.IsTrue(TValue.From('cteThree').TryConvert(TypeInfo(TConvTestEnum), converted), 'enum');
  Assert.AreEqual(Ord(cteThree), Integer(converted.AsOrdinal));
  Assert.IsTrue(TValue.From('[cteOne,cteThree]').TryConvert(TypeInfo(TConvTestSet), converted), 'set');
  Assert.IsTrue(converted.AsType<TConvTestSet> = [cteOne, cteThree], 'set value');
end;

procedure TValueHelperTests.TryConvert_Date_Meaning_Does_Not_Depend_On_Locale;
var
  converted : TValue;
  locale : string;
begin
  for locale in TArray<string>.Create('EN-GB', 'EN-US') do
  begin
    setFormatSettings(locale);
    Assert.IsTrue(TValue.From('01/02/2020').TryConvert(TypeInfo(TDate), converted), locale);
    Assert.IsSameDate(EncodeDate(2020, 1, 2), converted.AsType<TDate>, locale);
    Assert.IsTrue(TValue.From('2020-02-01 10:20:30').TryConvert(TypeInfo(TDateTime), converted), locale);
    Assert.IsSameDateTime(EncodeDateTime(2020, 2, 1, 10, 20, 30, 0), converted.AsType<TDateTime>, locale);
  end;
end;

procedure TValueHelperTests.ToVarRec_Reads_Back_The_Value;
var
  storage : TValue;
  storages : TArray<TValue>;
  rec : TVarRec;
  recs : TArray<TVarRec>;
begin
  rec := TValue.From<Int64>(1234567890123).ToVarRec(storage);
  Assert.AreEqual(Integer(vtInt64), Integer(rec.VType), 'Int64 VType');
  Assert.AreEqual<Int64>(1234567890123, rec.VInt64^, 'Int64 value');

  rec := TValue.From<Single>(1.5).ToVarRec(storage);
  Assert.AreEqual(Integer(vtExtended), Integer(rec.VType), 'Single VType');
  Assert.AreEqual(1.5, rec.VExtended^, 0, 'Single value');

  rec := TValue.From<Double>(2.5).ToVarRec(storage);
  Assert.AreEqual(Integer(vtExtended), Integer(rec.VType), 'Double VType');
  Assert.AreEqual(2.5, rec.VExtended^, 0, 'Double value');

  // Built from a string that is not a literal, so a dangling pointer would read freed memory.
  rec := TValue.From<string>(StringOfChar('x', 3) + 'y').ToVarRec(storage);
  Assert.AreEqual(Integer(vtUnicodeString), Integer(rec.VType), 'string VType');
  Assert.AreEqual('xxxy', UnicodeString(rec.VUnicodeString), False, 'string value');

  recs := TValue.ToVarRecs([TValue.From<Integer>(7), TValue.From<ShortString>('short'), TValue.From<string>('long'),
    TValue.From<Currency>(1.25), TValue.From<Double>(0.5)], storages);
  Assert.AreEqual('7 short long 1.25 0.50', Format('%d %s %s %.2f %.2f', recs, TFormatSettings.Invariant), False);
end;

procedure TValueHelperTests.TestDateConversion(const locale, text : string);
var
  asTValue : TValue;
  actual : TDate;
begin
  setFormatSettings(locale);
  Assert.IsTrue( TValue.From(text).TryConvert<TDate>(asTValue), 'TryConvert<TDate>' );
  Assert.IsTrue( asTValue.IsType<TDate>(), 'IsType TDate' );

  actual := asTValue.AsType<TDate>();
  Assert.IsSameDate(expectedDate, actual, 'SameDate(..)');
end;

procedure TValueHelperTests.TestDateTimeConversion(const locale, text : string);
var
  asTValue : TValue;
  expected, actual : TDateTime;
begin
  setFormatSettings(locale);
  Assert.IsTrue(TValue.From(text).TryConvert<TDateTime>(asTValue), 'TryConvert<TDateTime>');
  Assert.IsTrue(asTvalue.IsType<TDateTime>(), 'IsType TDateTime');

  expected := (expectedDate + expectedTime);
  actual := asTValue.AsType<TDateTime>();
  Assert.IsSameDateTime(expected, actual, 'SameDateTime(..)');
end;

procedure TValueHelperTests.TestDateTimeConversion2(const locale, text : string);
var
  expected, actual : TDateTime;
begin
  setFormatSettings(locale);

  expected := (expectedDate + expectedTime);
  actual := StrToDateTime(text);
  Assert.IsSameDateTime(expected, actual, 'SameDateTime(..)');
end;

procedure TValueHelperTests.TestTimeConversion(const locale, text : string);
var
  asTValue : TValue;
  actual : TTime;
begin
  setFormatSettings(locale);
  Assert.IsTrue(TValue.From(text).TryConvert<TTime>(asTValue), 'TryConvert<TTime>');
  Assert.IsTrue(asTvalue.IsType<TTime>(), 'IsType TTime');

  actual := asTValue.AsType<TTime>();
  Assert.IsSameTime(expectedTime, actual, 'SameTime(..)');
end;

{ TDUnitXListTests }

procedure TDUnitXListTests.ToArray_Returns_The_Items;
var
  list : IList<Integer>;
  items : TArray<Integer>;
begin
  list := TDUnitXList<Integer>.Create;
  list.AddRange([3, 1, 2]);
  items := list.ToArray;
  Assert.AreEqual(3, Length(items), 'Length');
  Assert.AreEqual(3, items[0]);
  Assert.AreEqual(1, items[1]);
  Assert.AreEqual(2, items[2]);
end;

procedure TDUnitXListTests.NonGeneric_Enumerator_Yields_Objects;
var
  list : IList<TObject>;
  first, second : TObject;
  enumerable : IEnumerable;
  enumerator : IEnumerator;
begin
  first := TObject.Create;
  second := TObject.Create;
  try
    list := TDUnitXList<TObject>.Create;
    list.Add(first);
    list.Add(second);
    enumerable := list;
    enumerator := enumerable.GetEnumerator;
    Assert.IsNotNull(enumerator, 'GetEnumerator');
    Assert.IsTrue(enumerator.MoveNext, 'MoveNext 1');
    Assert.AreSame(first, enumerator.Current, 'Current 1');
    Assert.IsTrue(enumerator.MoveNext, 'MoveNext 2');
    Assert.AreSame(second, enumerator.Current, 'Current 2');
    Assert.IsFalse(enumerator.MoveNext, 'MoveNext 3');
  finally
    second.Free;
    first.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TValueHelperTests);
  TDUnitX.RegisterTestFixture(TDUnitXListTests);

end.

