#!/bin/sh

if [ $# -lt 1 ];
then
    printf "usage: %s time\n" "$(basename $0)" 2>&1
    exit 1
fi

idletime=$(echo $1 | grep -o -E '[0-9]+')
idleunit=$(echo $1 | grep -o -E '[a-zA-Z]+')
scale=1
case $idleunit in
     s)
      timeout=$(($idletime*1000))
      ;;

     m)
      timeout=$(($idletime*60*1000))
      ;;

     h)
      scale=$(($idletime*3600*1000))
      ;;

     *)
      printf "ERROR: time unit '%s' not valid\n\tValid values are 's' (seconds), 'm' (minutes) or 'h' (hours)\n" $idleunit
      return 100
      ;;
esac
shift
triggered=false

while true
do
    tosleep=$(((timeout - $(xssstate -i)) / 1000))
    brightness=$(cat /sys/class/backlight/10-0045/brightness)
    if [ $tosleep -le 0 ];
    then
	while [ $brightness -ge 20 ]; do
           $triggered || eval $(sudo sh -c 'echo '"$brightness"' > /sys/class/backlight/10-0045/brightness')
           brightness=$(($brightness-2))
	done
        triggered=true
    else
        triggered=false
        while [ $brightness -le 255 ]; do
	   $triggered || eval $(sudo sh -c 'echo '"$brightness"' > /sys/class/backlight/10-0045/brightness')
	   brightness=$(($brightness+2))
	done
	$triggered || eval $(sudo sh -c 'echo 255 > /sys/class/backlight/10-0045/brightness')
        sleep $tosleep
    fi
done
