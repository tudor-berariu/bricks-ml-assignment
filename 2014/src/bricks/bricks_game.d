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

import std.conv;
import std.stdio;
import std.array;
import std.algorithm;

class BricksGame {

  private static enum Phase { NextBrick, PlaceBrick, CleanBoard, GameOver };
  private static enum uint[5] scores = [0, 1, 3, 9, 27];

  private static immutable char filled = '#';
  private static immutable char brick = '+';
  private static immutable char empty = 32;

  private const string separatorLine;

  private const uint linesNo;
  private const uint columnsNo;
  private const bool verbose;

  private char[][] board;
  private int[] heights;
  private bool[][] nextBrick;
  private Phase phase;
  private int totalScore;

  // ----------------------------------------------------------------------
  // Constructor

  this(uint linesNo, uint columnsNo, bool verbose) {
    this.linesNo = linesNo;
    this.columnsNo = columnsNo;
    this.verbose = verbose;

    separatorLine = this.makeSeparatorLine();

    this.board = new char[][this.linesNo];
    foreach (ref line; board) {
      line = new char[this.columnsNo];
      foreach (ref cell; line)
        cell = empty;
    }
    this.heights = new int[this.columnsNo];
    foreach (ref colHeight; heights)
      colHeight = this.linesNo - 1;
    phase = Phase.NextBrick;
    totalScore = 0;
  }

  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Properties

  @property public int score() const {
    return totalScore;
  }

  @property public bool isOver() const {
    return phase == Phase.GameOver;
  }

  @property public string strBoard() const {
    string str = "|";
    foreach (line; board) str ~= line ~ "|";
    return str;
  }

  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Operations

  public void setNextBrick(bool[][] nextBrick)
    in {
      assert(phase == Phase.NextBrick);
    }
    out {
      assert(phase == Phase.PlaceBrick);
    }
    body {
      this.nextBrick.clear();
      foreach (line; nextBrick)
        this.nextBrick ~= line.dup;
      phase = Phase.PlaceBrick;
      if (verbose) {
        writeln(this);
      }
    }

  public int placeBrick(uint rot, uint left)
    in {
      assert(rot <= 3);
      assert(left <=
	     columnsNo -(rot%2 == 0) ? nextBrick[0].length : nextBrick.length);
      assert(phase == Phase.PlaceBrick || phase == Phase.GameOver);
    }
    out {
      assert(phase == Phase.NextBrick || phase == Phase.GameOver);
    }
    body {
      bool[][] rotBrick = rotateBrick(rot);
      int freeLine = to!int(board.length) - 1;

      foreach (col; 0 .. rotBrick[0].length) {
        int colHeight = heights[col + left];
        long j = rotBrick.length - 1;
        while(!rotBrick[j--][col])
          colHeight++;
        if (colHeight < freeLine)
          freeLine = colHeight;
      }

      int startLine = freeLine - cast(int)(rotBrick.length) + 1;

      if (verbose) {
	phase = Phase.CleanBoard;
        foreach (int l, line; rotBrick)
	  if (startLine + l < 0)
	    phase = Phase.GameOver;
	  else
	    foreach (c, cell; line)
	      if (cell) board[startLine + l][left + c] = brick;
        writeln(this);
      }

      phase = Phase.NextBrick;
      foreach (int l, line; rotBrick)
	if (startLine + l < 0)
	  phase = Phase.GameOver;
	else
	  foreach (c, cell; line)
	    if (cell) board[startLine + l][left + c] = filled;

      if (phase == Phase.GameOver) {
	totalScore -= 20;
	return -20;
      }

      uint completedLines = 0;

      for (int line = linesNo - 1; line >= 0; line--) {
	if (all!((x) => x == filled)(board[line][])) {
	  completedLines++;
	  for (int copyLine = line; copyLine > 0; copyLine--)
	    board[copyLine] = board[copyLine - 1];
	  board[0] = new char[columnsNo];
	  foreach (ref cell; board[0]) cell = empty;
	  line++;
	}
      }

      totalScore += scores[completedLines];

      foreach (j, ref h; heights) {
	h = -1;
	for(ulong i = 0; i < linesNo && board[i][j] == empty; i++) h++;
      }

      if (verbose) writeln(this);

      return scores[completedLines];
    }

