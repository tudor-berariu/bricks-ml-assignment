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

#ifndef __NAMED_PIPES_BRICKS_PLAYER_H__
#define __NAMED_PIPES_BRICKS_PLAYER_H__

#include <fstream>

#include "bricks/bricks_player.h"

using namespace std;

class NamedPipesBricksPlayer : public BricksPlayer {
 public:
  NamedPipesBricksPlayer(const string inName, const string outName);
  void start(const long long gamesNo, const int height, const int width);
  void getMove(const int lastScore, const string board,
               const char nextBrick, int& left, int& rotation);
  void endGame(const int lastScore);
  void stop();

 private:
  ifstream inPipe;
  ofstream outPipe;
};

#endif
