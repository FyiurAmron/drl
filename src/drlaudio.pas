{$INCLUDE drl.inc}
{$DEFINE DISABLE_MUSIC}
{$DEFINE DISABLE_SOUND}
{
 ----------------------------------------------------
Copyright (c) 2002-2025 by Kornel Kisielewicz
----------------------------------------------------
}
unit drlaudio;
interface
uses classes, vgenerics, vrltools, vluaconfig, vdf,
     callbacks;

type TSoundEvent = packed record
       Time    : QWord;
       Coord   : TCoord2D;
       IDs     : array of AnsiString;
     end;

type TAudioEntry = record
       ID       : AnsiString;
       Root     : AnsiString;
       FileName : AnsiString;
       IsMusic  : Boolean;
       DataFile : TVDataFile;
     end;


type TAudioRegistry   = specialize TGArray< TAudioEntry >;
     TAudioLookup     = specialize TGHashMap< Integer >;
     TSoundEventHeap  = specialize TGHeap< TSoundEvent >;


type TDRLAudio = class
  constructor Create;
  procedure Reset;
  procedure Reconfigure;
  procedure Configure( aConfig : TLuaConfig; aReload : Boolean = False );
  procedure Update( aMSec : DWord );
  procedure QueueSound( IDs : array of AnsiString; aCoord : TCoord2D; aDelay : DWord );
  procedure PlaySound( const mIDs : array of AnsiString; aCoord : TCoord2D );
  procedure PlaySound( const mID : AnsiString );
  procedure PlayMusic( const MusicID : AnsiString; aNotFound : Boolean = False );
  destructor Destroy; override;
private
  FTime        : QWord;
  FSoundEvents : TSoundEventHeap;
  FCurrentData : TVDataFile;
end;

implementation

uses sysutils, math,
     vdebug, vutil, vmath,
     drlio, drlconfiguration, dfplayer, dfdata;

function DRLSoundEventCompare( const Item1, Item2: TSoundEvent ): Integer;
begin
       if Item1.Time < Item2.Time then Exit(1)
  else if Item1.Time > Item2.Time then Exit(-1)
  else Exit(0);
end;

constructor TDRLAudio.Create;
begin
  FSoundEvents   := TSoundEventHeap.Create( @DRLSoundEventCompare );
  Reset;
end;

procedure TDRLAudio.Reset;
begin
  FSoundEvents.Clear;
  FCurrentData := nil;
  FTime        := 0;
end;

procedure TDRLAudio.Reconfigure;
begin
  Setting_MusicVolume      := Configuration.GetInteger( 'music_volume' );
  Setting_SoundVolume      := Configuration.GetInteger( 'sound_volume' );

  INTEROP( CB_MUSIC, 'volume', IntToStr(Setting_MusicVolume) );
  INTEROP( CB_SOUND, 'volume', IntToStr(Setting_SoundVolume) );
end;

procedure TDRLAudio.Update( aMSec : DWord );
var iSoundEvent : TSoundEvent;
begin
  FTime += aMSec;
  while (not FSoundEvents.isEmpty) and (FSoundEvents.Top.Time <= FTime) do
  begin
    iSoundEvent := FSoundEvents.Pop;
    PlaySound( iSoundEvent.IDs, iSoundEvent.Coord );
  end;
end;

procedure TDRLAudio.Configure ( aConfig : TLuaConfig; aReload : Boolean ) ;
begin
  FSoundEvents.Clear;
end;

procedure TDRLAudio.QueueSound( IDs : array of AnsiString; aCoord : TCoord2D; aDelay : DWord );
var
  iSoundEvent : TSoundEvent;
  i : Integer;
begin
  iSoundEvent.Coord   := aCoord;
  SetLength(iSoundEvent.IDs, Length(IDs));
  for i := Low(IDs) to High(IDs) do
    iSoundEvent.IDs[i] := IDs[i];
  iSoundEvent.Time    := FTime + aDelay;
  FSoundEvents.Insert( iSoundEvent );
end;

procedure TDRLAudio.PlaySound( const mID: AnsiString );
begin
  INTEROP( CB_SOUND, 'play', mID );
end;

function JoinAnsi(const Arr: array of AnsiString; const Delim: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := Low(Arr) to High(Arr) do
  begin
    if i > Low(Arr) then
      Result := Result + Delim;
    Result := Result + string(Arr[i]);
  end;
end;

procedure TDRLAudio.PlaySound( const mIDs: array of AnsiString; aCoord : TCoord2D );
var iVolume     : Byte;
    iPan        : Byte;
    iDist       : Word;
    iPos        : TCoord2D;
begin
  if (not Option_Sound) or SoundOff or ( Setting_SoundVolume = 0 ) then Exit;

  iPos := Player.Position;

  iDist := Distance(aCoord,iPos);
  if iDist <= 1 then iVolume := 127 else
                    iVolume := Clamp((25 - iDist) * 6,0,127);
  if iVolume = 0 then Exit;

  iPan := Clamp((aCoord.x-iPos.x) * 15,-128,127)+128;

  INTEROP( CB_SOUND, 'play', ''+JoinAnsi(mIDs,'?') + ',' + IntToStr(iVolume) + ',' + IntToStr(iPan) );
  // TODO simplify the interface and pass just sound source coords
  // - emit player pos update CB event just before for 100% pos accuracy
end;

procedure TDRLAudio.PlayMusic(const MusicID : Ansistring; aNotFound : Boolean = False );
begin
  INTEROP( CB_MUSIC, 'play', MusicID );
end;

destructor TDRLAudio.Destroy;
begin
  FreeAndNil( FSoundEvents );
end;

end.

