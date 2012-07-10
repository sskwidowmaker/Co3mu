module Co3mu.Game;

import std.stdio, std.socket, std.conv, core.thread, Co3mu.Client, Co3mu.Core, Co3mu.Helper, Co3mu.Packets, Co3mu.XML, Co3mu.Enums;

public class GameServer {
	public static Thread gameThread;
	public static Socket gameSocket;
	public static c3Client[] game_sockets;
	public const uint MAX_CONNECTIONS = 1000;
	public const char[8] BAD_NAMES = [' ', '[', ']', '#', '*', '{', '(', ')'];
	public static shared bool sendResp;
	public static void initGame() {
		sendResp = true;
		gameThread = new Thread(&gamePoll);
		gameThread.start();
	}
	
	public static void processPacket(ubyte[] data, c3Client cli) {
		int Type = c3Helper.readUint16(data, 0); 
		switch(Type) {
			case 1052: {
				AuthMessagePacket pack = AuthMessagePacket(data);
				string account = "ER";
				foreach(key; c3Core.loginAuth.keys.sort) {
					if((c3Core.loginAuth[key]) == pack.LoginToken) {
						account = key; 
						break;
					}
				}
				if(account != "ER") {
					cli.accountName = account;
					if(XMLOp.hasCharacter(account)) { 
						cli.loadCharacter();
						//cli.send((new Unknown2079(0)).create());
						//cli.send((new Unknown2078(0x4e591dba)).create());
						cli.send(( new ChatPacket(0xffffff, ChatType.Entrance, 0, "SYSTEM", "ALLUSERS", "ANSWER_OK")).create());
						cli.send((new HeroInfoPacket(cli.myChar)).create());
						//cli.send((new GeneralPacket(cli.myChar.curLoc.MapID, cli.myChar.curLoc.MapID, cast(ushort)cli.myChar.curLoc.X, cast(ushort)cli.myChar.curLoc.Y, 74)).create());
						cli.send((new DateTimePacket()).create());
					} else { // Tell client they need to create a character
							writefln("New charactar");
						ChatPacket packres = new ChatPacket(0xffffff, ChatType.Entrance, 0, "SYSTEM", "ALLUSERS", "NEW_ROLE");
						cli.send(packres.create());
					}
				} else {
					writefln("Logintoken not found.");
				}
				break;
			}
			case 1001: //Create character
			{
				ubyte subType = data[4];
				if(subType == 0) {
					CreateCharacterPacket chPack = CreateCharacterPacket(data);
					writefln("Create character; Name %s Model %s Job %s", chPack.charName, chPack.charModel, chPack.charClass);
					if(chPack.charClass == 60) //Fucking monks and shit
					{
						cli.send((new ChatPacket(0xffffff, ChatType.Register, 0, "SYSTEM", "ALLUSERS", "Fuck monks.")).create());
						return;
					} else { //check for bad character name
						if(!validName(chPack.charName)) {
							cli.send((new ChatPacket(0xffffff, ChatType.Register, 0, "SYSTEM", "ALLUSERS", "Invalid name!")).create());
							return;
						} else { //check existing names
							if(XMLOp.charExists(chPack.charName)) {
								cli.send((new ChatPacket(0xffffff, ChatType.Register, 0, "SYSTEM", "ALLUSERS", "Name taken.")).create());
								return;
							} else { //Create character
								if(XMLOp.createCharacter(chPack.charName, chPack.charModel, chPack.charClass, cli.accountName)) {
									cli.send((new ChatPacket(0xffffff, ChatType.Register, 0, "SYSTEM", "ALLUSERS", "Create character OK. Login again.")).create());
									return;
								} else {
									cli.send((new ChatPacket(0xffffff, ChatType.Register, 0, "SYSTEM", "ALLUSERS", "Create character failed.")).create());
									return;
								}
							}
						}
					}
				} else {
					//Disconnect, player quit
				}
				break;
			}
			case 10010: //General data 
			{
				int subType = c3Helper.readUint16(data, 18);
				writefln("Data packet subtype: %s", subType);
				switch(subType) 
				{
					case 74://Data.EnterMap
					{
						//Todo: Handle map checking
						cli.send((new GeneralPacket(cli.myChar.curLoc.MapID, cli.myChar.curLoc.MapID, cast(ushort)cli.myChar.curLoc.X, cast(ushort)cli.myChar.curLoc.Y, 74)).create());
						cli.sendWelcome();
						break;
					}
					default:
						break;
				}
				break;
			}
			case 1134: //Quest packet?
			{
				int subType = c3Helper.readUint16(data, 2);
				writefln("Quest packet subtype %s", subType);
				break;
			}
			default: { 
				writefln("Unknown packet type %s", Type);
				break;
			}
		}
	}
	
