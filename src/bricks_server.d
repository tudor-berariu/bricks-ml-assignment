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
import std.getopt;
import bricks.bricks_game_server;

void printHelp(string name) {
  writeln("Usage: ", name, " [options]");
  writeln("--port P        \t",
          "Start server on port P (default is 9923)");
  writeln("--verbose       \t",
          "Writes games states to stdout (default is false)");
  writeln("--help          \t",
          "Displays this message");
  writeln("--height H      \t",
          "Sets the number of lines to H (default is 10)");
  writeln("--length L      \t",
          "Sets the well's length to L (default is 6)");
  writeln("--games-no N    \t",
          "Sets the number of games to N (default is 100)");
  writeln("--output-file F \t",
          "Writes Bricklayer's scores to file F (default is 'scores')");
}

void main(string[] args) {
  bool verbose = false;
  bool help = false;
  uint height = 10;
  uint length = 6;
  uint gamesNo = 200;
  ushort port = 9923;
  string outputFile = "scores";

  getopt(args,
	 "port",        &port,
	 "help",        &help,
	 "verbose",     &verbose,
	 "height",      &height,
	 "length",      &length,
	 "games-no",    &gamesNo,
	 "output-file", &outputFile);

  debug {
    writeln("port=", port);
    writeln("help=",    help);
    writeln("verbose=", verbose);
    writeln("height=", height);
    writeln("length=", length);
    writeln("games-no=", gamesNo);
    writeln("output-file=", outputFile);
  }
  if (help) {
    printHelp(args[0]);
    return;
  }

  BricksGameServer server = new BricksGameServer(port,
						 height,
						 length,
						 gamesNo,
						 verbose,
						 outputFile);
  server.run();
}
