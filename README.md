# piidle
Change Brightness of official Rasperry PI LCD 7" if system are in idle after a period of time

<H1>How it work:</H1>
Usde <a href="http://manpages.ubuntu.com/manpages/bionic/man1/xssstate.1.html">xssstate</a> to check if system are in idle (no keyboard or mouse input) and after a predefinited period of time down the brightness of screen to a specific level.
If input key or mouse movement are detectet bring up the brightness to a specific level.

Can be use as system service.

<H1>Usage</H1>

![Help Image](/docs/assets/images/piidle-help.png)


<H1>Install</H1>

<h3>Prerequisite</h3>

<a href="https://suckless.org/">suckless-tools</a> package is needed
You can install it by command:
<code>sudo apt install suckless-tools</code>

<h3>Installation</h3>

copy piidle.sh in /usr/bin/ directory
give execution permission with 

<code>sudo chmod +x /usr/bin/piidle.sh</code>

Next, copy the service file piidle.service the under /lib/systemd/system/ directory to create service file for the systemd on your system.
Let’s reload the systemctl daemon to read new file. You need to reload this deamon each time after making any changes in in .service file.

sudo systemctl daemon-reload

Now enable the service to start on system boot, also start the service using the following commands.

<code>sudo systemctl enable piidle.service</code> 

<code>sudo systemctl start piidle.service</code>

Finally verify the script is up and running as a systemd service.

<code>sudo systemctl status piidle.service</code>
