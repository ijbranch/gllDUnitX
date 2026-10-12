{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2016 Vincent Parrett                              }
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

unit DUnitX.ComparableFormat;

interface

{$I DUnitX.inc}

type
  /// <summary>
  ///   Abstract marker base class for a serialisation format in which two values can be compared (the string
  ///   <c>Assert.AreEqual</c> overloads in <c>DUnitX.Assert.Ex</c> take one). It has no members; descendants only name a
  ///   format.
  /// </summary>
  TDUnitXComparableFormat = class abstract(TObject);
  /// <summary>
  ///   Class reference to a <see cref="TDUnitXComparableFormat" /> descendant, used to pass a format by type.
  /// </summary>
  TDUnitXComparableFormatClass = class of TDUnitXComparableFormat;

implementation

end.
