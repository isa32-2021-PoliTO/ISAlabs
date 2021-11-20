#!/bin/bash

echo "Creating backup of ${PWD##*/} in ${PWD##*/}.B"
rsync -av --delete ./ ../BACKUPs/${PWD##*/}.B/
