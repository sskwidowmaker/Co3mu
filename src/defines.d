module Co3mu.Defines;
//DebugLevel used in message output (via c3Logger)
enum DebugLevel {
	LOW = 0,
	LMED = 1,
	MED = 2,
	HMED = 3,
	HIGH = 4
}

enum ChatType {
	Talk = 2000,
    Whisper = 2001,
    Team = 2003,
    Guild = 2004,
    System = 2005,
    Clan = 2006,
    Friend = 2009,
    Center = 2011,
    Ghost = 2013,
    Service = 2014,
    Tip = 2015,
    World = 2021,
    Qualifier = 2022,
    Register = 2100,
    Entrance = 2101,
    MessageBox = 2102,
    HawkMessage = 2104,
    Website = 2105,
    GuildWarFirst = 2108,
    GuildWarNext = 2109,
    GuildBulletin = 2111,
    BroadcastMessage = 2500,
    TopLeft = 2012,
    CharacterCreation = 2100,
    Login = 2101,
    BeginRight = 2108,
    Right = 2109,
    SystemWhisper = 2110,
    GuildAnnouncement = 2111,
    Agate = 2115,
    Broadcast = 2500,
    Monster = 2600,
    SlideFromRight = 100000,
    SlideFromRightRedVib = 1000000,
    WhiteVibrate = 10000000
}

enum MapID {
	DesertCity = 1000,
    AncientMaze = 1001,
    TwinCity = 1002,
    Promotion = 1004,
    Arena = 1005,
    Stables = 1006,
    MapleForest = 1011,
    //WonderLand = 1013,
    DragonPool = 1014,
    BirdIsland = 1015,
    KylinCave = 1016,
    AdvanceZone = 1017,
    SmallArena = 1018,
    LargeArena = 1019,
    ApeMoutain = 1020,
    Market = 1036,
    playground = 1039,
    newcanyon = 1075,//2nd AC Map
    newwoods = 1076, //2nd PC Map
    newdesert = 1077,
    newisland = 1078,
    task07 = 1207,
    task08 = 1208,
    task10 = 1210,
    task11 = 1211,
    islandsnail = 1212,
    desertsnail = 1213,
    canyonfairy = 1214, // Advance zone, alien apes etc
    woodsfairy = 1215,
    newplainfairy = 1216,
    stask01 = 1351,
    stask02 = 1352,
    stask03 = 1353,
    stask04 = 1354,
    blpk = 1507, //BI PK Map
    tiger1 = 1512, // Hawk cave
    Gulf = 1700, //2nd rb
    Dgate = 2021,
    Dsquare = 2022,
    Dcloister = 2023,
    Dsigil = 2024,
    prison = 6000,
    	/*
    	 * 2024 = Discity
    	 * 1505 = TC Pk Map
    	 * s-task01-04 = Lab
    	 */
}