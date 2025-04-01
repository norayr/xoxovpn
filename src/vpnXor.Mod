MODULE vpnXor;
IMPORT SYSTEM;

CONST
  Key* = 42;

PROCEDURE EncryptDecrypt*(VAR buf: ARRAY OF CHAR; len: LONGINT);
VAR
  i: LONGINT;
  s: SET;
  b: CHAR;
  raw: SYSTEM.BYTE;
BEGIN
  FOR i := 0 TO len - 1 DO
    SYSTEM.GET(SYSTEM.ADR(buf[i]), b);
    (*s := SYSTEM.VAL(SET, ORD(b));*)
    SYSTEM.GET(SYSTEM.ADR(b), raw);
    SYSTEM.GET(SYSTEM.ADR(raw), s);

    s := s / SYSTEM.VAL(SET, Key);  (* XOR as symmetric difference *)
    buf[i] := CHR(SYSTEM.VAL(INTEGER, s))
  END
END EncryptDecrypt;

END vpnXor.
