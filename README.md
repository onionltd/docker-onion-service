# docker-onion-service

This is a fork of Christophe Mehay's [docker-tor-hidden-service](https://github.com/cmehay/docker-tor-hidden-service).

## Setup

### Setup hosts

```yaml
version: "2"

services:
  tor:
    image: localhost/onion-service:0.3.5.8
    links:
      - hello
      - world
      - again
    environment:
        # Set mapping ports
        SERVICE1_TOR_SERVICE_HOSTS: 80:hello:80,800:hello:80,8888:hello:80
        # Set private key
        SERVICE1_TOR_SERVICE_KEY: |
            -----BEGIN RSA PRIVATE KEY-----
            MIICXQIBAAKBgQDR8TdQF9fDlGhy1SMgfhMBi9TaFeD12/FK27TZE/tYGhxXvs1C
            NmFJy1hjVxspF5unmUsCk0yEsvEdcAdp17Vynz6W41VdinETU9yXHlUJ6NyI32AH
            dnFnHEcsllSEqD1hPAAvMUWwSMJaNmBEFtl8DUMS9tPX5fWGX4w5Xx8dZwIDAQAB
            AoGBAMb20jMHxaZHWg2qTRYYJa8LdHgS0BZxkWYefnBUbZn7dOz7mM+tddpX6raK
            8OSqyQu3Tc1tB9GjPLtnVr9KfVwhUVM7YXC/wOZo+u72bv9+4OMrEK/R8xy30XWj
            GePXEu95yArE4NucYphxBLWMMu2E4RodjyJpczsl0Lohcn4BAkEA+XPaEKnNA3AL
            1DXRpSpaa0ukGUY/zM7HNUFMW3UP00nxNCpWLSBmrQ56Suy7iSy91oa6HWkDD/4C
            k0HslnMW5wJBANdz4ehByMJZmJu/b5y8wnFSqep2jmJ1InMvd18BfVoBTQJwGMAr
            +qwSwNXXK2YYl9VJmCPCfgN0o7h1AEzvdYECQAM5UxUqDKNBvHVmqKn4zShb1ugY
            t1RfS8XNbT41WhoB96MT9P8qTwlniX8UZiwUrvNp1Ffy9n4raz8Z+APNwvsCQQC9
            AuaOsReEmMFu8VTjNh2G+TQjgvqKmaQtVNjuOgpUKYv7tYehH3P7/T+62dcy7CRX
            cwbLaFbQhUUUD2DCHdkBAkB6CbB+qhu67oE4nnBCXllI9EXktXgFyXv/cScNvM9Y
            FDzzNAAfVc5Nmbmx28Nw+0w6pnpe/3m0Tudbq3nHdHfQ
            -----END RSA PRIVATE KEY-----

        # hello and again will share the same onion v3 address
        SERVICE2_TOR_SERVICE_HOSTS: 88:again:80,8000:world:80
        SERVICE2_TOR_SERVICE_VERSION: '3'
        # tor v3 address private key base 64 encoded
        SERVICE2_TOR_SERVICE_KEY: |
            PT0gZWQyNTUxOXYxLXNlY3JldDogdHlwZTAgPT0AAACArobDQYyZAWXei4QZwr++
            j96H1X/gq14NwLRZ2O5DXuL0EzYKkdhZSILY85q+kfwZH8z4ceqe7u1F+0pQi/sM

  hello:
    image: tutum/hello-world
    hostname: hello

  world:
    image: tutum/hello-world
    hostname: world

  again:
    image: tutum/hello-world
    hostname: again
```

This configuration will output:

```
service2: xwjtp3mj427zdp4tljiiivg2l5ijfvmt5lcsfaygtpp6cw254kykvpyd.onion:88, xwjtp3mj427zdp4tljiiivg2l5ijfvmt5lcsfaygtpp6cw254kykvpyd.onion:8000
service1: 5azvyr7dvvr4cldn.onion:80, 5azvyr7dvvr4cldn.onion:800, 5azvyr7dvvr4cldn.onion:8888
```

`xwjtp3mj427zdp4tljiiivg2l5ijfvmt5lcsfaygtpp6cw254kykvpyd.onion:88` will hit `again:80`.
`xwjtp3mj427zdp4tljiiivg2l5ijfvmt5lcsfaygtpp6cw254kykvpyd.onion:8000` will hit `wold:80`.

`5azvyr7dvvr4cldn.onion:80` will hit `hello:80`.
`5azvyr7dvvr4cldn.onion:800` will hit `hello:80` too.
`5azvyr7dvvr4cldn.onion:8888` will hit `hello:80` again.

#### Environment variables

##### `{SERVICE}_TOR_SERVICE_HOSTS`

The config patern for this variable is: `{exposed_port}:{hostname}:{port}}`

For example `80:hello:8080` will expose an onion service on port 80 to the port 8080 of hello hostname.

