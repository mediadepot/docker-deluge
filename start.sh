#!/usr/bin/env bash

if [ ! -f /srv/deluge/config/core.conf ]; then
	#generate the deluge config files

	cheetah fill --oext conf --env /srv/deluge/tmpl/core
	cheetah fill --oext conf --env /srv/deluge/tmpl/label
	cheetah fill --oext conf --env /srv/deluge/tmpl/scheduler
	cheetah fill --oext conf --env /srv/deluge/tmpl/auth

	mv /srv/deluge/tmpl/auth.conf /srv/deluge/config/auth
	mv /srv/deluge/tmpl/core.conf /srv/deluge/config/core.conf
	mv /srv/deluge/tmpl/label.conf /srv/deluge/config/label.conf
	mv /srv/deluge/tmpl/scheduler.conf /srv/deluge/config/scheduler.conf

	#do web and autoadd last, they require some extra data which we're going to generate
	python <<-HEREDOC
import hashlib
import pickle
import os

data = ("$DELUGE_PASSWORD_SALT" + "$DEPOT_PASSWORD").encode('ascii')
h = hashlib.new('sha1', data)
password_hash = h.hexdigest()

# find all common directories in the downloads folder and the blackhole folder
download_subfolders = [os.path.basename(x[0]) for x in os.walk('/mnt/downloads')]
blackhole_subfolders = [os.path.basename(x[0]) for x in os.walk('/mnt/blackhole')]

print "Write data for autoadd plugin and web.conf"
data_file = open('/srv/deluge/tmpl/data.pkl', 'w+')
data = {

	'password_hash': password_hash,
	'mapped_folders': list(set(download_subfolders).intersection(blackhole_subfolders))
}
pickle.dump(data, data_file)

HEREDOC
	cheetah fill --oext conf --env --pickle /srv/deluge/tmpl/data.pkl /srv/deluge/tmpl/web
	mv /srv/deluge/tmpl/web.conf /srv/deluge/config/web.conf
fi


rm -f "/srv/deluge/config/autoadd.conf"
rm -f "/srv/deluge/config/autoadd.conf~"

cheetah fill --oext conf --pickle /srv/deluge/tmpl/data.pkl /srv/deluge/tmpl/autoadd
mv /srv/deluge/tmpl/autoadd.conf /srv/deluge/config/autoadd.conf
chown -R depot:depot /srv/deluge


rm -f /srv/deluge/data/deluged.pid

su -c "deluged -c /srv/deluge/config -L info -l /srv/deluge/data/deluged.log" depot

su -c "deluge-web -c /srv/deluge/config -L info -l /srv/deluge/data/deluge-web.log" depot
