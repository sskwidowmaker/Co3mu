module Co3mu.LoginServer;

import std.stdio, core.thread, std.socket, Co3mu.Client, Co3mu.Core, Co3mu.Packets, Co3mu.Database, Co3mu.Defines, Co3mu.Logger;

public class LoginServer {
	//Thread holder object to hold this server's running thread
	public static Thread serverThread;
	//Socket holder object to hold this server's running socket
	public static Socket serverSocket;
	//c3Client collection full of connected sockets
	public static c3Client[] login_sockets;
	//CONST to specify maximum number of connections to hold on this server
	public static const uint MAX_CONN = 255;
	public static shared bool shouldDie;
	/*
	Method: lsInit()  
	Return: Void 
	Expl: Initializes the login server's socket and any data it needs
	*/
	public static void lsInit() {
		c3Logger.outMsg("INIT", "Login socket coming online...", DebugLevel.LOW);
		//We don't want to die
		shouldDie = false;
		//Create thread and start it
		serverThread = new Thread(&lsPoll);
		serverThread.start();
	}
	/*
	Method: lsPoll
	Return: void
	Expl: Polls the login server socket and connected sockets for data. Async thread holder for this server
	*/
	public static void lsPoll() {
		//create new socket
		serverSocket = new TcpSocket;
		assert(serverSocket.isAlive);
		//Set socket options
		serverSocket.blocking = false; //disable block
		serverSocket.bind(new InternetAddress(9959));
		serverSocket.listen(25);
		SocketSet servSocks = new SocketSet(MAX_CONN + 1);//Need room for this server's socket
		//Loop forever(until i die)
		while(!shouldDie) {
			for(;; servSocks.reset()) {
NEXT:
				//Add base server socket to poll
				servSocks.add(serverSocket);
				//Add each client connected, to check for new data
				foreach(c3Client f; login_sockets) {
					if(f.my_sock)//If NOT NULL
						servSocks.add(f.my_sock);
				}
				try{
					Socket.select(servSocks, null, null);
				} catch {
					//Do something?
				}
				int i;
				for(i = 0;; i++) {
					if(i >= login_sockets.length)
						break;
					if(login_sockets.length == 0)
						break;
					if(servSocks.isSet(login_sockets[i].my_sock)) {
						ubyte[1024] buffer;
						auto read = login_sockets[i].my_sock.receive(buffer);
						if(read == 0 || read == Socket.ERROR){ //Socket closed
							writefln("Connection closed from %s", login_sockets[i].my_sock.remoteAddress().toString());
							login_sockets[i].my_sock.close();
							if(i != login_sockets.length -1) //If not the last socket, set this index to the last socket
								login_sockets[i] = login_sockets[login_sockets.length -1];
							login_sockets = login_sockets[0 .. login_sockets.length -1];
							goto NEXT; //index remains the same to skip over the current if needed(see previous comment for logic)
						} else {
							auto data = buffer[0 .. read];
							c3Client cli = login_sockets[i];
							data = cli.decryptData(data, cast(int)read);
							int Type = c3Core.readUint16(data, 2);
							if(Type == 1060 || Type == 1086) {
								AuthRequestPacket pack = AuthRequestPacket(data);
								if(Data.accountExists(pack.Account)) {
									if(Data.passwordCorrect(pack.Account, pack.Password)) {
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
									Data.createAccount(pack.Account, pack.Password);
									writefln("Account not exist, created.");
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
								}
							}
						}
					}
				}
				if(servSocks.isSet(serverSocket)) //New connection
				{
					Socket incoming;
					c3Client cli;
					try {
						if(login_sockets.length < MAX_CONN) {
							incoming = serverSocket.accept();
							writefln("Connection estd from %s", incoming.remoteAddress().toString());
							assert(incoming.isAlive);
							assert(serverSocket.isAlive);
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
		}
	}
}