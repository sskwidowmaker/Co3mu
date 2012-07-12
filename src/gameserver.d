module Co3mu.GameServer;

import std.stdio, core.thread, std.socket, Co3mu.Client, Co3mu.Core, Co3mu.Packets, Co3mu.Database, Co3mu.Defines, Co3mu.Logger;
import std.conv;
public class GameServer {
	private static Thread serverThread;
	private static Socket serverSocket;
	public static c3Client[] game_sockets;
	//CONST to specify maximum number of connections to hold on this server
	public static const uint MAX_CONN = 3000;
	private static shared bool shouldDie;
	private const char[8] BAD_NAMES = [' ', '[', ']', '#', '*', '{', '(', ')'];
	@property
	public static Thread getServerThread() {
		return serverThread;
	}
	@property
	public static Socket getServerSocket() {
		return serverSocket;
	}
	@property
	public static bool getShouldDie() {
		return shouldDie;
	}
	/*
	Method: gsInit() 
	Return: Void 
	Expl: Initializes the game server's socket and any data it needs
	*/
	public static void gsInit() {
		c3Logger.outMsg("INIT", "Login socket coming online...", DebugLevel.LOW);
		//We don't want to die
		shouldDie = false;
		//Create thread and start it
		serverThread = new Thread(&gsPoll);
		serverThread.start();
	}
	
