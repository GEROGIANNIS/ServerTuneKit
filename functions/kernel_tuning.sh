#!/bin/bash

tune_kernel() {
    print_yellow "Tuning kernel parameters..."
    cat <<'EOF' >> /etc/sysctl.conf
# Increase file descriptors limit
fs.file-max = 65535
# Increase maximum network connections queue
net.core.somaxconn = 65535
# Increase network buffer sizes
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
# Adjust TCP buffer sizes
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
# Enable TCP optimizations
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fastopen = 3
# Optimize TCP timeouts and connection reuse
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
# Optimize TIME_WAIT backlog and limits
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.ip_local_port_range = 2000 65000
net.ipv4.tcp_max_syn_backlog = 3240000
net.ipv4.tcp_max_orphans = 3240000
net.core.netdev_max_backlog = 3240000
EOF
    sysctl -p
    print_green "Kernel parameters tuned."
}