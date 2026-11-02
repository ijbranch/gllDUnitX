{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett & Contributors               }
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

//Delphi 13 or later: this fork targets nothing older ( Delphi 13+, Win32 and Win64 ).
{$IF CompilerVersion < 37.0}
  {$MESSAGE FATAL 'gllDUnitX requires Delphi 13 or later'}
{$IFEND}
{$LEGACYIFEND ON}

//Always defined on Delphi 13.  gllDUnitX tests none of them any more; they are kept for code that includes this
//file and does.
{$DEFINE DELPHI_XE_UP}
{$DEFINE SUPPORTS_TARRAY}
{$DEFINE DELPHI_XE2_UP}
{$DEFINE USE_NS}
{$DEFINE SUPPORTS_REGEX}
{$DEFINE DELPHI_XE3_UP}
{$DEFINE DELPHI_XE4_UP}
{$DEFINE DELPHI_XE6_UP}
{$DEFINE DELPHI_XE8_UP}
{$DEFINE DELPHIX_SEATTLE_UP}
{$DEFINE DELPHI_XE101_UP}
{$DEFINE DELPHI_XE103_UP}

{$I DUnitX.Stacktrace.inc}
{$I DUnitX.MemoryLeaks.inc}

//turn off debug info so you do not step into DUNITX when debugging your tests

//Note from Ryan McGinty 04/25/2016 - I had legacy code in conditional IFDEF DEBUG
//using XE.  When I put in a directive of DUNITX-DEBUG in my project, it started
//making the tests for IFDEF DEBUG true as well.  I tested with an _ and had same
//result, so added one without a spacer and it seems to work.  Kept both values
//as to not break any backward compatbilities.
{$IFNDEF DUNITX-DEBUG}
  {$IFNDEF DUNITXDEBUG}
    {$D-}
  {$ENDIF}
{$ENDIF}

