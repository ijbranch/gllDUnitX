unit DUnitX.Tests.CommandLineParser;
{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
{           Modified (C) 2026 Ian Branch (GITLAK Software) - gllDUnitX fork }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

interface

{$I DUnitX.inc}

uses
  DUnitX.TestFramework,
  DUnitX.CommandLine.Options,
  DUnitX.CommandLine.Parser;

type
  /// <summary>
  ///   Sample enumeration registered as an option type, to prove enum values are parsed from their identifiers.
  /// </summary>
  TExampleEnum = (
    /// <summary>First sample value.</summary>
    enOne,
    /// <summary>Second sample value; the one Can_Parse_Enum_Parameter expects.</summary>
    enTwo,
    /// <summary>Third sample value.</summary>
    enThree
  );

  /// <summary>
  ///   Sample set type registered as an option type, to prove '[a,b]' set syntax is parsed.
  /// </summary>
  TExampleSet = set of TExampleEnum;

  /// <summary>
  ///   Tests for <c>TOptionsRegistry</c>: option registration rules and parsing of named, unnamed, quoted, enum, set,
  ///   float and options-file arguments, including the fork's fixes for '@file', recursion and the XML output name.
  /// </summary>
  [TestFixture]
  TCommandLineParserTests = class
  public

    /// <summary>
    ///   Clears the global named and unnamed option registries so each test starts with no registered options.
    /// </summary>
    [Setup]
    procedure Setup;

    /// <summary>
    ///   Clears the global option registries again so no test's registrations leak into the next test or the runner.
    /// </summary>
    [TearDown]
    procedure TearDown;

    /// <summary>
    ///   Proves registering an option whose long name, short name, or long name equal to another's short name is
    ///   already registered raises, naming the clash, so two options can never compete for the same switch. Each case
    ///   starts from an empty registry, so one case cannot satisfy another's assertion.
    /// </summary>
    [Test]
    procedure Will_Raise_On_Registering_Duplicate_Options;

    /// <summary>
    ///   Proves <c>RegisterOption</c> with an empty long name raises; unnamed options must go through
    ///   <c>RegisterUnNamedOption</c>.
    /// </summary>
    [Test]
    procedure Will_Raise_On_Registering_UnNamed_Option;

    /// <summary>
    ///   Proves a value-less boolean switch ('--test') invokes its setter with True.
    /// </summary>
    [Test]
    procedure Test_Single_Option;

    /// <summary>
    ///   Proves an unregistered switch is reported in the parse result's errors rather than silently ignored.
    /// </summary>
    [Test]
    procedure Will_Generate_Error_For_Unknown_Option;

    /// <summary>
    ///   Proves an option declared HasValue given without a value is reported as an error.
    /// </summary>
    [Test]
    procedure Will_Generate_Error_For_Missing_Value;

    /// <summary>
    ///   Proves <c>RegisterUnNamedOption</c> returns a definition flagged IsUnnamed.
    /// </summary>
    [Test]
    procedure Can_Register_Unnamed_Parameter;

    /// <summary>
    ///   Proves a bare (switchless) argument is delivered to the registered unnamed option's setter.
    /// </summary>
    [Test]
    procedure Can_Parse_Unnamed_Parameter;

    /// <summary>
    ///   Proves several bare arguments fill the unnamed options in registration order, even with a named switch
    ///   between them.
    /// </summary>
    [Test]
    procedure Can_Parse_Multiple_Unnamed_Parameters;

    /// <summary>
    ///   Proves a bare argument beyond the registered unnamed options is an error, while the arguments that did match
    ///   are still applied.
    /// </summary>
    [Test]
    procedure Will_Generate_Error_For_Extra_Unamed_Parameter;

    /// <summary>
    ///   Proves both double- and single-quoted values are unquoted, keeping the embedded space.
    /// </summary>
    [Test]
    procedure Can_Parse_Quoted_Value;

    /// <summary>
    ///   Proves an options-file switch naming a file that does not exist is reported as a parse error (it does not
    ///   raise, despite the test's name).
    /// </summary>
    [Test]
    procedure Will_Raise_For_Missing_Param_File;

    /// <summary>
    ///   Proves an enum option is parsed from the identifier text ('enTwo').
    /// </summary>
    [Test]
    procedure Can_Parse_Enum_Parameter;

    /// <summary>
    ///   Proves an identifier that is not a member of the enum is reported as a parse error.
    /// </summary>
    [Test]
    procedure Will_Generate_Error_For_Invalid_Enum;

    /// <summary>
    ///   Proves a set option is parsed from '[enOne,enThree]' into exactly those members.
    /// </summary>
    [Test]
    procedure Can_Parse_Set_Parameter;

    /// <summary>
    ///   Proves a set literal containing a non-member identifier is reported as a parse error.
    /// </summary>
    [Test]
    procedure Will_Generate_Error_For_Invalid_Set;

    /// <summary>
    ///   Proves an options file that includes itself reports an error instead of recursing until the stack overflows.
    /// </summary>
    [Test]
    procedure Options_File_Including_Itself_Reports_An_Error;

    /// <summary>
    ///   Proves options-file lines are trimmed and blank, '#' and ';' lines are skipped rather than reported as errors.
    /// </summary>
    [Test]
    procedure Options_File_Lines_Are_Trimmed_And_Comments_Skipped;

    /// <summary>
    ///   Proves a float option is parsed with the invariant format ('1.5'), whatever the machine's decimal separator.
    /// </summary>
    [Test]
    procedure Float_Option_Uses_Invariant_Format;

    /// <summary>
    ///   Proves '@&lt;file&gt;' reads an options file, as the parser's '@' prefix promised: the prefix was stripped and
    ///   the file name then looked up as an option name, so it always failed as an unknown option. The path contains
    ///   a drive colon, which must not split it.
    /// </summary>
    [Test]
    procedure At_Prefix_Reads_An_Options_File;

    /// <summary>
    ///   Proves a relative options-file name inside an options file resolves against THAT file's folder, not the
    ///   current directory: the current directory is set elsewhere, so the nested file is found only if the parser
    ///   resolves it next to the file that names it.
    /// </summary>
    [Test]
    procedure Nested_Relative_Options_File_Resolves_Against_Its_Parent_Folder;

    /// <summary>
    ///   Proves the bare argument that names the XML output file must be an .xml file name: a test name given without
    ///   --run used to become the output file, so every test ran and a file of that name was overwritten.
    /// </summary>
    [Test]
    procedure Bare_Argument_Must_Name_An_XML_File;

  end;

implementation

uses
  Classes,
  System.IOUtils,
  System.SysUtils,
  DUnitX.CommandLine.OptionDef,
  DUnitX.OptionsDefinition,
  DUnitX.ResStrs;

{ TCommandLineParserTests }

procedure TCommandLineParserTests.Options_File_Including_Itself_Reports_An_Error;
var
  def : IOptionDefinition;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
  fileName : string;
begin
  def := TOptionsRegistry.RegisterOption<string>('options', 'opt', nil);
  def.IsOptionFile := true;
  fileName := TPath.Combine(TPath.GetTempPath, 'DUnitX.Tests.RecursiveOptions.txt');
  TFile.WriteAllText(fileName, '--options:"' + fileName + '"');
  sList := TStringList.Create;
  try
    sList.Add('--options:"' + fileName + '"');
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
    TFile.Delete(fileName);
  end;
  Assert.IsTrue(parseResult.HasErrors, 'recursion reported');
end;

procedure TCommandLineParserTests.Options_File_Lines_Are_Trimmed_And_Comments_Skipped;
var
  def : IOptionDefinition;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
  fileName : string;
  test : string;
begin
  def := TOptionsRegistry.RegisterOption<string>('options', 'opt', nil);
  def.IsOptionFile := true;
  TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(value : string)
    begin
      test := value;
    end);
  fileName := TPath.Combine(TPath.GetTempPath, 'DUnitX.Tests.CommentedOptions.txt');
  TFile.WriteAllText(fileName, '# a comment' + sLineBreak + '; another comment' + sLineBreak + sLineBreak +
    '   --test:abc   ' + sLineBreak);
  sList := TStringList.Create;
  try
    sList.Add('--options:"' + fileName + '"');
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
    TFile.Delete(fileName);
  end;
  Assert.IsFalse(parseResult.HasErrors, parseResult.ErrorText);
  Assert.AreEqual('abc', test, False);
