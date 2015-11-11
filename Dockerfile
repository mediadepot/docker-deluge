FROM debian:jessie
MAINTAINER jason@thesparktree.com

#Create internal depot user (which will be mapped to external DEPOT_USER, with the uid and gid values)
RUN groupadd -g 15000 -r depot && useradd --uid 15000 -r -g depot depot

#Install base applications + deps
RUN apt-get -q update && \
    apt-get install -qy --force-yes python-cheetah deluged deluge-webui curl && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

#Create deluge folder structure & set as volumes
RUN mkdir -p /srv/deluge/config && \
	mkdir -p /srv/deluge/data && \

	# create deluge storage structure
    mkdir -p /mnt/blackhole/[Tvshows] && \
    mkdir -p /mnt/blackhole/[Movies] && \
    mkdir -p /mnt/blackhole/[Music] && \
    mkdir -p /mnt/processing && \
    mkdir -p /mnt/downloads/[Tvshows] && \
    mkdir -p /mnt/downloads/[Movies] && \
    mkdir -p /mnt/downloads/[Music]


#Copy over start script and docker-gen files
ADD ./start.sh /srv/start.sh
RUN chmod u+x  /srv/start.sh
ADD ./template/auth.tmpl /srv/deluge/config/auth.tmpl
ADD ./template/autoadd.tmpl /srv/deluge/config/autoadd.tmpl
ADD ./template/core.tmpl /srv/deluge/config/core.tmpl
ADD ./template/label.tmpl /srv/deluge/config/label.tmpl
ADD ./template/scheduler.tmpl /srv/deluge/config/scheduler.tmpl
ADD ./template/web.tmpl /srv/deluge/config/web.tmpl

VOLUME ["/srv/deluge/config", "/srv/deluge/data"]

EXPOSE 8081

CMD ["/srv/start.sh"]