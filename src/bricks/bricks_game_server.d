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

import std.socket;
import std.stdio;
import std.conv;
import std.file;

import bricks.bricks_game;
import bricks.brick_types;

import utils.continuous_line_splitter;

class BricksGameServer {

  alias CLS = ContinuousLineSplitter!(char[]);

  private const uint linesNo;
  private const uint columnsNo;
  private const uint gamesNo;
  private const bool verbose;
  private const string outputFile;

  private Socket server, bricklayer, brickmaker;

  public this(ushort port,
              uint height, uint length, uint gamesNo,
              bool verbose, string outputFile) {
    this.linesNo = height;
    this.columnsNo = length;
    this.gamesNo = gamesNo;
    this.verbose = verbose;
    this.outputFile = outputFile;

    server = new TcpSocket();
    server.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, 1);
    server.bind(new InternetAddress(Socket.hostName, port));
    server.listen(2);

    assert(server.isAlive);

    writeln("Server is up!");
  }

  public void run() {
    Socket client1, client2;
    char[1024] buf;
    bool role1, role2;
    string msg1, msg2;
    long l;

    client1 = server.accept();
    CLS cls1 = new CLS();
    l = client1.receive(buf);
    cls1.addText(buf[0 .. l]);
    while(!cls1.hasLine) {
      l = client1.receive(buf);
      cls1.addText(buf[0 .. l]);
    }
    msg1 = cls1.getLine();

    assert(msg1 == "BRICKMAKER" || msg1 == "BRICKLAYER");
    role1 = (msg1 == "BRICKMAKER");
    writeln(role1 ? "brickmaker" : "bricklayer", " connected!");

    client2 = server.accept();
    CLS cls2 = new CLS();
    l = client2.receive(buf);
    cls2.addText(buf[0 .. l]);
    while(!cls2.hasLine) {
      l = client2.receive(buf);
      cls2.addText(buf[0 .. l]);
    }
    msg2 = cls2.getLine();

    assert(msg2 == "BRICKLAYER" || msg2 == "BRICKMAKER");
    role2 = (msg2 == "BRICKLAYER");
    writeln(role2 ? "bricklayer" : "brickmaker", " connected!");

    assert(role2 == role1);

    bricklayer = role1 ? client2 : client1;
    brickmaker = role1 ? client1 : client2;

    File f = File(outputFile, "w");
    f.write("");
    f.close();

    play();

    stop();
  }

  private void play() {
    sendInfo();
    foreach (uint gameNo; 0 .. gamesNo) {
      BricksGame game = new BricksGame(linesNo, columnsNo, verbose);

      int lastScore = 0;
      uint bricksNo = 0;
      char nextBrick;

      ulong l;
      char buf[1024];
      char[] msg1, msg2;

      while (!game.isOver && bricksNo < 18) {
        // send message to brickmaker
        msg1 = to!(char[])(-lastScore) ~ "," ~
          to!(char[])(game.strBoard()) ~ "\n";
        brickmaker.send(msg1);

        // receive message from brickmaker
        CLS clsMaker = new CLS();
        l = brickmaker.receive(buf);
        clsMaker.addText(buf[0 .. l]);
        while(!clsMaker.hasLine) {
          l = brickmaker.receive(buf);
          clsMaker.addText(buf[0 .. l]);
        }
        nextBrick = clsMaker.getLine()[0];
        assert(nextBrick >= 'A' && nextBrick <= 'G');
        game.setNextBrick(brickTypes[nextBrick]);

        // send message to bricklayer
        msg2 = to!(char[])(lastScore) ~ "," ~
          to!(char[])(game.strBoard()) ~ "," ~ nextBrick ~ "\n";
        bricklayer.send(msg2);

        // receive message from bricklayer
        CLS clsLayer = new CLS();
        l = bricklayer.receive(buf);
        clsLayer.addText(buf[0 .. l]);
        while(!clsLayer.hasLine) {
          l = bricklayer.receive(buf);
          clsLayer.addText(buf[0 .. l]);
        }

        int[] args = to!(int[])("[" ~ clsLayer.getLine() ~ "]");
        assert(args.length == 2);
        lastScore = game.placeBrick(args[0], args[1]);
        bricksNo++;
      }
      msg1 = to!(char[])(-lastScore) ~ ",GAME OVER\n";
      msg2 = to!(char[])(lastScore) ~ ",GAME OVER\n";
      brickmaker.send(msg1);
      bricklayer.send(msg2);
      std.file.append(outputFile, to!(char[])(game.score) ~ "\n");
    }
  }

  private void sendInfo() {
    char[] info = to!(char[])(to!string(linesNo) ~ "," ~
                              to!string(columnsNo) ~ "\n");
    bricklayer.send(info);
    brickmaker.send(info);
  }

  private void stop() {
    bricklayer.shutdown(SocketShutdown.BOTH);
    brickmaker.shutdown(SocketShutdown.BOTH);
    bricklayer.close();
    brickmaker.close();
    server.shutdown(SocketShutdown.BOTH);
    server.close();
    writeln("Bye!");
  }
}
