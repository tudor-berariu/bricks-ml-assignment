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

#include "brick_distribution.h"

BrickDistribution::BrickDistribution(const vector<pair<char, float>>& dist)
  : rd{ }, e {rd()} {
  vector<float> probabilities(dist.size());

  auto probIt = probabilities.begin();
  for(auto it = dist.begin(); it != dist.end(); ++it, ++probIt) {
    *probIt = it->second;
    bricks.push_back(make_pair(it->first, Brick::getBrick(it->first)));
  }
  d = discrete_distribution<int>(probabilities.begin(), probabilities.end());
}

pair<char, Brick> BrickDistribution::getNextBrick() {
  return bricks[d(e)];
}
