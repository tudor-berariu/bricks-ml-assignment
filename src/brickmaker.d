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

float[char] readProbabilities(string inFileName) {
  float[char] d;
  float sum = 0.0f;
  string line;
  File inFile = File(inFileName, "r");
  while ((line = inFile.readln()) !is null) {
    line = line.chomp();
    string[] parts = line.split();
    assert(parts.length == 2);
    immutable float value = to!float(parts[1]);
    d[to!(char)(parts[0][0])] = value;
    sum += value;
  }
  inFile.close();
  assert(sum > 0.999);
  return d;
}

char getNextBrick(float[char] d) {
  float a = uniform(0.0f, 1.0f, gen);
  float s = 0;
  foreach (c, v; d) {
    s += v;
    if (s >= a) {
      return c;
    }
  }
  return d.keys()[d.length-1];
}

void printHelp(string name) {
  writeln("Usage: ", name, " [options]");
  writeln("--port P     \t",
          "Connect to game server on port P (default is 9923)");
  writeln("--help       \t",
          "Displays this message");
  writeln("--in-file F  \t",
          "Read probabilities from file F (default is 'distributions/dist1'");
}

void main(string[] args) {
  alias CLS = ContinuousLineSplitter!(char[]);

  ushort port = 9923;
  string inFile = "distributions/dist1";
  bool help = false;
  getopt(args, "port", &port, "in-file", &inFile);

  debug {
    writeln("port=", port);
    writeln("in-file=", inFile);
    writeln("help=", help);
  }

  if (help) {
    printHelp(args[0]);
    return;
  }

  gen.seed(unpredictableSeed);

  float[char] dist = readProbabilities(inFile);

  Socket socket = new TcpSocket();
  socket.connect(new InternetAddress(to!(char[])(Socket.hostName), port));
  socket.send("BRICKMAKER\n");

  CLS cls = new CLS();
  long l;
  char[1024] buf;

  l = socket.receive(buf);
  cls.addText(buf[0 .. l]);
  while (!cls.hasLine()) {
    l = socket.receive(buf);
    cls.addText(buf[0 .. l]);
  }
  string firstLine = cls.getLine();

  if (cls.hasLine) {
    cls.getLine();
    char[] msg = to!(char[])([]) ~ getNextBrick(dist) ~ "\n";
    socket.send(msg);
  }

  l = socket.receive(buf);
  while (l > 0) {
    cls.addText(buf[0 .. l]);
    if (cls.hasLine()) {
      string line = cls.getLine();
      if (line.indexOf("GAME OVER") == -1) {
        char[] msg = to!(char[])([]) ~ getNextBrick(dist) ~ "\n";
        socket.send(msg);
      }
    }
    l = socket.receive(buf);
  }

  return;
}
