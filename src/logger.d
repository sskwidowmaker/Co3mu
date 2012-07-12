module Co3mu.Logger;
import std.stdio, std.datetime;
public class c3Logger {
	public static shared uint DEBUG_LEVEL;
	/*
	 * Method: outMsg(string src, string msg, uint lvl)
	 * Output: void
	 * Expl: Writes a message to stdout formed as: [src) msg
	*/
	public static void outMsg(string src, string msg, uint lvl) {
		if(lvl >= DEBUG_LEVEL) {
			writefln("[%s] %s", src, msg);
		}
	}
}