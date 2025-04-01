

# build

type

```
make
```

# how to use

## on server

as root

```
./vpnServer
```

you'll see output like:

```
TUN device created: vpn0
VPN server waiting for client...
```

now, set the ip:

```
ifconfig vpn0 10.2.0.1 netmask 255.255.255.0 up
```

or with contemporary iproute2 syntax:

```
ip link set vpn0 up
ip addr add 10.2.0.1/24 dev vpn0
```

# route

if you need a route

```
route add -net 10.2.0.0 netmask 255.255.255.0 dev vpn0
```


## on client

as root, so that it would create the interface.

```
./vpnClient
```

output:

```
TUN device created: vpn0
Connected to VPN server.
```

set the ip:

```
ifconfig vpn0 10.2.0.2 netmask 255.255.255.0 up
```

or with contemporary syntax:

```
ip link set vpn0 up
ip addr add 10.2.0.2/24 dev vpn0
```

# test

ping each other's ips.

on client, do:
```
nc -l -p 2020
```

on server:

```
nc 10.2.0.2 2020
```

now run tcpdump:

```
tcpdump -i eth0 port 5555 -X
```

if eth0 is the interface you are connected to the other party.

now if you're sending 'aaaaaaa...' from one machine, it becomes KKK on the other, because XOR of a with 42 will be K

```
ack 245, win 509, options [nop,nop,TS val 3085257361 ecr 1583262159], length 79
        0x0000:  4500 0083 565e 4000 4006 6062 c0a8 014d  E...V^@.@.`b...M
        0x0010:  c0a8 0117 15b3 adf4 25a4 2827 ea9a f01a  ........%.('....
        0x0020:  8018 01fd 842a 0000 0101 080a b7e5 4a91  .....*........J.
        0x0030:  5e5e a9cf 6f2a 2a65 625b 6a2a 6a2c f41b  ^^..o**eb[j*j,..
        0x0040:  2028 2a2b 2028 2a28 87f0 2dce 157e 8169  .(*+.(*(..-..~.i
        0x0050:  1b36 e71b aa32 2bdc f2ca 2a2a 2b2b 2220  .6...2+...**++".
        0x0060:  5ddc f6f1 61f4 665c 4b4b 4b4b 4b4b 4b4b  ]...a.f\KKKKKKKK
        0x0070:  4b4b 4b4b 4b4b 4b4b 4b4b 4b4b 4b4b 4b4b  KKKKKKKKKKKKKKKK
        0x0080:  4b4b 20                                  KK.
```


