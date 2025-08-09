unit callbacks;

interface

type
  TCallbackType = (
    CB_LOG = 0,
    CB_APP = 1,
    CB_MUSIC = 2
  );

type
  TCallbackProc = function( callbackType: TCallbackType; const message: PChar ) : Integer; cdecl;

function DefaultCallback( callbackType: TCallbackType; const message: PChar ) : Integer; cdecl;
function INTEROP( callbackType: TCallbackType; const message: Ansistring ) : Integer;

var
  GlobalInteropCallback : TCallbackProc = @DefaultCallback;

implementation

uses TypInfo, vdebug;

function DefaultCallback( callbackType: TCallbackType; const message: PChar ) : Integer; cdecl;
begin
  Log( 'default callback; got type: ' + GetEnumName(TypeInfo(TCallbackType), Ord(callbackType)) + ' message: ' + message );
  Result := 0;
end;

function INTEROP( callbackType: TCallbackType; const message: Ansistring ) : Integer;
begin
  // TODO add a reasonable try-catch for internal errors if possible?
  Result := GlobalInteropCallback( callbackType, PChar( message ) );
end;

end.
