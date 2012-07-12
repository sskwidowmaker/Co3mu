module Co3mu.Core;
import std.stdio, Co3mu.Logger, Co3mu.Defines, Co3mu.Database, deimos.openssl.ssl, Co3mu.LoginServer, Co3mu.GameServer;
import std.conv, Co3mu.Location, Co3mu.Client, std.math;
public class c3Core {
	/*
	Where does the base co3mu directory lie?
	Ex: C:\server\
	set BASE_DIR = "C;\\server\\"
	needed to access files that the server needs. it should contain a directcory structure as follows:
	C:\server\
	 ->\dat\
	  ->\characters\
	  ->\accounts\
	 ->\maps\
	 ->\log\
	*/
	public const string BASE_DIR = "C:\\home-andrew\\andrew\\Co3mu\\"; 
	//uint used to return a "unique" login-token to each player that signs in
	public static shared uint tokGen;
	//uint used to issue a NEW UID to a NEW PLAYER
	public static shared uint uidGen;
	public static shared int[string] loginAuth;
	public const string GameIP = "192.168.0.2";
	public const char[8] TQs = "TQServer";
	/*
	Method: init()
	Return: Void
	Expl: Initializes the server from the main() method of the executable
	*/
	public static void init() {
		//Set the GLOBAL DEBUG_LEVEL var to setting here
		c3Logger.DEBUG_LEVEL = DebugLevel.LOW;
		//Let everyone know what we're doing...
		c3Logger.outMsg("INIT", "Core Init...", DebugLevel.HIGH);
		//init tok&uid
		initTokUid();
		//init libopenssl
		SSL_library_init();
		//Initialize the login socket
		LoginServer.lsInit();
		//Initialize the game socket
		GameServer.gsInit();
	}
	/*
	Method: initTokUid()
	Return: Void
	Expl: Initializes the tokGen variable to 1000 (lowest number allowed)
	; Initializes the uidGen variable to the NextUID() obtained from the data holder
	*/
	public static void initTokUid() {
		tokGen = 1000;
		uidGen = Data.getNextUID();
		writefln("next uid %s", uidGen);
	}
	
	public static int readUint16(ubyte[] data, int start) { 
		assert(data.length > start);
		return ((data[start+1] << 8) + data[start]);
	}
	
	public static string readString(ubyte[] data, int start, int len) {
		assert(data.length >= start+len);
		return cast(string)data[start .. start+len];
	}
	
	public static void sendAround(c3Location loc, ubyte[] data) {
		foreach(c3Client cli; GameServer.game_sockets) {
			if(cli.myChar) {
				if(cli.keysExchanged) {
					if(canSee(loc, cli.myChar.curLoc)) {
						cli.send(data);
					}
				}
			}
		}
	}
	
	public static void sendAroundNotMe(c3Location loc, ubyte[] data, uint UID) {
		foreach(c3Client cli; GameServer.game_sockets) {
			if(cli.myChar) {
				if(cli.keysExchanged) {
					if(cli.myChar.UID != UID)
						if(canSee(loc, cli.myChar.curLoc)) {
							cli.send(data);
							}
				}
			}
		}
	}
	
	public static uint distance2D(int X1, int Y1, int X2, int Y2) {
		return cast(uint)(fmax(abs(X2 - X1), abs(Y2 - Y1)));
	}
	
	public static string[] splitCmds(string cmd) {
		string[] retVal;
		retVal.length = 1;
		int x = 0;
		for(int i=0; i<cmd.length; i++) {
			if(cmd[i] == ' ') {
				x++;
				retVal.length += 1;
				continue;
			}
			retVal[x] ~= cmd[i];
		}
		return retVal;
	}
	
	public static int readUint32(ubyte[] Data, int StartLocation)
	{
		if(Data.length < StartLocation)
			return 0;
		return ((Data[StartLocation + 3] << 24) + (Data[StartLocation + 2] << 16) + (Data[StartLocation + 1] << 8) + (Data[StartLocation]));
	}
	
	public static uint getNextUID() {
		return uidGen++;
	}
	public static bool canSee(c3Location loc1, c3Location loc2) {
		//writefln("cansee %s,%s %s,%s %s %s", loc1.X, loc1.Y, loc2.X, loc2.Y, loc1.MapID, loc2.MapID); 
		if(loc1.MapID == loc2.MapID) {
			int max = 0;
			int dX = loc1.X - loc2.X; if(dX < 0) dX *= 1;
			int dY = loc1.Y - loc2.Y; if(dY < 0) dY *= 1;
			if(dX > dY)
				max = dX;
			else
				max = dY;
			return (max <= 18);
		} else {
			return false;
		}
	}
	
	public static uint getToken(string cli) {
		loginAuth[cli] = tokGen;
		return tokGen++;
	}

}