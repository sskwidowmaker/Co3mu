module Co3mu.Login;

import std.stdio, core.thread, std.conv, std.socket, Co3mu.Logger, Co3mu.Core, std.file, Co3mu.Client, Co3mu.Packets, std.file, std.xml;
import Co3mu.Helper, Co3mu.XML;

public class LoginServer {
	public static Thread loginThread;
	public static Socket loginSocket;
	public static c3Client[] login_sockets;
	public const uint MAX_CONNECTIONS = 120;
	public static void initLogin() {
		//Create login thread, start it.
		loginThread = new Thread(&loginPoll);
		loginThread.start();
	}
	
	public static void loginPoll() {
		loginSocket = new TcpSocket;
		assert(loginSocket.isAlive);
		loginSocket.blocking = false;
		loginSocket.bind(new InternetAddress(9959));
		loginSocket.listen(25);
		SocketSet inSockets = new SocketSet(MAX_CONNECTIONS + 1); //Need to have room for MAX_CON + 1(listener) socks
		while(c3Core.shouldContinue()) {
			for(;; inSockets.reset()) {
next:
				inSockets.add(loginSocket);
				foreach(c3Client f; login_sockets) {
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
					if( i >= login_sockets.length)
						break;
					if(login_sockets.length == 0)
						break;
					if(inSockets.isSet(login_sockets[i].my_sock)) {
						ubyte[1024] buffer;
						auto read = login_sockets[i].my_sock.receive(buffer);
						if(read == 0 || read == Socket.ERROR){ //Socket closed
							writefln("Connection closed from %s", login_sockets[i].my_sock.remoteAddress().toString());
							login_sockets[i].my_sock.close();
							if(i != login_sockets.length -1) //If not the last socket, set this index to the last socket
								login_sockets[i] = login_sockets[login_sockets.length -1];
							login_sockets = login_sockets[0 .. login_sockets.length -1];
							goto next; //index remains the same to skip over the current if needed(see previous comment for logic)
						} else {
							auto data = buffer[0 .. read];
							c3Client cli = login_sockets[i];
							data = cli.decryptData(data, cast(int)read);
							int Type = c3Helper.readUint16(data, 2);
							if(Type == 1060 || Type == 1086) {
								AuthRequestPacket pack = AuthRequestPacket(data);
								if(XMLOp.accountExists(pack.Account)) {
									if(XMLOp.passwordCorrect(pack.Account, pack.Password)) {
										AuthResponsePacket resp;
										resp.Size = 52;
										resp.Type = 1055;
										resp.Hash = 10;
										resp.LoginToken = c3Core.getToken(pack.Account);
										resp.AccountID = 10;
										for(i=0; i<16; i++) {
											if(i < c3Core.GameIP.length)
												resp.GameIP[i] = c3Core.GameIP[i];
											else
												resp.GameIP[i] = 0;
										}
										resp.Port = 5816;
										ubyte[] tosend = *(cast(ubyte[AuthResponsePacket.sizeof]*)(&resp));
										cli.my_sock.send(cli.encryptData(tosend, 52));
									} else { // Wrong password
										AuthResponsePacket resp;
										resp.Size = 52;
										resp.Type = 1055;
										resp.Hash = 0;
										resp.LoginToken = 1; // Wrong password indicator
										resp.AccountID = 0; 
										for(i=0; i<16; i++) {
											if(i < c3Core.GameIP.length)
												resp.GameIP[i] = c3Core.GameIP[i];
											else
												resp.GameIP[i] = 0;
										}
										resp.Port = 5816;
										ubyte[] tosend = *(cast(ubyte[AuthResponsePacket.sizeof]*)(&resp));
										cli.my_sock.send(cli.encryptData(tosend, 52));
									}
								} else { //Create new account with given user/pass
									XMLOp.createAccount(pack.Account, pack.Password);
									writefln("Account not exist, created.");
								}
							}
						}
					}
				}
				if(inSockets.isSet(loginSocket)) //New connection
				{
					Socket incoming;
					c3Client cli;
					try {
						if(login_sockets.length < MAX_CONNECTIONS) {
							incoming = loginSocket.accept();
							writefln("Connection estd from %s", incoming.remoteAddress().toString());
							assert(incoming.isAlive);
							assert(loginSocket.isAlive);
							cli = new c3Client; 
							cli.setSocket(incoming);
							cli.initAuthEnc();
							login_sockets ~= cli;
							PasswordSeedPacket psp;
							psp.Seed = 8000000;
							psp.Size = 8;
							psp.Type = 1059;
							ubyte[] data = *(cast(ubyte[PasswordSeedPacket.sizeof]*)(&psp));
							incoming.send(cli.encryptData(data, cast(int)data.length));
						} else {
							incoming = loginSocket.accept();
							writefln("Connection rejected from %s ; maximum number of connections achieved.", incoming.remoteAddress().toString());
							assert(incoming.isAlive);
							incoming.close();
							assert(!incoming.isAlive);
							assert(loginSocket.isAlive);
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