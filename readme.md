

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
ifconfig vpn0 10.0.0.1 netmask 255.255.255.0 up
```

or with contemporary iproute2 syntax:

```
ip link set vpn0 up
ip addr add 10.0.0.1/24 dev vpn0
```

# route

if you need a route

```
route add -net 10.0.0.0 netmask 255.255.255.0 dev vpn0
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
ifconfig vpn0 10.0.0.2 netmask 255.255.255.0 up
```

or with contemporary syntax:

```
ip link set vpn0 up
ip addr add 10.0.0.2/24 dev vpn0
```

# test

ping each other's ips.


