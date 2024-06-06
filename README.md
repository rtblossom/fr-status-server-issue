# fr-status-server-issue

This repository contains information about an issue I've seen in FreeRADIUS when testing status-server through TLS.

FreeRADIUS version: 3.2.3

Problem: FreeRADIUS crashes when sending status-server messages to endpoints over RadSec.

EDIT: Issue fixed in FreeRADIUS 3.2.4. See https://github.com/FreeRADIUS/freeradius-server/issues/5326

My architecture is as follows:
```
client -> system-under-test -> endpoint1/endpoint2
```

The purpose is to simulate a backend timeout which causes status-server messages to be sent.

The `client` sends RADIUS messages over UDP containing username "test@user" to `system-under-test` which forwards them to `endpoint1` and `endpoint2` over RadSec. But `endpoint1` and `endpoint2` respond in 10 seconds which causes a timeout from system-under-test's point of view. This causes system-under-test to send status-server messages to the endpoints.

Eventually `system-under-test` crashes.

## How to replicate the issue
1. Clone this repository
2. Build and run the containers
```
docker-compose up --build
```

There should be several auths that time out and eventually FreeRADIUS `system-under-test` crashes. The following errors appears right before the crash

```
Bad talloc magic value - unknown value

talloc abort: Bad talloc magic value - unknown value
Aborted
```



