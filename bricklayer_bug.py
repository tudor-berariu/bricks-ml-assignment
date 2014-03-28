#!/usr/bin/python

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


import socket
import random

lengths =\
    {'A':[4,1],'B':[3,2],'C':[3,2],'D':[3, 2],'E':[3,2],'F':[3,2],'G':[2,2]}

DBG_MOVES = [(1, 3), (1, 3), (0, 2), (0, 2)]

class BrickLayer:
    """Demo BrickLayer
    """

    def __init__(self, port=9923):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.connect((socket.gethostname(), port))
        self.mysend("BRICKLAYER\n")
        self.buffer = b''
        firstLine = self.myreceive()
        [self.height, self.length] = map(lambda x: int(x), firstLine.split(','))

    def loop(self):
        DBG_COUNT = 0
        line = self.myreceive();
        while line:
            if "GAME OVER" not in line:
                # rot = random.randint(0, 3)
                # max_offset = self.length - lengths[line[-1]][rot % 2]
                # offset = random.randint(0, max_offset)
                msg = str(DBG_MOVES[DBG_COUNT][0]) + "," +\
                    str(DBG_MOVES[DBG_COUNT][1]) + "\n"
                self.mysend(msg)
                DBG_COUNT = (DBG_COUNT + 1) % len(DBG_MOVES)
            else:
                DBG_COUNT = 0
            line = self.myreceive()

    def mysend(self, msg):
        totalsent = 0
        while totalsent < len(msg):
            sent = self.socket.send(msg[totalsent:])
            if sent == 0:
                raise RuntimeError("S-A BUSIT SOCKETUL")
            totalsent = totalsent + sent

    def myreceive(self):
        while '\n' not in self.buffer:
            chunk = self.socket.recv(1024)
            if chunk == b'':
                return False
            self.buffer = self.buffer + chunk
        line = self.buffer[0:self.buffer.index('\n')]
        self.buffer = self.buffer[self.buffer.index('\n')+1:]
        return line

if __name__ == "__main__":
    import sys
    if len(sys.argv) == 2:
        port = int(sys.argv[1])
    else:
        port = 9923
    bricklayer = BrickLayer(port)
    bricklayer.loop()
