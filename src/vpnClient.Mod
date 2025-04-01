MODULE vpnClient;
IMPORT vpnTun, vpnXor, Internet, Out, SYSTEM, Platform;

CONST
  BUFSIZE = 2048;

VAR
  dev: vpnTun.TunDevice;
  sock: Internet.Socket;
  buf: ARRAY BUFSIZE OF CHAR;
  res: LONGINT;
  nRead: LONGINT;

BEGIN
  IF ~vpnTun.OpenTun(dev) THEN HALT(1) END;

  IF ~Internet.Connect("127.0.0.1", "5555", sock) THEN
    Out.String("Failed to connect to server"); Out.Ln;
    HALT(2)
  END;

  Out.String("Connected to VPN server."); Out.Ln;

  LOOP
    res := Platform.Read(dev.fd, SYSTEM.ADR(buf[0]), BUFSIZE, nRead);
    IF res = 0 THEN
      vpnXor.EncryptDecrypt(buf, nRead);
      res := Platform.Write(sock, SYSTEM.ADR(buf[0]), nRead)
    END;

    res := Platform.Read(sock, SYSTEM.ADR(buf[0]), BUFSIZE, nRead);
    IF res = 0 THEN
      vpnXor.EncryptDecrypt(buf, nRead);
      res := Platform.Write(dev.fd, SYSTEM.ADR(buf[0]), nRead)
    END;

    Platform.Delay(100);
  END;
END vpnClient.
