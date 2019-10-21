# !/bin/bash
#    Usage: vsegen.sh <type> <config file>
#      <type> = evcc | secc
#      If the first and second argument is missing, show error message and usage 

ETT=0
Country=0
OpID=0
CSID=0
ACStr="AC"
DCStr="DC"
WPTStr="WPT"
AIStr=""
Type="$1"
Config="$2"

if [ "${Type}" == "secc" ]; then
	while read LINE
	do
  	case "$LINE" in \#*) continue ;; esac
		case "$LINE" in "") continue ;; esac

	  TEMPS=(`echo $LINE | awk -F= '{print $1" "$2}'`)
	  key=${TEMPS[0]}
	  value=${TEMPS[1]}
	  case "${key}" in
	    ETT_AC)
	      if [ "${value}" == "yes" ]; then
	        ETT=$[ETT+1]
	      fi;;
	    ETT_DC)
	      if [ "${value}" == "yes" ]; then
	        ETT=$[ETT+2]
	      fi;;
	    ETT_WPT)
	      if [ "${value}" == "yes" ]; then
	        ETT=$[ETT+4]
	      fi;;
	    ETT_ACD)
	      if [ "${value}" == "yes" ]; then
	        ETT=$[ETT+8]
	      fi;;
	    Country)
	      Country=`echo ${value} | tr -d '\n' | xxd -p`;;
	    OpID)
	      OpID=`echo ${value} | tr -d '\n' | xxd -p`;;
	    CSID)
	      CSID=`echo ${value} | tr -d '\n' | xxd -p`;;
	    AC:C)
	      ACStr="${ACStr}`echo ${key: -2}=${value//type/}`";; # 모든 'type' 을''로 replacement
	    AC:M)
	      ACStr="${ACStr}`echo ${key: -2}=$(sed -e's/single/1/; s/three/3/' <<< $value)`";;
	    AC:S)
	      ACStr="${ACStr}`echo ${key: -2}=$(sed -e's/charge/C/; s/BPT/B/; s/island/I/' <<< $value)`";;
	    DC:C)
	      DCStr="${DCStr}`echo ${key: -2}=${value//type/}`";;
	    DC:M)
	      DCStr="${DCStr}`echo ${key: -2}=$(sed -e's/core/1/; s/extended/2/; s/combo_core/3/; s/unique/4/' <<< $value)`";;
	    DC:S)
	      DCStr="${DCStr}`echo ${key: -2}=$(sed -e's/charge/C/; s/charge_hp/H/; s/BPT/B/; s/island/I/' <<< $value)`";;
	    WPT:Z)
	      WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/z1/1/; s/z2/2/; s/z3/3/' <<< $value)`";;
	    WPT:P)
	      if [[ $value == *"wpt"* ]]; then
	        WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/wpt1/1/; s/wpt2/2/; s/wpt3/3/; s/wpt4/4/' <<< $value)`"
	      else
	        WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/LPE/E/; s/P2P/P/; s/MV/V/; s/LF/A/' <<< $value)`"
	      fi;;
	    WPT:F)
	      WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/manual/M/; s/LF_ev/A1/; s/LF_se/A2/; s/MV_ev/V1/; s/MV_se/V2/; s/LPE/E/' <<< $value)`";;
	    WPT:A)
	      WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/LPE/E/; s/P2P/P/' <<< $value)`";;
	    WPT:G)
	      WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/circular/C/; s/doubleD/D/; s/polar/P/' <<< $value)`";;
	    ACD:ID);;
	  esac
	done < ${Config}
