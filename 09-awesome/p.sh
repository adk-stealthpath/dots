#!/bin/bash
echo "=== TLP profile check ==="
sudo tlp-stat -p | grep -E "Mode|policy|boost|profile";
echo "=== Where pcie_aspm comes from ==="
sudo grep -rln pcie_aspm /etc/ /boot/ 2>/dev/null
echo "=== Backlight ==="
for f in /sys/class/backlight/*/brightness; do
    echo "$f: $(cat $f) / $(cat $(dirname $f)/max_brightness)";
done
echo "=== System76 packages ==="
dpkg -l | grep -i system76 || echo "(none)"
echo "=== Per-device power (20s sample) ==="
sudo powertop --time=20 --csv=/tmp/pt.csv >/dev/null 2>&1 && grep -A100 "Top 10 Power Consumers" /tmp/pt.csv | head -40