  private bool[][] rotateBrick(uint rotations)
    in {
      assert(rotations <= 3);
    }
    body {
      bool[][] finalBrick;
      immutable bool oddRotations = rotations % 2;
      immutable ulong width = nextBrick[0].length;
      immutable ulong height = nextBrick.length;

      finalBrick = new bool[][rotations % 2 ? width : height];
      foreach (ref row; finalBrick)
	row = new bool[rotations % 2 ? height : width];

      foreach (ulong lf, ref line; finalBrick)
	foreach (ulong cf, ref cell; line) {
	  immutable ulong l = oddRotations ? cf : lf;
	  immutable ulong c = oddRotations ? lf : cf;
	  cell = nextBrick[rotations % 3 ? height - l - 1 : l]
	    [rotations < 2 ? c : width - c - 1];
        }

      return finalBrick;
    }

  // ----------------------------------------------------------------------
  // Output

  final override string toString() const {
    string strBoard = "Score : " ~ to!string(totalScore) ~ "\n";
    foreach (line; board)
      strBoard ~= "|" ~ line ~ "|\n";
    strBoard ~= separatorLine;

    switch (phase){
    case Phase.NextBrick:
      strBoard ~= "Waiting for next brick...\n";
      break;
    case Phase.PlaceBrick:
      strBoard ~= "Next brick:   ";
      foreach (c; nextBrick[0]) strBoard ~= c ? brick : empty;
      foreach (l; 1 .. nextBrick.length) {
        strBoard ~= "\n              ";
        foreach (c; nextBrick[l]) strBoard ~= c ? brick : empty;
      }
      strBoard ~= "\n";
      break;
    case Phase.GameOver:
      strBoard ~= "Game over!\n";
      break;
    default:
      strBoard ~= "\n";
    }
    return strBoard;
  }

  private string makeSeparatorLine() {
    string t = "+";
    foreach (i ; 0 .. columnsNo) t ~= "-";
    t ~= "+\n";
    return t;
  }


}

unittest {
  BricksGame game = new BricksGame(4, 4, false);

  assert(game.strBoard == "|    |    |    |    |");
  assert(game.score == 0);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true, false, false], [true, true, true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(2,1) == 0);
  assert(game.strBoard == "|    |    | ###|   #|");
  assert(game.score == 0);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true, false, false], [true, true, true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(1,0) == 1);
  assert(game.strBoard == "|    |    |##  |#  #|");
  assert(game.score == 1);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true, true], [true, true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(3,0) == 0);
  assert(game.strBoard == "|##  |##  |##  |#  #|");
  assert(game.score == 1);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true, true, true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(1,3) == 0);
  assert(game.strBoard == "|## #|## #|## #|#  #|");
  assert(game.score == 1);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true, true, true, true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(3,2) == 9);
  assert(game.strBoard == "|    |    |    |# ##|");
  assert(game.score == 10);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true], [true], [true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(0,0) == 0);
  assert(game.strBoard == "|#   |#   |#   |# ##|");
  assert(game.score == 10);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true], [true], [true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(2,2) == 0);
  assert(game.strBoard == "|# # |# # |# # |# ##|");
  assert(game.score == 10);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true, true, true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(3,3) == 0);
  assert(game.strBoard == "|# ##|# ##|# ##|# ##|");
  assert(game.score == 10);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true, true, true, true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(3,1) == 27);
  assert(game.strBoard == "|    |    |    |    |");
  assert(game.score == 37);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true, true, true, true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(1,3) == 0);
  assert(game.strBoard == "|   #|   #|   #|   #|");
  assert(game.score == 37);
  assert(game.phase == BricksGame.Phase.NextBrick);

  game.setNextBrick([[true, true], [true, true]]);
  assert(game.phase == BricksGame.Phase.PlaceBrick);
  assert(game.placeBrick(0,2) == -20);
  assert(game.score == 17);
  assert(game.phase == BricksGame.Phase.GameOver);

  BricksGame game2 = new BricksGame(4, 4, false);
  assert(game2.strBoard == "|    |    |    |    |");
  assert(game2.score == 0);
  assert(game2.phase == BricksGame.Phase.NextBrick);

  game2.setNextBrick([[true, false, false], [true, true, true]]);
  assert(game2.phase == BricksGame.Phase.PlaceBrick);
  assert(game2.placeBrick(2,1) == 0);
  assert(game2.strBoard == "|    |    | ###|   #|");
  assert(game2.score == 0);
  assert(game2.phase == BricksGame.Phase.NextBrick);

  game2.setNextBrick([[true, true, true, true]]);
  assert(game2.phase == BricksGame.Phase.PlaceBrick);
  assert(game2.placeBrick(1,3) == -20);
  assert(game2.score == -20);
  assert(game2.phase == BricksGame.Phase.GameOver);
}