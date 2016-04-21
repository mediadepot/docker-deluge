FROM mediadepot/base:python
MAINTAINER Jason Kulatunga <jason@thesparktree.com>

ENV DELUGE_VER=1.3-stable

RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
        apk add --update bash python py-setuptools py-six py-mako py-cffi@testing py-chardet \
                xdg-utils py-xdg@testing py-gtk libtorrent-rasterbar@testing py-openssl \
                py-twisted py-cryptography@testing py-enum34 py-pip librsvg git supervisor && \
        pip install service_identity && cd / && git clone -b ${DELUGE_VER} git://deluge-torrent.org/deluge.git && \
        cd /deluge && python setup.py build && python setup.py install && \
        apk del py-pip git && rm -rf /var/cache/apk/* /deluge

EXPOSE 53160
EXPOSE 53160/udp
EXPOSE 8112
EXPOSE 58846

VOLUME ["/data", "/config"]


##Install base applications + deps
#RUN apt-get -q update && \
#    apt-get install -qy --force-yes deluged deluge-webui curl && \
#    apt-get -y autoremove && \
#    apt-get -y clean && \
#    rm -rf /var/lib/apt/lists/* && \
#    rm -rf /tmp/*
#
##Create deluge folder structure & set as volumes
#RUN mkdir -p /srv/deluge/config && \
#	mkdir -p /srv/deluge/data && \
#	mkdir -p /srv/deluge/tmpl && \
#
#	# create deluge storage structure
#    mkdir -p /mnt/blackhole && \
#    mkdir -p /mnt/processing && \
#    mkdir -p /mnt/downloads
#
#
##Copy over start script and docker-gen files
#ADD ./start.sh /srv/start.sh
#RUN chmod u+x  /srv/start.sh
#ADD ./template/auth.tmpl /srv/deluge/tmpl/auth.tmpl
#ADD ./template/autoadd.tmpl /srv/deluge/tmpl/autoadd.tmpl
#ADD ./template/core.tmpl /srv/deluge/tmpl/core.tmpl
#ADD ./template/label.tmpl /srv/deluge/tmpl/label.tmpl
#ADD ./template/scheduler.tmpl /srv/deluge/tmpl/scheduler.tmpl
#ADD ./template/web.tmpl /srv/deluge/tmpl/web.tmpl
#
#VOLUME ["/srv/deluge/config", "/srv/deluge/data"]
#
#EXPOSE 8080
#
#CMD ["/srv/start.sh"]