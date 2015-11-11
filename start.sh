#!/usr/bin/env bash
if [ ! -f /srv/deluge/config/core.conf ]; then
	#generate the deluge config files

	cheetah fill --oext conf --env /srv/deluge/config/core
	cheetah fill --oext conf --env /srv/deluge/config/label
	cheetah fill --oext conf --env /srv/deluge/config/scheduler
	cheetah fill --oext conf --env /srv/deluge/config/auth && mv /srv/deluge/config/auth.conf /srv/deluge/config/auth

	#do web and autoadd last, they require some extra data which we're going to generate
	python <<-HEREDOC
import hashlib
import pickle

data = ("$DEPOT_PASSWORD_SALT" + "$DEPOT_PASSWORD").encode('ascii')
h = hashlib.new('sha1', data)
password_hash = h.hexdigest()

print "Write data for autoadd plugin and web.conf"
data_file = open('/srv/deluge/config/data.pkl', 'w+')
data = {

	'password_hash': password_hash,
	'folder_structure': {
		'tvshows': {
			'folder_name': "[Tvshows]",
			'label': "tvshows"
		},
		"movies": {
			'folder_name': "[Movies]",
			'label': "movies"
		},
		"music": {
			'folder_name': "[Music]",
			'label': "music"
		}
	}
}
pickle.dump(data, data_file)

HEREDOC
	cheetah fill --oext conf --pickle /srv/deluge/config/data.pkl /srv/deluge/config/autoadd
	cheetah fill --oext conf --env --pickle /srv/deluge/config/data.pkl /srv/deluge/config/web
	chown -R depot:depot /srv/deluge

fi

rm -f /srv/deluge/data/deluged.pid

su -c "deluged -c /srv/deluge/config -L info -l /srv/deluge/data/deluged.log" depot

su -c "deluge-web -c /srv/deluge/config -L info -l /srv/deluge/data/deluge-web.log" depot
