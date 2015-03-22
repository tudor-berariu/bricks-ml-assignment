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

module continuous_line_splitter;

import std.algorithm;
import std.string;
import std.array;
import std.conv;

class ContinuousLineSplitter(T) {
  private string buffer;

  public this() {
    buffer = "";
  }

  public void addText(T newChars) {
    buffer ~= to!(string)(newChars);
  }

  public string getLine() {
    string line;
    auto idx = buffer.indexOf('\n');
    line = buffer[0 .. idx];
    buffer = buffer[(idx+1) .. $];
    return line;
  }

  public string[] getLines() {
    string[] lines = buffer.splitLines!(string)(KeepTerminator.yes);
    if (lines[$ - 1][$ - 1] == '\n') {
      buffer = "";
      return array(lines.map!((string s) => s.chomp())());
    } else {
      buffer = lines[$ - 1];
      return array(map!((s) => chomp(s))(lines[0 .. $-1]));
    }
  }

  public @property bool hasLine() const {
    return buffer.indexOf('\n') > -1;
  }

  public @property string rest() const {
    return buffer;
  }
}

unittest{
  alias CLSChar = ContinuousLineSplitter!(char[]);

  string[] lines;
  string line;

  CLSChar cls = new CLSChar();
  assert(cls.buffer == "");

  cls.addText(to!(char[])("line1\nline2\nli"));
  assert(cls.hasLine);
  lines = cls.getLines();
  assert(lines == ["line1", "line2"]);
  assert(cls.rest == "li");

  cls.addText(to!(char[])("ne"));
  assert(!cls.hasLine);
  cls.addText(to!(char[])("3\nlin"));
  assert(cls.hasLine);
  line = cls.getLine();
  assert(line == "line3");
  assert(cls.rest == "lin");
  assert(!cls.hasLine);

  cls.addText(['e', '4']);
  assert(!cls.hasLine);
  assert(cls.getLines() == []);
  assert(cls.rest == "line4");

  cls.addText(['\n']);
  assert(cls.hasLine);
  lines = cls.getLines();
  assert(lines == ["line4"]);
  assert(cls.rest == "");
}