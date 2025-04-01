MODULE vpnClient;
IMPORT vpnTun, vpnNB, vpnXor, Internet, Out, SYSTEM, Platform;

CONST
  BUFSIZE = 2048;
  EAGAIN  = 11;
VAR
  dev: vpnTun.TunDevice;
  sock: Internet.Socket;
  buf: ARRAY BUFSIZE OF CHAR;
  res: LONGINT;
  nRead: LONGINT;
  b, keep: BOOLEAN;
  err: INTEGER;
BEGIN
  IF ~vpnTun.OpenTun(dev) THEN HALT(1) END;

  IF ~Internet.Connect("127.0.0.1", "5555", sock) THEN
    Out.String("Failed to connect to server"); Out.Ln;
    HALT(2)
  END;

  Out.String("Connected to VPN server."); Out.Ln;

  b := vpnNB.SetNonBlockingFd(dev.fd);     (* TUN fd *)
  b := vpnNB.SetNonBlockingFd(sock);       (* connected TCP socket *)

keep := TRUE;

  LOOP
    IF ~keep THEN EXIT END;

    (* socket → tun *)
    res := Platform.Read(sock, SYSTEM.ADR(buf[0]), BUFSIZE, nRead);
    IF res = 0 THEN
      IF nRead > 0 THEN
        vpnXor.EncryptDecrypt(buf, nRead);
        res := Platform.Write(dev.fd, SYSTEM.ADR(buf[0]), nRead);
        IF res # 0 THEN
            err := Platform.Error();
            IF err # EAGAIN THEN
               Out.String("Socket read failed: "); Out.Int(err, 0); Out.Ln;
               keep := FALSE;
            END
        END;
      END
    ELSIF res # 0 THEN
            err := Platform.Error();
            IF err # EAGAIN THEN
               Out.String("Socket read failed: "); Out.Int(err, 0); Out.Ln;
               keep := FALSE;
            END
      END
    END;

    (* tun → socket *)
    res := Platform.Read(dev.fd, SYSTEM.ADR(buf[0]), BUFSIZE, nRead);
    IF res = 0 THEN
      IF nRead > 0 THEN
        vpnXor.EncryptDecrypt(buf, nRead);
        res := Platform.Write(sock, SYSTEM.ADR(buf[0]), nRead);
        IF res # 0 THEN
            err := Platform.Error();
            IF err # EAGAIN THEN
               Out.String("Socket read failed: "); Out.Int(err, 0); Out.Ln;
               keep := FALSE;
            END
        END;
      END
    ELSIF res # 0 THEN
      IF Platform.Error() # 11 THEN
            err := Platform.Error();
            IF err # EAGAIN THEN
               Out.String("Socket read failed: "); Out.Int(err, 0); Out.Ln;
               keep := FALSE;
            END
      END
    END;

    Platform.Delay(10);

  Out.String("VPN session ended."); Out.Ln;
  Platform.Exit(0);

END vpnClient.
