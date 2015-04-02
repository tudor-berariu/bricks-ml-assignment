#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <scenario>"
    exit
fi

./delete_pipes.sh
./create_pipes.sh

make

if [ "$1" -eq 1 ]; then
    ./bricks-game-server --gamesNo 1000000 --height 4 --width 4 \
                         --bricks distributions/dist1 \
                         --verbose 0 \
                         /
fi

if [ "$1" -eq 2 ]; then
    ./bricks-game-server --gamesNo 1000000 --height 8 --width 5 \
                         --bricks distributions/dist2 \
                         --verbose 0 \
                         /
fi

if [ "$1" -eq 3 ]; then
    ./bricks-game-server --gamesNo 1000000 --height 8 --width 5 \
                         --bricks distributions/dist3 \
                         --verbose 0 \
                         /
fi

if [ "$1" -eq 4 ]; then
    ./bricks-game-server --gamesNo 1000000 --height 8 --width 6 \
                         --bricks distributions/dist4 \
                         --verbose 0 \
                         /
fi

./delete_pipes.sh
