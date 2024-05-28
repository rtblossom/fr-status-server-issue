# fr-status-server-issue

This repository contains docker-compose for replicating an issue I've seen when testing status-server through TLS.

The architecture of my test setup is as follows:

```
client -> system-under-test -> endpoint1/endpoint2
```

The purpose is to simulate a backend timeout which causes the status-server messages to be sent.

The `client` sends RADIUS messages over UDP containing username "test@user" to `system-under-test` which forwards them to `endpoint1` and `endpoint2` over RadSec. But `endpoint1` and `endpoint2` respond in 10 seconds which causes a timeout from system-under-test's point of view. This causes system-under-test to send status-server messages to the endpoints.

Eventually `system-under-test` crashes and generates a core dump.

## How to replicate the issue
