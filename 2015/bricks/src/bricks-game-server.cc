// Copyright (C) 2015 Tudor Berariu

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the “Software”), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include <cstring>
#include <cassert>

#include <string>
#include <fstream>
#include <utility>
#include <vector>
#include <sstream>

#include "bricks/bricks_game_controller.h"
#include "bricks/named_pipes_bricks_player.h"
#include "utils/arguments.h"

vector<pair<char, float>> readDistribution(string fileName) {
  vector<pair<char, float>> d;
  ifstream f(fileName, ifstream::in);
  assert(f.is_open());
  while(!f.eof()) {
    char c;
    float p;
    f >> c >> p;
    assert( 'A' <= c && c <= 'G');
    assert( 0.0 <= p && p <= 1.0);
    d.push_back(make_pair(c, p));
  }
  f.close();
  return d;
}

void printInfo(char * name) {
  cout << "Usage: " << name << " [opts]" << endl
       << "Options:" << endl
       << "\t--height <height>" << endl
       << "\t--width <width>" << endl
       << "\t--gamesNo <number of games>" <<endl
       << "\t--bricks <file with brick distribution>" <<endl
       << "\t--inFIFO <in fifo> # the named pipe the player writes to" << endl
       << "\t--outFIFO <out fifo> # the named pipe the server writes to" << endl
       << "\t--verbose <verbose> # 0 or 1" << endl
       << "\t--log <log file> # STDOUT to output to standard output" << endl;
}

int main(int argc, char * argv[])
{
  for (int i = 1; i < argc; i++) {
    if (!strcmp(argv[i], "--help")) {
      printInfo(argv[0]);
      return 0;
    }
  }

  int height = 8;
  int width = 6;
  long long gamesNo = 100000;
  bool verbose = false;
  string logFile("STDOUT");
  string distFile("distributions/dist1");
  string inFifoName("player_to_server");
  string outFifoName("server_to_player");

  optionalArgument(argc, argv, "--height", height);
  optionalArgument(argc, argv, "--width", width);
  optionalArgument(argc, argv, "--gamesNo", gamesNo);
  optionalArgument(argc, argv, "--verbose", verbose);
  optionalArgument(argc, argv, "--log", logFile);
  optionalArgument(argc, argv, "--bricks", distFile);
  optionalArgument(argc, argv, "--inFIFO", inFifoName);
  optionalArgument(argc, argv, "--outFIFO", outFifoName);

  ostream* log;
  if (logFile.compare("STDOUT") !=0) {
    log = new ofstream(logFile, ofstream::out);
  } else {
    log =&cout;
  }

  NamedPipesBricksPlayer npbp(inFifoName, outFifoName);
  BricksGameController bgc(gamesNo, height, width, readDistribution(distFile),
                           verbose, *log, npbp);
  bgc.run();
  log->flush();
  if (logFile.compare("STDOUT") !=0) {
    dynamic_cast<ofstream*>(log)->close();
  }
  return 0;
}
