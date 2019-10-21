# !/bin/bash

## This script runs an SECC in 2.4GHz band

# kill background process
kill -9 `ps -ef | grep 'hostapd' | awk '{print $2}'`
sleep 3

# read VSE from VSE generator file(vsegen.sh) using the configuration file(secc.vse)
# Note that VSE generator file must be in Shared folder and the configuration file must be in current folder 
VSE=`echo $(bash ../common/vsegen.sh secc secc.vse)`
echo ${VSE}

# write VSE in hostapd configuration file(hostapd.conf)
sed -i -e "s/vendor_elements.*/vendor_elements=${VSE}/" hostapd2.conf
sed -i -e "s/assocresp_elements.*/assocresp_elements=${VSE}/" hostapd2.conf

# run hostapd using configuration file
sudo hostapd hostapd2.conf -B

echo Setting...
sleep 3

# run SECC
# for example, run RISE-V2G-SECC
(cd risev2g-secc && java -jar rise-v2g-secc-1.1.4-SNAPSHOT.jar)
