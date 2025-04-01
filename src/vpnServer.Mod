MODULE vpnServer;
IMPORT vpnTun, vpnNB, vpnXor, netSockets, Out, SYSTEM, Platform;

CONST
  BUFSIZE = 2048;

TYPE
  PSockAddr = POINTER TO netSockets.SockAddr;

VAR
  dev: vpnTun.TunDevice;
  sock, client, res: LONGINT;
  addr: netSockets.SockAddrIn;
  pSockAddr: PSockAddr;
  addrLen: LONGINT;
  buf: ARRAY BUFSIZE OF CHAR;
  nRead: LONGINT;
  b, keep: BOOLEAN;
BEGIN
  IF ~vpnTun.OpenTun(dev) THEN HALT(1) END;

  b := vpnNB.SetNonBlockingFd(dev.fd);     (* TUN fd *)
  b := vpnNB.SetNonBlockingFd(client);     (* accepted TCP client socket *)

  sock := netSockets.Socket(netSockets.AfInet, netSockets.SockStream, 0);
  IF sock = -1 THEN
    Out.String("Socket creation failed."); Out.Ln;
    HALT(2)
  END;

  netSockets.SetSockAddrIn(netSockets.AfInet, 5555, netSockets.InAddrAny, addr);

  pSockAddr := SYSTEM.VAL(PSockAddr, SYSTEM.ADR(addr));
  res := netSockets.Bind(sock, pSockAddr^, SIZE(netSockets.SockAddrIn));
  IF res # 0 THEN
    Out.String("Bind failed"); Out.Ln;
    HALT(3)
  END;

  res := netSockets.Listen(sock, 1);
  IF res # 0 THEN
    Out.String("Listen failed"); Out.Ln;
    HALT(4)
  END;

  Out.String("VPN server waiting for client..."); Out.Ln;
  addrLen := SIZE(netSockets.SockAddrIn);
  client := netSockets.Accept(sock, pSockAddr^, addrLen);
  Out.String("Client connected."); Out.Ln;

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
          Out.String("Write to TUN failed."); Out.Ln;
          keep := FALSE;
        END;
      END
    ELSIF res # 0 THEN
      Out.String("Socket read error."); Out.Ln;
      keep := FALSE;
    END;

    (* tun → socket *)
    res := Platform.Read(dev.fd, SYSTEM.ADR(buf[0]), BUFSIZE, nRead);
    IF res = 0 THEN
      IF nRead > 0 THEN
        vpnXor.EncryptDecrypt(buf, nRead);
        res := Platform.Write(sock, SYSTEM.ADR(buf[0]), nRead);
        IF res # 0 THEN
          Out.String("Write to socket failed."); Out.Ln;
          keep := FALSE;
        END;
      END
    ELSIF res # 0 THEN
      Out.String("TUN read error."); Out.Ln;
      keep := FALSE;
    END;

    Platform.Delay(10);
  END;

  Out.String("VPN session ended."); Out.Ln;
  Platform.Exit(0);

END vpnServer.
