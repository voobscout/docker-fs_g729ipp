# Jenkins.

FROM debian:jessie-backports
MAINTAINER Voob of Doom <voobofdoom@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV GIT_SSL_NO_VERIFY 1
ENV container docker

RUN apt-get update && apt-get install -y -q curl && \
    curl http://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add - && \
    echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list && \
    apt-get update && \
    apt-get -y -q upgrade && \
    echo "Europe/Berlin" > /etc/timezone && \
    dpkg-reconfigure tzdata && \
    echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections && \
    echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections && \
#    apt-get -y -q --force-yes install less vim zsh screen git-core sudo curl wget locales freeswitch-video-deps-most && \
    apt-get -y -q install curl wget locales freeswitch-all && \
    gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    rm /var/log/apt/* /var/log/alternatives.log /var/log/bootstrap.log /var/log/dpkg.log

RUN rm -rf /usr/lib/freeswitch/mod/mod_g729.so
ADD mod_g729.so /usr/lib/freeswitch/mod/

COPY docker-entrypoint.sh /

# Open the container up to the world.
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 5066/tcp 7443/tcp
EXPOSE 8021/tcp
EXPOSE 64535-65535/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeswitch"]
# COPY skel.tar.gz /root/
# RUN cd /etc; rm -rf ./skel; tar xzf /root/skel.tar.gz
# RUN rm -rf /root/skel.tar.gz

# ADD dockerize-systemd.sh /tmp/
# RUN sh /tmp/dockerize-systemd.sh && rm /tmp/dockerize-systemd.sh

# RUN useradd -m -g users -G sudo -s /bin/zsh app
# #&& usermod -a -G rvm app
# RUN echo -n "app ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/10-admins

# USER app

# ENTRYPOINT ["/bin/systemd"]
# CMD []

# ONBUILD RUN apt-get update

# # Enable the Ubuntu multiverse repository.
# RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/source.list
# RUN echo "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty multiverse">> /etc/apt/source.list
# RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/source.list
# RUN echo "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/source.list

# # Install Dependencies.
# RUN apt-get update && apt-get install -y autoconf automake bison build-essential fail2ban gawk git-core groff groff-base erlang-dev libasound2-dev libavformat-dev libdb-dev libexpat1-dev libcurl4-openssl-dev libgdbm-dev libgnutls-dev libjpeg-dev libmp3lame-dev libncurses5 libncurses5-dev libperl-dev libogg-dev libsnmp-dev libssl-dev libtiff4-dev libtool libvorbis-dev libx11-dev libzrtpcpp-dev make portaudio19-dev python-dev snmp snmpd subversion unixodbc-dev uuid-dev zlib1g-dev libsqlite3-dev libpcre3-dev libspeex-dev libspeexdsp-dev libldns-dev libedit-dev libladspa-ocaml-dev libmemcached-dev libmp4v2-dev libmyodbc libpq-dev libvlc-dev libv8-dev liblua5.2-dev libyaml-dev libpython-dev odbc-postgresql sendmail unixodbc wget yasm

# # Use Gawk.
# RUN update-alternatives --set awk /usr/bin/gawk

# # Install source code dependencies.
# ADD build/install-deps.sh /root/install-deps.sh
# WORKDIR /root
# RUN chmod +x install-deps.sh
# RUN ./install-deps.sh
# RUN rm install-deps.sh

# # Configure Fail2ban
# ADD conf/freeswitch.conf /etc/fail2ban/filter.d/freeswitch.conf
# ADD conf/freeswitch-dos.conf /etc/fail2ban/filter.d/freeswitch-dos.conf
# ADD conf/jail.local /etc/fail2ban/jail.local

# # Download FreeSWITCH.
# WORKDIR /usr/src
# RUN git clone https://freeswitch.org/stash/scm/fs/freeswitch.git -b v1.6.5

# # Bootstrap the build.
# WORKDIR freeswitch
# RUN ./bootstrap.sh

# # Enable the desired modules.
# ADD build/modules.conf /usr/src/freeswitch/modules.conf

# # Build FreeSWITCH.
# RUN ./configure --enable-core-pgsql-support
# RUN make
# RUN make install
# RUN make uhd-sounds-install
# RUN make uhd-moh-install
# RUN make samples

# # Post install configuration.
# ADD sysv/init /etc/init.d/freeswitch
# RUN chmod +x /etc/init.d/freeswitch
# RUN update-rc.d -f freeswitch defaults
# ADD sysv/default /etc/default/freeswitch

# # Add the freeswitch user.
# RUN adduser --gecos "FreeSWITCH Voice Platform" --no-create-home --disabled-login --disabled-password --system --ingroup daemon --home /usr/local/freeswitch freeswitch
# RUN chown -R freeswitch:daemon /usr/local/freeswitch

# # Create the log file.
# RUN touch /usr/local/freeswitch/log/freeswitch.log
# RUN chown freeswitch:daemon /usr/local/freeswitch/log/freeswitch.log


# # Start the container.
# CMD service snmpd start && service freeswitch start && tail -f /usr/local/freeswitch/log/freeswitch.log
