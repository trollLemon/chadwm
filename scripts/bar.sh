#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/custom

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  printf "^c$c6^ ^b$c3^  "
  printf "^c$c3^ ^b$c6^ $cpu_val"
}

pkg_updates() {
  #updates=$({ timeout 20 doas xbps-install -un 2>/dev/null || true; } | wc -l) # void
  updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l) # arch
  # updates=$({ timeout 20 aptitude search '~U' 2>/dev/null || true; } | wc -l)  # apt (ubuntu, debian etc)

  if [ -z "$updates" ]; then
    printf "  ^c$c1^    Fully Updated"
  else
    printf "  ^c$c2^    $updates"" updates"
  fi
}

battery() {
  get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
  printf "^c$c3^   $get_capacity"
}

brightness() {
  printf "^c$c5^   "
  printf "^c$c5^%.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
  printf "^c$c6^^b$c4^  "
  printf "^c$c4^ ^b$c6^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf "^c$c6^ ^b$c8^ 󰤨  ^d^%s" " ^c$c8^^b$c6^Connected" ;;
	down) printf "^c$c6^ ^b$c8^ 󰤭  ^d^%s" " ^c$c8^^b$c6^Disconnected" ;;
	esac
}

clock() {
	printf "^c$c6^ ^b$c8^ 󱑆 "
	printf "^c$c4^^b$c6^ $(date '+%H:%M')  "
}


hcu () {

  printf "^c$c6^^b$c9^ 󰔵  "
  printf "^c$c9^^b$c6^ $( ps -eo comm --sort=-%cpu | sed -n '2p' )"

}

disk1() {
  printf "^c$c6^^b$c7^   " 
  printf "^c$c7^^b$c6^ / $(df /dev/nvme0n1p1  | awk '/nvme0n1p1/ {print $5}')%"
}

disk2() {
  printf "^c$c6^^b$c2^   " 
  printf "^c$c2^^b$c6^ /home $(df /dev/sda1  | awk '/sda/ {print $5}')%"
}


spacer() {

  printf " "
}

while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$(spacer) $(pkg_updates) $(hcu) $(cpu) $(mem) $(disk1) $(disk2) $(wlan) $(clock)"
done
