{$INCLUDE drl.inc}
{
 ----------------------------------------------------
Copyright (c) 2002-2025 by Kornel Kisielewicz
----------------------------------------------------
}
unit drlconfig;
interface

uses Classes, SysUtils, vluaconfig;

type

{ TDRLConfig }

TDRLConfig = class(TLuaConfig)
  constructor Create( const FileName : Ansistring; Reload : Boolean );
end;


implementation

uses dfdata, drlio;


{ TDRLConfig }

constructor TDRLConfig.Create( const FileName : Ansistring; Reload : Boolean );
begin
  inherited Create;

  SetConstant('VERSION_STRING', VERSION_STRING);
  SetConstant('VERSION_BETA',   VERSION_BETA);

  LoadMain( FileName );

  Option_Graphics         := Configure('Graphics',Option_Graphics);
  Option_Blending         := Configure('Blending',Option_Blending);
  Option_SaveOnCrash      := Configure('SaveOnCrash',Option_SaveOnCrash);

  Option_HighASCII        := Configure('AllowHighAscii',Option_HighASCII);
  Option_AlwaysName       := Configure('AlwaysName',Option_AlwaysName);
  Option_BlindMode        := Configure('BlindMode',Option_BlindMode);
  Option_ClearMessages    := Configure('ClearMessages',Option_ClearMessages);// TODO : Reimplement
  Option_MorePrompt       := Configure('MorePrompt',Option_MorePrompt);
  Option_MessageColoring  := Configure('MessageColoring',Option_MessageColoring);
  Option_InvFullDrop      := Configure('InvFullDrop',Option_InvFullDrop);
  Option_MortemArchive    := Configure('MortemArchive',Option_MortemArchive);
  Option_MenuReturn       := Configure('MenuReturn',Option_MenuReturn);
  Option_ColoredInventory := Configure('ColoredInventory',Option_ColoredInventory);
  Option_LockBreak        := Configure('LockBreak',Option_LockBreak);
  Option_LockClose        := Configure('LockClose',Option_LockClose);
  Option_TimeStamp        := Configure('TimeStamp',Option_TimeStamp);

  Option_PlayerBackups    := Configure('PlayerBackups',Option_PlayerBackups);
  Option_ScoreBackups     := Configure('ScoreBackups',Option_ScoreBackups);

  Option_RunDelay         := Configure('RunDelay',Option_RunDelay);
  Option_MessageBuffer    := Configure('MessageBuffer',Option_MessageBuffer);

  Option_IntuitionColor   := Configure('IntuitionColor',Option_IntuitionColor);
  Option_IntuitionChar    := AnsiString(Configure('IntuitionChar',Option_IntuitionChar))[1];

  Option_MaxRun           := Configure('MaxRun',Option_MaxRun);
  Option_MaxWait          := Configure('MaxWait',Option_MaxWait);
  Option_ForceRaw         := Configure('ForceRaw',GodMode);

  TDRLIO.RegisterLuaAPI( State );
end;

end.

