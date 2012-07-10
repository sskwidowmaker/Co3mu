module Co3mu.Logger;
import std.stdio, std.string;

public class c3Logger {
	public static void outMsg(string prefix, string txt) {
		writefln("[%s] %s", prefix, txt);
	}
}