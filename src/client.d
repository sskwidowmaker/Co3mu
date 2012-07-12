module Co3mu.Client;

import std.socket, Co3mu.Encryption, std.stdio, Co3mu.Core, Co3mu.Character, Co3mu.Database;
import Co3mu.Packets, Co3mu.Defines, Co3mu.GameServer;
public class c3Client {
	private BaseEncryption crypto;
	public Socket my_sock;
	public bool keysExchanged;
	public string accountName;
	public c3Char myChar;
	public this() { //Ctor
		
	}
	
	public ubyte[] decryptData(ubyte[] data, int len) {
		return crypto.doDecrypt(data, len); 
	}
	
	public ubyte[] encryptData(ubyte[] data, int len) {
		return crypto.doEncrypt(data, len);
	}
	
	public void loadCharacter() {
		myChar = Data.loadCharacter(accountName);
	}
	
	public void saveCharacter() {
		Data.saveCharacter(myChar, accountName);
	}
	
	public void setSocket(Socket f) {
		my_sock = f;
	}
	
	public void initAuthEnc() {
		crypto = new AuthEncryption();
	}
	
	public void disconnect() {
		my_sock.close();
		if(myChar)
			saveCharacter();
	}
	
	public void send(ubyte[] data) {
		assert(my_sock.isAlive);
		ubyte[] toSend = new ubyte[data.length+8];
		toSend[0 .. data.length] = data[0 .. data.length];
		for(int i=0; i<8; i++) {
			toSend[i+data.length] = c3Core.TQs[i];
		}
		my_sock.send(this.encryptData(toSend, cast(int)toSend.length));
	}
	
	public void sendWelcome() {
		systemMsg("Welcome to beautiful, scenic, exciting Co3mu! Enjoy!(/help for more)");
	}
	
	public void systemMsg(string message) {
		this.send((new ChatPacket(0xffffff, ChatType.Service, 0, "SYSTEM", myChar.name, message)).create());
	}
	
	public void spawnToScreen() {
		SpawnPacket spawn = new SpawnPacket(this.myChar);
		foreach(c3Client cli; GameServer.game_sockets) {
			if(cli.myChar) {
				if(cli.myChar.UID != this.myChar.UID) {
					if(c3Core.canSee(cli.myChar.curLoc, this.myChar.curLoc)) {
							if(!c3Core.canSee(cli.myChar.curLoc, this.myChar.prevLoc)) {
								cli.send(spawn.create());
								SpawnPacket me = new SpawnPacket(cli.myChar);
								this.send(me.create());
							}
					}
				}
			}
		}
	}
	
	public void spawnScreenTo() {
	}
	
	public void topMsg(string message) {
		this.send((new ChatPacket(0xffffff, ChatType.TopLeft, 0, "SYSTEM", myChar.name, message)).create());
	}
	
	public void doTeleport(int mapID, int x, int y) {
		this.send((new GeneralPacket(myChar.UID, mapID, cast(ushort)x, cast(ushort)y, 86)).create());
		this.send((new GeneralPacket(myChar.UID, mapID, cast(ushort)x, cast(ushort)y, 85)).create());
		myChar.curLoc.MapID = mapID;
		myChar.curLoc.X = x;
		myChar.curLoc.Y = y;
	}
	
	public void beginDHExchange() {
		assert(my_sock.isAlive);
		writefln("chere");
		keysExchanged = false;
		crypto = new GameEncryption();
		ubyte[] toSend = (cast(GameEncryption)(crypto)).generateServerPack();
		toSend = this.encryptData(toSend, cast(int)toSend.length);
		my_sock.send(toSend);
	}
	
	public void finishExchange(string key) {
		keysExchanged = true;
		(cast(GameEncryption)(crypto)).completeDH(key);
	}
}