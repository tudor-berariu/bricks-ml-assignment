#!/bin/bash

# Copyright (C) 2014 Tudor Berariu
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

get_free_port()
{
    Port=35000
    while netstat -atwn | grep "^.*:${Port}.*:\*\s*LISTEN\s*$"
    do
    Port=$(( ${Port} + 1 ))
    done
    eval "$1='${Port}'"
}

launch_round()
{
    eval "./bricks_server --port $1 --height $2 --length $3 --output-file $4 &"
    sleep 1
    eval "./brickmaker --port $1 --in-file $5 &"
    eval "./bricklayer.py $1 &"
}

make build

PORT_SERVER_1=
get_free_port PORT_SERVER_1
launch_round $PORT_SERVER_1 4 4 score1 distributions/dist1

PORT_SERVER_2=
get_free_port PORT_SERVER_2
launch_round $PORT_SERVER_2 8 5 score2 distributions/dist2

PORT_SERVER_3=
get_free_port PORT_SERVER_3
launch_round $PORT_SERVER_3 8 6 score3 distributions/dist3
