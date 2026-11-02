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
  System.SysUtils,
  System.UITypes;

type
  /// <summary>
  ///   Tests for the TValue helper in <c>DUnitX.Utils</c>: the string-to-value conversion behind [TestCase]
  ///   arguments (dates, times, colours, numbers, enums, sets) across locales, range checking, and ToVarRec.
  /// </summary>
  [TestFixture('TValueHelper')]
  [Category('Utils')]
  TValueHelperTests = class
  private var
    /// <summary>The process FormatSettings captured at construction, restored by revertFormatSettings.</summary>
    originalFormatSettings : TFormatSettings;
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
    ///   Restores the FormatSettings captured at construction.
    /// </summary>
    procedure revertFormatSettings();
    /// <summary>
    ///   Restores the FormatSettings after every test: many tests switch the locale, and one left switched would
    ///   change what the next test, run in any order, reads.
    /// </summary>
    [TearDown]
    procedure RestoreLocaleAfterEachTest;
  public
    /// <summary>
    ///   Captures the current format settings and sets the expected date and time.
    /// </summary>
    constructor Create;
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
    [NamedTestCase('EN-US local format', 'EN-US,06/22/2020')]
    [NamedTestCase('EN-US iso8601 format', 'EN-US,2020-06-22')]
    [NamedTestCase('EN-GB local format', 'EN-GB,22/06/2020')]
    [NamedTestCase('EN-GB iso8601 format', 'EN-GB,2020-06-22')]
    [NamedTestCase('DE local format', 'DE,22.06.2020')]
    [NamedTestCase('DE local format, no leading zeroes', 'DE,22.6.2020')]
    [NamedTestCase('DE iso8601 format', 'DE,2020-06-22')]
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
    [NamedTestCase('EN-US local format, no leading zero, no seconds', 'EN-US,6:36 pm')]
    [NamedTestCase('EN-US local format, with seconds', 'EN-US,06:36:00 PM')]
    [NamedTestCase('DE local format, no seconds', 'DE,18:36')]
    [NamedTestCase('DE local format, with seconds', 'DE,18:36:00')]
    [NamedTestCase('DE iso8601 format', 'DE,18:36:00.000')]
    [NamedTestCase('EN-GB local 12 h format', 'EN-GB,06:36 pm')]
    [NamedTestCase('EN-GB local 24 h format', 'EN-GB,18:36')]
    [NamedTestCase('FI local format, only the locale reads it', 'fi-FI,18.36')]
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
    [NamedTestCase('EN-US local format, verbose', 'EN-US,06/22/2020 06:36:00 pm')]
    [NamedTestCase('EN-US local format short', 'EN-US,6/22/2020 6:36 pm')]
    [NamedTestCase('EN-US iso 8601 format', 'EN-US,2020-06-22 18:36:00')]
    [NamedTestCase('EN-US iso 8601 format, verbose', 'EN-US,2020-06-22T18:36:00.000Z')]
    [NamedTestCase('EN-GB local format, 24 h, verbose', 'EN-GB,22/06/2020 18:36:00')]
    [NamedTestCase('EN-GB local format, 12 h, verbose', 'EN-GB,22/06/2020 06:36:00 pm')]
    [NamedTestCase('EN-GB iso8601 format', 'EN-GB,2020-06-22 18:36')]
    [NamedTestCase('EN-GB iso8601 format, verbose', 'EN-GB,2020-06-22T18:36:00+00')]
    [NamedTestCase('EN-GB iso8601, zone hh:mm', 'EN-GB,2020-06-22T18:36+02:00')]
    [NamedTestCase('EN-GB iso8601, zone hhmm', 'EN-GB,2020-06-22T18:36:00-0500')]
    [NamedTestCase('EN-GB iso8601, zone hh after a fraction', 'EN-GB,2020-06-22 18:36:00.000-05')]
    [NamedTestCase('NL iso8601 format, verbose', 'nl-NL,2020-06-22T18:36:00Z')]
    [NamedTestCase('DE local format, verbose', 'DE,22.06.2020 18:36:00.000')]
    [NamedTestCase('DE local format, short', 'DE,22.6.2020 18:36')]
    [NamedTestCase('DE iso8601 format', 'DE,2020-06-22 18:36:00')]
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
    [NamedTestCase('EN-US local format, verbose', 'EN-US,06/22/2020 06:36:00 pm')]
    [NamedTestCase('EN-US local format short', 'EN-US,6/22/2020 6:36 pm')]
    [NamedTestCase('EN-GB local format, 24 h, verbose', 'EN-GB,22/06/2020 18:36:00')]
    [NamedTestCase('EN-GB local format, 12 h, verbose', 'EN-GB,22/06/2020 06:36:00 pm')]
    [NamedTestCase('DE local format, verbose', 'DE,22.06.2020 18:36:00.000')]
    [NamedTestCase('DE local format, short', 'DE,22.6.20 18:36')]
    procedure TestDateTimeConversion2(const locale : string; const text : string);

    /// <summary>
    ///   Proves a non-ISO date converts only when the invariant format and the locale agree on it, or only one of them
    ///   reads it: '01/02/2020' is 2 January under EN-US, is refused under EN-GB (1 February there, 2 January
    ///   invariant), and a year-first locale does not misread a day-first date.  A 2-digit year is not taken for ISO
    ///   8601.  Upstream #528.
    /// </summary>
    /// <param name="locale">
    ///   Locale to switch to before converting.
    /// </param>
    /// <param name="text">
    ///   The date text to convert.
    /// </param>
    /// <param name="year">
    ///   The expected year, or 0 when the text must not convert.
    /// </param>
    /// <param name="month">
    ///   The expected month.
    /// </param>
    /// <param name="day">
    ///   The expected day.
    /// </param>
    [Test]
    [NamedTestCase('EN-US 01/02/2020, both readings agree', 'EN-US,01/02/2020,2020,1,2')]
    [NamedTestCase('EN-GB 01/02/2020, the readings disagree', 'EN-GB,01/02/2020,0,0,0')]
    [NamedTestCase('EN-GB 22/06/2020, only the locale reads it', 'EN-GB,22/06/2020,2020,6,22')]
    [NamedTestCase('DE 01/02/2020, only the invariant format reads it', 'DE,01/02/2020,2020,1,2')]
    [NamedTestCase('NL 22-06-20, a two-digit year: 22 June 2020 or 20 June 2022', 'nl-NL,22-06-20,0,0,0')]
    [NamedTestCase('EN-US 6/22/20, a two-digit year', 'EN-US,6/22/20,0,0,0')]
    [NamedTestCase('DE 22.06.20, a two-digit year', 'DE,22.06.20,0,0,0')]
    [NamedTestCase('SK 22. 6. 2020, spaces inside the date', 'sk-SK,22. 6. 2020,2020,6,22')]
    [NamedTestCase('NL 22-06-2020, a four-digit year in the locale order', 'nl-NL,22-06-2020,2020,6,22')]
    [NamedTestCase('NL iso8601 format', 'nl-NL,2020-06-22,2020,6,22')]
    [NamedTestCase('JA 22/06/2020, not in the locale order', 'ja-JP,22/06/2020,0,0,0')]
    procedure Date_Converts_Only_When_Its_Meaning_Is_Unambiguous(const locale : string; const text : string;
      const year, month, day : Word);

    /// <summary>
    ///   Proves the same rule for a TDateTime (time 10:30 where it converts), and that a year is never taken for an
    ///   hour: '22/06/2020' under a year-first locale used to become 20 June 2022 at 20:00.  ISO 8601 with each zone
    ///   form converts.  Upstream #528.
    /// </summary>
    /// <param name="locale">
    ///   Locale to switch to before converting.
    /// </param>
    /// <param name="text">
    ///   The date-time text to convert.
    /// </param>
    /// <param name="year">
    ///   The expected year, or 0 when the text must not convert.
    /// </param>
    /// <param name="month">
    ///   The expected month.
    /// </param>
    /// <param name="day">
    ///   The expected day.
    /// </param>
    [Test]
    [NamedTestCase('EN-US 01/02/2020 10:30, both readings agree', 'EN-US,01/02/2020 10:30,2020,1,2')]
    [NamedTestCase('EN-GB 01/02/2020 10:30, the readings disagree', 'EN-GB,01/02/2020 10:30,0,0,0')]
    [NamedTestCase('NL 22-06-20 10:30, a two-digit year', 'nl-NL,22-06-20 10:30,0,0,0')]
    [NamedTestCase('NL 22-06-2020 10:30, a four-digit year in the locale order', 'nl-NL,22-06-2020 10:30,2020,6,22')]
    [NamedTestCase('FI 22.06.20, a two-digit year that also reads as a time', 'fi-FI,22.06.20,0,0,0')]
    [NamedTestCase('EN-US 6/22/20 10:30:00.0123, four digits that are not the year', 'EN-US,6/22/20 10:30:00.0123,0,0,0')]
    [NamedTestCase('EN-US 1/2/20 0010, four digits that are not the year', 'EN-US,1/2/20 0010,0,0,0')]
    [NamedTestCase('DE iso8601 format, verbose', 'DE,2020-06-22T10:30:00.000Z,2020,6,22')]
    [NamedTestCase('JA 22/06/2020, the year is not an hour', 'ja-JP,22/06/2020,0,0,0')]
    [NamedTestCase('JA 22/06/2020 10:30, not in the locale order', 'ja-JP,22/06/2020 10:30,0,0,0')]
    [NamedTestCase('ZH 22/06/2020 10:30, not in the locale order', 'zh-CN,22/06/2020 10:30,0,0,0')]
    [NamedTestCase('SV 22-06-2020, the year is not an hour', 'sv-SE,22-06-2020,0,0,0')]
    [NamedTestCase('SV 1-2-2020, the year is not an hour', 'sv-SE,1-2-2020,0,0,0')]
    procedure DateTime_Converts_Only_When_Its_Meaning_Is_Unambiguous(const locale : string; const text : string;
      const year, month, day : Word);

    /// <summary>
    ///   Proves a time with no date still converts to a TDateTime: the rule that a date needs a four-digit year
    ///   (Ian, 2026-11-02) applies only to text that holds a date, and a time has no year to write.
    /// </summary>
    /// <param name="locale">
    ///   Locale to switch to before converting.
    /// </param>
    /// <param name="text">
    ///   The time text to convert.
    /// </param>
    /// <param name="hour">
    ///   The expected hour.
    /// </param>
    /// <param name="minute">
    ///   The expected minute.
    /// </param>
    /// <param name="second">
    ///   The expected second.
    /// </param>
    [Test]
    [NamedTestCase('EN-GB 10:30', 'EN-GB,10:30,10,30,0')]
    [NamedTestCase('NL 10:30:15', 'nl-NL,10:30:15,10,30,15')]
    [NamedTestCase('FI 18.36, only the locale reads it', 'fi-FI,18.36,18,36,0')]
    procedure Time_Without_A_Date_Converts_To_A_DateTime(const locale : string; const text : string;
      const hour, minute, second : Word);

    /// <summary>
    ///   Proves what each locale itself writes (DateTimeToStr, DateToStr, TimeToStr) reads back as the same value,
    ///   including the Korean afternoon marker written before the time, which used to read as the morning.
    ///   Upstream #528.
    /// </summary>
    /// <param name="locale">
    ///   Locale to switch to before formatting and converting.
    /// </param>
    [Test]
    [NamedTestCase('EN-US', 'EN-US')]
    [NamedTestCase('EN-GB', 'EN-GB')]
    [NamedTestCase('DE', 'DE')]
    [NamedTestCase('NL', 'nl-NL')]
    [NamedTestCase('JA', 'ja-JP')]
    [NamedTestCase('ZH', 'zh-CN')]
    [NamedTestCase('FI', 'fi-FI')]
    [NamedTestCase('SV', 'sv-SE')]
    [NamedTestCase('KO, the afternoon marker before the time', 'ko-KR')]
    procedure Date_And_Time_Formatted_In_The_Locale_Read_Back(const locale : string);

    /// <summary>
    ///   Proves a value that starts like ISO 8601 but is not (trailing or embedded text, a one-digit field, an hour
    ///   without minutes, an impossible day or hour, a one-digit zone, a point with no digit) does not convert to
    ///   TDate or TDateTime, rather than being read in part.  Upstream #528.
    /// </summary>
    /// <param name="text">
    ///   The text to convert, under EN-GB.
    /// </param>
    [Test]
    [NamedTestCase('Text inside', '2020-06-22 foo 18:36')]
    [NamedTestCase('Text after the time', '2020-06-22 18:36 extra')]
    [NamedTestCase('Text after a space', '2020-06-22 xyz')]
    [NamedTestCase('Text after the date', '2020-06-22X')]
    [NamedTestCase('One-digit month', '2020-6-22')]
    [NamedTestCase('Hour only', '2020-06-22 18')]
    [NamedTestCase('No such day', '2020-02-30')]
    [NamedTestCase('No such hour', '2020-06-22T25:00')]
    [NamedTestCase('One-digit zone', '2020-06-22T18:36+2')]
    [NamedTestCase('No digit after the point', '2020-06-22T18:36:00.')]
    procedure Iso8601_Lookalike_Does_Not_Convert(const text : string);

    /// <summary>
    ///   Proves the digits after an ISO 8601 point are a decimal fraction of a second: '.5' is 500 ms, not 5 ms, and
    ///   digits beyond the millisecond are accepted.  Upstream #528.
    /// </summary>
    /// <param name="text">
    ///   The date-time text to convert.
    /// </param>
    /// <param name="milliseconds">
    ///   The expected milliseconds.
    /// </param>
    [Test]
    [NamedTestCase('One digit', '2020-06-22T18:36:00.5,500')]
    [NamedTestCase('Two digits', '2020-06-22T18:36:00.25,250')]
    [NamedTestCase('Three digits', '2020-06-22T18:36:00.123,123')]
    [NamedTestCase('Six digits', '2020-06-22 18:36:00.123456,123')]
    procedure Iso8601_Fraction_Is_A_Fraction_Of_A_Second(const text : string; const milliseconds : Word);

    /// <summary>
    ///   Proves the same for an ISO 8601 time on its own converted to TTime, after a point or a comma, and with a zone.
    ///   Upstream #528.
    /// </summary>
    /// <param name="text">
    ///   The time text to convert, under EN-GB.
    /// </param>
    /// <param name="milliseconds">
    ///   The expected milliseconds.
    /// </param>
    [Test]
    [NamedTestCase('Point', '18:36:00.5;500', ';')]
    [NamedTestCase('Comma', '18:36:00,25;250', ';')]
    [NamedTestCase('Zone', '18:36:00.5Z;500', ';')]
    procedure Iso8601_Time_Fraction_Is_A_Fraction_Of_A_Second(const text : string; const milliseconds : Word);

    /// <summary>
    ///   Proves the same for an ISO 8601 time on its own converted to TDateTime.  Upstream #528.
    /// </summary>
    /// <param name="text">
    ///   The time text to convert, under EN-GB.
    /// </param>
    /// <param name="milliseconds">
    ///   The expected milliseconds.
    /// </param>
    [Test]
    [NamedTestCase('Point', '18:36:00.5;500', ';')]
    [NamedTestCase('Zone', '18:36:00.25Z;250', ';')]
    procedure Iso8601_Time_As_DateTime_Fraction_Is_A_Fraction_Of_A_Second(const text : string;
      const milliseconds : Word);

    /// <summary>
    ///   Proves a time with an hour or minute out of range does not convert, where it used to become midnight.
    ///   Upstream #528.
    /// </summary>
    /// <param name="text">
    ///   The time text to convert, under EN-GB.
    /// </param>
    [Test]
    [NamedTestCase('No such hour', '25:00')]
    [NamedTestCase('No such minute', '18:60')]
    procedure Time_Out_Of_Range_Does_Not_Convert(const text : string);

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
    [NamedTestCase('claRed = xFFFF0000', 'claRed,xFFFF0000')]
    [NamedTestCase('Red = xFFFF0000', 'Red,xFFFF0000')]
    [NamedTestCase('red = xFFFF0000', 'red,xFFFF0000')]
    [NamedTestCase('$FFFF0000 = xFFFF0000', '$FFFF0000,xFFFF0000')]
    [NamedTestCase('xFFFF0000 = xFFFF0000', 'xFFFF0000,xFFFF0000')]
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
    [NamedTestCase('clRed = 255', 'clRed,255')]
    [NamedTestCase('clred = 255', 'clred,255')]
    [NamedTestCase('clRed = $000000FF', 'clRed,$000000FF')]
    [NamedTestCase('clBlue = $00FF0000', 'clBlue,$00FF0000')]
    [NamedTestCase('$00FF0000 = $00FF0000', '$00FF0000,$00FF0000')]
    [NamedTestCase('$000000FF = $000000FF', '$000000FF,$000000FF')]
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
    ///   Proves a hex [TestCase] integer that fits its type's unsigned width is read as that type's bit pattern, as in
    ///   code ('$FFFFFFFF' is the Integer -1, '$FF' the ShortInt -1, '0xFFFF' the SmallInt -1), in every hex
    ///   spelling and with a leading space or '+'; an unsigned type keeps the plain value; and a hex value that does
    ///   not fit the width, or a subrange that does not cover its width, is only range-checked.  Upstream #522.
    /// </summary>
    [Test]
    procedure Hex_Integer_Is_Read_As_A_Bit_Pattern_Of_Its_Type;

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

  System.DateUtils,
  System.RegularExpressions,
  System.Rtti,
  System.TypInfo,
  Winapi.Windows,
  DUnitX.Generics,
  DUnitX.Utils;

