#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.src/chadwm/scripts/bar_themes/onedark

cpu() {
	cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

	printf "CPU"
	printf "^c$white^ ^b$grey^ $cpu_val"
}

pkg_updates() {
	#updates=$(doas xbps-install -un | wc -l) # void
	 updates=$(checkupdates | wc -l)   # arch , needs pacman contrib
	# updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

	if [ -z "$updates" ]; then
		printf "^c$green^  Fully Updated"
	else
		printf "^c$green^  $updates"" updates"
	fi
}

#battery() {
#	get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
#	printf "^c$blue^   $get_capacity"
#}

#brightness() {
#	printf "^c$red^   "
#	printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
#}

temp() {
    TEMP="$(
        sensors|awk 'BEGIN{i=0;t=0;b=0}/id [0-9]/{b=$4};/Core/{++i;t+=$3}END{if(i>0){printf("%0.1f\n",t/i)}else{sub(/[^0-9.]/,"",b);print b}}'
        )"
    printf " :  " 
    printf "$TEMP"
}

disk() {
  total = $(df -h / | awk '{ if ($6 == \"/\") print $4, $5 }')
  printf "  root: " 
  printf $total 
}

mem() {
	printf "^c$blue^^b$black^  "
	printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf "^c$black^  ^b$blue^  ^d^%s" " ^c$blue^Connected" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
	esac
}

clock() {
	#printf "^c$black^ ^b$darkblue^ 󱑆 "
	printf "$(date '+%I:%M %p') "
}

while true; do

	[ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
	interval=$((interval + 1))

        sleep 1 && xsetroot -name "$updates  [$(cpu) $(temp)] [$(mem)] [$(wlan)] [$(clock)]"
        #sleep 1 && xsetroot -name " [$(cpu) $(temp)] [$(mem)] [$(wlan)] [$(clock)]"
done
