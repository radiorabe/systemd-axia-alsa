# Systemd service units for the AXIA - ALSA soundcard driver for Livewire
systemd service units and udev rules for managing the _AXIA - ALSA soundcard driver for Livewire_ services.

## Motivation
[Paravel Systems](http://www.paravelsystems.com/) offers an AXIA - ALSA
Soundcard Driver for
[Livewire](https://www.telosalliance.com/Axia/Livewire-AoIP-Networking) (also
known as _Axia IP Audio Driver for Linux_) which consists out of a Linux kernel
module (`snd-axia`) and three related daemons (`axialwrd`, `axiaadvd` and
`axiagpr`).

The [`axia-alsa` CentOS
RPM](http://download.paravelsystems.com/CentOS/7com/CentOS/) provides a
SysV-style init script (`axiad`) and an auto-generated systemd service unit
wrapper (`axiad.service`). Apart from being only a wrapper around the
SysV-style init script, everything is bundled into one script (module loading,
device node creation and the start of the three daemons). Furthermore
the daemons will all be started with _root_ privileges and the startup options
are hard coded into the init script.

These were the reasons and main motivations for re-creating the start-up of the
services in a more modern and flexible fashion.
             
## Features
* Dedicated systemd services (no SysV wrapper) with configurable startup
  options.
* One systemd service unit per service
  * [`axialwrd.service`](systemd/axialwrd.service) - Axia Livewire Routing
    Daemon
  * [`axiaadvd.service`](systemd/axiaadvd.service) - Axia Advertising Daemon
  * [`axiagpr.service`](systemd/axiagpr.service) - Axia GPIO Bridge for
    Livewire/Control Surface control
* `snd-axia` Kernel module loading via standard systemd
  [modules-load.d](https://www.freedesktop.org/software/systemd/man/modules-load.d.html)
  mechanism.
* Automatic `/dev/axia0` device node creation via
  [udev](https://www.freedesktop.org/software/systemd/man/udev.html) upon
  module loading
* Minimization of `root` privileges
* [firewalld](http://www.firewalld.org) service file (for IGMP and *Livewire
  Routing Protocol*)

## Installation
A valid serial number (license) for the _Axia IP-Audio Driver for Linux_ from
[Paravel Systems](http://www.paravelsystems.com/contact-us/) is required.


### RPM installation on CentOS
The systemd service units and udev rules are packaged for CentOS 7 and are
available on [Radio RaBe's Audio Packages for Enterprise Linux
repository](https://build.opensuse.org/project/show/home:radiorabe:audio). They
can be installed as follows:

```bash
# Install the RaBe APEL repository configuration
curl -o /etc/yum.repos.d/home:radiorabe:audio.repo \
     http://download.opensuse.org/repositories/home:/radiorabe:/audio/CentOS_7/home:radiorabe:audio.repo


# Import the Paravel-Broadcast GPG key
rpm --import \
    http://download.paravelsystems.com/CentOS/7com/RPM-GPG-KEY-Paravel-Broadcast

# Install the Paravel-Commercial repository configuration
curl -o /etc/yum.repos.d/Paravel-Commercial.repo \
    http://download.paravelsystems.com/CentOS/7com/Paravel-Commercial.repo


# Install the required packages (axia-alsa-cli contains the lwlicense command)
yum install systemd-axia-alsa axia-alsa-cli

# Reload the systemd manager configuration
systemctl daemon-reload

# Register your license
lwlicense <SERIAL-NUMBER>
```

Afterwards, reboot your system or manually load the kernel module (`modprobe
snd-axia`), then follow the [Usage](#usage) section.

### Manual installation on CentOS
To install the files manually, use the provided [`Makefile`](Makefile) and set
the prefix to `/` (which will install the files directly into the root of your
system):
```bash
# Install all files
make prefix=/ install

# Create the axia service user and group
userName='axia'

useradd --comment "${userName} system user account" \
        --home-dir /dev/null \
        --no-create-home \
        --system \
        --shell /sbin/nologin \
        --user-group \
        "${userName}"


# Import the Paravel-Broadcast GPG key
rpm --import \
    http://download.paravelsystems.com/CentOS/7com/RPM-GPG-KEY-Paravel-Broadcast

# Install the Paravel-Commercial repository configuration
curl -o /etc/yum.repos.d/Paravel-Commercial.repo \
    http://download.paravelsystems.com/CentOS/7com/Paravel-Commercial.repo

# Install the required axia-alsa packages
yum install axia-alsa axia-alsa-cli

# Reload the systemd manager configuration
systemctl daemon-reload

# Register your license
lwlicense <SERIAL-NUMBER>
```

Afterwards, reboot your system or manually load the kernel module (`modprobe
snd-axia`), then follow the [Usage](#usage) section.

## Usage
### Kernel module and device node
The `axia-alsa` kernel module and its related `/dev/axia0` device node should
be automatically loaded and created upon boot. You can check that with the
following commands.

Check that the module was loaded:
```bash
lsmod | grep snd_axia
```
```
snd_axia               24539  2 
snd_pcm               106416  2 snd_axia
snd                    83432  8 snd_timer,snd_pcm,snd_seq,snd_seq_device,snd_axia
```

Check that the device node was created by udev
```bash
ls -la /dev/axia0
```
```
crw-r--r--. 1 root root 247, 0 Sep 11 22:09 /dev/axia0
```

### Kernel module parameters
The `axia-alsa` kernel module parameters (such as the number of virtual
livewire devices) can be changed within `/etc/modprobe.d/snd-axia.conf`

### Firewall
In case you have a local firewall active, make sure that you allow at least the
[IGMP](https://tools.ietf.org/html/rfc2236) protocol. This is required for IGMP
snooping to work and allows the `axialwrd` daemon to maintain multicast
subscriptions of the audio and sync streams.
For remote control of the audio routes via the *Livewire Routing Protocol*, the
TCP port 93 needs to be allowed as well.

If you use [firewalld](http://www.firewalld.org), the required rules can be
added via the included [firewalld service file](firewalld/services):
```bash
# Replace YOUR-ZONE with your actual zone name or omit --zone= to use the
# default zone
firewall-cmd --permanent --zone=YOUR-ZONE --add-service=axialwrd
firewall-cmd --reload
```

This will add the following iptables/netfiler rules:
```
-A IN_YOUR-ZONE_allow -p tcp -m tcp --dport 93 -m conntrack --ctstate NEW -j ACCEPT
-A IN_YOUR-ZONE_allow -p igmp -m conntrack --ctstate NEW -j ACCEPT
```

Consider restricting access to the *Livewire Routing* port (tcp/93) to a
specific management IP address or range.

### systemd services
The three Axia daemons can be managed with the following commands.

#### Axia Livewire Routing Daemon (`axialwrd`)
```bash
# Start the axialwrd service
systemctl start axialwrd.service

# Stop the axialwrd service
systemctl stop axialwrd.service

# Restart the axialwrd service
systemctl restart axialwrd.service

# Get the status of the axialwrd service
systemctl status axialwrd.service

# Show log messages of the axialwrd service
journalctl -u axialwrd.service

# Tail the log messages of the axialwrd service
journalctl -u axialwrd.service -f
```

#### Axia Advertising Daemon (`axiaadvd`)
```bash
# Start the axiaadvd service
systemctl start axiaadvd.service

# Stop the axiaadvd service
systemctl stop axiaadvd.service

# Restart the axiaadvd service
systemctl restart axiaadvd.service

# Get the status of the axiaadvd service
systemctl status axiaadvd.service

# Show log messages of the axiaadvd service
journalctl -u axiaadvd.service

# Tail the log messages of the axiaadvd service
journalctl -u axiaadvd.service -f
```

#### Axia GPIO Bridge for Livewire/Control Surface control (`axiagpr`)
```bash
# Start the axiagpr service
systemctl start axiagpr.service

# Stop the axiagpr service
systemctl stop axiagpr.service

# Restart the axiagpr service
systemctl restart axiagpr.service

# Get the status of the axiagpr service
systemctl status axiagpr.service

# Show log messages of the axiagpr service
journalctl -u axiagpr.service

# Tail the log messages of the axiagpr service
journalctl -u axiagpr.service -f
```

### Axia daemons startup options
The startup options for all three Axia daemons can be changed within the
[systemd environment
file](https://www.freedesktop.org/software/systemd/man/systemd.exec.html#EnvironmentFile=)
located at `/etc/axia/systemd-env.conf`. Refer to the daemon's respective
`--help` output for a list of supported startup options and remember to restart
the respective system service unit after making a change to this file.

The following example startup configuration, instructs `axialwrd` and `axiaadvd`to use  the `eth1` network interface rather than the default of `eth0`:
```
# Systemd environment file for the Axia services

# Axia Livewire Routing Daemon (axialwrd) startup options, see
# 'axialwrd --help' for supported options.
AXIALWRD_OPTS="-i eth1"

# Axia Advertising Daemon (axiaadvd) startup options, see 'axiaadvd --help' for
# supported options.
AXIAADVD_OPTS="-if eth1"
```

## Monitoring
[Zabbix](https://www.zabbix.com/) users can import the
[_Zabbix Axia ALSA Soundcard Driver for Livewire
monitoring_ templates](https://github.com/radiorabe/rabe-zabbix/tree/master/app/Axia_ALSA_Soundcard_Driver_for_Livewire)
in order to monitor the various components of the _Axia IP Audio
Driver for Linux_.

## Troubleshooting
The following commands might help on debugging.

### Systemd service units status
Systemd service units status:
```bash
systemctl status axialwrd.service
systemctl status axiaadvd.service
systemctl status axiagpr.service
systemctl status sys-module-snd_axia.device
```

### snd_axia kernel module
Check that [the kernel module has been loaded and the device node was
created](#kernel-module-and-device-node).

### udev status
udev sysfs info:
```bash
udevadm info /sys/module/snd_axia
```
```
P: /module/snd_axia
E: DEVNAME=/dev/axia0
E: DEVPATH=/module/snd_axia
E: MAJOR=247
E: MINOR=0
E: NAME=axia0
E: SUBSYSTEM=module
E: TAGS=:systemd:
E: USEC_INITIALIZED=18014
```

udev add event test:
```bash
udevadm test -a add /sys/module/snd_axia
```
```
[...]
Reading rules file: /usr/lib/udev/rules.d/90-snd-axia.rules
[...]
IMPORT 'snd-axia.sh --env' /usr/lib/udev/rules.d/90-snd-axia.rules:11
starting 'snd-axia.sh --env'
'snd-axia.sh --env'(out) 'NAME=axia0'
'snd-axia.sh --env'(out) 'MAJOR=247'
'snd-axia.sh --env'(out) 'MINOR=0'
'snd-axia.sh --env'(out) 'DEVNAME=/dev/axia0'
'snd-axia.sh --env' [2793] exit with return code 0
RUN 'snd-axia.sh --mknod' /usr/lib/udev/rules.d/90-snd-axia.rules:11
created db file '/run/udev/data/+module:snd_axia' for '/module/snd_axia'
ACTION=add
DEVNAME=/dev/axia0
DEVPATH=/module/snd_axia
MAJOR=247
MINOR=0
NAME=axia0
SUBSYSTEM=module
TAGS=:systemd:
USEC_INITIALIZED=18014
run: 'snd-axia.sh --mknod'
Unload module index
Unloaded link configuration context.
```

udev helper script tests:
```bash
# Create udev env vars
/usr/lib/udev/snd-axia.sh --env

# Create the /dev/axia0 device node
/usr/lib/udev/snd-axia.sh --mknod

# Remove the /dev/axia0 device node
/usr/lib/udev/snd-axia.sh --rmnod
```

### Network status
Network status and debugging:
```bash
# List socket binding
ss -apn | grep -i axia

# List socket bindings on legacy systems
netstat -anp | grep axia

# Firewall (if active)
firewall-cmd --zone <ZONE> --list-all
iptables -nvL

# Display multicast group membership information for IPv4
ip -4 maddr

# Display multicast group membership information for IPv4 on legacy systems
netstat -gn4

# Package dump
tcpdump -i <DEVICE> -nn -vvv 'net 239.0.0.0/8'
```

## License
systemd-axia-alsa is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, version 3 of the License.

## Copyright
Copyright (c) 2017 - 2018 [Radio Bern RaBe](http://www.rabe.ch)
