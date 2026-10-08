#!/bin/sh
# r12: Matikan IPv6 total + perbaikan sisa dari analisa log ssh4

# === 1. MATIKAN IPv6 TOTAL ===
# Nonaktifkan IPv6 di kernel
cat >> /etc/sysctl.d/10-noipv6.conf <<'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

# Hapus ip6assign dari interface lan (jangan assign IPv6)
uci -q delete network.lan.ip6assign
uci -q delete network.globals.ula_prefix
uci commit network

# Matikan odhcp6c (DHCPv6 client) & dhcpv6
/etc/init.d/odhcp6c disable 2>/dev/null
/etc/init.d/odhcp6c stop 2>/dev/null

# Set AGH: matikan juga DNS-over-IPv6 listener (biar bersih)
# (AGH bind_hosts 0.0.0.0 sudah IPv4 saja)

# === 2. FIX SISA (dari analisa log ssh4) ===
# Hapus netdata + luci-app-netmonitor (sumber error plugin + makan RAM)
opkg remove --force-depends netdata luci-app-netmonitor 2>/dev/null
/etc/init.d/netdata stop 2>/dev/null
/etc/init.d/netdata disable 2>/dev/null

# Disable fixcpufreq.pl (error compile perl)
chmod -x /usr/sbin/fixcpufreq.pl 2>/dev/null

# Samba: bind ke br-lan saja (hilangkan error IPv6 "Address not available")
uci -q set samba4.@samba[0].interface='br-lan'
uci commit samba4

exit 0
