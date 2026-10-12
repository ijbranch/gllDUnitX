{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2015 Vincent Parrett & Contributors               }
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

unit DUnitX.Constants;

interface

const
{$IFDEF NEXTGEN}
  /// <summary>Index of the first character of a string (0 on NEXTGEN zero-based-string compilers).</summary>
  MinStringOffset   : integer = 0;
  /// <summary>Amount subtracted from Length() to get the index of the last character (1 for zero-based strings).</summary>
  MaxStringOffset   : integer = 1;
{$ELSE}
  /// <summary>Index of the first character of a string (1 on the Windows one-based-string compilers).</summary>
  MinStringOffset   : integer = 1;
  /// <summary>Amount subtracted from Length() to get the index of the last character (0 for one-based strings).</summary>
  MaxStringOffset   : integer = 0;
{$ENDIF}

implementation

end.

