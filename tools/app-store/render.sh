#!/bin/zsh
# render.sh: draws the ten Mac App Store frames (2880×1800 PNGs) from frame.html into out/.
#   tools/app-store/render.sh [n...]     (all ten when no numbers are given)
cd "${0:A:h}"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
nums=($@); (( $#nums )) || nums=(1 2 3 4 5 6 7 8 9 10)
for n in $nums; do
  "$chrome" --headless=new --disable-gpu --hide-scrollbars --allow-file-access-from-files \
    --window-size=1440,900 --force-device-scale-factor=2 --virtual-time-budget=4000 \
    --screenshot="$PWD/out/puli-appstore-$n.png" "file://$PWD/frame.html?n=$n" 2>/dev/null
  echo "out/puli-appstore-$n.png $(sips -g pixelWidth -g pixelHeight out/puli-appstore-$n.png | awk '/pixel/ {printf $2 " "}')"
done
