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

#ifndef __BRICKS_GAME_H__
#define __BRICKS_GAME_H__

#include <utility>
#include <array>
#include <vector>

#include "bricks/brick_distribution.h"

using namespace std;

class BricksGame {
public:
  enum class GamePhase;
  BricksGame(const vector<pair<char,float>>&, int, int);
  void reset();
  char getNextBrick();
  string strBoard() const;
  int placeBrick(int rotation, int left);
  int score() const;
  bool isOver() const;

  friend ostream& operator<<(ostream&, const BricksGame&);

  const int height;
  const int width;

private:
  static const array<int, 5> scores;
  vector<string> board;
  static const char EMPTY;
  static const char BRICK;

  BrickDistribution bd;
  GamePhase phase;
  int totalScore;
  Brick* nextBrick;
  vector<int> heights;
  vector<int> sums;
};

#endif