Unix sockets are supported too, `80:unix://path/to/socket.sock` will expose an onion service on port 80 to the socket `/path/to/socket.sock`. See `docker-compose.v2.socket.yml` for an example.

You can concatenate services using comas.

> **WARNING**: Using sockets and ports in the same service group can lead to issues

##### `{SERVICE}_TOR_SERVICE_VERSION`

Can be `2` or `3`. Set the tor address type.

`2` gives short addresses `5azvyr7dvvr4cldn.onion` and `3` long addresses `xwjtp3mj427zdp4tljiiivg2l5ijfvmt5lcsfaygtpp6cw254kykvpyd.onion`


##### `{SERVICE}_TOR_SERVICE_KEY`

You can set the private key for the current service.

Tor v2 addresses uses RSA PEM keys like:
```
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDR8TdQF9fDlGhy1SMgfhMBi9TaFeD12/FK27TZE/tYGhxXvs1C
NmFJy1hjVxspF5unmUsCk0yEsvEdcAdp17Vynz6W41VdinETU9yXHlUJ6NyI32AH
dnFnHEcsllSEqD1hPAAvMUWwSMJaNmBEFtl8DUMS9tPX5fWGX4w5Xx8dZwIDAQAB
AoGBAMb20jMHxaZHWg2qTRYYJa8LdHgS0BZxkWYefnBUbZn7dOz7mM+tddpX6raK
8OSqyQu3Tc1tB9GjPLtnVr9KfVwhUVM7YXC/wOZo+u72bv9+4OMrEK/R8xy30XWj
GePXEu95yArE4NucYphxBLWMMu2E4RodjyJpczsl0Lohcn4BAkEA+XPaEKnNA3AL
1DXRpSpaa0ukGUY/zM7HNUFMW3UP00nxNCpWLSBmrQ56Suy7iSy91oa6HWkDD/4C
k0HslnMW5wJBANdz4ehByMJZmJu/b5y8wnFSqep2jmJ1InMvd18BfVoBTQJwGMAr
+qwSwNXXK2YYl9VJmCPCfgN0o7h1AEzvdYECQAM5UxUqDKNBvHVmqKn4zShb1ugY
t1RfS8XNbT41WhoB96MT9P8qTwlniX8UZiwUrvNp1Ffy9n4raz8Z+APNwvsCQQC9
AuaOsReEmMFu8VTjNh2G+TQjgvqKmaQtVNjuOgpUKYv7tYehH3P7/T+62dcy7CRX
cwbLaFbQhUUUD2DCHdkBAkB6CbB+qhu67oE4nnBCXllI9EXktXgFyXv/cScNvM9Y
FDzzNAAfVc5Nmbmx28Nw+0w6pnpe/3m0Tudbq3nHdHfQ
-----END RSA PRIVATE KEY-----
```

Tor v3 addresses uses ed25519 binary keys. It should be base64 encoded:
```
PT0gZWQyNTUxOXYxLXNlY3JldDogdHlwZTAgPT0AAACArobDQYyZAWXei4QZwr++j96H1X/gq14NwLRZ2O5DXuL0EzYKkdhZSILY85q+kfwZH8z4ceqe7u1F+0pQi/sM
```

##### `{SERVICE}_TOR_SERVICE_MASTER_ADDRESS`

Set to master onion address if this service is load balanced by [OnionBalance](https://github.com/asn-d6/onionbalance).

##### `TOR_SOCKS_PORT`

Set tor sock5 proxy port for this tor instance. (Use this if you need to connect to tor network with your service)

##### `TOR_EXTRA_OPTIONS`

Add any options in the `torrc` file.

```yaml
services:
  tor:
    environment:
        # Add any option you need
        TOR_EXTRA_OPTIONS: |
          HiddenServiceNonAnonymousMode 1
          HiddenServiceSingleHopMode 1
```


#### Secrets

Secret key can be set through docker `secrets`, see `docker-compose.v3.yml` for example.


### Tools

A command line tool `onions` is available in container to get `.onion` url when container is running.

```sh
# Get services
$ docker exec -ti torhiddenproxy_tor_1 onions
hello: vegm3d7q64gutl75.onion:80
world: b2sflntvdne63amj.onion:80

# Get json
$ docker exec -ti torhiddenproxy_tor_1 onions --json
{"hello": ["b2sflntvdne63amj.onion:80"], "world": ["vegm3d7q64gutl75.onion:80"]}
```

### Auto reload

Changing `/etc/tor/torrc` file triggers a `SIGHUP` signal to `tor` to reload configuration.

To disable this behavior, add `ENTRYPOINT_DISABLE_RELOAD` in environment.

### Versions

Container version will follow tor release versions.

### pyentrypoint

This container uses [`pyentrypoint`](https://github.com/cmehay/pyentrypoint) to generate its setup.

### pytor

This containner uses [`pytor`](https://github.com/cmehay/pytor) to mannages tor cryptography, generate keys and compute onion urls.