{ TValueHelperTests }

constructor TValueHelperTests.Create;

begin
  inherited;
  originalFormatSettings := System.SysUtils.FormatSettings;

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
  System.SysUtils.FormatSettings := originalFormatSettings;
end;

procedure TValueHelperTests.RestoreLocaleAfterEachTest;
begin
  revertFormatSettings();
end;

procedure TValueHelperTests.setFormatSettings(const locale : string);
begin
  FormatSettings := TFormatSettings.Create(locale);
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

type
  //A signed type that does not cover its whole width
  TSignedSubrange = -10..10;

procedure TValueHelperTests.Hex_Integer_Is_Read_As_A_Bit_Pattern_Of_Its_Type;
var
  asTValue : TValue;
begin
  Assert.IsTrue(TValue.From<string>('$FFFFFFFF').TryConvert<Integer>(asTValue), '''$FFFFFFFF'' to Integer');
  Assert.AreEqual(-1, asTValue.AsInteger, '''$FFFFFFFF'' to Integer');
  Assert.IsTrue(TValue.From<string>('$FF').TryConvert<ShortInt>(asTValue), '''$FF'' to ShortInt');
  Assert.AreEqual(-1, asTValue.AsInteger, '''$FF'' to ShortInt');
  Assert.IsTrue(TValue.From<string>('0xFFFF').TryConvert<SmallInt>(asTValue), '''0xFFFF'' to SmallInt');
  Assert.AreEqual(-1, asTValue.AsInteger, '''0xFFFF'' to SmallInt');
  Assert.IsTrue(TValue.From<string>('x7F').TryConvert<ShortInt>(asTValue), '''x7F'' to ShortInt');
  Assert.AreEqual(127, asTValue.AsInteger, '''x7F'' to ShortInt');
  Assert.IsTrue(TValue.From<string>('$FF').TryConvert<Byte>(asTValue), '''$FF'' to Byte');
  Assert.AreEqual(255, asTValue.AsInteger, '''$FF'' to Byte');
  Assert.IsTrue(TValue.From<string>('$FFFFFFFF').TryConvert<Cardinal>(asTValue), '''$FFFFFFFF'' to Cardinal');
  Assert.AreEqual(Int64(4294967295), asTValue.AsInt64, '''$FFFFFFFF'' to Cardinal');
  Assert.IsTrue(TValue.From<string>(' $FFFFFFFF').TryConvert<Integer>(asTValue), ''' $FFFFFFFF'' to Integer');
  Assert.AreEqual(-1, asTValue.AsInteger, ''' $FFFFFFFF'' to Integer');
  Assert.IsTrue(TValue.From<string>('+$FFFFFFFF').TryConvert<Integer>(asTValue), '''+$FFFFFFFF'' to Integer');
  Assert.AreEqual(-1, asTValue.AsInteger, '''+$FFFFFFFF'' to Integer');
  //A decimal value is never a bit pattern, and a hex value wider than the type does not fit
  Assert.IsFalse(TValue.From<string>('2147483648').TryConvert<Integer>(asTValue), '''2147483648'' to Integer');
  Assert.IsFalse(TValue.From<string>('$100').TryConvert<Byte>(asTValue), '''$100'' to Byte');
  Assert.IsFalse(TValue.From<string>('$100').TryConvert<ShortInt>(asTValue), '''$100'' to ShortInt');
  //A subrange does not cover its type's width, so its hex values are only range-checked
  Assert.IsTrue(TValue.From<string>('$A').TryConvert<TSignedSubrange>(asTValue), '''$A'' to -10..10');
  Assert.AreEqual(10, asTValue.AsInteger, '''$A'' to -10..10');
  Assert.IsFalse(TValue.From<string>('$FF').TryConvert<TSignedSubrange>(asTValue), '''$FF'' to -10..10');
  Assert.IsFalse(TValue.From<string>('11').TryConvert<TSignedSubrange>(asTValue), '''11'' to -10..10');
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

procedure TValueHelperTests.Date_Converts_Only_When_Its_Meaning_Is_Unambiguous(const locale, text : string;
  const year, month, day : Word);
var
  asTValue : TValue;
begin
  setFormatSettings(locale);
  if year = 0 then
    Assert.IsFalse(TValue.From(text).TryConvert<TDate>(asTValue), 'An ambiguous or misread date must not convert')
  else
  begin
    Assert.IsTrue(TValue.From(text).TryConvert<TDate>(asTValue), 'TryConvert<TDate>');
    Assert.IsSameDate(EncodeDate(year, month, day), asTValue.AsType<TDate>(), 'TDate');
  end;
end;

procedure TValueHelperTests.DateTime_Converts_Only_When_Its_Meaning_Is_Unambiguous(const locale, text : string;
  const year, month, day : Word);
var
  asTValue : TValue;
begin
  setFormatSettings(locale);
  if year = 0 then
    Assert.IsFalse(TValue.From(text).TryConvert<TDateTime>(asTValue), 'An ambiguous or misread date must not convert')
  else
  begin
    Assert.IsTrue(TValue.From(text).TryConvert<TDateTime>(asTValue), 'TryConvert<TDateTime>');
    Assert.IsSameDateTime(EncodeDateTime(year, month, day, 10, 30, 0, 0), asTValue.AsType<TDateTime>(), 'TDateTime');
  end;
end;

procedure TValueHelperTests.Time_Without_A_Date_Converts_To_A_DateTime(const locale, text : string;
  const hour, minute, second : Word);
var
  asTValue : TValue;
begin
  setFormatSettings(locale);
  Assert.IsTrue(TValue.From(text).TryConvert<TDateTime>(asTValue), 'a time with no date must still convert');
  Assert.IsSameTime(EncodeTime(hour, minute, second, 0), TimeOf(asTValue.AsType<TDateTime>()), 'the time of day');
end;

procedure TValueHelperTests.Date_And_Time_Formatted_In_The_Locale_Read_Back(const locale : string);
var
  expected : TDateTime;
  asTValue : TValue;
begin
  expected := EncodeDateTime(2020, 6, 22, 18, 36, 0, 0);
  setFormatSettings(locale);
  //A user who picked a two-digit year for the machine's own locale writes dates that, by design, do not read back
  //(a date needs its year in full), so the round trip is tested with the year in full.
  if Pos('YYYY', UpperCase(FormatSettings.ShortDateFormat)) = 0 then
    FormatSettings.ShortDateFormat := TRegEx.Replace(FormatSettings.ShortDateFormat, '[yY]+', 'yyyy');
  Assert.IsTrue(TValue.From(DateTimeToStr(expected)).TryConvert<TDateTime>(asTValue), DateTimeToStr(expected));
  Assert.IsSameDateTime(expected, asTValue.AsType<TDateTime>(), DateTimeToStr(expected));
  Assert.IsTrue(TValue.From(DateToStr(expected)).TryConvert<TDate>(asTValue), DateToStr(expected));
  Assert.IsSameDate(expected, asTValue.AsType<TDate>(), DateToStr(expected));
  Assert.IsTrue(TValue.From(TimeToStr(expected)).TryConvert<TTime>(asTValue), TimeToStr(expected));
  Assert.IsSameTime(expected, asTValue.AsType<TTime>(), TimeToStr(expected));
end;

procedure TValueHelperTests.Iso8601_Lookalike_Does_Not_Convert(const text : string);
var
  asTValue : TValue;
begin
  setFormatSettings('EN-GB');
  Assert.IsFalse(TValue.From(text).TryConvert<TDate>(asTValue), 'TDate');
  Assert.IsFalse(TValue.From(text).TryConvert<TDateTime>(asTValue), 'TDateTime');
end;

procedure TValueHelperTests.Iso8601_Fraction_Is_A_Fraction_Of_A_Second(const text : string; const milliseconds : Word);
var
  asTValue : TValue;
begin
  setFormatSettings('EN-GB');
  Assert.IsTrue(TValue.From(text).TryConvert<TDateTime>(asTValue), 'TryConvert<TDateTime>');
  Assert.AreEqual(Integer(milliseconds), Integer(MilliSecondOf(asTValue.AsType<TDateTime>())), 'Milliseconds');
  Assert.IsSameDateTime(EncodeDateTime(2020, 6, 22, 18, 36, 0, milliseconds), asTValue.AsType<TDateTime>(), 'TDateTime');
end;

procedure TValueHelperTests.Iso8601_Time_Fraction_Is_A_Fraction_Of_A_Second(const text : string;
  const milliseconds : Word);
var
  asTValue : TValue;
begin
  setFormatSettings('EN-GB');
  Assert.IsTrue(TValue.From(text).TryConvert<TTime>(asTValue), 'TryConvert<TTime>');
  Assert.AreEqual(Integer(milliseconds), Integer(MilliSecondOf(asTValue.AsType<TTime>())), 'Milliseconds');
  Assert.IsSameTime(EncodeTime(18, 36, 0, milliseconds), asTValue.AsType<TTime>(), 'TTime');
end;

procedure TValueHelperTests.Iso8601_Time_As_DateTime_Fraction_Is_A_Fraction_Of_A_Second(const text : string;
  const milliseconds : Word);
var
  asTValue : TValue;
begin
  setFormatSettings('EN-GB');
  Assert.IsTrue(TValue.From(text).TryConvert<TDateTime>(asTValue), 'TryConvert<TDateTime>');
  Assert.AreEqual(Integer(milliseconds), Integer(MilliSecondOf(asTValue.AsType<TDateTime>())), 'Milliseconds');
  Assert.IsSameDateTime(EncodeTime(18, 36, 0, milliseconds), asTValue.AsType<TDateTime>(), 'TDateTime');
end;

procedure TValueHelperTests.Time_Out_Of_Range_Does_Not_Convert(const text : string);
var
  asTValue : TValue;
begin
  setFormatSettings('EN-GB');
  Assert.IsFalse(TValue.From(text).TryConvert<TTime>(asTValue), 'TTime');
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

