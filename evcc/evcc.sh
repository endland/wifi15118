# !/bin/bash

#    Usage: evcc.sh <interface name>

#### generate VSE value from the configuration file ####

VSE=`echo $(bash ../common/vsegen.sh evcc evcc.vse)`

echo ----------------------------------------------
echo VSE=${VSE}
echo ---------------------------------------------

ETT=${VSE:16:2}
echo ETT=${ETT}
echo ---------------------------------------------

#### Remove list ####
wpa_cli -i $1 list_network > list.txt

remove=`echo $(gawk -f removeap.awk list.txt)`

echo ${remove}

i=${remove}

while [ $i -gt -1 ]
do
	wpa_cli -i $1 remove_network ${i}
	i=$((i-1))
		
done

#### Configure VSE ####

wpa_cli -i $1 VENDOR_ELEM_REMOVE 13 ${VSE}

wpa_cli -i $1 VENDOR_ELEM_REMOVE 14 ${VSE}

wpa_cli -i $1 scan

wpa_cli -i $1 VENDOR_ELEM_ADD 13 ${VSE}

wpa_cli -i $1 VENDOR_ELEM_ADD 14 ${VSE}

#### Find best SECC ####

echo ----------------------------------------------
echo Scanning...
echo ---------------------------------------------

iw dev $1 scan dump -u > scan_result.txt

apinfo=`echo $(gawk -v ETT="${ETT}" -f selectap.awk scan_result.txt)`

echo "Returned Value"
echo ${apinfo}

bssidVal="$(cut -d' ' -f1 <<<"$apinfo")"
ssidVal="$(cut -d' ' -f2 <<<"$apinfo")"

echo ${bssidVal}
echo ${ssidVal}

if [ "${bssidVal}" == "NOTFOUND" ]; then
	echo "NOT FOUND.... Exit Process..."
	exit 1;
fi


#### Associate to the best SECC ####

echo ----------------------------------------------
echo Connecting to ${ssidVal} \(${bssidVal}\)
echo ---------------------------------------------

addNetwork=`echo $(wpa_cli -i $1 add_network)`
echo ${addNetwork}

wpa_cli -i $1 set_network ${addNetwork} bssid "${bssidVal}"

wpa_cli -i $1 set_network ${addNetwork} ssid "\"$ssidVal\""

wpa_cli -i $1 set_network ${addNetwork} key_mgmt 'NONE'

wpa_cli -i $1 select_network ${addNetwork}

#### RUN EVCC
echo ----------------------------------------------
echo Running EVCC...
echo ---------------------------------------------

(cd risev2g-evcc && java -jar rise-v2g-evcc-1.1.4-SNAPSHOT.jar)
