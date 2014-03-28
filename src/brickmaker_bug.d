// Copyright (C) 2014 Tudor Berariu
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import std.stdio;
import std.string;
import std.getopt;
import std.conv;
import std.random;
import std.socket;
import utils.continuous_line_splitter;

Random gen;

static immutable char[4] DBG_BRICKS = ['C', 'B', 'B', 'B'];
static int DBG_COUNT = 0;

char getNextBrick() {
  return DBG_BRICKS[DBG_COUNT++];
}

void main(string[] args) {
  alias CLS = ContinuousLineSplitter!(char[]);

  ushort port = 9923;
  getopt(args, "port", &port);

  Socket socket = new TcpSocket();
  socket.connect(new InternetAddress(to!(char[])(Socket.hostName), port));
  socket.send("BRICKMAKER\n");

  CLS cls = new CLS();
  char[1024] buf;

  auto l = socket.receive(buf);
  cls.addText(buf[0 .. l]);
  while (!cls.hasLine()) {
    l = socket.receive(buf);
    cls.addText(buf[0 .. l]);
  }
  string firstLine = cls.getLine();

  if (cls.hasLine) {
    cls.getLine();
    char[] msg = to!(char[])([]) ~ getNextBrick() ~ "\n";
    socket.send(msg);
  }

  l = socket.receive(buf);
  while (l > 0) {
    cls.addText(buf[0 .. l]);
    if (cls.hasLine()) {
      string line = cls.getLine();
      if (line.indexOf("GAME OVER") == -1) {
        char[] msg = to!(char[])([]) ~ getNextBrick() ~ "\n";
        socket.send(msg);
      } else {
	DBG_COUNT = 0;
      }
    }
    l = socket.receive(buf);
  }

  return;
}