## Logs:
Below are debug logs from running the above docker-compose command
```
Attaching to endpoint2, endpoint1, system-under-test, tester
endpoint2         |[0m installing certs
endpoint1         |[0m installing certs
endpoint1         |[0m done installing certs
endpoint2         |[0m done installing certs
endpoint1         |[0m Tue May 28 19:16:08 2024 : Info: Starting - reading configuration files ...
system-under-test |[0m installing certs
system-under-test |[0m done installing certs
endpoint2         |[0m Tue May 28 19:16:08 2024 : Info: Starting - reading configuration files ...
tester            |[0m installing certs
system-under-test |[0m /entrypoint.sh: 15: [: unexpected operator
system-under-test |[0m /entrypoint.sh: 17: [: unexpected operator
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Server was built with:
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   accounting                : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   authentication            : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   ascend-binary-attributes  : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   coa                       : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   recv-coa-from-home-server : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   control-socket            : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   detail                    : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   dhcp                      : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   dynamic-clients           : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   osfc2                     : no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   proxy                     : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   regex-pcre                : no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   regex-posix               : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   regex-posix-extended      : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   session-management        : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   stats                     : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   systemd                   : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   tcp                       : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   threads                   : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   tls                       : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   unlang                    : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   vmps                      : yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   developer                 : no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Server core libs:
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   freeradius-server         : 3.2.3
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   talloc                    : 2.3.*
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   ssl                       : 3.0.0b dev
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Endianness:
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   little
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Compilation flags:
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   cppflags : -Wdate-time -D_FORTIFY_SOURCE=2
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   cflags   : -I. -Isrc -include src/freeradius-devel/autoconf.h -include src/freeradius-devel/build.h -include src/freeradius-devel/features.h -include src/freeradius-devel/radpaths.h -fno-strict-aliasing -g -O2 -ffile-prefix-map=/usr/local/src/repositories/freeradius-server=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -O2 -Wall -std=c99 -D_GNU_SOURCE -D_REENTRANT -D_POSIX_PTHREAD_SEMANTICS -DOPENSSL_NO_KRB5 -DNDEBUG -DIS_MODULE=1
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   ldflags  :  -Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   libs     : -lcrypto -lssl -ltalloc -latomic -lcap -lnsl -lresolv -ldl -lpthread -lreadline
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: FreeRADIUS Version 3.2.3
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: Copyright (C) 1999-2022 The FreeRADIUS server project and contributors
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: PARTICULAR PURPOSE
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: You may redistribute copies of FreeRADIUS under the terms of the
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: GNU General Public License
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: For more information about these matters, see the file named COPYRIGHT
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: Starting - reading configuration files ...
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including dictionary file /usr/share/freeradius/dictionary
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including dictionary file /usr/share/freeradius/dictionary.dhcp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including dictionary file /usr/share/freeradius/dictionary.vqp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including dictionary file /etc/freeradius/dictionary
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/radiusd.conf
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/proxy.common.conf
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including files in directory /etc/freeradius/mods-enabled/
endpoint2         |[0m Tue May 28 19:16:08 2024 : Info: Debug state unknown (cap_sys_ptrace capability not set)
endpoint2         |[0m Tue May 28 19:16:08 2024 : Info: systemd watchdog is disabled
endpoint1         |[0m Tue May 28 19:16:08 2024 : Info: Debug state unknown (cap_sys_ptrace capability not set)
endpoint1         |[0m Tue May 28 19:16:08 2024 : Info: systemd watchdog is disabled
endpoint1         |[0m Tue May 28 19:16:08 2024 : Info: Loaded virtual server <default>
endpoint1         |[0m Tue May 28 19:16:08 2024 : Info: Loaded virtual server test_server
endpoint1         |[0m Tue May 28 19:16:08 2024 : Info: Ready to process requests
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/utf8
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/preprocess
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/expiration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/mschap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/radutmp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/detail.log
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/totp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/unpack
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/ntlm_auth
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/replicate
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/pap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/dynamic_clients
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/expr
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/chap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/unix
endpoint2         |[0m Tue May 28 19:16:08 2024 : Info: Loaded virtual server <default>
endpoint2         |[0m Tue May 28 19:16:08 2024 : Info: Loaded virtual server test_server
tester            |[0m done installing certs
endpoint2         |[0m Tue May 28 19:16:08 2024 : Info: Ready to process requests
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/exec
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/echo
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/files
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/digest
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/logintime
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/linelog
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/date
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/soh
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/passwd
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/detail
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/mods-enabled/sradutmp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including files in directory /etc/freeradius/sites-enabled/
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/sites-enabled/status
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including files in directory /etc/freeradius/policy.d/
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/dhcp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/eap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/moonshot-targeted-ids
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/cui
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: OPTIMIZING (${policy.cui_require_operator_name} == yes) --> FALSE
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: OPTIMIZING (no == yes) --> FALSE
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: OPTIMIZING (${policy.cui_require_operator_name} == yes) --> FALSE
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: OPTIMIZING (no == yes) --> FALSE
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/operator-name
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/debug
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/abfab-tr
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/canonicalization
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/accounting
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/rfc7542
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: including configuration file /etc/freeradius/policy.d/control
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: main {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  security {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	user = "root"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	group = "root"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	allow_core_dumps = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[533]: The item 'max_attributes' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[551]: The item 'reject_delay' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[571]: The item 'status_server' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	name = "freeradius"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	prefix = "/usr"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	localstatedir = "/var"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	logdir = "/var/log/freeradius"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	run_dir = "/var/run/freeradius"
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[85]: The item 'sysconfdir' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[97]: The item 'confdir' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[99]: The item 'pkidir' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[101]: The item 'cadirclient' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[105]: The item 'db_dir' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[140]: The item 'libdir' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[151]: The item 'pidfile' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[172]: The item 'correct_escapes' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[226]: The item 'max_request_time' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[247]: The item 'cleanup_delay' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[266]: The item 'max_requests' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[284]: The item 'hostname_lookups' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[389]: The item 'checkrad' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[592]: The item 'proxy_requests' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: }
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: Core dumps are enabled
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: main {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	name = "freeradius"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	prefix = "/usr"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	localstatedir = "/var"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	sbindir = "/usr/sbin"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	logdir = "/var/log/freeradius"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	run_dir = "/var/run/freeradius"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	libdir = "/usr/lib/freeradius"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	radacctdir = "/var/log/freeradius/radacct"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	hostname_lookups = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	max_request_time = 10
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	cleanup_delay = 5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	max_requests = 16384
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	postauth_client_lost = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	pidfile = "/var/run/freeradius/freeradius.pid"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	checkrad = "/usr/sbin/checkrad"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	debug_level = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	proxy_requests = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  log {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	stripped_names = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	auth = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	auth_accept = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	auth_reject = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	auth_badpass = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	auth_goodpass = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	colourise = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	msg_denied = "You are already logged in - access denied"
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[303]: The item 'destination' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[320]: The item 'file' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[328]: The item 'syslog_facility' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  resources {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  security {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	max_attributes = 200
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	reject_delay = 1.000000
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	status_server = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[85]: The item 'sysconfdir' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[97]: The item 'confdir' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[99]: The item 'pkidir' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[101]: The item 'cadirclient' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[105]: The item 'db_dir' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/radiusd.conf[172]: The item 'correct_escapes' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: radiusd: #### Loading Realms and Home Servers ####
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  proxy server {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	retry_delay = 5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	retry_count = 3
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	default_fallback = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	dead_time = 120
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	wake_all_if_all_dead = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  home_server radsec1 {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	nonblock = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	ipaddr = test_endpoint1 IPv4 address [192.168.0.3]
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	port = 2083
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	type = "auth+acct"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	proto = "tcp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	secret = "radsec"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	response_window = 7.000000
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	response_timeouts = 5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	max_outstanding = 65536
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	zombie_period = 40
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	status_check = "status-server"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	ping_interval = 30
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	check_interval = 10
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	check_timeout = 1
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	num_answers_to_alive = 3
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	revive_interval = 300
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   limit {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	max_connections = 128
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	max_requests = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	lifetime = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	idle_timeout = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/proxy.common.conf[65]: The item 'idle-timeout' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   coa {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	irt = 2
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mrt = 16
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mrc = 5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mrd = 30
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   recv_coa {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   tls {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	verify_depth = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	pem_file_type = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	private_key_file = "/pki/client.key"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	certificate_file = "/pki/client.crt"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ca_file = "/pki/ca/ca.crt"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	fragment_size = 8192
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	include_length = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	check_crl = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ca_path_reload_interval = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ecdh_curve = "prime256v1"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	tls_min_version = "1.2"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  home_server radsec2 {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	nonblock = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	ipaddr = test_endpoint2 IPv4 address [192.168.0.2]
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	port = 2083
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	type = "auth+acct"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	proto = "tcp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	secret = "radsec"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	response_window = 7.000000
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	response_timeouts = 5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	max_outstanding = 65536
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	zombie_period = 40
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	status_check = "status-server"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	ping_interval = 30
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	check_interval = 10
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	check_timeout = 1
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	num_answers_to_alive = 3
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	revive_interval = 300
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   limit {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	max_connections = 128
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	max_requests = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	lifetime = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	idle_timeout = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: /etc/freeradius/proxy.common.conf[92]: The item 'idle-timeout' is defined, but is unused by the configuration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   coa {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	irt = 2
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mrt = 16
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mrc = 5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mrd = 30
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   recv_coa {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   tls {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	verify_depth = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	pem_file_type = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	private_key_file = "/pki/client.key"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	certificate_file = "/pki/client.crt"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ca_file = "/pki/ca/ca.crt"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	fragment_size = 8192
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	include_length = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	check_crl = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ca_path_reload_interval = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ecdh_curve = "prime256v1"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	tls_min_version = "1.2"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  home_server_pool radsec_pool {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	type = keyed-balance
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	home_server = radsec1
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	home_server = radsec2
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  home_server_pool radsec_pool {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	type = keyed-balance
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	home_server = radsec1
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	home_server = radsec2
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  realm DEFAULT {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	auth_pool = radsec_pool
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	acct_pool = radsec_pool
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: 	nostrip
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: radiusd: #### Loading Clients ####
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: Debugger not attached
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: systemd watchdog is disabled
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  # Creating Autz-Type = Status-Server
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: radiusd: #### Instantiating modules ####
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  modules {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_utf8, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_utf8
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "utf8" from file /etc/freeradius/mods-enabled/utf8
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_preprocess, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_preprocess
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "preprocess" from file /etc/freeradius/mods-enabled/preprocess
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   preprocess {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	huntgroups = "/etc/freeradius/mods-config/preprocess/huntgroups"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	hints = "/etc/freeradius/mods-config/preprocess/hints"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	with_ascend_hack = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ascend_channels_per_line = 23
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	with_ntdomain_hack = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	with_specialix_jetstream_hack = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	with_cisco_vsa_hack = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	with_alvarion_vsa_hack = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_expiration, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_expiration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "expiration" from file /etc/freeradius/mods-enabled/expiration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_mschap, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_mschap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "mschap" from file /etc/freeradius/mods-enabled/mschap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   mschap {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	use_mppe = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	require_encryption = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	require_strong = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	with_ntdomain_hack = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    passchange {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	allow_retry = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	winbind_retry_with_normalised_username = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_radutmp, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_radutmp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "radutmp" from file /etc/freeradius/mods-enabled/radutmp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   radutmp {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/var/log/freeradius/radutmp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	username = "%{User-Name}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	case_sensitive = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	check_with_nas = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	permissions = 384
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	caller_id = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_detail, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_detail
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "auth_log" from file /etc/freeradius/mods-enabled/detail.log
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   detail auth_log {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/var/log/freeradius/radacct/%{%{Packet-Src-IP-Address}:-%{Packet-Src-IPv6-Address}}/auth-detail-%Y%m%d"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	header = "%t"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	permissions = 384
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	locking = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	escape_filenames = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	log_packet_header = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "reply_log" from file /etc/freeradius/mods-enabled/detail.log
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   detail reply_log {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/var/log/freeradius/radacct/%{%{Packet-Src-IP-Address}:-%{Packet-Src-IPv6-Address}}/reply-detail-%Y%m%d"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	header = "%t"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	permissions = 384
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	locking = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	escape_filenames = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	log_packet_header = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "pre_proxy_log" from file /etc/freeradius/mods-enabled/detail.log
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   detail pre_proxy_log {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/var/log/freeradius/radacct/%{%{Packet-Src-IP-Address}:-%{Packet-Src-IPv6-Address}}/pre-proxy-detail-%Y%m%d"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	header = "%t"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	permissions = 384
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	locking = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	escape_filenames = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	log_packet_header = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "post_proxy_log" from file /etc/freeradius/mods-enabled/detail.log
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   detail post_proxy_log {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/var/log/freeradius/radacct/%{%{Packet-Src-IP-Address}:-%{Packet-Src-IPv6-Address}}/post-proxy-detail-%Y%m%d"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	header = "%t"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	permissions = 384
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	locking = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	escape_filenames = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	log_packet_header = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_totp, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_totp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "totp" from file /etc/freeradius/mods-enabled/totp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_unpack, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_unpack
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "unpack" from file /etc/freeradius/mods-enabled/unpack
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_realm, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "IPASS" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   realm IPASS {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = "prefix"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	delimiter = "/"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_default = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_null = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "suffix" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   realm suffix {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = "suffix"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	delimiter = "@"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_default = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_null = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "bangpath" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   realm bangpath {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = "prefix"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	delimiter = "!"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_default = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_null = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "realmpercent" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   realm realmpercent {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = "suffix"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	delimiter = "%"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_default = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_null = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "ntdomain" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   realm ntdomain {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = "prefix"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	delimiter = "\\"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_default = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_null = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_exec, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_exec
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "ntlm_auth" from file /etc/freeradius/mods-enabled/ntlm_auth
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   exec ntlm_auth {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	wait = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	program = "/path/to/ntlm_auth --request-nt-key --domain=MYDOMAIN --username=%{mschap:User-Name} --password=%{User-Password}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	shell_escape = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_replicate, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_replicate
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "replicate" from file /etc/freeradius/mods-enabled/replicate
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_pap, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_pap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "pap" from file /etc/freeradius/mods-enabled/pap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   pap {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	normalise = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_dynamic_clients, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_dynamic_clients
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "dynamic_clients" from file /etc/freeradius/mods-enabled/dynamic_clients
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_expr, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_expr
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "expr" from file /etc/freeradius/mods-enabled/expr
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   expr {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	safe_characters = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_: /äéöüàâæçèéêëîïôœùûüaÿÄÉÖÜßÀÂÆÇÈÉÊËÎÏÔŒÙÛÜŸ"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_chap, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_chap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "chap" from file /etc/freeradius/mods-enabled/chap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_unix, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_unix
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "unix" from file /etc/freeradius/mods-enabled/unix
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   unix {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	radwtmp = "/var/log/freeradius/radwtmp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Creating attribute Unix-Group
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "exec" from file /etc/freeradius/mods-enabled/exec
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   exec {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	wait = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	input_pairs = "request"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	shell_escape = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	timeout = 10
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "echo" from file /etc/freeradius/mods-enabled/echo
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   exec echo {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	wait = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	program = "/bin/echo %{User-Name}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	input_pairs = "request"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	output_pairs = "reply"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	shell_escape = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_files, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_files
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "files" from file /etc/freeradius/mods-enabled/files
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   files {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/etc/freeradius/mods-config/files/authorize"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	acctusersfile = "/etc/freeradius/mods-config/files/accounting"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	preproxy_usersfile = "/etc/freeradius/mods-config/files/pre-proxy"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_digest, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_digest
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "digest" from file /etc/freeradius/mods-enabled/digest
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_logintime, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_logintime
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "logintime" from file /etc/freeradius/mods-enabled/logintime
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   logintime {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	minimum_timeout = 60
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_attr_filter, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "attr_filter.post-proxy" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   attr_filter attr_filter.post-proxy {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/etc/freeradius/mods-config/attr_filter/post-proxy"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	key = "%{Realm}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	relaxed = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "attr_filter.pre-proxy" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   attr_filter attr_filter.pre-proxy {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/etc/freeradius/mods-config/attr_filter/pre-proxy"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	key = "%{Realm}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	relaxed = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "attr_filter.access_reject" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   attr_filter attr_filter.access_reject {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/etc/freeradius/mods-config/attr_filter/access_reject"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	key = "%{User-Name}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	relaxed = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "attr_filter.access_challenge" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   attr_filter attr_filter.access_challenge {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/etc/freeradius/mods-config/attr_filter/access_challenge"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	key = "%{User-Name}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	relaxed = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "attr_filter.accounting_response" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   attr_filter attr_filter.accounting_response {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/etc/freeradius/mods-config/attr_filter/accounting_response"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	key = "%{User-Name}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	relaxed = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "attr_filter.coa" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   attr_filter attr_filter.coa {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/etc/freeradius/mods-config/attr_filter/coa"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	key = "%{User-Name}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	relaxed = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_linelog, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_linelog
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "linelog" from file /etc/freeradius/mods-enabled/linelog
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   linelog {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/var/log/freeradius/linelog"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	escape_filenames = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	syslog_severity = "info"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	permissions = 384
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = "This is a log message for %{User-Name}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	reference = "messages.%{%{reply:Packet-Type}:-default}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "log_accounting" from file /etc/freeradius/mods-enabled/linelog
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   linelog log_accounting {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/var/log/freeradius/linelog-accounting"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	escape_filenames = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	syslog_severity = "info"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	permissions = 384
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = ""
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	reference = "Accounting-Request.%{%{Acct-Status-Type}:-unknown}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_date, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_date
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "date" from file /etc/freeradius/mods-enabled/date
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   date {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = "%b %e %Y %H:%M:%S %Z"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	utc = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "wispr2date" from file /etc/freeradius/mods-enabled/date
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   date wispr2date {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = "%Y-%m-%dT%H:%M:%S"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	utc = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_soh, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_soh
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "soh" from file /etc/freeradius/mods-enabled/soh
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   soh {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	dhcp = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_passwd, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_passwd
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "etc_passwd" from file /etc/freeradius/mods-enabled/passwd
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   passwd etc_passwd {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/etc/passwd"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	format = "*User-Name:Crypt-Password:"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	delimiter = ":"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_nislike = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ignore_empty = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	allow_multiple_keys = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	hash_size = 100
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Loaded rlm_always, checking if it's valid
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loaded module rlm_always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "reject" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   always reject {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	rcode = "reject"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	simulcount = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mpp = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "fail" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   always fail {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	rcode = "fail"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	simulcount = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mpp = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "ok" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   always ok {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	rcode = "ok"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	simulcount = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mpp = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "handled" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   always handled {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	rcode = "handled"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	simulcount = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mpp = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "invalid" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   always invalid {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	rcode = "invalid"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	simulcount = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mpp = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "userlock" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   always userlock {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	rcode = "userlock"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	simulcount = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mpp = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "notfound" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   always notfound {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	rcode = "notfound"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	simulcount = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mpp = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "noop" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   always noop {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	rcode = "noop"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	simulcount = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mpp = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "updated" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   always updated {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	rcode = "updated"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	simulcount = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	mpp = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "detail" from file /etc/freeradius/mods-enabled/detail
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   detail {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/var/log/freeradius/radacct/%{%{Packet-Src-IP-Address}:-%{Packet-Src-IPv6-Address}}/detail-%Y%m%d"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	header = "%t"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	permissions = 384
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	locking = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	escape_filenames = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	log_packet_header = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Loading module "sradutmp" from file /etc/freeradius/mods-enabled/sradutmp
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   radutmp sradutmp {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	filename = "/var/log/freeradius/sradutmp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	username = "%{User-Name}"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	case_sensitive = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	check_with_nas = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	permissions = 420
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	caller_id = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "preprocess" from file /etc/freeradius/mods-enabled/preprocess
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/preprocess/huntgroups
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/preprocess/hints
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "expiration" from file /etc/freeradius/mods-enabled/expiration
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "mschap" from file /etc/freeradius/mods-enabled/mschap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: rlm_mschap (mschap): using internal authentication
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "auth_log" from file /etc/freeradius/mods-enabled/detail.log
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: rlm_detail (auth_log): 'User-Password' suppressed, will not appear in detail output
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "reply_log" from file /etc/freeradius/mods-enabled/detail.log
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "pre_proxy_log" from file /etc/freeradius/mods-enabled/detail.log
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "post_proxy_log" from file /etc/freeradius/mods-enabled/detail.log
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "IPASS" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "suffix" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "bangpath" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "realmpercent" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "ntdomain" from file /etc/freeradius/mods-enabled/realm
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "pap" from file /etc/freeradius/mods-enabled/pap
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "files" from file /etc/freeradius/mods-enabled/files
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/files/authorize
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/files/accounting
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/files/pre-proxy
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "logintime" from file /etc/freeradius/mods-enabled/logintime
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "attr_filter.post-proxy" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/attr_filter/post-proxy
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "attr_filter.pre-proxy" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/attr_filter/pre-proxy
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "attr_filter.access_reject" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/attr_filter/access_reject
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "attr_filter.access_challenge" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/attr_filter/access_challenge
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "attr_filter.accounting_response" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/attr_filter/accounting_response
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "attr_filter.coa" from file /etc/freeradius/mods-enabled/attr_filter
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: reading pairlist file /etc/freeradius/mods-config/attr_filter/coa
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "linelog" from file /etc/freeradius/mods-enabled/linelog
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "log_accounting" from file /etc/freeradius/mods-enabled/linelog
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "etc_passwd" from file /etc/freeradius/mods-enabled/passwd
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: rlm_passwd: nfields: 3 keyfield 0(User-Name) listable: no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "reject" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "fail" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "ok" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "handled" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "invalid" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "userlock" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "notfound" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "noop" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "updated" from file /etc/freeradius/mods-enabled/always
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   # Instantiating module "detail" from file /etc/freeradius/mods-enabled/detail
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  } # modules
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: radiusd: #### Loading Virtual Servers ####
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: server { # from file /etc/freeradius/radiusd.conf
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: } # server
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: server status { # from file /etc/freeradius/sites-enabled/status
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  # Loading authorize {...}
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   ok
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Compiling Autz-Type Status-Server for attr Autz-Type
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: } # server status
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: server openroaming { # from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  # Loading authenticate {...}
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Compiling Auth-Type reject for attr Auth-Type
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  # Loading authorize {...}
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   update {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    &control:Load-Balance-Key := &Calling-Station-Id
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   update {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    &control:Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  # Loading preacct {...}
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   update {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    &control:Load-Balance-Key := &Calling-Station-Id
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   update {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    &control:Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  # Loading accounting {...}
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   ok
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: } # server openroaming
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  thread pool {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	start_servers = 5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	max_servers = 32
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	min_spare_servers = 3
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	max_spare_servers = 10
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	max_requests_per_server = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	cleanup_delay = 5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	max_queue_size = 65536
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	auto_limit_acct = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread spawned new child 1. Total threads in pool: 1
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread spawned new child 2. Total threads in pool: 2
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread 1 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread spawned new child 3. Total threads in pool: 3
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread spawned new child 4. Total threads in pool: 4
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread spawned new child 5. Total threads in pool: 5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread pool initialized
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: radiusd: #### Opening IP addresses and Ports ####
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread 2 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread 5 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread 4 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: listen {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	type = "auth"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	virtual_server = "openroaming"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	ipaddr = *
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	port = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	proto = "udp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread 3 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	clients = "udp_clients"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   client any {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ipaddr = 0.0.0.0/0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	require_message_authenticator = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	secret = "secret"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	proto = "udp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    limit {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	max_connections = 16
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	lifetime = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	idle_timeout = 30
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Adding client 0.0.0.0/0 (0.0.0.0) to prefix tree 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: listen {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	type = "acct"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	virtual_server = "openroaming"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	ipaddr = *
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	port = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	proto = "udp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	clients = "udp_clients"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: listen {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	type = "auth+acct"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	virtual_server = "openroaming"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	ipaddr = *
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	port = 2083
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	proto = "tcp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   tls {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	verify_depth = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	pem_file_type = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	private_key_file = "/pki/server.key"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	certificate_file = "/pki/server.crt"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ca_file = "/pki/ca/ca.crt"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	fragment_size = 8192
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	include_length = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	auto_chain = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	check_crl = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	check_all_crl = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ca_path_reload_interval = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	cipher_list = "DEFAULT"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	cipher_server_preference = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	require_client_cert = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	reject_unknown_intermediate_ca = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ecdh_curve = ""
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	tls_max_version = "1.3"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	tls_min_version = "1.2"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    cache {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	enable = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	lifetime = 24
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	max_entries = 255
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    verify {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	skip_if_ocsp_ok = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    ocsp {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	enable = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	override_cert_url = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	use_nonce = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	timeout = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	softfail = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	check_client_connections = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   limit {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	max_connections = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	lifetime = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	idle_timeout = 30
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	clients = "openroaming_radsec_clients"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   client any {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ipaddr = 0.0.0.0/0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	require_message_authenticator = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	secret = "radsec"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	proto = "tls"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    limit {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	max_connections = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	lifetime = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	idle_timeout = 30
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Adding client 0.0.0.0/0 (0.0.0.0) to prefix tree 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: listen {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	type = "auth+acct"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	virtual_server = "openroaming"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	ipaddr = *
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	port = 3083
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	proto = "tcp"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   tls {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	verify_depth = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	pem_file_type = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	private_key_file = "/pki/server.key"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	certificate_file = "/pki/server.crt"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ca_file = "/pki/ca/ca.crt"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	fragment_size = 8192
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	include_length = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	auto_chain = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	check_crl = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	check_all_crl = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ca_path_reload_interval = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	cipher_list = "DEFAULT"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	cipher_server_preference = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	require_client_cert = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	reject_unknown_intermediate_ca = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ecdh_curve = ""
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	tls_max_version = "1.3"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	tls_min_version = "1.2"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    cache {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	enable = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	lifetime = 24
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	max_entries = 255
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    verify {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	skip_if_ocsp_ok = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    ocsp {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	enable = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	override_cert_url = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	use_nonce = yes
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	timeout = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	softfail = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	check_client_connections = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   limit {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	max_connections = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	lifetime = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	idle_timeout = 30
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:  	clients = "openroaming_radsec_clients"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: listen {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	type = "status"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ipaddr = 0.0.0.0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	port = 18121
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   client admin {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	ipaddr = 0.0.0.0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	require_message_authenticator = no
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   	secret = "secret"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    limit {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	max_connections = 16
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	lifetime = 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    	idle_timeout = 30
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:    }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug:   }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Adding client 0.0.0.0/0 (0.0.0.0) to prefix tree 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Listening on auth address * port 1812 bound to server openroaming
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Listening on acct address * port 1813 bound to server openroaming
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Listening on auth+acct proto tcp address * port 2083 (TLS) bound to server openroaming
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Listening on auth+acct proto tcp address * port 3083 (TLS) bound to server openroaming
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Listening on status address * port 18121 bound to server status
system-under-test |[0m Tue May 28 19:16:09 2024 : Info: Ready to process requests
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Threads: total/active/spare threads = 5/0/5
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread 2 got semaphore
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread 2 handling request 0, (1 handled so far)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) Received Access-Request Id 47 from 192.168.0.5:52203 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) session-state: No State attribute
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   authorize {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)     update control {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)     update control {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   } # authorize = noop
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) server openroaming {
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) }
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) proxy: Trying to open a new listener to the home server
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Requiring Server certificate
endpoint1         |[0m Tue May 28 19:16:09 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 55545) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:16:09 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 55545) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Listening on proxy (192.168.0.4, 55545) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Waking up in 0.2 seconds.
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) proxy: allocating destination 192.168.0.3 port 2083 - Id 148
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) Sent Access-Request Id 148 from 192.168.0.4:55545 to 192.168.0.3:2083 length 53
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0)   Proxy-State = 0x3437
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Proxy is writing 53 bytes to SSL
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Thread 2 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: (0) Expecting proxy response no later than 6.702940 seconds from now
system-under-test |[0m Tue May 28 19:16:09 2024 : Debug: Waking up in 6.7 seconds.
system-under-test |[0m Tue May 28 19:16:14 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 148
system-under-test |[0m Tue May 28 19:16:14 2024 : Debug: Waking up in 2.0 seconds.
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:16:16 2024 : ERROR: (0) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: Thread 1 got semaphore
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: Thread 1 handling request 0, (1 handled so far)
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) server openroaming {
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) }
system-under-test |[0m Tue May 28 19:16:16 2024 : Auth: (0) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) Sent Access-Reject Id 47 from 192.168.0.4:1812 to 192.168.0.5:52203 length 20
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: (0) Finished request
system-under-test |[0m Tue May 28 19:16:16 2024 : Debug: Thread 1 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 47 from 0.0.0.0:cbeb to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 47 from 0.0.0.0:cbeb to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 47 from 192.168.0.4:714 to 192.168.0.5:52203 length 20
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: Thread 5 got semaphore
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: Thread 5 handling request 1, (1 handled so far)
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) Received Access-Request Id 194 from 192.168.0.5:40426 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) session-state: No State attribute
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)   authorize {
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)     update control {
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)     update control {
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)   } # authorize = noop
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) server openroaming {
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) }
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) proxy: allocating destination 192.168.0.3 port 2083 - Id 59
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1) Sent Access-Request Id 59 from 192.168.0.4:55545 to 192.168.0.3:2083 length 54
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: (1)   Proxy-State = 0x313934
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: Proxy is writing 54 bytes to SSL
system-under-test |[0m Tue May 28 19:16:17 2024 : Debug: Thread 5 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:18 2024 : Debug: (1) Expecting proxy response no later than 6.661502 seconds from now
system-under-test |[0m Tue May 28 19:16:18 2024 : Debug: Waking up in 3.6 seconds.
endpoint1         |[0m Tue May 28 19:16:19 2024 : Auth: (0) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:16:19 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:16:19 2024 : Debug: Proxy received header saying we have a packet of 24 bytes
system-under-test |[0m Tue May 28 19:16:19 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 148
system-under-test |[0m Tue May 28 19:16:19 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:16:21 2024 : Debug: (0) Cleaning up request packet ID 47 with timestamp +0 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:16:21 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:16:22 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 59
system-under-test |[0m Tue May 28 19:16:22 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:16:24 2024 : ERROR: (1) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: Thread 4 got semaphore
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: Thread 4 handling request 1, (1 handled so far)
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) server openroaming {
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) }
system-under-test |[0m Tue May 28 19:16:24 2024 : Auth: (1) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) Sent Access-Reject Id 194 from 192.168.0.4:1812 to 192.168.0.5:40426 length 20
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: (1) Finished request
system-under-test |[0m Tue May 28 19:16:24 2024 : Debug: Thread 4 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 194 from 0.0.0.0:9dea to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 194 from 0.0.0.0:9dea to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 194 from 192.168.0.4:714 to 192.168.0.5:40426 length 20
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: Thread 3 got semaphore
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: Thread 3 handling request 2, (1 handled so far)
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) Received Access-Request Id 10 from 192.168.0.5:38097 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) session-state: No State attribute
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)   authorize {
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)     update control {
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)     update control {
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)   } # authorize = noop
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) server openroaming {
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) }
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) proxy: allocating destination 192.168.0.3 port 2083 - Id 87
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2) Sent Access-Request Id 87 from 192.168.0.4:55545 to 192.168.0.3:2083 length 53
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: (2)   Proxy-State = 0x3130
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: Proxy is writing 53 bytes to SSL
system-under-test |[0m Tue May 28 19:16:25 2024 : Debug: Thread 3 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:26 2024 : Debug: (2) Expecting proxy response no later than 6.661842 seconds from now
system-under-test |[0m Tue May 28 19:16:26 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:16:27 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:16:27 2024 : Debug: Proxy received header saying we have a packet of 25 bytes
system-under-test |[0m Tue May 28 19:16:27 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 59
system-under-test |[0m Tue May 28 19:16:27 2024 : Debug: Waking up in 1.8 seconds.
endpoint1         |[0m Tue May 28 19:16:27 2024 : Auth: (1) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:16:29 2024 : Debug: (1) Cleaning up request packet ID 194 with timestamp +8 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:16:29 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:16:30 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 87
system-under-test |[0m Tue May 28 19:16:30 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:16:32 2024 : ERROR: (2) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: Thread 2 got semaphore
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: Thread 2 handling request 2, (2 handled so far)
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) server openroaming {
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) }
system-under-test |[0m Tue May 28 19:16:32 2024 : Auth: (2) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) Sent Access-Reject Id 10 from 192.168.0.4:1812 to 192.168.0.5:38097 length 20
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: (2) Finished request
system-under-test |[0m Tue May 28 19:16:32 2024 : Debug: Thread 2 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 10 from 0.0.0.0:94d1 to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 10 from 0.0.0.0:94d1 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 10 from 192.168.0.4:714 to 192.168.0.5:38097 length 20
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: Thread 1 got semaphore
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: Thread 1 handling request 3, (2 handled so far)
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) Received Access-Request Id 105 from 192.168.0.5:56674 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) session-state: No State attribute
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)   authorize {
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)     update control {
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)     update control {
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)   } # authorize = noop
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) server openroaming {
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) }
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) proxy: allocating destination 192.168.0.3 port 2083 - Id 168
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3) Sent Access-Request Id 168 from 192.168.0.4:55545 to 192.168.0.3:2083 length 54
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: (3)   Proxy-State = 0x313035
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: Proxy is writing 54 bytes to SSL
system-under-test |[0m Tue May 28 19:16:33 2024 : Debug: Thread 1 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:34 2024 : Debug: (3) Expecting proxy response no later than 6.663556 seconds from now
system-under-test |[0m Tue May 28 19:16:34 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:16:35 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:16:35 2024 : Debug: Proxy received header saying we have a packet of 24 bytes
system-under-test |[0m Tue May 28 19:16:35 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 87
system-under-test |[0m Tue May 28 19:16:35 2024 : Debug: Waking up in 1.8 seconds.
endpoint1         |[0m Tue May 28 19:16:35 2024 : ERROR: (2)     ERROR: Failed to read from child output
endpoint1         |[0m Tue May 28 19:16:35 2024 : Auth: (2) Login incorrect (Failed to read from child output): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:16:37 2024 : Debug: (2) Cleaning up request packet ID 10 with timestamp +16 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:16:37 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:16:38 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 168
system-under-test |[0m Tue May 28 19:16:38 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:16:40 2024 : ERROR: (3) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: Thread 5 got semaphore
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: Thread 5 handling request 3, (2 handled so far)
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) server openroaming {
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) }
system-under-test |[0m Tue May 28 19:16:40 2024 : Auth: (3) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) Sent Access-Reject Id 105 from 192.168.0.4:1812 to 192.168.0.5:56674 length 20
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: (3) Finished request
system-under-test |[0m Tue May 28 19:16:40 2024 : Debug: Thread 5 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 105 from 0.0.0.0:dd62 to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 105 from 0.0.0.0:dd62 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 105 from 192.168.0.4:714 to 192.168.0.5:56674 length 20
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: Thread 4 got semaphore
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: Thread 4 handling request 4, (2 handled so far)
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) Received Access-Request Id 171 from 192.168.0.5:37520 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) session-state: No State attribute
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)   authorize {
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)     update control {
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)     update control {
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)   } # authorize = noop
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) server openroaming {
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) }
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) proxy: allocating destination 192.168.0.3 port 2083 - Id 48
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4) Sent Access-Request Id 48 from 192.168.0.4:55545 to 192.168.0.3:2083 length 54
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: (4)   Proxy-State = 0x313731
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: Proxy is writing 54 bytes to SSL
system-under-test |[0m Tue May 28 19:16:41 2024 : Debug: Thread 4 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:42 2024 : Debug: (4) Expecting proxy response no later than 6.664532 seconds from now
system-under-test |[0m Tue May 28 19:16:42 2024 : Debug: Waking up in 3.6 seconds.
endpoint1         |[0m Tue May 28 19:16:43 2024 : ERROR: (3)     ERROR: Failed to read from child output
endpoint1         |[0m Tue May 28 19:16:43 2024 : Auth: (3) Login incorrect (Failed to read from child output): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:16:43 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:16:43 2024 : Debug: Proxy received header saying we have a packet of 25 bytes
system-under-test |[0m Tue May 28 19:16:43 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 168
system-under-test |[0m Tue May 28 19:16:43 2024 : Debug: Waking up in 1.8 seconds.
system-under-test |[0m Tue May 28 19:16:45 2024 : Debug: (3) Cleaning up request packet ID 105 with timestamp +24 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:16:45 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:16:46 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 48
system-under-test |[0m Tue May 28 19:16:46 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:16:48 2024 : Proxy: Marking home server 192.168.0.3 port 2083 as zombie (it has not responded in 7.000000 seconds).
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (5) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (5) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (5) proxy: allocating destination 192.168.0.3 port 2083 - Id 241
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: PING: Waiting 1 seconds for response to ping
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (5) Sent Status-Server Id 241 from 192.168.0.4:55545 to 192.168.0.3:2083 length 70
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (5)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (5)   NAS-Identifier := "Status Check 0. Are you alive?"
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: Proxy is writing 70 bytes to SSL
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: PING: Next status packet in 10 seconds
system-under-test |[0m Tue May 28 19:16:48 2024 : ERROR: (4) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: Thread 3 got semaphore
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: Thread 3 handling request 4, (2 handled so far)
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) server openroaming {
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) }
system-under-test |[0m Tue May 28 19:16:48 2024 : Auth: (4) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) Sent Access-Reject Id 171 from 192.168.0.4:1812 to 192.168.0.5:37520 length 20
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: (4) Finished request
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: Thread 3 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: Proxy received header saying we have a packet of 20 bytes
system-under-test |[0m Tue May 28 19:16:48 2024 : Proxy: (5) Marking home server 192.168.0.3 port 2083 alive
system-under-test |[0m Tue May 28 19:16:48 2024 : Proxy: (5) Received response to status check 5 ID 241 (1 in current sequence)
system-under-test |[0m Tue May 28 19:16:48 2024 : Debug: Waking up in 0.3 seconds.
tester            |[0m Sent Access-Request Id 171 from 0.0.0.0:9290 to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 171 from 0.0.0.0:9290 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 171 from 192.168.0.4:714 to 192.168.0.5:37520 length 20
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: Thread 2 got semaphore
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: Thread 2 handling request 6, (3 handled so far)
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) Received Access-Request Id 9 from 192.168.0.5:37288 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) session-state: No State attribute
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)   authorize {
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)     update control {
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)     update control {
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)   } # authorize = noop
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) server openroaming {
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) }
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) proxy: allocating destination 192.168.0.3 port 2083 - Id 198
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6) Sent Access-Request Id 198 from 192.168.0.4:55545 to 192.168.0.3:2083 length 52
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: (6)   Proxy-State = 0x39
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: Proxy is writing 52 bytes to SSL
system-under-test |[0m Tue May 28 19:16:49 2024 : Debug: Thread 2 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:50 2024 : Debug: (6) Expecting proxy response no later than 6.664631 seconds from now
system-under-test |[0m Tue May 28 19:16:50 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:16:51 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:16:51 2024 : Debug: Proxy received header saying we have a packet of 25 bytes
system-under-test |[0m Tue May 28 19:16:51 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 48
system-under-test |[0m Tue May 28 19:16:51 2024 : Debug: Waking up in 1.9 seconds.
endpoint1         |[0m Tue May 28 19:16:51 2024 : Auth: (4) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:16:53 2024 : Debug: (4) Cleaning up request packet ID 171 with timestamp +32 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:16:53 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:16:54 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 198
system-under-test |[0m Tue May 28 19:16:54 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:16:56 2024 : ERROR: (6) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: Thread 1 got semaphore
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: Thread 1 handling request 6, (3 handled so far)
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) server openroaming {
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) }
system-under-test |[0m Tue May 28 19:16:56 2024 : Auth: (6) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) Sent Access-Reject Id 9 from 192.168.0.4:1812 to 192.168.0.5:37288 length 20
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: (6) Finished request
system-under-test |[0m Tue May 28 19:16:56 2024 : Debug: Thread 1 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 9 from 0.0.0.0:91a8 to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 9 from 0.0.0.0:91a8 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 9 from 192.168.0.4:714 to 192.168.0.5:37288 length 20
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: Thread 5 got semaphore
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: Thread 5 handling request 7, (3 handled so far)
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) Received Access-Request Id 115 from 192.168.0.5:37087 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) session-state: No State attribute
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)   authorize {
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)     update control {
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)     update control {
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)     } # update control = noop
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)   } # authorize = noop
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) server openroaming {
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) }
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) proxy: allocating destination 192.168.0.3 port 2083 - Id 22
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7) Sent Access-Request Id 22 from 192.168.0.4:55545 to 192.168.0.3:2083 length 54
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: (7)   Proxy-State = 0x313135
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: Proxy is writing 54 bytes to SSL
system-under-test |[0m Tue May 28 19:16:57 2024 : Debug: Thread 5 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:16:58 2024 : Debug: (7) Expecting proxy response no later than 6.664193 seconds from now
system-under-test |[0m Tue May 28 19:16:58 2024 : Debug: Waking up in 3.6 seconds.
endpoint1         |[0m Tue May 28 19:16:59 2024 : Auth: (6) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:16:59 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:16:59 2024 : Debug: Proxy received header saying we have a packet of 23 bytes
system-under-test |[0m Tue May 28 19:16:59 2024 : Debug: (6) Reply from home server 192.168.0.3 port 2083  - ID: 198 arrived too late.  Try increasing 'retry_delay' or 'max_request_time'
system-under-test |[0m Tue May 28 19:16:59 2024 : Debug: Waking up in 1.8 seconds.
system-under-test |[0m Tue May 28 19:17:01 2024 : Debug: (6) Cleaning up request packet ID 9 with timestamp +40 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:01 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:17:02 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 22
system-under-test |[0m Tue May 28 19:17:02 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:17:04 2024 : ERROR: (7) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: Thread 4 got semaphore
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: Thread 4 handling request 7, (3 handled so far)
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) server openroaming {
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) }
system-under-test |[0m Tue May 28 19:17:04 2024 : Auth: (7) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) Sent Access-Reject Id 115 from 192.168.0.4:1812 to 192.168.0.5:37087 length 20
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: (7) Finished request
system-under-test |[0m Tue May 28 19:17:04 2024 : Debug: Thread 4 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 115 from 0.0.0.0:90df to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 115 from 0.0.0.0:90df to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 115 from 192.168.0.4:714 to 192.168.0.5:37087 length 20
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Thread 3 got semaphore
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Thread 3 handling request 8, (3 handled so far)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) Received Access-Request Id 36 from 192.168.0.5:40652 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)   authorize {
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)     update control {
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)     update control {
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) server openroaming {
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) }
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) proxy: Trying to open a new listener to the home server
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
endpoint1         |[0m Tue May 28 19:17:05 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 57735) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Requiring Server certificate
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:17:05 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:17:05 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:05 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 57735) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:17:05 2024 : ERROR: (8) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:17:05 2024 : Proxy: (8) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Listening on proxy (192.168.0.4, 57735) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) Sent Access-Reject Id 36 from 192.168.0.4:1812 to 192.168.0.5:40652 length 20
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: (8) Finished request
system-under-test |[0m Tue May 28 19:17:05 2024 : Debug: Thread 3 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 36 from 0.0.0.0:9ecc to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 36 from 192.168.0.4:714 to 192.168.0.5:40652 length 20
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: Thread 2 got semaphore
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: Thread 2 handling request 9, (4 handled so far)
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) Received Access-Request Id 69 from 192.168.0.5:50621 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)   authorize {
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)     update control {
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)     update control {
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) server openroaming {
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) }
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) proxy: allocating destination 192.168.0.3 port 2083 - Id 77
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9) Sent Access-Request Id 77 from 192.168.0.4:57735 to 192.168.0.3:2083 length 53
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: (9)   Proxy-State = 0x3639
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: Proxy is writing 53 bytes to SSL
system-under-test |[0m Tue May 28 19:17:06 2024 : Debug: Thread 2 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:07 2024 : Debug: (9) Expecting proxy response no later than 6.666019 seconds from now
system-under-test |[0m Tue May 28 19:17:07 2024 : Debug: Waking up in 2.5 seconds.
endpoint1         |[0m Tue May 28 19:17:07 2024 : ERROR: (7)     ERROR: Failed to read from child output
endpoint1         |[0m Tue May 28 19:17:07 2024 : Auth: (7) Login incorrect (Failed to read from child output): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:17:07 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:17:07 2024 : Debug: Proxy received header saying we have a packet of 25 bytes
system-under-test |[0m Tue May 28 19:17:07 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 22
system-under-test |[0m Tue May 28 19:17:07 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:17:09 2024 : Debug: (7) Cleaning up request packet ID 115 with timestamp +48 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:09 2024 : Debug: Waking up in 1.0 seconds.
system-under-test |[0m Tue May 28 19:17:10 2024 : Debug: (8) Cleaning up request packet ID 36 with timestamp +56 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:10 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:17:11 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 77
system-under-test |[0m Tue May 28 19:17:11 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:17:13 2024 : ERROR: (9) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: Thread 1 got semaphore
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: Thread 1 handling request 9, (4 handled so far)
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) server openroaming {
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) }
system-under-test |[0m Tue May 28 19:17:13 2024 : Auth: (9) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) Sent Access-Reject Id 69 from 192.168.0.4:1812 to 192.168.0.5:50621 length 20
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: (9) Finished request
system-under-test |[0m Tue May 28 19:17:13 2024 : Debug: Thread 1 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 69 from 0.0.0.0:c5bd to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 69 from 0.0.0.0:c5bd to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 69 from 192.168.0.4:714 to 192.168.0.5:50621 length 20
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: Thread 5 got semaphore
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: Thread 5 handling request 10, (4 handled so far)
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) Received Access-Request Id 106 from 192.168.0.5:46284 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)   authorize {
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)     update control {
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)     update control {
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) server openroaming {
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) }
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) proxy: allocating destination 192.168.0.3 port 2083 - Id 141
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10) Sent Access-Request Id 141 from 192.168.0.4:55545 to 192.168.0.3:2083 length 54
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: (10)   Proxy-State = 0x313036
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: Proxy is writing 54 bytes to SSL
system-under-test |[0m Tue May 28 19:17:14 2024 : Debug: Thread 5 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:15 2024 : Debug: (10) Expecting proxy response no later than 6.662335 seconds from now
system-under-test |[0m Tue May 28 19:17:15 2024 : Debug: Waking up in 3.6 seconds.
endpoint1         |[0m Tue May 28 19:17:17 2024 : Auth: (8) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:17:17 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:17:17 2024 : Debug: Proxy received header saying we have a packet of 24 bytes
system-under-test |[0m Tue May 28 19:17:17 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 77
system-under-test |[0m Tue May 28 19:17:17 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:17:18 2024 : Debug: (9) Cleaning up request packet ID 69 with timestamp +57 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:18 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:17:19 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 141
system-under-test |[0m Tue May 28 19:17:19 2024 : Debug: Waking up in 2.0 seconds.
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:17:21 2024 : ERROR: (10) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: Thread 4 got semaphore
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: Thread 4 handling request 10, (4 handled so far)
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) server openroaming {
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) }
system-under-test |[0m Tue May 28 19:17:21 2024 : Auth: (10) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) Sent Access-Reject Id 106 from 192.168.0.4:1812 to 192.168.0.5:46284 length 20
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: (10) Finished request
system-under-test |[0m Tue May 28 19:17:21 2024 : Debug: Thread 4 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 106 from 0.0.0.0:b4cc to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 106 from 0.0.0.0:b4cc to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 106 from 192.168.0.4:714 to 192.168.0.5:46284 length 20
system-under-test |[0m Tue May 28 19:17:22 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: Thread 3 got semaphore
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: Thread 3 handling request 11, (4 handled so far)
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) Received Access-Request Id 39 from 192.168.0.5:42043 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)   authorize {
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)     update control {
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)     update control {
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) server openroaming {
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) }
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) proxy: allocating destination 192.168.0.3 port 2083 - Id 83
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) Sent Access-Request Id 83 from 192.168.0.4:57735 to 192.168.0.3:2083 length 53
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11)   Proxy-State = 0x3339
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: Proxy is writing 53 bytes to SSL
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: Thread 3 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: (11) Expecting proxy response no later than 6.661752 seconds from now
system-under-test |[0m Tue May 28 19:17:23 2024 : Debug: Waking up in 3.6 seconds.
endpoint1         |[0m Tue May 28 19:17:24 2024 : Auth: (9) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:17:24 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:17:24 2024 : Debug: Proxy received header saying we have a packet of 25 bytes
system-under-test |[0m Tue May 28 19:17:24 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 141
system-under-test |[0m Tue May 28 19:17:24 2024 : Debug: Waking up in 2.0 seconds.
system-under-test |[0m Tue May 28 19:17:26 2024 : Debug: (10) Cleaning up request packet ID 106 with timestamp +65 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:26 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:17:28 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 83
system-under-test |[0m Tue May 28 19:17:28 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:17:30 2024 : Proxy: Marking home server 192.168.0.3 port 2083 as zombie (it has not responded in 7.000000 seconds).
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (12) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (12) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (12) proxy: allocating destination 192.168.0.3 port 2083 - Id 31
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: PING: Waiting 1 seconds for response to ping
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (12) Sent Status-Server Id 31 from 192.168.0.4:57735 to 192.168.0.3:2083 length 70
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (12)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (12)   NAS-Identifier := "Status Check 0. Are you alive?"
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: Proxy is writing 70 bytes to SSL
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: PING: Next status packet in 10 seconds
system-under-test |[0m Tue May 28 19:17:30 2024 : ERROR: (11) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: Thread 2 got semaphore
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: Thread 2 handling request 11, (5 handled so far)
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) server openroaming {
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) }
system-under-test |[0m Tue May 28 19:17:30 2024 : Auth: (11) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) Sent Access-Reject Id 39 from 192.168.0.4:1812 to 192.168.0.5:42043 length 20
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: (11) Finished request
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: Thread 2 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: Proxy received header saying we have a packet of 20 bytes
system-under-test |[0m Tue May 28 19:17:30 2024 : Proxy: (12) Marking home server 192.168.0.3 port 2083 alive
system-under-test |[0m Tue May 28 19:17:30 2024 : Proxy: (12) Received response to status check 12 ID 31 (1 in current sequence)
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: Waking up in 0.3 seconds.
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 39 from 0.0.0.0:a43b to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 39 from 0.0.0.0:a43b to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 39 from 192.168.0.4:714 to 192.168.0.5:42043 length 20
system-under-test |[0m Tue May 28 19:17:30 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Thread 1 got semaphore
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Thread 1 handling request 13, (5 handled so far)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) Received Access-Request Id 33 from 192.168.0.5:49693 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)   authorize {
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)     update control {
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)     update control {
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) server openroaming {
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) }
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) proxy: Trying to open a new listener to the home server
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
endpoint1         |[0m Tue May 28 19:17:31 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 41331) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Requiring Server certificate
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:17:31 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:17:31 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:31 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 41331) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Listening on proxy (192.168.0.4, 41331) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:17:31 2024 : ERROR: (13) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:31 2024 : Proxy: (13) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) Sent Access-Reject Id 33 from 192.168.0.4:1812 to 192.168.0.5:49693 length 20
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: (13) Finished request
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Thread 1 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 33 from 0.0.0.0:c21d to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 33 from 192.168.0.4:714 to 192.168.0.5:49693 length 20
system-under-test |[0m Tue May 28 19:17:31 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: Thread 5 got semaphore
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: Thread 5 handling request 14, (5 handled so far)
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) Received Access-Request Id 254 from 192.168.0.5:60591 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)   authorize {
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)     update control {
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)     update control {
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) server openroaming {
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) }
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) proxy: allocating destination 192.168.0.3 port 2083 - Id 161
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) Sent Access-Request Id 161 from 192.168.0.4:55545 to 192.168.0.3:2083 length 54
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14)   Proxy-State = 0x323534
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: Proxy is writing 54 bytes to SSL
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: Thread 5 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: (14) Expecting proxy response no later than 6.661722 seconds from now
system-under-test |[0m Tue May 28 19:17:32 2024 : Debug: Waking up in 2.5 seconds.
endpoint1         |[0m Tue May 28 19:17:33 2024 : Auth: (10) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:17:33 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:17:33 2024 : Debug: Proxy received header saying we have a packet of 24 bytes
system-under-test |[0m Tue May 28 19:17:33 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 83
system-under-test |[0m Tue May 28 19:17:33 2024 : Debug: Waking up in 1.8 seconds.
system-under-test |[0m Tue May 28 19:17:35 2024 : Debug: (11) Cleaning up request packet ID 39 with timestamp +74 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:35 2024 : Debug: Waking up in 1.0 seconds.
system-under-test |[0m Tue May 28 19:17:36 2024 : Debug: (13) Cleaning up request packet ID 33 with timestamp +82 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:36 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:17:37 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 161
system-under-test |[0m Tue May 28 19:17:37 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:17:39 2024 : ERROR: (14) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: Thread 4 got semaphore
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: Thread 4 handling request 14, (5 handled so far)
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) server openroaming {
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) }
system-under-test |[0m Tue May 28 19:17:39 2024 : Auth: (14) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) Sent Access-Reject Id 254 from 192.168.0.4:1812 to 192.168.0.5:60591 length 20
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: (14) Finished request
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: Thread 4 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 254 from 0.0.0.0:ecaf to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 254 from 0.0.0.0:ecaf to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 254 from 192.168.0.4:714 to 192.168.0.5:60591 length 20
system-under-test |[0m Tue May 28 19:17:39 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Thread 3 got semaphore
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Thread 3 handling request 15, (5 handled so far)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) Received Access-Request Id 188 from 192.168.0.5:53826 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)   authorize {
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)     update control {
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)     update control {
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) server openroaming {
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) }
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) proxy: Trying to open a new listener to the home server
endpoint1         |[0m Tue May 28 19:17:40 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 52465) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Requiring Server certificate
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:17:40 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:17:40 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:40 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 52465) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:17:40 2024 : ERROR: (15) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:17:40 2024 : Proxy: (15) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) Sent Access-Reject Id 188 from 192.168.0.4:1812 to 192.168.0.5:53826 length 20
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: (15) Finished request
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Thread 3 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Listening on proxy (192.168.0.4, 52465) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Waking up in 0.3 seconds.
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 188 from 0.0.0.0:d242 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 188 from 192.168.0.4:714 to 192.168.0.5:53826 length 20
system-under-test |[0m Tue May 28 19:17:40 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: Thread 2 got semaphore
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: Thread 2 handling request 16, (6 handled so far)
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) Received Access-Request Id 49 from 192.168.0.5:46092 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)   authorize {
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)     update control {
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)     update control {
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) server openroaming {
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) }
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) proxy: allocating destination 192.168.0.3 port 2083 - Id 60
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) Sent Access-Request Id 60 from 192.168.0.4:57735 to 192.168.0.3:2083 length 53
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16)   Proxy-State = 0x3439
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: Proxy is writing 53 bytes to SSL
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: Thread 2 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: (16) Expecting proxy response no later than 6.665637 seconds from now
system-under-test |[0m Tue May 28 19:17:41 2024 : Debug: Waking up in 2.5 seconds.
system-under-test |[0m Tue May 28 19:17:42 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:17:42 2024 : Debug: Proxy received header saying we have a packet of 25 bytes
system-under-test |[0m Tue May 28 19:17:42 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 161
system-under-test |[0m Tue May 28 19:17:42 2024 : Debug: Waking up in 1.9 seconds.
endpoint1         |[0m Tue May 28 19:17:42 2024 : Auth: (12) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:17:44 2024 : Debug: (14) Cleaning up request packet ID 254 with timestamp +83 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:44 2024 : Debug: Waking up in 1.0 seconds.
system-under-test |[0m Tue May 28 19:17:45 2024 : Debug: (15) Cleaning up request packet ID 188 with timestamp +91 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:45 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:17:46 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 60
system-under-test |[0m Tue May 28 19:17:46 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:17:48 2024 : ERROR: (16) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: Thread 1 got semaphore
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: Thread 1 handling request 16, (6 handled so far)
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) server openroaming {
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) }
system-under-test |[0m Tue May 28 19:17:48 2024 : Auth: (16) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) Sent Access-Reject Id 49 from 192.168.0.4:1812 to 192.168.0.5:46092 length 20
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: (16) Finished request
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: Thread 1 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 49 from 0.0.0.0:b40c to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 49 from 0.0.0.0:b40c to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 49 from 192.168.0.4:714 to 192.168.0.5:46092 length 20
system-under-test |[0m Tue May 28 19:17:48 2024 : Debug: Waking up in 4.6 seconds.
endpoint1         |[0m Tue May 28 19:17:49 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 53029) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Thread 5 got semaphore
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Thread 5 handling request 17, (6 handled so far)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) Received Access-Request Id 243 from 192.168.0.5:41458 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)   authorize {
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)     update control {
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)     update control {
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) server openroaming {
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) }
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) proxy: Trying to open a new listener to the home server
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Requiring Server certificate
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:17:49 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:17:49 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:49 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 53029) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Listening on proxy (192.168.0.4, 53029) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:49 2024 : ERROR: (17) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:17:49 2024 : Proxy: (17) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) Sent Access-Reject Id 243 from 192.168.0.4:1812 to 192.168.0.5:41458 length 20
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: (17) Finished request
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Thread 5 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 243 from 0.0.0.0:a1f2 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 243 from 192.168.0.4:714 to 192.168.0.5:41458 length 20
system-under-test |[0m Tue May 28 19:17:49 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: Thread 4 got semaphore
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: Thread 4 handling request 18, (6 handled so far)
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) Received Access-Request Id 26 from 192.168.0.5:47692 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)   authorize {
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)     update control {
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)     update control {
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) server openroaming {
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) }
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) proxy: allocating destination 192.168.0.3 port 2083 - Id 192
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) Sent Access-Request Id 192 from 192.168.0.4:41331 to 192.168.0.3:2083 length 53
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18)   Proxy-State = 0x3236
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: Proxy is writing 53 bytes to SSL
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: Thread 4 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: (18) Expecting proxy response no later than 6.665331 seconds from now
system-under-test |[0m Tue May 28 19:17:50 2024 : Debug: Waking up in 2.5 seconds.
system-under-test |[0m Tue May 28 19:17:51 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:17:51 2024 : Debug: Proxy received header saying we have a packet of 24 bytes
endpoint1         |[0m Tue May 28 19:17:51 2024 : Auth: (13) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:17:51 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 60
system-under-test |[0m Tue May 28 19:17:51 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:17:53 2024 : Debug: (16) Cleaning up request packet ID 49 with timestamp +92 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:53 2024 : Debug: Waking up in 1.0 seconds.
system-under-test |[0m Tue May 28 19:17:54 2024 : Debug: (17) Cleaning up request packet ID 243 with timestamp +100 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:17:54 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:17:55 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 192
system-under-test |[0m Tue May 28 19:17:55 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:17:57 2024 : ERROR: (18) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: Thread 3 got semaphore
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: Thread 3 handling request 18, (6 handled so far)
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) server openroaming {
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) }
system-under-test |[0m Tue May 28 19:17:57 2024 : Auth: (18) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) Sent Access-Reject Id 26 from 192.168.0.4:1812 to 192.168.0.5:47692 length 20
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: (18) Finished request
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: Thread 3 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 26 from 0.0.0.0:ba4c to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 26 from 0.0.0.0:ba4c to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 26 from 192.168.0.4:714 to 192.168.0.5:47692 length 20
system-under-test |[0m Tue May 28 19:17:57 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Thread 2 got semaphore
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Thread 2 handling request 19, (7 handled so far)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) Received Access-Request Id 29 from 192.168.0.5:35087 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)   authorize {
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)     update control {
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)     update control {
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) server openroaming {
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) }
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) proxy: Trying to open a new listener to the home server
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Requiring Server certificate
endpoint1         |[0m Tue May 28 19:17:58 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 56965) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:17:58 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:17:58 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:58 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 56965) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:17:58 2024 : ERROR: (19) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:17:58 2024 : Proxy: (19) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) Sent Access-Reject Id 29 from 192.168.0.4:1812 to 192.168.0.5:35087 length 20
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: (19) Finished request
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Thread 2 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Listening on proxy (192.168.0.4, 56965) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Waking up in 0.3 seconds.
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 29 from 0.0.0.0:890f to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 29 from 192.168.0.4:714 to 192.168.0.5:35087 length 20
system-under-test |[0m Tue May 28 19:17:58 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: Thread 1 got semaphore
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: Thread 1 handling request 20, (7 handled so far)
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) Received Access-Request Id 189 from 192.168.0.5:43018 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) session-state: No State attribute
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)   authorize {
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)     update control {
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)     update control {
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)     } # update control = noop
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)   } # authorize = noop
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) server openroaming {
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) }
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) proxy: allocating destination 192.168.0.3 port 2083 - Id 115
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) Sent Access-Request Id 115 from 192.168.0.4:57735 to 192.168.0.3:2083 length 54
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20)   Proxy-State = 0x313839
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: Proxy is writing 54 bytes to SSL
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: Thread 1 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: (20) Expecting proxy response no later than 6.663521 seconds from now
system-under-test |[0m Tue May 28 19:17:59 2024 : Debug: Waking up in 2.5 seconds.
endpoint1         |[0m Tue May 28 19:18:00 2024 : ERROR: (14)     ERROR: Failed to read from child output
endpoint1         |[0m Tue May 28 19:18:00 2024 : Auth: (14) Login incorrect (Failed to read from child output): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:18:00 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:18:00 2024 : Debug: Proxy received header saying we have a packet of 24 bytes
system-under-test |[0m Tue May 28 19:18:00 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 192
system-under-test |[0m Tue May 28 19:18:00 2024 : Debug: Waking up in 1.8 seconds.
system-under-test |[0m Tue May 28 19:18:02 2024 : Debug: (18) Cleaning up request packet ID 26 with timestamp +101 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:18:02 2024 : Debug: Waking up in 1.0 seconds.
system-under-test |[0m Tue May 28 19:18:02 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:18:02 2024 : Debug: (0) (TLS) send TLS 1.2 Alert, fatal decode_error
system-under-test |[0m Tue May 28 19:18:02 2024 : ERROR: (0) (TLS) Alert write:fatal:decode error
system-under-test |[0m Tue May 28 19:18:02 2024 : Debug: (TLS) Home server has closed the connection
system-under-test |[0m Tue May 28 19:18:02 2024 : Debug: (TLS) Closing connection
system-under-test |[0m Tue May 28 19:18:02 2024 : Debug: Closing TLS socket to home server
system-under-test |[0m Tue May 28 19:18:02 2024 : Debug: Waking up in 0.8 seconds.
endpoint1         |[0m Tue May 28 19:18:02 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 55545) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:18:03 2024 : Debug: (19) Cleaning up request packet ID 29 with timestamp +109 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:18:03 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:18:04 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 115
system-under-test |[0m Tue May 28 19:18:04 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:18:06 2024 : ERROR: (20) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: Thread 5 got semaphore
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: Thread 5 handling request 20, (7 handled so far)
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) server openroaming {
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) }
system-under-test |[0m Tue May 28 19:18:06 2024 : Auth: (20) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) Sent Access-Reject Id 189 from 192.168.0.4:1812 to 192.168.0.5:43018 length 20
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: (20) Finished request
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: Thread 5 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 189 from 0.0.0.0:a80a to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 189 from 0.0.0.0:a80a to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 189 from 192.168.0.4:714 to 192.168.0.5:43018 length 20
system-under-test |[0m Tue May 28 19:18:06 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Thread 4 got semaphore
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Thread 4 handling request 21, (7 handled so far)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) Received Access-Request Id 15 from 192.168.0.5:33640 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) session-state: No State attribute
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)   authorize {
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)     update control {
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)     update control {
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)   } # authorize = noop
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) server openroaming {
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) }
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) proxy: Trying to open a new listener to the home server
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Requiring Server certificate
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Waking up in 0.3 seconds.
endpoint1         |[0m Tue May 28 19:18:07 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 57695) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:18:07 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:18:07 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:07 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 57695) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:18:07 2024 : ERROR: (21) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:18:07 2024 : Proxy: (21) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) Sent Access-Reject Id 15 from 192.168.0.4:1812 to 192.168.0.5:33640 length 20
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: (21) Finished request
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Thread 4 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Listening on proxy (192.168.0.4, 57695) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Waking up in 0.3 seconds.
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 15 from 0.0.0.0:8368 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 15 from 192.168.0.4:714 to 192.168.0.5:33640 length 20
system-under-test |[0m Tue May 28 19:18:07 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: Thread 3 got semaphore
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: Thread 3 handling request 22, (7 handled so far)
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) Received Access-Request Id 38 from 192.168.0.5:46298 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) session-state: No State attribute
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)   authorize {
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)     update control {
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)     update control {
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)   } # authorize = noop
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) server openroaming {
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) }
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) proxy: allocating destination 192.168.0.3 port 2083 - Id 231
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) Sent Access-Request Id 231 from 192.168.0.4:53029 to 192.168.0.3:2083 length 53
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22)   Proxy-State = 0x3338
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: Proxy is writing 53 bytes to SSL
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: Thread 3 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: (22) Expecting proxy response no later than 6.666914 seconds from now
system-under-test |[0m Tue May 28 19:18:08 2024 : Debug: Waking up in 2.5 seconds.
endpoint1         |[0m Tue May 28 19:18:09 2024 : Auth: (15) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:18:09 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:18:09 2024 : Debug: Proxy received header saying we have a packet of 25 bytes
system-under-test |[0m Tue May 28 19:18:09 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 115
system-under-test |[0m Tue May 28 19:18:09 2024 : Debug: Waking up in 1.8 seconds.
system-under-test |[0m Tue May 28 19:18:10 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:18:10 2024 : Debug: (0) (TLS) send TLS 1.2 Alert, fatal decode_error
system-under-test |[0m Tue May 28 19:18:10 2024 : ERROR: (0) (TLS) Alert write:fatal:decode error
system-under-test |[0m Tue May 28 19:18:10 2024 : Debug: (TLS) Home server has closed the connection
system-under-test |[0m Tue May 28 19:18:10 2024 : Debug: (TLS) Closing connection
system-under-test |[0m Tue May 28 19:18:10 2024 : Info:  ... shutting down socket proxy (192.168.0.4, 52465) -> home_server (192.168.0.3, 2083) (7 of 128)
system-under-test |[0m Tue May 28 19:18:10 2024 : Debug: ... cleaning up socket proxy (192.168.0.4, 52465) -> home_server (192.168.0.3, 2083)
endpoint1         |[0m Tue May 28 19:18:10 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 52465) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:18:10 2024 : Debug: Closing TLS socket to home server
system-under-test |[0m Tue May 28 19:18:10 2024 : Debug: Waking up in 0.8 seconds.
system-under-test |[0m Tue May 28 19:18:11 2024 : Debug: (20) Cleaning up request packet ID 189 with timestamp +110 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:18:11 2024 : Debug: Waking up in 1.0 seconds.
system-under-test |[0m Tue May 28 19:18:12 2024 : Debug: (21) Cleaning up request packet ID 15 with timestamp +118 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:18:12 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:18:13 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 231
system-under-test |[0m Tue May 28 19:18:13 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:18:15 2024 : Proxy: Marking home server 192.168.0.3 port 2083 as zombie (it has not responded in 7.000000 seconds).
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (23) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (23) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (23) proxy: allocating destination 192.168.0.3 port 2083 - Id 118
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: PING: Waiting 1 seconds for response to ping
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (23) Sent Status-Server Id 118 from 192.168.0.4:41331 to 192.168.0.3:2083 length 70
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (23)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (23)   NAS-Identifier := "Status Check 0. Are you alive?"
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: Proxy is writing 70 bytes to SSL
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: PING: Next status packet in 10 seconds
system-under-test |[0m Tue May 28 19:18:15 2024 : ERROR: (22) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: Thread 2 got semaphore
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: Thread 2 handling request 22, (8 handled so far)
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) server openroaming {
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) }
system-under-test |[0m Tue May 28 19:18:15 2024 : Auth: (22) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) Sent Access-Reject Id 38 from 192.168.0.4:1812 to 192.168.0.5:46298 length 20
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: (22) Finished request
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: Thread 2 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: Proxy received header saying we have a packet of 20 bytes
system-under-test |[0m Tue May 28 19:18:15 2024 : Proxy: (23) Marking home server 192.168.0.3 port 2083 alive
system-under-test |[0m Tue May 28 19:18:15 2024 : Proxy: (23) Received response to status check 23 ID 118 (1 in current sequence)
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: Waking up in 0.3 seconds.
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 38 from 0.0.0.0:b4da to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 38 from 0.0.0.0:b4da to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 38 from 192.168.0.4:714 to 192.168.0.5:46298 length 20
system-under-test |[0m Tue May 28 19:18:15 2024 : Debug: Waking up in 4.6 seconds.
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Thread 1 got semaphore
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Thread 1 handling request 24, (8 handled so far)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) Received Access-Request Id 14 from 192.168.0.5:40757 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) session-state: No State attribute
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)   authorize {
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)     update control {
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)     update control {
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)   } # authorize = noop
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Using home pool auth for realm DEFAULT
endpoint1         |[0m Tue May 28 19:18:16 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 52103) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) server openroaming {
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) }
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) proxy: Trying to open a new listener to the home server
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Requiring Server certificate
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:18:16 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:18:16 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:16 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 52103) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Listening on proxy (192.168.0.4, 52103) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:16 2024 : ERROR: (24) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:18:16 2024 : Proxy: (24) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) Sent Access-Reject Id 14 from 192.168.0.4:1812 to 192.168.0.5:40757 length 20
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: (24) Finished request
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Thread 1 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 14 from 0.0.0.0:9f35 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 14 from 192.168.0.4:714 to 192.168.0.5:40757 length 20
system-under-test |[0m Tue May 28 19:18:16 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Thread 5 got semaphore
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Thread 5 handling request 25, (8 handled so far)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) Received Access-Request Id 163 from 192.168.0.5:33156 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) session-state: No State attribute
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)   authorize {
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)     update control {
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)     update control {
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)   } # authorize = noop
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) server openroaming {
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) }
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) proxy: Trying to open a new listener to the home server
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Requiring Server certificate
endpoint1         |[0m Tue May 28 19:18:17 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 51579) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:18:17 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:18:17 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:17 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 51579) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:18:17 2024 : ERROR: (25) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:18:17 2024 : Proxy: (25) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Listening on proxy (192.168.0.4, 51579) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) Sent Access-Reject Id 163 from 192.168.0.4:1812 to 192.168.0.5:33156 length 20
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: (25) Finished request
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Thread 5 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 163 from 0.0.0.0:8184 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 163 from 192.168.0.4:714 to 192.168.0.5:33156 length 20
system-under-test |[0m Tue May 28 19:18:17 2024 : Debug: Waking up in 2.5 seconds.
endpoint1         |[0m Tue May 28 19:18:18 2024 : Auth: (16) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Proxy received header saying we have a packet of 24 bytes
system-under-test |[0m Tue May 28 19:18:18 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 231
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Thread 4 got semaphore
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Thread 4 handling request 26, (8 handled so far)
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) Received Access-Request Id 64 from 192.168.0.5:47183 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) session-state: No State attribute
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)   authorize {
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)     update control {
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)     update control {
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)   } # authorize = noop
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) server openroaming {
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) }
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) proxy: allocating destination 192.168.0.3 port 2083 - Id 148
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) Sent Access-Request Id 148 from 192.168.0.4:57695 to 192.168.0.3:2083 length 53
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26)   Proxy-State = 0x3634
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Proxy is writing 53 bytes to SSL
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Thread 4 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: (26) Expecting proxy response no later than 6.662439 seconds from now
system-under-test |[0m Tue May 28 19:18:18 2024 : Debug: Waking up in 1.5 seconds.
system-under-test |[0m Tue May 28 19:18:20 2024 : Debug: (22) Cleaning up request packet ID 38 with timestamp +119 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:18:20 2024 : Debug: Waking up in 1.0 seconds.
system-under-test |[0m Tue May 28 19:18:21 2024 : Debug: (24) Cleaning up request packet ID 14 with timestamp +127 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:18:21 2024 : Debug: Waking up in 1.0 seconds.
system-under-test |[0m Tue May 28 19:18:22 2024 : Debug: (25) Cleaning up request packet ID 163 with timestamp +128 due to cleanup_delay was reached
system-under-test |[0m Tue May 28 19:18:22 2024 : Debug: Waking up in 3.0 seconds.
system-under-test |[0m Tue May 28 19:18:23 2024 : Debug: Suppressing duplicate proxied request (tcp) to home server 192.168.0.3 port 2083 proto TCP - ID: 148
system-under-test |[0m Tue May 28 19:18:23 2024 : Debug: Waking up in 1.9 seconds.
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) No proxy response, giving up on request and marking it done
system-under-test |[0m Tue May 28 19:18:25 2024 : ERROR: (26) Failing proxied request for user "test@user", due to lack of any response from home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: Thread 3 got semaphore
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: Thread 3 handling request 26, (8 handled so far)
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) Clearing existing &reply: attributes
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) Found Post-Proxy-Type Fail-Authentication
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) server openroaming {
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26)   Post-Proxy-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) }
system-under-test |[0m Tue May 28 19:18:25 2024 : Auth: (26) Login incorrect (Home Server failed to respond): [test@user] (from client any port 0)
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) Sent Access-Reject Id 64 from 192.168.0.4:1812 to 192.168.0.5:47183 length 20
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: (26) Finished request
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: Thread 3 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 64 from 0.0.0.0:b84f to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 64 from 0.0.0.0:b84f to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 64 from 192.168.0.4:714 to 192.168.0.5:47183 length 20
system-under-test |[0m Tue May 28 19:18:25 2024 : Debug: Waking up in 4.6 seconds.
endpoint1         |[0m Tue May 28 19:18:26 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 40889) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Thread 2 got semaphore
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Thread 2 handling request 27, (9 handled so far)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) Received Access-Request Id 150 from 192.168.0.5:57877 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) session-state: No State attribute
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)   authorize {
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)     update control {
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)     update control {
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)   } # authorize = noop
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) server openroaming {
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) }
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) proxy: Trying to open a new listener to the home server
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Requiring Server certificate
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:18:26 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:18:26 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:26 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 40889) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:18:26 2024 : ERROR: (27) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:18:26 2024 : Proxy: (27) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) Sent Access-Reject Id 150 from 192.168.0.4:1812 to 192.168.0.5:57877 length 20
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Listening on proxy (192.168.0.4, 40889) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: (27) Finished request
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Thread 2 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 150 from 0.0.0.0:e215 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 150 from 192.168.0.4:714 to 192.168.0.5:57877 length 20
system-under-test |[0m Tue May 28 19:18:26 2024 : Debug: Waking up in 3.6 seconds.
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Thread 1 got semaphore
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Thread 1 handling request 28, (9 handled so far)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) Received Access-Request Id 18 from 192.168.0.5:56866 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) session-state: No State attribute
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)   authorize {
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)     update control {
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)     update control {
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)   } # authorize = noop
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) server openroaming {
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) }
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) proxy: Trying to open a new listener to the home server
endpoint1         |[0m Tue May 28 19:18:27 2024 : Info:  ... adding new socket auth+acct from client (192.168.0.4, 51035) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (TLS) Trying new outgoing proxy connection to proxy (0.0.0.0, 0) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Requiring Server certificate
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [PINIT] - before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [PINIT] - Client before SSL initialization (0)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientHello
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TWCH] - Client SSLv3/TLS write client hello (12)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHello
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TRSH] - Client SSLv3/TLS read server hello (3)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Creating attributes from server certificate
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Cert-Serial := "10b07c2c514073c3514ef8bea9782f92e00216f7"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Cert-Expiration := "21210302182204Z"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Cert-Valid-Since := "210326182204Z"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Cert-Subject := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Cert-Common-Name := "valid_ca"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) chain-depth   : 1
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) common name   : valid_ca
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) subject       : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Creating attributes from client certificate
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-Serial := "e966c4723931eef697e941e858faad6d"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-Expiration := "21210302182244Z"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-Valid-Since := "210326182244Z"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-Subject := "/CN=valid_server"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-Issuer := "/CN=valid_ca"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-Common-Name := "valid_server"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-Subject-Alt-Name-Dns := "valid_server"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Basic-Constraints += "CA:FALSE"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Subject-Key-Identifier += "EE:CA:3B:69:D0:43:44:B8:74:C2:99:E1:61:5A:6C:02:F9:E1:2C:62"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Authority-Key-Identifier += "keyid:CC:0E:1E:EF:44:88:74:BF:E8:A6:63:DB:0C:1D:D5:33:8C:2C:30:D5\nDirName:/CN=valid_ca\nserial:10:B0:7C:2C:51:40:73:C3:51:4E:F8:BE:A9:78:2F:92:E0:02:16:F7"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage += "TLS Web Server Authentication"
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Key-Usage += 'Digital Signature, Key Encipherment'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   Skipping TLS-Client-Cert-X509v3-Subject-Alternative-Name += 'DNS:valid_server'.  Please check that both the attribute and value are defined in the dictionaries
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0)   TLS-Client-Cert-X509v3-Extended-Key-Usage-OID += "1.3.6.1.5.5.7.3.1"
system-under-test |[0m Tue May 28 19:18:27 2024 : Warning: Certificate chain - 1 cert(s) untrusted
system-under-test |[0m Tue May 28 19:18:27 2024 : Warning: (TLS) untrusted certificate with depth [1] subject name /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:27 2024 : Warning: (TLS) untrusted certificate with depth [0] subject name /CN=valid_server
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) chain-depth   : 0
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) error         : 0
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) common name   : valid_server
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) subject       : /CN=valid_server
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) issuer        : /CN=valid_ca
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) verify return : 1
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TRSC] - Client SSLv3/TLS read server certificate (4)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerKeyExchange
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TRSKE] - Client SSLv3/TLS read server key exchange (6)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, CertificateRequest
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TRCR] - Client SSLv3/TLS read server certificate request (7)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, ServerHelloDone
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TRSD] - Client SSLv3/TLS read server done (8)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Certificate
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TWCC] - Client SSLv3/TLS write client certificate (13)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, ClientKeyExchange
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TWCKE] - Client SSLv3/TLS write client key exchange (14)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, CertificateVerify
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TWCV] - Client SSLv3/TLS write certificate verify (15)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) send TLS 1.2 ChangeCipherSpec
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TWCCS] - Client SSLv3/TLS write change cipher spec (16)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) send TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TWFIN] - Client SSLv3/TLS write finished (18)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TRCCS] - Client SSLv3/TLS read change cipher spec (10)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) recv TLS 1.2 Handshake, Finished
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [TRFIN] - Client SSLv3/TLS read finished (11)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (0) (TLS) Handshake state [SSLOK] - SSL negotiation finished successfully (1)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Opened new proxy socket 'proxy (192.168.0.4, 51035) -> home_server (192.168.0.3, 2083)'
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) proxy: Trying to allocate ID (1/2)
system-under-test |[0m Tue May 28 19:18:27 2024 : ERROR: (28) proxy: Failed allocating Id for proxied request
system-under-test |[0m Tue May 28 19:18:27 2024 : Proxy: (28) Failed to insert request into the proxy list
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) There was no response configured: rejecting request
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) Using Post-Auth-Type Reject
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) Post-Auth-Type sub-section not found.  Ignoring.
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) Sent Access-Reject Id 18 from 192.168.0.4:1812 to 192.168.0.5:56866 length 20
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Listening on proxy (192.168.0.4, 51035) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: (28) Finished request
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Thread 1 waiting to be assigned a request
tester            |[0m (0) -: Expected Access-Accept got Access-Reject
tester            |[0m Sent Access-Request Id 18 from 0.0.0.0:de22 to 192.168.0.4:1812 length 31
tester            |[0m Received Access-Reject Id 18 from 192.168.0.4:714 to 192.168.0.5:56866 length 20
system-under-test |[0m Tue May 28 19:18:27 2024 : Debug: Waking up in 2.5 seconds.
endpoint1         |[0m Tue May 28 19:18:28 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 56965) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (0) (TLS) send TLS 1.2 Alert, fatal decode_error
system-under-test |[0m Tue May 28 19:18:28 2024 : ERROR: (0) (TLS) Alert write:fatal:decode error
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (TLS) Home server has closed the connection
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (TLS) Closing connection
system-under-test |[0m Tue May 28 19:18:28 2024 : Info:  ... shutting down socket proxy (192.168.0.4, 56965) -> home_server (192.168.0.3, 2083) (10 of 128)
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: ... cleaning up socket proxy (192.168.0.4, 56965) -> home_server (192.168.0.3, 2083)
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Closing TLS socket to home server
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Waking up in 2.0 seconds.
endpoint1         |[0m Tue May 28 19:18:28 2024 : Auth: (18) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Proxy received header saying we have a packet of 24 bytes
system-under-test |[0m Tue May 28 19:18:28 2024 : Proxy: No outstanding request was found for Access-Reject packet from host 192.168.0.3 port 2083 - ID 148
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Waking up in 1.8 seconds.
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Waking up in 0.3 seconds.
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Thread 5 got semaphore
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Thread 5 handling request 29, (9 handled so far)
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) Received Access-Request Id 17 from 192.168.0.5:50908 to 192.168.0.4:1812 length 31
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) session-state: No State attribute
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) # Executing section authorize from file /etc/freeradius/sites-enabled/openroaming
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)   authorize {
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)     update control {
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)       No attributes updated for RHS &Calling-Station-Id
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)     update control {
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)       &Proxy-To-Realm := ""
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)     } # update control = noop
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)   } # authorize = noop
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Using home pool auth for realm DEFAULT
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) Starting proxy to home server 192.168.0.3 port 2083
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) server openroaming {
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)   Empty pre-proxy section in virtual server "openroaming".  Using default return values.
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) }
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) proxy: Trying to allocate ID (0/2)
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) proxy: request is now in proxy hash
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) proxy: allocating destination 192.168.0.3 port 2083 - Id 55
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) Proxying request to home server 192.168.0.3 port 2083 (TLS) timeout 7.000000
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29) Sent Access-Request Id 55 from 192.168.0.4:51035 to 192.168.0.3:2083 length 53
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)   User-Name = "test@user"
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)   Message-Authenticator := 0x00
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: (29)   Proxy-State = 0x3137
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Proxy is writing 53 bytes to SSL
system-under-test |[0m Tue May 28 19:18:28 2024 : Debug: Thread 5 waiting to be assigned a request
system-under-test |[0m Tue May 28 19:18:29 2024 : Debug: (29) Expecting proxy response no later than 6.665358 seconds from now
system-under-test |[0m Tue May 28 19:18:29 2024 : Debug: Waking up in 1.5 seconds.
endpoint1         |[0m Tue May 28 19:18:29 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 57735) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Tue May 28 19:18:29 2024 : Debug: Proxy SSL socket has data to read
system-under-test |[0m Tue May 28 19:18:29 2024 : Debug: (0) (TLS) send TLS 1.2 Alert, fatal decode_error
system-under-test |[0m Tue May 28 19:18:29 2024 : ERROR: (0) (TLS) Alert write:fatal:decode error
system-under-test |[0m Tue May 28 19:18:29 2024 : Debug: (TLS) Home server has closed the connection
system-under-test |[0m Tue May 28 19:18:29 2024 : Debug: (TLS) Closing connection
system-under-test |[0m Tue May 28 19:18:29 2024 : Debug: Closing TLS socket to home server
system-under-test |[0m Tue May 28 19:18:29 2024 : Debug: Waking up in 0.1 seconds.
system-under-test |[0m Bad talloc magic value - unknown value
system-under-test |[0m
system-under-test |[0m talloc abort: Bad talloc magic value - unknown value
system-under-test |[0m
endpoint1         |[0m Tue May 28 19:18:29 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 41331) -> (*, 2083, virtual-server=test_server)
system-under-test |[0m Aborted
endpoint1         |[0m Tue May 28 19:18:29 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 52103) -> (*, 2083, virtual-server=test_server)
endpoint1         |[0m Tue May 28 19:18:29 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 53029) -> (*, 2083, virtual-server=test_server)
endpoint1         |[0m Tue May 28 19:18:29 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 51579) -> (*, 2083, virtual-server=test_server)
endpoint1         |[0m Tue May 28 19:18:29 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 40889) -> (*, 2083, virtual-server=test_server)
system-under-test exited with code 134
endpoint1         |[0m Tue May 28 19:18:33 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 57695) -> (*, 2083, virtual-server=test_server)
endpoint1         |[0m Tue May 28 19:18:38 2024 : Auth: (19) Login incorrect (No Auth-Type found: rejecting the user via Post-Auth-Type = Reject): [test@user] (from client anyradsec port 0)
tester            |[0m Sent Access-Request Id 17 from 0.0.0.0:c6dc to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 17 from 0.0.0.0:c6dc to 192.168.0.4:1812 length 31
tester            |[0m Sent Access-Request Id 17 from 0.0.0.0:c6dc to 192.168.0.4:1812 length 31
endpoint1         |[0m Tue May 28 19:18:43 2024 : Info:  ... shutting down socket auth+acct from client (192.168.0.4, 51035) -> (*, 2083, virtual-server=test_server)
```
