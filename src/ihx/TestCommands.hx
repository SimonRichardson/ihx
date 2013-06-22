/*
  Copyright (c) 2009-2013, Ian Martins (ianxm@jhu.edu)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/

package ihx;

import ihx.CmdProcessor;

class TestCommands extends haxe.unit.TestCase
{
    public function testDir()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='one'");
        assertEquals("String : one", ret);
        ret = proc.process("var b='two'");
        assertEquals("String : two", ret);
        ret = proc.process("dir");
        assertEquals("vars: a, b", ret);
    }

    public function testHelp()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("help");
        var ans = CmdProcessor.printHelp();
        assertEquals(ans, ret);
    }

    public function testClear()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='one'");
        assertEquals("String : one", ret);
        ret = proc.process("var b='two'");
        assertEquals("String : two", ret);
        ret = proc.process("clear");
        ret = proc.process("dir");
        assertEquals('vars: (none)', ret);
    }

    public function testPrint()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=0");
        var ret = proc.process("print");
        assertEquals("   1: import neko.Lib;", ret.split("\n")[0] );
        assertEquals("   6:         var a;", ret.split("\n")[5] );
        assertEquals("   8:         a = 0;", ret.split("\n")[7] );
    }

    public function testLibs()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("libs");
        assertEquals("libs: (none)", ret);

        ret = proc.process("addlib some-lib-that-does-not-exist");
        ret = proc.process("libs");
        assertEquals("libs: (none)", ret);

        ret = proc.process("addlib ihx");
        ret = proc.process("libs");
        assertEquals("libs: ihx", ret);

        ret = proc.process("rmlib ihx");
        ret = proc.process("libs");
        assertEquals("libs: (none)", ret);
    }

    public function testPaths()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("path");
        assertEquals("path: (empty)", ret);

        ret = proc.process("addpath doesnotexist/");
        ret = proc.process("path");
        assertEquals("path: (empty)", ret);

        ret = proc.process("addpath src/");
        ret = proc.process("addpath bin/");
        ret = proc.process("path");
        var srcFullPath = sys.FileSystem.fullPath("src/");
        var binFullPath = sys.FileSystem.fullPath("bin/");
        assertEquals('path: $srcFullPath, $binFullPath', ret);

        ret = proc.process("rmpath bin/");
        ret = proc.process("path");
        assertEquals('path: $srcFullPath', ret);
    }

    public function testDefines()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("defines");
        assertEquals("defines: (none)", ret);

        ret = proc.process("adddefine ABC");
        ret = proc.process("adddefine DEF");
        ret = proc.process("defines");
        assertEquals('defines: ABC, DEF', ret);

        ret = proc.process("rmdefine ABC");
        ret = proc.process("defines");
        assertEquals('defines: DEF', ret);

        ret = proc.process("var b1 = #if ABC true #else false #end");
        assertEquals('Bool : false', ret);
        ret = proc.process("var b2 = #if DEF true #else false #end");
        assertEquals('Bool : true', ret);
    }

    public function testDebug()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("debug");
        assertEquals("debug mode on", ret);

        ret = proc.process("var b1 = #if debug true #else false #end");
        assertEquals('Bool : true', ret);

        ret = proc.process("debug");
        assertEquals("debug mode off", ret);

        ret = proc.process("var b2 = #if debug true #else false #end");
        assertEquals('Bool : false', ret);
    }

    public function testInitialization()
    {
        var srcFullPath = sys.FileSystem.fullPath("src/");
        var binFullPath = sys.FileSystem.fullPath("bin/");

        var proc = new CmdProcessor( true, ["src/","bin/"], ["ihx"], ["ABC","DEF"] );
        var ret = proc.process("path");
        assertEquals('path: $srcFullPath, $binFullPath', ret);
        ret = proc.process("libs");
        assertEquals("libs: ihx", ret);
        ret = proc.process("defines");
        assertEquals('defines: ABC, DEF', ret);
        ret = proc.process("debug");
        assertEquals("debug mode off", ret);

        var proc = new CmdProcessor();
        var ret = proc.process("path");
        assertEquals('path: (empty)', ret);
        ret = proc.process("libs");
        assertEquals("libs: (none)", ret);
        ret = proc.process("defines");
        assertEquals('defines: (none)', ret);
        ret = proc.process("debug");
        assertEquals("debug mode on", ret);
    }
}
