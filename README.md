# Implementing VSE-based Association between EVCC and SECC according to ISO 15118 part 8

## Background
International standard for EV charging, ISO 15118, defines the communication between EV (Electric Vehicle) and EVSE (EV Supply Equipment, aka EV-Charger). The original standard published in 2014 assumes that EV and EVSE communicate by TCP/IP over PLC (Power Line Communication, GreenPHY) using the charging cable. In 2018, ISO also published ISO 15118 part 8, "Physical layer and data link layer requirements for wireless communication", enabling possibilities for EV and EVSE to communicate over wireless medium. IEEE 802.11n (High Throughput WiFi) was chosen for this communication. 

This standard (ISO 15118 part 8) defines requirements for EVCC (EV's communication controller) and SECC (EVSE's communication controller) in order to allow the followings:
- SECC can announce its presence as a ISO15118-compliant SECC and compatible charging services it can provide
- EVCC can discover and associate to a nearby SECC that is compatible to EV user's needs for charging
- EVCC and SECC can maintain reliable communication throughout the charging session

At the heart of EV/EVSE discovery and association is VSE (Vendor-Specific Elements) in the management frames of 802.11: Beacon, Probe Request/Response, Association Request, and Reassociation Request. VSE can deliver service profile (SECC) or charging profile (EVCC) so that EVCC and SECC can selectively associate with each other based on the compatibility of the two. To implement ISO-compliant EVs and EVSEs, one needs to add necessary VSEs in 802.11 management frames and allow EVCC and SECC to make association decisions based on the compatibility with each other.

## Goals
In this project, we aimed to provide a simple and easy software solution for setting up an SECC and EVCC using open source tools. In particular, we achieved the followings:
- Setup an SECC, a ISO-compliant 802.11n AP (Access Point), using HostAP (modified) and unix/linux shell scripts
- Setup an EVCC, a ISO-compliant 802.11n STA (Station), using Atheros drivers and unix/linux shell scripts.

## Features
EVCC and SECC provided in this project can do the followings:

### SECC
- SECC acts as an 802.11n access point (in dual mode, both 2GHz and 5GHz)
- SECC can broadcast beacon messages with VSEs according to ISO 15118-8
- SECC can selectively allow an EVCC to associate based on the compatibility of the EV's VSE with its own

### EVCC
- EVCC acts as an 802.11n station (client, either 2GHz and 5GHz)
- EVCC can perform active scanning (Probe Request) and determine to which AP to associate based on the VSE-compatibility
- EVCC can associate to the SECC with compatible VSEs and the strongest signal strength, if any

## Specifications

This project was tested using the following hardware/software with indicated versions. Other versions may work but not tested.