elif [ "${Type}" == "evcc" ]; then
while read LINE
	do
  	case "$LINE" in \#*) continue ;; esac
		case "$LINE" in "") continue ;; esac

	  TEMPS=(`echo $LINE | awk -F= '{print $1" "$2}'`)
	  key=${TEMPS[0]}
	  value=${TEMPS[1]}
	  case "${key}" in
	    ETT_AC)
	      if [ "${value}" == "yes" ]; then
	        ETT=$[ETT+1]
	      fi;;
	    ETT_DC)
	      if [ "${value}" == "yes" ]; then
	        ETT=$[ETT+2]
	      fi;;
	    ETT_WPT)
	      if [ "${value}" == "yes" ]; then
	        ETT=$[ETT+4]
	      fi;;
	    ETT_ACD)
	      if [ "${value}" == "yes" ]; then
	        ETT=$[ETT+8]
	      fi;;
	    AC:C)
	      ACStr="${ACStr}`echo ${key: -2}=${value//type/}`";; # 모든 'type' 을''로 replacement
	    AC:M)
	      ACStr="${ACStr}`echo ${key: -2}=$(sed -e's/single/1/; s/three/3/' <<< $value)`";;
	    AC:S)
	      ACStr="${ACStr}`echo ${key: -2}=$(sed -e's/charge/C/; s/BPT/B/; s/island/I/' <<< $value)`";;
	    DC:C)
	      DCStr="${DCStr}`echo ${key: -2}=${value//type/}`";;
	    DC:M)
	      DCStr="${DCStr}`echo ${key: -2}=$(sed -e's/core/1/; s/extended/2/; s/combo_core/3/; s/unique/4/' <<< $value)`";;
	    DC:S)
	      DCStr="${DCStr}`echo ${key: -2}=$(sed -e's/charge/C/; s/charge_hp/H/; s/BPT/B/; s/island/I/' <<< $value)`";;
	    WPT:Z)
	      WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/z1/1/; s/z2/2/; s/z3/3/' <<< $value)`";;
	    WPT:P)
	      if [[ $value == *"wpt"* ]]; then
	        WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/wpt1/1/; s/wpt2/2/; s/wpt3/3/; s/wpt4/4/' <<< $value)`"
	      else
	        WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/LPE/E/; s/P2P/P/; s/MV/V/; s/LF/A/' <<< $value)`"
	      fi;;
	    WPT:F)
	      WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/manual/M/; s/LF_ev/A1/; s/LF_se/A2/; s/MV_ev/V1/; s/MV_se/V2/; s/LPE/E/' <<< $value)`";;
	    WPT:A)
	      WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/LPE/E/; s/P2P/P/' <<< $value)`";;
	    WPT:G)
	      WPTStr="${WPTStr}`echo ${key: -2}=$(sed -e's/circular/C/; s/doubleD/D/; s/polar/P/' <<< $value)`";;
	    ACD:ID);;
	  esac
	done < ${Config}
else 
	echo "    Usage: vsegen.sh <type> <config>"
	echo "      <type> = evcc | secc"
	echo "      <config> = VSE definition file path"
	exit
fi

# if ETT is units digit, add '0'
if [ ${#ETT} -eq 1 ]; then ETT="0${ETT}"; fi

# Add generated Additional Information
if [ "${ACStr}" != "AC" ]; then
  AIStr="${AIStr}`echo $ACStr`"
fi
if [ "${DCStr}" != "DC" ]; then
  AIStr=$([ "${AIStr}" == "" ] && echo ${DCStr} || echo "${AIStr}|`echo $DCStr`") # 3항연산자
fi
if [ "${WPTStr}" != "WPT" ]; then
  AIStr=$([ "${AIStr}" == "" ] && echo ${WPTStr} || echo "${AIStr}|`echo $WPTStr`") # 3항연산자
fi

# After generates Additional Information(hex), trimming
AI="`echo ${AIStr} | tr -d '\n' | xxd -p | tr -d '[:space:]'`"

# generate payload
OrganizationID="70b3d53190"
if [ "${Type}" == "secc" ]; then
	elementType="01"
	payload="$OrganizationID$elementType$ETT$Country$OpID$CSID$AI"
elif [ "${Type}" == "evcc" ]; then
	elementType="02"
	payload="$OrganizationID$elementType$ETT$AI"
fi


# get payload length (hex)
length=`printf '%x' $((${#payload} / 2))`
VSE="dd$length$payload"
echo ${VSE}
