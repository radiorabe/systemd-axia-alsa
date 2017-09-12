# Systemd service units for the AXIA - ALSA soundcard driver for Livewire
[Paravel Systems](http://www.paravelsystems.com/) offers an AXIA - ALSA
Soundcard Driver for
[Livewire](https://www.telosalliance.com/Axia/Livewire-AoIP-Networking) (also
known as _Axia IP Audio Driver for Linux_) which consists out of a Linux kernel
module (`snd-axia`) and three related daemons (`axialwrd`, `axiaadvd` and
`axiagpr`).

## Motivation
The [`axia-alsa` CentOS
RPM](http://download.paravelsystems.com/CentOS/7com/CentOS/) provides a
SysV-style init script (`axiad`) and an auto-generated systemd service unit
wrapper (`axiad.service`). Apart from being only a wrapper around the
SysV-style init script, everything is bundled into one script (module loading,
device node creation and the start of the three daemons), furthermore
everything will be started with `root` privileges.

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
### Manuall installation
@TODO

### RPM installation
@TODO
