# Automatic updater for Play2 projects

> For basic Play2 apps builded on **Jenkins** and managed by **svc**. <br />
> In other world, it will only works for **Zenexity** projects! <br />
> **USE WITH CAUTION!**

## Prerequisites
* Must be Play 2.x project
* Managed by svc
* Works only for simple app (automatic db update, no manual operation...)
* Builded on Jenkin with this configuration

        /home/builder/play/2.1.0/play clean dist;
        cd dist; mv *.zip myapp-release.zip;

## Installation

**This script must be installed on an already working project!**

    cd /home/sites/myapp
    mkdir delivery
    git clone https://github.com/studiodev/play2-svc-deployment.git
    mv play2-svc-deployment scripts
    cd scripts
    chmod +x update.sh
    mv config.properties.sample config.properties
    vim config.properties # and edit the file with good configuration. Double check the settings!

## Usage

Build your project on jenkins (I'll try to automate that in the next version), and run:

    /home/sites/myapp/scripts/update.sh

<center><img src="http://img15.hostingpics.net/pics/115803Capturedcran20130514225815.png" /></center>

## Why this tool ?

Because I'm a real slacker!

And yes I know, I'm a terrible shell coder...

## License

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
Version 2, December 2004
 
Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
 
Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.
 
DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 
0. You just DO WHAT THE FUCK YOU WANT TO.
