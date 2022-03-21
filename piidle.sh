#!/bin/sh
RED='\e[1;31m'
YEL='\e[0;33m'
NC='\e[0m'
GREEN='\e[0;32m'
DGRAY='\e[0;30m'
BLUE='\e[1;34m'
IDLE=30
BMIN=15
BMAX=255
triggered=false

usage() {
	printf '\nUse : piidle [option]\n'
	printf '\nHelp: \n'
	printf '\n-i, --idle\t\tIdle Time in seconds. Default value is 30 secods'
	printf '\n-bmin, --brightness-min\tMinimun value of brightness.\n\t\t\tValid value are from 0 to 255'
	printf '\n-bmax, --brightness-max\tMaximun value of brightness.\n\t\t\tValid value are from 0 to 255'
	printf '\n-r, --reset\t\tReset birghtness to 255'
	printf '\n-h, --help\t\tthis help'
	printf '\n\n'
}

reset() {
	printf 'Reset brightness\n'
	eval $(sudo sh -c 'echo 255 > /sys/class/backlight/10-0045/brightness')
}

prerequisite() {
        REQUIRED_PKG="suckless-tools"
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
        echo Checking for $REQUIRED_PKG: $PKG_OK
        if [ "" = "$PKG_OK" ]; then
                echo "No $REQUIRED_PKG. Please install with: 'sudo apt install $REQUIRED_PKG' "
                exit 1
        fi
}

while true; do
  case "$1" in
    -bmin|--brightness-min)
      BMIN="$2"
      shift 2;;
    -bmax|--brightness-max)
      BMAX="$2"
      shift 2;;
    -i|--idle)
      IDLE="$2"
      shift 2;;
    -h|--help)
      usage
      exit 0;;
     -r|--reset)
	reset
	exit 0;;
    --)
      break;;
     *)
      break;;
  esac
done

prerequisite

if ! [ "$IDLE" -eq "$IDLE" ] 2>/dev/null
then
        printf "${RED}ERROR: Invalid value of idle${NC}\n"
        usage
        exit 1
fi

if ! [ "$BMIN" -eq "$BMIN" ] 2>/dev/null
then
	printf "${RED}ERROR: Invalid value of brightness-min${NC}\n"
	usage
	exit 1
fi

if ! [ "$BMAX" -eq "$BMAX" ] 2>/dev/null
then
        printf "${RED}ERROR: Invalid value of brightness-max${NC}\n"
	usage
        exit 1
fi

if [ $BMIN -ge $BMAX ]
then
	printf "${RED}ERROR: brightness-max must be greater than brightness-min${NC}\n"
	usage
	exit 1
fi

if [ $BMIN -gt 255 ] || [ $BMIN -lt 0 ]
then
	printf "${RED}ERROR: brightness-min out of range.\nValid value are from 0 to 255${NC}\n"
	usage
	exit 1
fi

if [ $BMAX -gt 255 ] || [ $BMAX -lt 0 ]
then
	printf "${RED}ERROR: brightness-max out of range.\nValid value are from 0 to 255${NC}\n"
	exit 1
fi

printf "PIIDLE : IDLE: %s - BMIN: %s - BMAX: %s" "$IDLE" "$BMIN" "$BMAX"

timeout=$(($IDLE*1000))

while true
do
    tosleep=$(((timeout - $(xssstate -i)) / 1000))
    brightness=$(cat /sys/class/backlight/10-0045/brightness)
    if [ $tosleep -le 0 ];
    then
        while [ $brightness -ge $BMIN ]; do
           tosleep=$(((timeout - $(xssstate -i)) / 1000))
           if [ $tosleep -gt 0 ]
           then
                break
           fi
           $triggered || eval $(sudo sh -c 'echo '"$brightness"' > /sys/class/backlight/10-0045/brightness')
           brightness=$(($brightness-3))
        done
        tosleep=$(((timeout - $(xssstate -i)) / 1000))
        if [ $tosleep -le 0 ]
        then
                $triggered || eval $(sudo sh -c 'echo '"$BMIN"' > /sys/class/backlight/10-0045/brightness')
        fi
        triggered=true
    else
        triggered=false
        while [ $brightness -le $BMAX ]; do
                $triggered || eval $(sudo sh -c 'echo '"$brightness"' > /sys/class/backlight/10-0045/brightness')
                brightness=$(($brightness+3))
        done
        $triggered || eval $(sudo sh -c 'echo '"$BMAX"' > /sys/class/backlight/10-0045/brightness')
        sleep $tosleep
    fi
done
