FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      systemd \
      apache2 \
      pacemaker \
      corosync \
      pcs \
      vim \
      curl \
      iproute2 \
      net-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable pcsd user
RUN echo "hacluster:hacluster" | chpasswd

# Apache homepage
RUN echo "Junior DevOps Engineer - Home Task" > /var/www/html/index.html

# Copy configs
COPY apache-vhost.conf /etc/apache2/sites-available/000-default.conf
COPY corosync.conf /etc/corosync/corosync.conf
COPY init-cluster.sh /usr/local/bin/init-cluster.sh

RUN chmod +x /usr/local/bin/init-cluster.sh

EXPOSE 80

CMD ["/usr/local/bin/init-cluster.sh"]
