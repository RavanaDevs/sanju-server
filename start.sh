#!/bin/sh

# Replace the placeholder {{NAME}} in the index.html file with the NAME from the environment variable
sed -i "s/{{NAME}}/${NAME}/g" /usr/share/nginx/html/index.html
