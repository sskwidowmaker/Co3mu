module Co3mu.Client;

import std.socket, Co3mu.Encryption, std.stdio, Co3mu.Core, Co3mu.Character, Co3mu.XML, Co3mu.Helper;
import Co3mu.Packets, Co3mu.Enums;
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
		myChar = XMLOp.loadCharacter(accountName);
	}
	
	public void saveCharacter() {
		XMLOp.saveCharacter(myChar, accountName);
	}
	
	public void setSocket(Socket f) {
		my_sock = f;
	}
	
	public void initAuthEnc() {
		crypto = new AuthEncryption();
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
		this.send((new ChatPacket(0xffffff, ChatType.Service, 0, "SYSTEM", myChar.name, "Welcome to the wonderful world of Co3mu. Have a great time!")).create());

	}
	
	public void beginDHExchange() {
		assert(my_sock.isAlive);
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