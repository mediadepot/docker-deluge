# Requirements


# Environmental
The following environmental variables must be populated, when running container 

- DEPOT_USER,
- DEPOT_PASSWORD
- DEPOT_PASSWORD_SALT
- PUSHOVER_USER_KEY

# Ports
The following ports must be mapped, when running container 

 - 8081 #webui listen 
 - 6881-6891 #daemon listen ports
 
# Volumes
The following volumes must be mapped, when running container 

- /srv/deluge/config
- /srv/deluge/data

- /mnt/blackhole
- /mnt/processing
- /mnt/downloads

The following subfolders should exist in the above mapped volumes:

- /mnt/blackhole/tvshows
- /mnt/blackhole/movies
- /mnt/blackhole/music
- /mnt/downloads/tvshows
- /mnt/downloads/movies
- /mnt/downloads/music

