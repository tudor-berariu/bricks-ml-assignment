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

#include "brick.h"

Brick::Brick(int height, int width, vector<vector<bool>>&& cells)
  : height {height}, width {width}, cells {cells} { }

Brick::Brick(const Brick& other)
  : height {other.height}, width {other.width}, cells {other.cells} { }

Brick Brick::rotate(int n) const {
  n = n & 3;

  const int newHeight = ((n % 2) == 0) ? height : width;
  const int newWidth = ((n % 2) == 0) ? width : height;
  vector<vector<bool> > rotatedCells(newHeight, vector<bool>(newWidth, false));

  const auto f = [](bool left, int i, int len){
    return (left ? i : (len - i - 1));
  };

  for (int row = 0; row < height; row++) {
    for (int col = 0; col < width; col++) {
      int newRow = f(n < 2, (n & 1) == 0 ? row : col, newHeight);
      int newCol = f((n % 2) == (n / 2), (n % 2) == 0 ? col : row, newWidth);
      rotatedCells[newRow][newCol] = cells[row][col];
    }
  }
  return {newHeight, newWidth, std::move(rotatedCells)};
}

const Brick& Brick::A = {1, 4, {{1, 1, 1, 1}}};
const Brick& Brick::B = {2, 3, {{1, 0, 0}, {1, 1, 1}}};
const Brick& Brick::C = {2, 3, {{0, 0, 1}, {1, 1, 1}}};
const Brick& Brick::D = {2, 3, {{0, 1, 0}, {1, 1, 1}}};
const Brick& Brick::E = {2, 3, {{0, 1, 1}, {1, 1, 0}}};
const Brick& Brick::F = {2, 3, {{1, 1, 0}, {0, 1, 1}}};
const Brick& Brick::G = {2, 2, {{1, 1}, {1, 1}}};

const unordered_map<char, const Brick&> Brick::knownBricks =
  {{'A', Brick::A}, {'B', Brick::B}, {'C', Brick::C}, {'D', Brick::D},
   {'E', Brick::E}, {'F', Brick::F}, {'G', Brick::G}};

const Brick& Brick::getBrick(const char c) {
  return knownBricks.at(c);
}

ostream& operator<<(ostream& os, const Brick& brick) {
  for (int row = 0; row < brick.height; row++) {
    for (int col = 0; col < brick.width; col++) {
      os << (brick.cells[row][col] ? "X" : " ");
    }
    os << endl;
  }
  return os;
}