end;

procedure TCommandLineParserTests.At_Prefix_Reads_An_Options_File;
var
  def : IOptionDefinition;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
  fileName : string;
  test : string;
begin
  def := TOptionsRegistry.RegisterOption<string>('options', 'opt', nil);
  def.IsOptionFile := true;
  TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(value : string)
    begin
      test := value;
    end);
  fileName := TPath.Combine(TPath.GetTempPath, 'DUnitX.Tests.AtOptions.txt');
  TFile.WriteAllText(fileName, '--test:abc');
  sList := TStringList.Create;
  try
    sList.Add('@' + fileName);
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
    TFile.Delete(fileName);
  end;
  Assert.IsFalse(parseResult.HasErrors, parseResult.ErrorText);
  Assert.AreEqual('abc', test, False);
end;

procedure TCommandLineParserTests.Nested_Relative_Options_File_Resolves_Against_Its_Parent_Folder;
var
  def : IOptionDefinition;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
  folder, oldDir, test : string;
begin
  def := TOptionsRegistry.RegisterOption<string>('options', 'opt', nil);
  def.IsOptionFile := true;
  TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(value : string)
    begin
      test := value;
    end);
  folder := TPath.Combine(TPath.GetTempPath, 'DUnitX.Tests.NestedOptions.' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(folder);
  oldDir := GetCurrentDir;
  try
    TFile.WriteAllText(TPath.Combine(folder, 'A.txt'), '--options:B.txt');
    TFile.WriteAllText(TPath.Combine(folder, 'B.txt'), '--test:abc');
    //The current directory is the parent of the folder, where no B.txt exists.
    SetCurrentDir(TPath.GetTempPath);
    sList := TStringList.Create;
    try
      sList.Add('--options:"' + TPath.Combine(folder, 'A.txt') + '"');
      parseResult := TOptionsRegistry.Parse(sList);
    finally
      sList.Free;
    end;
  finally
    SetCurrentDir(oldDir);
    TDirectory.Delete(folder, True);
  end;
  Assert.IsFalse(parseResult.HasErrors, parseResult.ErrorText);
  Assert.AreEqual('abc', test, False, 'The nested options file was not read');
end;

procedure TCommandLineParserTests.Bare_Argument_Must_Name_An_XML_File;
begin
  Assert.WillRaiseDescendant(
    procedure
    begin
      CheckXmlOutputFileArgument('Unit.TFixture.Test');
    end, Exception, 'a test name');
  Assert.WillNotRaiseAny(
    procedure
    begin
      CheckXmlOutputFileArgument('C:\Results\dunitx-results.XML');
    end, 'an XML file name');
end;

procedure TCommandLineParserTests.Float_Option_Uses_Invariant_Format;
var
  parseResult : ICommandLineParseResult;
  sList : TStringList;
  test : Double;
  oldDecimalSeparator : Char;
begin
  test := 0;
  TOptionsRegistry.RegisterOption<Double>('float', 'f',
    procedure(value : Double)
    begin
      test := value;
    end);
  oldDecimalSeparator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := ',';
  sList := TStringList.Create;
  try
    sList.Add('--float:1.5');
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
    FormatSettings.DecimalSeparator := oldDecimalSeparator;
  end;
  Assert.IsFalse(parseResult.HasErrors, parseResult.ErrorText);
  Assert.AreEqual(1.5, test, 0);
end;

procedure TCommandLineParserTests.Can_Parse_Enum_Parameter;
var
  def : IOptionDefinition;
  test : TExampleEnum;
  sList : TStringList;
  parseResult : ICommandLineParseResult;

begin
  def := TOptionsRegistry.RegisterOption<TExampleEnum>('test', 't',
    procedure(value : TExampleEnum)
    begin
      test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:enTwo');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.IsFalse(parseResult.HasErrors);
{$IFDEF DELPHI_XE2_UP}
  Assert.AreEqual<TExampleEnum>(enTwo, test);
{$ENDIF}
end;

procedure TCommandLineParserTests.Can_Parse_Multiple_Unnamed_Parameters;
var
  def : IOptionDefinition;
  file1 : string;
  file2 : string;
  sList : TStringList;
  parseResult : ICommandLineParseResult;
  test : boolean;
begin
  TOptionsRegistry.RegisterUnNamedOption<string>('the file we want to process',
    procedure(value : string)
    begin
      file1 := value;
    end);

  TOptionsRegistry.RegisterUnNamedOption<string>('the second file we want to process',
    procedure(value : string)
    begin
      file2 := value;
    end);

  def := TOptionsRegistry.RegisterOption<boolean>('test', 't',
    procedure(value : boolean)
    begin
      test := value;
    end);
  def.HasValue := False;

  sList := TStringList.Create;
  sList.Add('c:\file1.txt');
  sList.Add('--test');
  sList.Add('c:\file2.txt');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.IsFalse(parseResult.HasErrors);
  Assert.AreEqual('c:\file1.txt', file1);
  Assert.AreEqual('c:\file2.txt', file2);
end;

procedure TCommandLineParserTests.Can_Parse_Quoted_Value;
var
  test : string;
  test2 : string;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(value : string)
    begin
      test := value;
    end);

  TOptionsRegistry.RegisterOption<string>('test2', 't2',
    procedure(value : string)
    begin
      test2 := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:"hello world"');
  sList.Add('--test2:''hello world''');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.AreEqual('hello world', test);
  Assert.AreEqual('hello world', test2);
end;

procedure TCommandLineParserTests.Can_Parse_Set_Parameter;
var
  def : IOptionDefinition;
  test : TExampleSet;
  sList : TStringList;
  parseResult : ICommandLineParseResult;

begin
  def := TOptionsRegistry.RegisterOption<TExampleSet>('test', 't',
    procedure(value : TExampleSet)
    begin
      test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:[enOne,enThree]');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.IsFalse(parseResult.HasErrors);
{$IFDEF DELPHI_XE2_UP}
  Assert.AreEqual<TExampleSet>(test, [enOne, enThree]);
{$ENDIF}
end;

procedure TCommandLineParserTests.Can_Parse_Unnamed_Parameter;
var
  def : IOptionDefinition;
  res : string;
  sList : TStringList;
  parseResult : ICommandLineParseResult;
begin
  def := TOptionsRegistry.RegisterUnNamedOption<string>('the file we want to process',
    procedure(value : string)
    begin
      res := value;
    end);

  sList := TStringList.Create;
  sList.Add('c:\test.txt');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.AreEqual('c:\test.txt', res);
end;

procedure TCommandLineParserTests.Can_Register_Unnamed_Parameter;
var
  def : IOptionDefinition;
begin
  def := TOptionsRegistry.RegisterUnNamedOption<string>('the file we want to process',
    procedure(value : string)
    begin
    end);

  Assert.IsTrue(def.IsUnnamed);

end;

procedure TCommandLineParserTests.Setup;
begin
  TOptionsRegistry.RegisteredOptions.Clear;
  TOptionsRegistry.RegisteredUnamedOptions.Clear;
end;

procedure TCommandLineParserTests.TearDown;
begin
  TOptionsRegistry.RegisteredOptions.Clear;
  TOptionsRegistry.RegisteredUnamedOptions.Clear;
end;

procedure TCommandLineParserTests.Test_Single_Option;
var
  def : IOptionDefinition;
  result : boolean;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<boolean>('test', 't',
    procedure(value : boolean)
    begin
      result := value;
    end);
  def.HasValue := False;

  sList := TStringList.Create;
  sList.Add('--test');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.IsTrue(result);

end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Extra_Unamed_Parameter;
var
  file1 : string;
  sList : TStringList;
  parseResult : ICommandLineParseResult;
  test : string;
begin
  TOptionsRegistry.RegisterUnNamedOption<string>('the file we want to process',
    procedure(value : string)
    begin
      file1 := value;
    end);

  TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(value : string)
    begin
      test := value;
    end);
  //  def.HasValue := False;

  sList := TStringList.Create;
  sList.Add('c:\file1.txt');
  sList.Add('--test:hello');
  sList.Add('c:\file2.txt');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    TDUnitX.CurrentRunner.Log(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);
  Assert.AreEqual('c:\file1.txt', file1);
  Assert.AreEqual('hello', test);
end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Missing_Value;
var
  def : IOptionDefinition;
  result : boolean;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<boolean>('test', 't',
    procedure(value : boolean)
    begin
      result := value;
    end);
  def.HasValue := True;

  sList := TStringList.Create;
  sList.Add('--test');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    TDUnitX.CurrentRunner.Log(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Unknown_Option;
var
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  sList := TStringList.Create;
  sList.Add('--blah');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    TDUnitX.CurrentRunner.Log(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);

end;

procedure TCommandLineParserTests.Will_Raise_For_Missing_Param_File;
var
  def : IOptionDefinition;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<boolean>('options', 'o', nil);
  def.IsOptionFile := true;
  sList := TStringList.Create;
  sList.Add('--options:"x:\blah blah.txt"');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    TDUnitX.CurrentRunner.Log(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCommandLineParserTests.Will_Raise_On_Registering_Duplicate_Options;
begin
  //Each case starts from an empty registry and registers the first option OUTSIDE the assertion, so only the
  //duplicate can satisfy it, and the expected message names the clashing name.

  //Same long name, different short name.
  TOptionsRegistry.RegisterOption<boolean>('test', 't', nil);
  Assert.WillRaiseWithMessage(
    procedure
    begin
      TOptionsRegistry.RegisterOption<boolean>('test', 'x', nil);
    end, Exception, Format(SOptionAlreadyRegistered, ['test']), 'A duplicate long name was accepted');

  //Same short name, different long name.
  TOptionsRegistry.RegisteredOptions.Clear;
  TOptionsRegistry.RegisterOption<boolean>('test', 't', nil);
  Assert.WillRaiseWithMessage(
    procedure
    begin
      TOptionsRegistry.RegisterOption<boolean>('other', 't', nil);
    end, Exception, Format(SOptionAlreadyRegistered, ['t']), 'A duplicate short name was accepted');

  //A long name equal to another option's short name.
  TOptionsRegistry.RegisteredOptions.Clear;
  TOptionsRegistry.RegisterOption<boolean>('test', 't', nil);
  Assert.WillRaiseWithMessage(
    procedure
    begin
      TOptionsRegistry.RegisterOption<boolean>('t', 'blah', nil);
    end, Exception, Format(SOptionAlreadyRegistered, ['t']), 'A long name clashing with a short name was accepted');
end;

procedure TCommandLineParserTests.Will_Raise_On_Registering_UnNamed_Option;
begin
  //same long names
  Assert.WillRaise(
    procedure
    begin
      TOptionsRegistry.RegisterOption<boolean>('', 't',
        procedure(value : boolean)
        begin
        end);

    end);
end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Invalid_Enum;
var
  def : IOptionDefinition;
  test : TExampleEnum;
  sList : TStringList;
  parseResult : ICommandLineParseResult;

begin
  def := TOptionsRegistry.RegisterOption<TExampleEnum>('test', 't',
    procedure(value : TExampleEnum)
    begin
      test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:enbBlah');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    TDUnitX.CurrentRunner.Log(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Invalid_Set;
var
  def : IOptionDefinition;
  test : TExampleSet;
  sList : TStringList;
  parseResult : ICommandLineParseResult;

begin
  def := TOptionsRegistry.RegisterOption<TExampleSet>('test', 't',
    procedure(value : TExampleSet)
    begin
      test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:[enOne,enFoo]');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    TDUnitX.CurrentRunner.Log(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);

end;

initialization
  TDUnitX.RegisterTestFixture(TCommandLineParserTests);
end.