	public static bool validName(string charName) {
		for(int i = 0; i<BAD_NAMES.length; i++) {
			if(std.string.indexOf(charName, BAD_NAMES[i]) > 0) {
				return false;
			}
		}
		if(std.string.indexOf(charName, "pm") > 0 || std.string.indexOf(charName, "gm") > 0 || charName.length < 3 || charName.length >= 16)
			return false;
		return true;
	}
	
	public static void gamePoll() {
		gameSocket = new TcpSocket;
		assert(gameSocket.isAlive);
		gameSocket.blocking = false;
		gameSocket.bind(new InternetAddress(5816));
		gameSocket.listen(50);
		SocketSet inSockets = new SocketSet(MAX_CONNECTIONS + 1);
		while(c3Core.shouldContinue()) {
			for(;; inSockets.reset()) {
				inSockets.add(gameSocket);
				foreach(c3Client f; game_sockets) {
					if(f.my_sock)
						inSockets.add(f.my_sock);
				}
				try {
					Socket.select(inSockets, null, null); 
				} catch(Exception e) {
					//writefln("Failed to select due to %s", e.toString());
				}
				int i;
				for(i=0;; i++) {
next:
					if( i >= game_sockets.length)
						break;
					if(inSockets.isSet(game_sockets[i].my_sock)) {
						c3Client cli = game_sockets[i];
						if(!cli.keysExchanged) {
							ubyte[1024] buffer;
							auto read = game_sockets[i].my_sock.receive(buffer);
							if(read == 0 || read == Socket.ERROR){ //Socket closed
							writefln("Connection closed from %s", game_sockets[i].my_sock.remoteAddress().toString());
							game_sockets[i].my_sock.close();
							if(i != game_sockets.length -1) //If not the last socket, set this index to the last socket
								game_sockets[i] = game_sockets[game_sockets.length -1];
							game_sockets = game_sockets[0 .. game_sockets.length -1];
							goto next; //index remains the same to skip over the current if needed(see previous comment for logic)
							} else {
								auto data = buffer[0 .. read];
								data = cli.decryptData(data, cast(int)read);
								//Need to get new key info from client...
								int Position = 7;
								uint packetLen = c3Helper.readUint32(data, Position); Position += 4;
								uint junk_len = c3Helper.readUint32(data,Position); Position += 4; Position += junk_len;
								uint keyLen = c3Helper.readUint32(data,Position); Position += 4;
								string key = c3Helper.readString(data, Position, keyLen);
								cli.finishExchange(key);
							}
						} else {
							ubyte[2] buffer;
							auto read = game_sockets[i].my_sock.receive(buffer);
							if(read == 0 || read == Socket.ERROR){ //Socket closed
								writefln("Connection closed from %s", game_sockets[i].my_sock.remoteAddress().toString());
								game_sockets[i].my_sock.close();
								if(i != game_sockets.length -1) //If not the last socket, set this index to the last socket
									game_sockets[i] = game_sockets[game_sockets.length -1];
								game_sockets = game_sockets[0 .. game_sockets.length -1];
								goto next; //index remains the same to skip over the current if needed(see previous comment for logic)
							} else {
								buffer = cli.decryptData(buffer, cast(int)read);
								int Size = (c3Helper.readUint16(buffer, 0) + 6);
								auto data = new ubyte[Size];
								read = cli.my_sock.receive(data);
								if(read != Size)
									writefln("Danger will robinson %s %s", read, Size);
								writefln("Size %s", Size);
								data = cli.decryptData(data, cast(int)read);
								processPacket(data, cli);
							}
						}
					}
				}
				if(inSockets.isSet(gameSocket)) //New connection
				{
					Socket incoming;
					c3Client cli;
					try {
						if(game_sockets.length < MAX_CONNECTIONS) {
							incoming = gameSocket.accept();
							writefln("Connection estd from %s", incoming.remoteAddress().toString());
							assert(incoming.isAlive);
							assert(gameSocket.isAlive);
							cli = new c3Client; 
							cli.setSocket(incoming);
							cli.beginDHExchange();
							game_sockets ~= cli;
						} else {
							incoming = gameSocket.accept();
							writefln("Connection rejected from %s ; maximum number of connections achieved.", incoming.remoteAddress().toString());
							assert(incoming.isAlive);
							incoming.close();
							assert(!incoming.isAlive);
							assert(gameSocket.isAlive);
						}
					}
					catch(Exception e) {
						//c3Logger.outMsg("ERROR", e.toString());
						if(incoming)
							incoming.close();
					}
				}
			}
			Thread.sleep(25);
		}
	}
}