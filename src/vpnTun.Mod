MODULE vpnTun;
IMPORT SYSTEM, Platform, Out;

CONST
  IFFTUN = 1;
  IFFNOPI = 1000H;
  TUNSETIFF = 400454CAH; (* ioctl code for TUNSETIFF *)
  TUNDEV = "/dev/net/tun";

TYPE
  ifreq = RECORD
    name: ARRAY 16 OF CHAR;
    flags: ARRAY 2 OF SYSTEM.BYTE;
    pad: ARRAY 22 OF SYSTEM.BYTE; (* match size of struct ifreq *)
  END;

  TunDevice* = POINTER TO RECORD
    fd*: LONGINT;
    name*: ARRAY 16 OF CHAR;
  END;

PROCEDURE -A001 "#include <sys/ioctl.h>";
PROCEDURE -A002 "#include <fcntl.h>"; (* for open() *)
PROCEDURE -A003 "#include <unistd.h>"; (* for close() *)
PROCEDURE -A004 "#include <linux/if_tun.h>"; (* defines struct ifreq and TUNSETIFF *)

PROCEDURE -ioctl(fd: LONGINT; req: LONGINT; argp: SYSTEM.ADDRESS): LONGINT
  "(LONGINT)ioctl(fd, req, (void*)argp)";

PROCEDURE OpenTun*(VAR dev: TunDevice): BOOLEAN;
VAR
  fd: LONGINT;
  res: LONGINT;
  ifr: ifreq;
  name: ARRAY 256 OF CHAR;
BEGIN
  COPY(TUNDEV, name);
  res := Platform.OldRW(name, fd);
  IF res # 0 THEN
    Out.String("Failed to open /dev/net/tun"); Out.Ln;
    RETURN FALSE
  END;

  (* Set up ifreq struct *)
  COPY("vpn0", ifr.name);
  ifr.flags[0] := CHR(IFFTUN);
  ifr.flags[1] := CHR(IFFNOPI DIV 100H);

  res := ioctl(fd, TUNSETIFF, SYSTEM.ADR(ifr));
  IF res = -1 THEN
    Out.String("TUNSETIFF ioctl failed"); Out.Ln;
    RETURN FALSE
  END;

  NEW(dev);
  dev.fd := fd;
  COPY(ifr.name, dev.name);

  Out.String("TUN device created: "); Out.String(dev.name); Out.Ln;
  RETURN TRUE
END OpenTun;

PROCEDURE CloseTun*(dev: TunDevice);
VAR res: INTEGER;
BEGIN
  res := Platform.Close(dev.fd);
  IF res # 0 THEN
    Out.String("Warning: failed to close TUN device."); Out.Ln;
  ELSE
    Out.String("TUN device closed."); Out.Ln;
  END;
END CloseTun;


END vpnTun.
