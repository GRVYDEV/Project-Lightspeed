#!/bin/sh

envsubst < /config.json.template > "/usr/share/nginx/html/config.json"
