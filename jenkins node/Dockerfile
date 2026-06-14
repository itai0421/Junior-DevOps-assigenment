FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      openjdk-11-jre \
      wget \
      gnupg \
      curl \
      cron \
      python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Jenkins
RUN wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add - && \
    echo "deb https://pkg.jenkins.io/debian binary/" > /etc/apt/sources.list.d/jenkins.list && \
    apt-get update && \
    apt-get install -y jenkins && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Log script
COPY curl-logger.sh /usr/local/bin/curl-logger.sh
RUN chmod +x /usr/local/bin/curl-logger.sh

# Cron job every 5 minutes
RUN echo "*/5 * * * * root /usr/local/bin/curl-logger.sh >> /var/log/curl-logger.cron.log 2>&1" > /etc/cron.d/curl-logger && \
    chmod 0644 /etc/cron.d/curl-logger && \
    crontab /etc/cron.d/curl-logger

# Make log accessible (you can mount a volume here if you want)
RUN touch /var/log/floating_ip.log && chmod 666 /var/log/floating_ip.log

EXPOSE 8080 8000

CMD service cron start && service jenkins start && \
    python3 -m http.server 8000 --directory /var/log && \
    tail -f /var/log/jenkins/jenkins.log
