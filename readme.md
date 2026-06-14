Junior DevOps Engineer – Home Task

Project Overview

This project implements a high‑availability (HA) cluster using Pacemaker and Corosync running on three Ubuntu‑based Docker containers. A Floating IP is managed by the cluster and served by Apache2, which displays a custom homepage.

A fourth container hosts Jenkins, which runs a scheduled job every 5 minutes that:

Sends a cURL request to the Floating IP

Logs the response, timestamp, and container hostname

Exposes the log file externally

This README documents the full setup, configuration, testing, troubleshooting, and improvement recommendations.

Architecture

Components:

webz-001, webz-002, webz-003 – HA cluster nodes (Pacemaker + Corosync + Apache)

webz-004 – Jenkins node

Floating IP: 172.20.0.50

Network: Docker bridge network (172.20.0.0/24)

1. Environment Setup

1.1 Clone the project

git clone <your-repo-url>
cd webz-home-task

1.2 Start all containers

docker-compose up -d --build

This launches:

3 cluster nodes

1 Jenkins node

Shared Docker network

2. Cluster Configuration

All cluster configuration is executed inside webz‑001.

Enter the container:

docker exec -it webz-001 bash

2.1 Authenticate cluster nodes

pcs cluster auth webz-001 webz-002 webz-003 -u hacluster -p hacluster

2.2 Create and start the cluster

pcs cluster setup --name webz_cluster webz-001 webz-002 webz-003
pcs cluster start --all

2.3 Create Floating IP resource

pcs resource create FloatingIP ocf:heartbeat:IPaddr2 ip=172.20.0.50 cidr_netmask=24 op monitor interval=30s

2.4 Create Apache resource

pcs resource create Apache ocf:heartbeat:apache configfile=/etc/apache2/sites-available/000-default.conf op monitor interval=30s

2.5 Set ordering & colocation

pcs constraint colocation add Apache with FloatingIP INFINITY
pcs constraint order FloatingIP then Apache

2.6 Define failover priority

pcs constraint location FloatingIP prefers webz-001=200
pcs constraint location FloatingIP prefers webz-002=100
pcs constraint location FloatingIP prefers webz-003=50

3. Apache Configuration

Apache VirtualHost listens on the Floating IP:

<VirtualHost 172.20.0.50:80>
    DocumentRoot /var/www/html
</VirtualHost>

Homepage content:

Junior DevOps Engineer - Home Task

4. Jenkins Configuration

Jenkins is installed inside webz‑004 and runs automatically.

4.1 Log script

Located at: jenkins-node/curl-logger.sh

It logs:

Timestamp

Hostname

Response from Floating IP

Example log entry:

2026-06-13 17:00:00 | webz-004 | Junior DevOps Engineer - Home Task

4.2 Cron job (every 5 minutes)

*/5 * * * * root /usr/local/bin/curl-logger.sh >> /var/log/curl-logger.cron.log 2>&1

4.3 Log exposure

Logs are accessible externally via:

http://localhost:8000/floating_ip.log

5. Testing

Test 1 — Identify active node & shut it down

Check active node:

pcs status

Shut it down:

docker stop webz-001

Test 2 — Floating IP moves to another machine

Verify:

docker exec -it webz-002 ip a

You should see:

inet 172.20.0.50

Test 3 — Automatic or manual failover

Failover is automatic.

Manual failover (optional):

pcs resource move FloatingIP webz-002

Test 4 — Jenkins job continues to run

Check log:

curl http://localhost:8000/floating_ip.log

Test 5 — Log shows new active machine

Example:

2026-06-13 17:05:00 | webz-004 | Junior DevOps Engineer - Home Task (served by webz-002)

6. Troubleshooting

Cluster not starting

pcs cluster stop --all
pcs cluster start --all

Floating IP not moving

pcs constraint

Apache not responding

service apache2 restart

Jenkins log empty

cat /var/log/curl-logger.cron.log

7. Suggestions for Improvement

Use Terraform + Ansible for full automation

Add Prometheus + Grafana monitoring

Replace Pacemaker with Keepalived for simpler failover

Add CI/CD pipeline in Jenkins

Migrate to Kubernetes for native HA

8. Conclusion

This project demonstrates:

High‑availability cluster design

Pacemaker + Corosync configuration

Floating IP failover

Apache service management

Jenkins automation

Logging and monitoring

Docker‑based infrastructure simulation

It fulfills all requirements of the assignment and provides a clean, reproducible environment.