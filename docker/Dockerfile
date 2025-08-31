FROM ubuntu:jammy

RUN apt-get update && apt-get install -y strongswan iproute2 inetutils-ping curl traceroute mtr iperf3

COPY conf/ipsec.conf /etc/ipsec.conf
COPY conf/ipsec.secrets /etc/ipsec.secrets

CMD ["ipsec", "start", "--nofork"]
