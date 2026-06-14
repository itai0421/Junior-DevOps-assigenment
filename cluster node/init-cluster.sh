#!/bin/bash
set -e

# Start required services
service corosync start || true
service pacemaker start || true
service apache2 start || true
service pcsd start || true

# Only print hint on first node
if [ "$(hostname)" = "webz-001" ]; then
  echo "=================================================="
  echo "Inside webz-001, run the following once:"
  echo ""
  echo "pcs cluster auth webz-001 webz-002 webz-003 -u hacluster -p hacluster"
  echo "pcs cluster setup --name webz_cluster webz-001 webz-002 webz-003"
  echo "pcs cluster start --all"
  echo ""
  echo "pcs resource create FloatingIP ocf:heartbeat:IPaddr2 ip=172.20.0.50 cidr_netmask=24 op monitor interval=30s"
  echo "pcs resource create Apache ocf:heartbeat:apache configfile=/etc/apache2/sites-available/000-default.conf op monitor interval=30s"
  echo "pcs constraint colocation add Apache with FloatingIP INFINITY"
  echo "pcs constraint order FloatingIP then Apache"
  echo ""
  echo "Optional: set preferred order:"
  echo "pcs constraint location FloatingIP prefers webz-001=200"
  echo "pcs constraint location FloatingIP prefers webz-002=100"
  echo "pcs constraint location FloatingIP prefers webz-003=50"
  echo "=================================================="
fi

tail -f /var/log/syslog
