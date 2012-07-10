module Co3mu.PacketBuilding;

import std.stdio;

public class PacketBuilder {
	private int Position;
	private ubyte[] buffer;
	this(int Size, int Type) {
		Position = 0;
		buffer = new ubyte[2048];
		putShort(Size);
		putShort(Type);
	}
	this() {
		Position = 0;
		buffer = new ubyte[2048];
	}
	
	public void putShort(uint value) {
		buffer[Position] = (cast(ubyte)(value & 0xff));
		Position++;
		buffer[Position] = (cast(ubyte)((value >> 8) & 0xff));
		Position++;
	}
	public void putInt(uint value) {
		buffer[Position] = (cast(ubyte)(value & 0xff));
		Position++;
       	buffer[Position] = (cast(ubyte)(value >> 8 & 0xff));
       	Position++;
        buffer[Position] = cast(ubyte)(value >> 16 & 0xff);
        Position++;
        buffer[Position] = (cast(ubyte)(value >> 24 & 0xff));
        Position++;
	}
	public void putULong(ulong value)
	{
		buffer[Position] = cast(ubyte)((cast(ulong)value & 0xff00000000000000L) >> 56);
		Position++;
        buffer[Position] = cast(ubyte)((value & 0xff000000000000) >> 48);
        Position++;
        buffer[Position] = cast(ubyte)((value & 0xff0000000000) >> 40);
        Position++;
        buffer[Position] = cast(ubyte)((value & 0xff00000000) >> 32);
        Position++;
        buffer[Position] = cast(ubyte)((value & 0xff000000) >> 24);
        Position++;
        buffer[Position] = cast(ubyte)((value & 0xff0000) >> 16);
        Position++;
        buffer[Position] = cast(ubyte)((value & 0xff00) >> 8);
        Position++;
        buffer[Position] = cast(ubyte)(value & 0xff);
        Position++;
	}
	public void putString(string val) {
		for(int i=0; i<val.length; i++) {
			buffer[Position] = cast(ubyte)val[i];
			Position++;
		}
	}
	public void putByte(ubyte val) {
		buffer[Position] = cast(ubyte)val;
		Position++;
	}
	public ubyte[] sealTQ() {
		putString("TQServer");
		return seal();
	}
	public ubyte[] seal() {
		return buffer[0 .. Position];
	}
}