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

#include "bricks_game.h"

#include <cassert>
#include <sstream>

const char BricksGame::EMPTY = ' ';
const char BricksGame::BRICK = '#';


// Phases of the game : NextBrick <-> PlaceBrick -> GameOver
enum class BricksGame::GamePhase {NextBrick, PlaceBrick, GameOver};

// Scores for 0, 1, 2, 3 and 4 lines
const array<int, 5> BricksGame::scores = {0, 1, 3, 9, 27};

BricksGame::BricksGame(const vector<pair<char,float>>& dist,
                       int height, int width)
  : height {height}, width {width}, bd {dist}  {
  reset();
}

void BricksGame::reset() {
  board = vector<string>(height, string(width, EMPTY));
  heights = vector<int>(width, height-1);
  sums = vector<int>(height, 0);
  phase = GamePhase::NextBrick;
  totalScore = 0;
}

int BricksGame::score() const {
  return totalScore;
}

bool BricksGame::isOver() const {
  return phase == GamePhase::GameOver;
}

char BricksGame::getNextBrick() {
  assert(phase == GamePhase::NextBrick);
  pair<char, Brick> next = bd.getNextBrick();
  nextBrick = new Brick(next.second);
  phase = GamePhase::PlaceBrick;
  return next.first;
}

int BricksGame::placeBrick(int rotation, int left) {
  assert(phase == GamePhase::PlaceBrick);
  // rotate brick
  Brick brick(nextBrick->rotate(rotation));
  assert(brick.width + left <= width);
  // find the line to place the brick
  int freeLine = height - 1;
  for (auto col = 0; col < brick.width; col++) {
    int colHeight = heights[col + left];
    int line  = brick.height - 1;
    while(!brick.cells[line][col]) {
      line--;
      colHeight++;
    }
    if (colHeight < freeLine) {
      freeLine = colHeight;
    }
  }
  int startLine = freeLine - brick.height + 1;
  if (startLine < 0) {
    phase = GamePhase::GameOver;
    totalScore -= 20;
    return -20;
  }
  phase = GamePhase::NextBrick;
  for (int ln = startLine, bln = 0; bln < brick.height; ++ln, ++bln) {
    for (int col = left, bcol = 0; bcol < brick.width; ++col, ++bcol) {
      if (brick.cells[bln][bcol]) {
        board[ln][col] = BRICK;
        sums[ln]++;
        if ((ln-1) < heights[col]) {
          heights[col] = ln-1;
        }
      }
    }
  }

  int completedLines = 0;
  for (int ln = startLine + brick.height - 1; ln >= startLine; --ln) {
    if (sums[ln] == width) {
      completedLines++;
      for (int ln2 = ln; ln2 > 0; --ln2) {
        board[ln2] = board[ln2-1];
        sums[ln2] = sums[ln2-1];
      }
      board[0] = string(width, EMPTY);
      sums[0] = 0;
      ln++;
    }
  }

  for (int col = 0; col < width; ++col) {
    int h = -1;
    while (h < (height-1) && board[h+1][col] == EMPTY) h++;
    heights[col] = h;
  }

  return scores[completedLines];
}

string BricksGame::strBoard() const {
  stringstream ss;
  ss << "|";
  for (auto line : board) {
    ss << line << "|";
  }
  return ss.str();
}


ostream& operator<<(ostream& os, const BricksGame& game) {
  os << "Score : " << game.totalScore << endl;
  for(auto line : game.board) {
    os << "|" << line << "|" << endl;
  }
  os << "+" << string(game.width, '-') << "+" << endl;

  switch (game.phase) {
  case BricksGame::GamePhase::NextBrick:
    os << "Waiting for next brick..." << endl;
    break;
  case BricksGame::GamePhase::PlaceBrick:
    os << "Next brick:" << endl << *(game.nextBrick) << endl;
    break;
  case BricksGame::GamePhase::GameOver:
    os << "Game over!" << endl;
    break;
  default:
    os << endl;
  }
  return os;
}
