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
device node creation and the start of the three daemons), furthermore
the daemons will all be started with _root_ privileges.

These were the reasons and main motivations for re-creating the service start
up in a more modern and flexible fashion.
             
## Features
* Dedicated systemd services (no SysV wrapper)
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

## Installation
### RPM installation
@TODO

### Manuall installation
Systemd service units:
1. Install the three systemd service units into the `/etc/systemd/system` directory.
  * [`axialwrd.service`](systemd/axialwrd.service) - Axia Livewire Routing
    Daemon
  * [`axiaadvd.service`](systemd/axiaadvd.service) - Axia Advertising Daemon
  * [`axiagpr.service`](systemd/axiagpr.service) - Axia GPIO Bridge for
    Livewire/Control Surface control

udev rule and helper script:
1. Install [`90-snd-axia.rules`](udev/90-snd-axia.rules) into the
   `/etc/udev/rules.d` directory.
2. Install [`snd-axia.sh`](udev/snd-axia.sh) into the `/usr/lib/udev`
   directory.

Kernel module loading:
1. Install [`snd-axia.conf`](modules-load.d/snd-axia.conf) into the
   `/etc/modules-load.d/` directory.
2. Install [`snd-axia.conf`](modprobe.d/snd-axia.conf) into the
   `/etc/modprobe.d` directory.

Reboot or manually load the kernel module (`modprobe snd-axia`)
