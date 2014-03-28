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
    Port=35013
    while netstat -atwn | grep "^.*:${Port}.*:\*\s*LISTEN\s*$"
    do
    Port=$(( ${Port} + 1 ))
    done
    eval "$1='${Port}'"
}

launch_round()
{
    eval "./bricks_server --port $1 --height $2 --length $3 --output-file $4 --verbose --games-no 2&"
    sleep 1
    eval "./brickmaker_bug --port $1 &"
    eval "./bricklayer_bug.py $1 &"
}

make build

PORT_SERVER_2=
get_free_port PORT_SERVER_2
launch_round $PORT_SERVER_2 8 5 score2
