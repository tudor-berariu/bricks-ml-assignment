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

make build

PORT_SERVER=
get_free_port PORT_SERVER

eval "./bricks_server --port $PORT_SERVER > log &"
sleep 1
eval "./brickmaker --port $PORT_SERVER &"
sleep 1
eval "./bricklayer.py $PORT_SERVER &"

