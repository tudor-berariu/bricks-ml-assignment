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

#include "named_pipes_bricks_player.h"

#include <cassert>
#include <cstring>

NamedPipesBricksPlayer::NamedPipesBricksPlayer(const string inName,
                                               const string outName) {
  inPipe.open(inName, ifstream::in);
  outPipe.open(outName, ofstream::out | ofstream::app);
  assert(inPipe.is_open());
  assert(outPipe.is_open());
}

void NamedPipesBricksPlayer::stop() {
  inPipe.close();
  outPipe.close();
}

void NamedPipesBricksPlayer::start(const long long gamesNo,
                                   const int height, const int width) {
  char id[10];
  inPipe.getline(id, 10);
  assert(strcmp(id, "MESHTER") == 0);
  outPipe << gamesNo << "," << height << "," << width << endl;
  outPipe.flush();
}

void NamedPipesBricksPlayer::getMove(const int lastScore, const string board,
                                     char nextBrick, int& rotation, int& left) {
  outPipe << lastScore << "," << board << "," << nextBrick << endl;
  outPipe.flush();
  char move[1024];
  inPipe.getline(move,20);
  char *p = strtok(move, ",\n");
  rotation = atoi(p);
  p = strtok(NULL, ",\n");
  left = atoi(p);
}

void NamedPipesBricksPlayer::endGame(const int lastScore) {
  outPipe << lastScore << ",GAME OVER" << endl;
}
