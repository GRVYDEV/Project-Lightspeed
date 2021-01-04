# Requirements
Install docker and docker-compose (https://docs.docker.com/compose/install/) 

# Using the docker containers
Standing at the root folder and run ``docker-compose up`` will start and build the containers. The ingest will give some warnings when run, could probably be suppressed somehow. 

## Development
Use ``docker-compose up --build`` ensures the containers are checked for changes and rebuilt if needed.

## run as daemon/detached
use ``docker-compose up -d`` to start it detached. 

# Configure containers
Containers are currently configured with default steamkey and for localhost. To edit for public ips:

#### webrtc
Open the dockerfile under webrtc and edit the parameter in the ``CMD ["lightspeed-webrtc", "--addr=localhost"]`` command to an ip/hostname, instead of localhost.

#### react
Open the dockerfile under react and edit the ``RUN sed -i "s|stream.gud.software|localhost|g" src/wsUrl.js`` command. The one saying ``localhost`` is what the original string is replace with. So change ``localhost`` to your hostname or ip. Make sure to have no spaces between the ``|`` pipes. 

If you want to configure the port of the wsURL.js too, you can replace that command with ``RUN sed -i "s|stream.gud.software:8080|localhost:8000|g" src/wsUrl.js`` and thus it also replaces the port part of the string with your new ip/port combo. 