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

#include <iostream>
#include <fstream>
#include <random>

#include "bricks/brick.h"
#include "utils/arguments.h"

using namespace std;

void getInfo(ifstream& inPipe, long long& gamesNo, int& height, int& width) {
  char info[50];
  inPipe.getline(info, 50);
  char *s = strtok(info, " ,\n");
  read(s, gamesNo);
  s = strtok(NULL, ",\n");
  read(s, height);
  s = strtok(NULL, ",\n");
  read(s, width);
  cout << "Received info : "
       << gamesNo << " games on a " << height << " x " << width << " board."
       << endl;
}

void play(long long gamesNo, int height, int width,
          ifstream& inPipe, ofstream& outPipe) {
  random_device r{ };
  default_random_engine e {r()};
  uniform_int_distribution<int> rot(0,3);
  uniform_int_distribution<int> left(0,width-1);

  char state[1024];

  int maxScore = -20;
  for (long long i = 1; i <= gamesNo; i++) {
    int score = 0;

    do {
      inPipe.getline(state, 1024);
      if (strstr(state, "GAME OVER") != NULL) break;

      char *s = strtok(state, ",\n");
      score += atoi(s);
      s = strtok(NULL, ",\n");
      s = strtok(NULL, ",\n");

      int r, w, l;
      r = rot(e);
      w = (r % 2) ? Brick::getBrick(s[0]).height : Brick::getBrick(s[0]).width;
      do { l = left(e); } while (l > (width - w));

      outPipe << r << "," << l << endl;
      outPipe.flush();
    }
    while (true);

    char *s = strtok(state, ",\n");
    score += atoi(s);

    if (score > maxScore) {
      maxScore = score;
      cout << "New record : " << maxScore << " @ episode " << i << endl;
    }
  }
  cout << "My record: " << maxScore << endl;
  cout << "Done" << endl;
}

int main(int argc, char * argv[])
{
  long long gamesNo;
  int height;
  int width;

  string inFifoName("server_to_player");
  string outFifoName("player_to_server");

  optionalArgument(argc, argv, "--inFIFO", inFifoName);
  optionalArgument(argc, argv, "--outFIFO", outFifoName);

  ofstream outPipe(outFifoName, ifstream::out | ifstream::app);
  ifstream inPipe(inFifoName, ifstream::in);

  outPipe << "MESHTER" << endl;
  outPipe.flush();

  getInfo(inPipe, gamesNo, height, width);

  play(gamesNo, height, width, inPipe, outPipe);

  outPipe.close();
  inPipe.close();
  return 0;
}
