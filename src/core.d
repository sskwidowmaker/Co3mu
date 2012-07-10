module Co3mu.Core;
import std.stdio, Co3mu.Logger, core.thread, Co3mu.Login, Co3mu.Game, deimos.openssl.ssl, Co3mu.Client, Co3mu.XML;

public class c3Core {
	public static bool continueServer = true;
	public const string GameIP = "192.168.0.2";
	public const char[8] TQs = "TQServer";
	public static shared uint tokenGen;
	public static shared uint uidGen;
	public static shared int[string] loginAuth;
	public static void init() {
		c3Logger.outMsg("INIT", "Co3mu coming online.");
		tokenGen = 1000;
		loadUID();
		writefln("next UID is %s", uidGen);
		init_login_socket();
		init_game_socket();
		SSL_library_init();
	} 
	
	public static bool shouldContinue() {
		return continueServer;
	}
	
	public static uint getNextUID() {
		return uidGen++;
	} 
	
	public static void loadUID() {
		uidGen = XMLOp.getNextUID();
	}
	
	public static uint getToken(string cli) {
		loginAuth[cli] = tokenGen;
		return tokenGen++;
	}
	
	public static void init_login_socket() {
		c3Logger.outMsg("INIT", "Login socket coming online...");
		LoginServer.initLogin();
	}
	
	public static void init_game_socket() {
		c3Logger.outMsg("INIT", "Game socket coming online...");
		GameServer.initGame();
	}
}