	public static void processPacket(ubyte[] data, c3Client cli) {
		int Type = c3Core.readUint16(data, 0); 
		switch(Type) {
			//1052 AUTH PACKET
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
					if(Data.hasCharacter(account)) { 
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
			//1001 CREATE CHARACTER PACKET
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
							if(Data.charExists(chPack.charName)) {
								cli.send((new ChatPacket(0xffffff, ChatType.Register, 0, "SYSTEM", "ALLUSERS", "Name taken.")).create());
								return;
							} else { //Create character
								if(Data.createCharacter(chPack.charName, chPack.charModel, chPack.charClass, cli.accountName)) {
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
			//case 10010 GENERAL DATA PACKET
			case 10010: //General data 
			{
				int subType = c3Core.readUint16(data, 18);
				switch(subType) 
				{
					case 74://Data.EnterMap
					{
						//Todo: Handle map checking
						cli.send((new GeneralPacket(cli.myChar.curLoc.MapID, cli.myChar.curLoc.MapID, cast(ushort)cli.myChar.curLoc.X, cast(ushort)cli.myChar.curLoc.Y, 74)).create());
						cli.sendWelcome();
						break;
					}
					case 137://Jump
					{
						int X = c3Core.readUint16(data, 6);
						int Y = c3Core.readUint16(data, 8);
						if(c3Core.distance2D(X, Y, cli.myChar.curLoc.X, cli.myChar.curLoc.Y) > 15) {
							//Pullback!
							cli.doTeleport(cli.myChar.curLoc.MapID, cli.myChar.curLoc.X, cli.myChar.curLoc.Y);
							cli.topMsg("PULLBACK! Jump too large...");
						} else {
							cli.myChar.prevLoc.X = cli.myChar.curLoc.X;
							cli.myChar.prevLoc.Y = cli.myChar.curLoc.Y;
							cli.myChar.prevLoc.MapID = cli.myChar.curLoc.MapID;
							cli.myChar.curLoc.X = X;
							cli.myChar.curLoc.Y = Y;
							ubyte[] resp = stripFooter(data);
							resp = addSizeHeader(resp);
							c3Core.sendAroundNotMe(cli.myChar.curLoc, resp, cli.myChar.UID);
							cli.spawnToScreen();
							cli.spawnScreenTo();
						}
						break;
					}
					default: {
						cli.topMsg("Unknown data packet subtype " ~ to!string(subType));
						break;
					}
				}
				break;
			}
			//1134 QUEST PACKET
			case 1134: //Quest packet?
			{
				int subType = c3Core.readUint16(data, 2);
				writefln("Quest packet subtype %s", subType);
				break;
			}
			//1009 ITEM USAGE PACKET
			case 1009: //Item use / ping
			{
				int subType = c3Core.readUint32(data, 10);
				switch(subType) {
					case 27: //Ping
					{
						ubyte[] resp = stripFooter(data);
						resp = addSizeHeader(resp);
						cli.send(resp);
						break;
					}
					default: 
					{
						writefln("Unknown item subtype %s", subType);
						break;
					}
				}
				break;
			}
			//1004 CONVERSATION PACKET
			case 1004: //Chat packet :)
			{
				ChatPacket cPack = new ChatPacket(data);
				if(cPack.Message[0] == '/') {
					string cmd = cPack.Message[1 .. cPack.MessageLength];
					string[] cmdArr = c3Core.splitCmds(cmd);
					switch(cmdArr[0]) {
						case "map":
						{ 
							if(cmdArr.length < 4) {
								cli.systemMsg("Usage: /map mapid x y");
								break;
							}
							int mapId = to!int(cmdArr[1]);
							int X = to!int(cmdArr[2]);
							int Y = to!int(cmdArr[3]);
							cli.doTeleport(mapId, X, Y);
							break;
						}
						case "spawn": 
						{
							
							break;
						}
						default: {
							cli.topMsg("Unknown command " ~ cmdArr[0] ~ ". /help shows cmds");
							break;
						}
					}
				} else { //Handle actual processing of chat
					int chatType = c3Core.readUint32(data, 6);
					switch(chatType) {
						case 2000://Chat
						{
							ubyte[] resp = stripFooter(data);
							resp = addSizeHeader(resp); 
							c3Core.sendAroundNotMe(cli.myChar.curLoc, resp, cli.myChar.UID);
							break;
						}
						default: {
							cli.topMsg("Unknown chat type " ~ to!string(chatType));
							break;
						}
					}
				}
				break;
			}
			//10005 WALK PACKET
			case 10005: //Walk
			{
				WalkPacket wp = new WalkPacket(data);
				if(wp.movetype == 0 || wp.movetype == 1) {
					//Walk/run
					int DY, DX = 0;
					switch(wp.direction) {
						case 0:
		                {
		                    DY = 1;
		                    break;
		                }
		            case 1:
		                {
		                    DX = -1;
		                    DY = 1;
		                    break;
		                }
		            case 2:
		                {
		                    DX = -1;
		                    break;
		                }
		            case 3:
		                {
		                    DX = -1;
		                    DY = -1;
		                    break;
		                }
		            case 4:
		                {
		                    DY = -1;
		                    break;
		                }
		            case 5:
		                {
		                    DX = 1;
		                    DY = -1;
		                    break;
		                }
		            case 6:
		                {
		                    DX = 1;
		                    break;
		                }
		            case 7:
		                {
		                    DY = 1;
		                    DX = 1;
		                    break;
		                }
		                default: 
		                 break;
					}
					cli.myChar.prevLoc.X = cli.myChar.curLoc.X;
					cli.myChar.prevLoc.Y = cli.myChar.curLoc.Y;
					cli.myChar.prevLoc.MapID = cli.myChar.curLoc.MapID;
					cli.myChar.curLoc.X += DX;
					cli.myChar.curLoc.Y += DY;
					ubyte[] resp = stripFooter(data);
					resp = addSizeHeader(resp);
					c3Core.sendAroundNotMe(cli.myChar.curLoc, resp, cli.myChar.UID);
					cli.spawnToScreen();
				}
				break;
			}
			default: { 
				writefln("Unknown packet type %s", Type);
				break;
			}
		}
	}
	
	public static ubyte[] addSizeHeader(ubyte[] data) {
		ubyte[] retVal = new ubyte[data.length + 2];
		retVal[0] = cast(ubyte)(retVal.length);
		retVal[2 .. $] = data[0 .. $];
		return retVal;
	}
	
	public static ubyte[] stripFooter(ubyte[] data) {
		ubyte[] retVal = new ubyte[data.length - 8];
		retVal[0 .. $] = data[0 .. $-8];
		return retVal;
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
	
	/*
	Method: gsPoll
	Return: void
	Expl: Polls the login server socket and connected sockets for data. Async thread holder for this server
	*/
	public static void gsPoll() {
		serverSocket = new TcpSocket;
		assert(serverSocket.isAlive);
		serverSocket.blocking = false;
		serverSocket.bind(new InternetAddress(5816));
		serverSocket.listen(50);
		SocketSet inSockets = new SocketSet(MAX_CONN + 1);
		while(!shouldDie) {
			for(;; inSockets.reset()) {
				inSockets.add(serverSocket);
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
							//game_sockets[i].my_sock.close();
							game_sockets[i].disconnect();
							if(i != game_sockets.length -1) //If not the last socket, set this index to the last socket
								game_sockets[i] = game_sockets[game_sockets.length -1];
							game_sockets = game_sockets[0 .. game_sockets.length -1];
							goto next; //index remains the same to skip over the current if needed(see previous comment for logic)
							} else {
								auto data = buffer[0 .. read];
								data = cli.decryptData(data, cast(int)read);
								//Need to get new key info from client...
								int Position = 7;
								uint packetLen = c3Core.readUint32(data, Position); Position += 4;
								uint junk_len = c3Core.readUint32(data,Position); Position += 4; Position += junk_len;
								uint keyLen = c3Core.readUint32(data,Position); Position += 4;
								string key = c3Core.readString(data, Position, keyLen);
								cli.finishExchange(key);
							}
						} else {
							ubyte[2] buffer;
							auto read = game_sockets[i].my_sock.receive(buffer);
							if(read == 0 || read == Socket.ERROR){ //Socket closed
								writefln("Connection closed from %s", game_sockets[i].my_sock.remoteAddress().toString());
								//game_sockets[i].my_sock.close();
								game_sockets[i].disconnect();
								if(i != game_sockets.length -1) //If not the last socket, set this index to the last socket
									game_sockets[i] = game_sockets[game_sockets.length -1];
								game_sockets = game_sockets[0 .. game_sockets.length -1];
								goto next; //index remains the same to skip over the current if needed(see previous comment for logic)
							} else {
								buffer = cli.decryptData(buffer, cast(int)read);
								int Size = (c3Core.readUint16(buffer, 0) + 6);
								auto data = new ubyte[Size];
								read = cli.my_sock.receive(data);
								if(read != Size)
									writefln("Danger will robinson %s %s", read, Size);
								data = cli.decryptData(data, cast(int)read);
								processPacket(data, cli);
								game_sockets[i] = cli;
							}
						}
					}
				}
				if(inSockets.isSet(serverSocket)) //New connection
				{
					Socket incoming;
					c3Client cli;
					try {
						if(game_sockets.length < MAX_CONN) {
							incoming = serverSocket.accept();
							writefln("GAME Connection estd from %s", incoming.remoteAddress().toString());
							assert(incoming.isAlive);
							assert(serverSocket.isAlive);
							cli = new c3Client; 
							cli.setSocket(incoming);
							cli.beginDHExchange();
							game_sockets ~= cli;
						} else {
							incoming = serverSocket.accept();
							writefln("Connection rejected from %s ; maximum number of connections achieved.", incoming.remoteAddress().toString());
							assert(incoming.isAlive);
							incoming.close();
							assert(!incoming.isAlive);
							assert(serverSocket.isAlive);
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