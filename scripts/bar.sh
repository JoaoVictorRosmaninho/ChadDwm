#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.src/ChadDwm/scripts/bar_themes/nord

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
  printf "^c$white^CPU "
  printf "^c$red^$cpu_val"
  printf "^c$white^"
}

pkg_updates() {
  updates=$(doas xbps-install -un | wc -l) # void
  # updates=$(checkupdates | wc -l)   # arch , needs pacman contrib
  # updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

  if [ -z "$updates" ]; then
    printf "^c$green^  Fully Updated"
  else
    printf "^c$green^  $updates"" updates"
  fi
}

battery() {
  get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
  printf "^c$blue^   $get_capacity"
}

brightness() {
  printf "^c$red^   "
  printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
  printf "MEM "
  printf "^c$red^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
  printf "^c$white^"
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf " ^c$green^Connected^c$white^" ;;
	down) printf "^c$red^Disconnected^c$white^" ;;
	esac
}

disk() {
    hdd="$(df -h | awk 'NR==4{print $5}')"
    printf "root ^c$red^ $hdd%"
    printf "^c$white^"
}

temp() {
  TEMP="$(sensors|awk 'BEGIN{i=0;t=0;b=0}/id [0-9]/{b=$4};/Core/{++i;t+=$3}END{if(i>0){printf("%0.1f\n",t/i)}else{sub(/[^0-9.]/,"",b);print b}}')"
printf "t° ^c$red^ $TEMP"
  printf "^c$white^"
}

clock() {
        dte="$(date +"%a, %B %d %l:%M%p"| sed 's/  / /g')"
        printf "$dte"
}

while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "[$(cpu)] [$(mem)] [$(temp)] [$(disk)] [$(wlan)] [$(clock)]"
done
