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

#ifndef __BRICK_H__
#define __BRICK_H__

#include <vector>
#include <unordered_map>
#include <iostream>

using namespace std;

class Brick {
public:
  Brick(const Brick&);
  Brick(int, int, const vector<vector<bool>>&);
  Brick(int, int, vector<vector<bool>>&&);
  const int height;
  const int width;
  const vector<vector<bool>> cells;

  Brick rotate(int n) const;

  static const Brick& A;
  static const Brick& B;
  static const Brick& C;
  static const Brick& D;
  static const Brick& E;
  static const Brick& F;
  static const Brick& G;

  static const unordered_map<char, const Brick&> knownBricks;
  static const Brick& getBrick(const char c);

  friend ostream& operator<<(ostream& os, const Brick& brick);
};

#endif
