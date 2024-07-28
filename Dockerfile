FROM kalilinux/kali-rolling:latest

LABEL org.opencontainers.image.author="benjitrapp.github.io"

ENV DEBIAN_FRONTEND noninteractive
ARG NGROK_TOKEN
ARG PASSWORD=rootuser
ENV GOROOT=/usr/lib/go
ENV GO111MODULE=on
ENV GOPATH=$HOME/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH
ENV AWS_DEFAULT_REGION=eu-central-1


RUN apt-get -y update \
    && apt-get -y dist-upgrade \
    && apt-get clean \
    && apt-get install -y --no-install-recommends software-properties-common curl wget vim nano build-essential autoconf automake libtool 

# https://www.kali.org/tools/kali-meta/#kali-tools-forensics
RUN apt-get install -y --no-install-recommends --allow-unauthenticated kali-linux-${KALI_METAPACKAGE} \
                                                                       kali-desktop-${KALI_DESKTOP} \
                                                                       kali-tools-top10 \
                                                                       kali-tools-forensics \
                                                                       kali-tools-web \
                                                                       kali-tools-windows-resources \
                                                                       binutils \
                                                                       burpsuite \
                                                                       libproxychains4 \
                                                                       proxychains4 \
                                                                       exploitdb \
                                                                       bloodhound \
                                                                       kerberoast \
                                                                       fail2ban \
                                                                       whois \
                                                                       ghidra \
                                                                       sslscan \
                                                                       traceroute \
                                                                       whois \
                                                                       git \
                                                                       jq \
                                                                       gobuster \
                                                                       python3-full \
                                                                       python3-pip \ 
                                                                       python3-dev build-essential \ 
                                                                       golang-go \ 
                                                                       tightvncserver \
                                                                       dbus \
                                                                       dbus-x11 \
                                                                       novnc \
                                                                       net-tools \
                                                                       xfonts-base \
    && cd /usr/local/bin \
    && ln -s /usr/bin/python3 python \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-package --no-cache-dir --upgrade pip && \
    pip3 install --break-system-package --no-cache-dir jupyterlab

COPY containerfiles/entrypoint.sh /entrypoint.sh
COPY containerfiles/bashrc.sh /bashrc.sh
RUN chmod +x /entrypoint.sh

RUN git clone https://github.com/duo-labs/cloudmapper.git /opt/cloudmapper
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y && apt install -y \
    ssh wget unzip vim curl python3
RUN wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O /ngrok-stable-linux-amd64.zip\
    && cd / && unzip ngrok-stable-linux-amd64.zip \
    && chmod +x ngrok
RUN mkdir /run/sshd \
    && echo "/ngrok tcp --authtoken ${NGROK_TOKEN} --region ${REGION} 22 &" >>/openssh.sh \
    && echo "sleep 5" >> /openssh.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(\\\"ssh info:\\\n\\\",\\\"ssh\\\",\\\"root@\\\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '),\\\"\\\nROOT Password:craxid\\\")\" || echo \"\nError：NGROK_TOKEN，Ngrok Token\n\"" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >>/openssh.sh \
    && echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config  \
    && echo root:craxid|chpasswd \
    && chmod 755 /openssh.sh
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000
ENTRYPOINT [ "/entrypoint.sh" ]