### SECC
- Operating Systems: 
   - Kali Linux version 2019.2 [Link](http://cdimage.kali.org/kali-2019.2/)
   - Ubuntu 18.04
- Wireless Interface cards 
   - TP-LINK TL-WN722N V1 (atheros AR9271N) for 2.4Ghz
   - iptime A3000UA (rtl8812BU) for 2.4Ghz, 5Ghz
- Software AP:
   - Modified HostAP based on the HostAP ver. 2.8 [Link](https://w1.fi/releases/hostapd-2.8.tar.gz)
   - In this modification, we implemented the association logic based on the VSE compatibility
- Configuration Tools: 
   - iw ver. 5.0.1 
   - wpa_cla ver. 2.8-devel
- Shell script: 
   - Bourn shell

### EVCC
- Operating Systems: 
   - Kali Linux version 2019.2 [Link](http://cdimage.kali.org/kali-2019.2/)
   - Ubuntu 18.04
- Wireless Interface : 
   - TP-LINK TL-WN722N V1 (atheros AR9271N)
- Configuration Tools: 
   - iw ver. 5.0.1
   - wpa_cla ver. 2.8-devel
- Shell script: 
   - Bourn shell

## How to install & run an Access Point and SECC in ubuntu & Kali Linux

**Pre-conditions**
* Install LAN card driver for the wireless interface card of your choice
* Make the system up-to-date

~~~
$ sudo apt-get update && sudo apt-get upgrade (just in case)
~~~

**Install dependencies**
~~~
$ sudo apt-get install net-tools make pkg-config libnl-3-dev libssl-dev libnl-genl-3-dev gawk dnsmasq
~~~

**Install extra tools**
~~~
$ sudo apt-get install git vim (depending on your choice)
~~~


**Download association15118 from github and compile hostapd**
~~~
$ git clone https://github.com/appseclab/wifi15118
~~~
* (case 1) Use the modified version of hostapd v2.8
~~~
$ cd secc/hostapd-2.8-modified/hostapd/

$ cp defconfig ./config

$ sudo make clean

$ sudo make

$ sudo make install
~~~
* (case 2) Patch the hostapd v2.8 source with hostapd.patch file
~~~
$ (download hostapd-2.8, at the parent directory of hostapd-2.8)

$ patch -p0 < hostapd.patch

$ cd hostapd-2.8/hostapd

$ cp defconfig ./config

$ sudo make clean

$ sudo make

$ sudo make install
~~~

**Configure network address of SECC**
~~~
$ vi /etc/network/interfaces ( add the following lines )

	auto <interface name>
	iface <interface name> inet static
	address <IP address>
	netmask <netmask>
	gateway <gateway-address>
	
	( example )
	
	auto wlan1
	iface wlan1 inet static
	address 10.0.0.1
	netmask 255.255.255.0
	
$ sudo service networking restart

$ vi /etc/dnsmasq.conf (add the following lines)

	interface=<interface name>
	dhcp-range=<from ipaddress>,<to ipaddress>,<subnetmask>,12h
	no-hosts
	addn-hosts=/etc/hosts.dnsmasq
	
	( example )
	
	interface=wlan1
	dhcp-range=10.0.0.2,10.0.0.254,255.255.255.0,12h
	no-hosts
	addn-hosts=/etc/hosts.dnsmasq
	
$ sudo systemctl restart dnsmasq
~~~

**Configure HostAP**

~~~
$ cd association15118/SECC/config

$ vi SECCConfig.properties ( modify network interface (line 33) )

	network.interface = <interface name>

$ vi hostapd.conf (line 1, for 5Ghz)

	interface=<interface name>

$ vi hostapd_g.conf (line 1, for 2.4Ghz)

	interface=<interface name>

$ vi secc.sh (line 24, for 5Ghz)

	sudo hostapd hostapd.conf -B

$ vi secc.sh (line 24, for 2.4Ghz)
	
	sudo hostapd hostapd_g.conf -B
	
$ airmon-ng check kill  ### Kali Linux ONLY ###

$ sudo bash secc.sh # Here you may run your SECC software 
~~~

**Configure EVCC**

~~~
$ cd association15118/EVCC

$ vi EVCCConfig.properties ( modify network interface setting (line 33) )

	network.interface = <interface name>

$ sudo bash evcc.sh <interface name>
~~~

## Folder descriptions 

**common/**

	vsegen.sh : generate Vendor Specific Elements indicated by a vse definition file: evcc.vse or secc.vse

	example.vse : Example VSE definition file 

**evcc/**

	evcc.vse : Define VSE for evcc
	
	evcc.sh : Find and associate to an SECC with compatible VSE and run EVCC program (e.g., riseV2G evcc)
	
	removeap.awk : gawk script to remove network list of EVCC
	
	selectap.awk : gawk script to find the best compatible AP (compatible ETT with highest signal)

	risev2g-evcc/ : RiseV2G EVCC implementation

**secc**

	secc.vse : Define VSE for secc
		
	hostapd2.conf : hostapd configuration file for 2.4GHz band
	
	hostapd5.conf : hostapd configuration file for 5GHz band

	secc2.sh : Setup a 15118-compliant 5GHz AP with VSE values in Beacon using hostap, and run SECC (e.g., riseV2G secc)

	secc5.sh : Setup a 15118-compliant 2.4GHz AP with VSE values in Beacon using hostap, and run SECC (e.g., riseV2G secc)

	hostapd.patch : Patch file from hostapd-2.8 to hostapd-2.8-modified.

	hostapd-2.8-modified/: modified version of hostpad that accepts EVCCs only with compatible VSE values
	
	risev2g-secc/ : RiseV2G SECC implementation
