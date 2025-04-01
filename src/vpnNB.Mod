MODULE vpnNB;
IMPORT SYSTEM;

PROCEDURE -A0
"#include <fcntl.h>";

PROCEDURE -getFlags(VAR fd: LONGINT): LONGINT
  "(LONGINT)fcntl(*fd, F_GETFL)";

PROCEDURE -setNonBlocking(VAR fd: LONGINT; flags: LONGINT): LONGINT
  "(LONGINT)fcntl(*fd, F_SETFL, flags | O_NONBLOCK)";

PROCEDURE SetNonBlockingFd*(fd: LONGINT): BOOLEAN;
VAR
  currentFlags, res: LONGINT;
BEGIN
  currentFlags := getFlags(fd);
  IF currentFlags # -1 THEN
    res := setNonBlocking(fd, currentFlags);
    RETURN res # -1
  ELSE
    RETURN FALSE
  END
END SetNonBlockingFd;



END vpnNB.
