MODULE vpnXor;
IMPORT SYSTEM;

CONST
  Key* = 42;

PROCEDURE EncryptDecrypt*(VAR buf: ARRAY OF CHAR; len: LONGINT);
VAR
  i, bit: LONGINT;
  c, k: SET;
  out: INTEGER;
BEGIN
  (* Convert Key to SET *)
  k := {};
  FOR bit := 0 TO 7 DO
    IF (Key DIV SYSTEM.LSH(1, bit)) MOD 2 = 1 THEN
      INCL(k, bit)
    END
  END;

  FOR i := 0 TO len - 1 DO
    c := {};
    FOR bit := 0 TO 7 DO
      IF (ORD(buf[i]) DIV SYSTEM.LSH(1, bit)) MOD 2 = 1 THEN
        INCL(c, bit)
      END
    END;

    c := c / k;  (* XOR via symmetric difference *)

    out := 0;
    FOR bit := 0 TO 7 DO
      IF bit IN c THEN
        out := out + SYSTEM.LSH(1, bit)
      END
    END;

    buf[i] := CHR(out)
  END
END EncryptDecrypt;

END vpnXor.

