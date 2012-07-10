module Co3mu.Helper;

import std.stdio, std.conv;

public class c3Helper {
	public static int readUint16(ubyte[] data, int start) {
		assert(data.length > start);
		return ((data[start+1] << 8) + data[start]);
	}
	public static string readString(ubyte[] data, int start, int len) {
		assert(data.length >= start+len);
		return cast(string)data[start .. start+len];
	}
	public static int readUint32(ubyte[] Data, int StartLocation)
	{
		if(Data.length < StartLocation)
			return 0;
		return ((Data[StartLocation + 3] << 24) + (Data[StartLocation + 2] << 16) + (Data[StartLocation + 1] << 8) + (Data[StartLocation]));
	}
}