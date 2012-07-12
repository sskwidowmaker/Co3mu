module Co3mu.Packets;

import std.string, Co3mu.Encryption, Co3mu.PacketBuilding, Co3mu.Character, std.datetime, std.stdio, Co3mu.Core;

struct PasswordSeedPacket {
    ushort Size;
    ushort Type;
    int Seed;
};

struct AuthMessagePacket {
	uint AccountID;
	uint LoginToken;
	this(ubyte[] data) {
		LoginToken = c3Core.readUint32(data, 6);
	}
}

struct AuthRequestPacket {
	ushort Type;
	string Account;
	string Password; 
	string _acc;
	string _psw;
	int state;
	this(ubyte[] data) {
		Type = cast(ushort)c3Core.readUint16(data, 2);
		Account = c3Core.readString(data, 4, 16);
		ubyte[] password = data[132 .. 132+16];
		windows_srand(8000000);
		ubyte[16] rc5Key;
		for(int i=0; i<16; i++)
			rc5Key[i] = cast(byte)windows_rand();
		//password = new ConquerPasswordCryptographer(Account).Decrypt(new rc5Encryption(rc5Key).rc5Decrypt(password), 16);
		rc5Encryption rc = new rc5Encryption(rc5Key); 
		ConquerPasswordCryptographer pwcrypt = new ConquerPasswordCryptographer(Account);
		password = rc.rc5Decrypt(password);
		password = pwcrypt.Decrypt(password, cast(int)password.length);
		Password = c3Core.readString(password, 0, cast(int)password.length);
		for(int i=0; i<Account.length; i++) {
			if((cast(int)Account[i]) != 0)
				_acc ~= Account[i];
		}
		Account = _acc;
		for(int i=0; i<Password.length; i++) {
			if((cast(int)Password[i]) != 0)
				_psw ~= Password[i];
		}
		Password = _psw;
	}
	void windows_srand(int st) {
		state = st;
	}
	long windows_rand() {
		return (((state = cast(int)(state * 214013L + 2531011L))>>16) & 0x7fff);
	}
};

struct AuthResponsePacket {
	ushort Size;
	ushort Type;
	uint AccountID;
	uint LoginToken;
	uint Port;
	uint Hash;
	char[16] GameIP;
	byte[16] nothing;
};
struct CreateCharacterPacket {
	string charName;
	string _cname;
	ushort charModel;
	ushort charClass;
	this(ubyte[] data) {
		charName = c3Core.readString(data, 22, 16);
		for(int i=0; i<charName.length; i++) {
			if(charName[i] != 0)
				_cname ~= charName[i];
		}
		charName = _cname;
		charModel = cast(ushort)c3Core.readUint16(data, 70);
		charClass = cast(ushort)c3Core.readUint16(data, 72);
	}
};

class SpawnPacket {
	ushort Size;
	ushort Type;
	uint UID;
	uint Model;
	ulong status;
	ushort GuildID;
	ubyte GuildRank;
	uint GarmentID;
	uint HelmID;
	uint Armor;
	uint RightHand;
	uint LeftHand;
	ushort X;
	ushort Y;
	ushort Hair;
	ubyte direction;
	ubyte action;
	ubyte reborn;
	ubyte level;
	uint Unknown;
	ubyte showname;
	ubyte nameLength;
	string Name;
	this(c3Char chars) {
		Type = 10014;
		Size = cast(ushort)(220 + chars.name.length);
		UID = chars.UID;
		Model = chars.model;
		status = 0;//TODO!!!
		GuildID = 0;//TODO!
		GuildRank = 0;
		GarmentID = 0;//TODO
		HelmID = 0;//TODO
		Armor = 0;//TODO
		RightHand = 0;//TODO
		LeftHand = 0;//TODO
		X = cast(ushort)chars.curLoc.X;
		Y = cast(ushort)chars.curLoc.Y;
		Hair = cast(ubyte)chars.hair;
		direction = chars.curLoc.faceDirection;
		action = 0;//TODO
		reborn = 1;
		level = cast(ubyte)chars.curLevel;
		showname = 3;
		nameLength = cast(ubyte)chars.name.length;
		Name = chars.name;
	}
	
	ubyte[] create() {
		PacketBuilder pb = new PacketBuilder(Size, Type);
		//pb.putInt(UID);
		//pb.putInt(Model);
		pb.putInt(Model);//4-7
		pb.putInt(UID);//8-11
		pb.putInt(GuildID);//12-15
		pb.putShort(GuildRank);//16-17
		pb.putInt(0);//Unknown//18-21
		pb.putULong(status);//22-29
		pb.putULong(status);//status2? 30-37
		pb.putShort(0);//?? 38-39
		pb.putInt(HelmID);//40 - 43
		pb.putInt(GarmentID);//44-47
		pb.putInt(Armor);//48-51
		pb.putInt(RightHand);//52-55
		pb.putInt(LeftHand);//56-59
		pb.putInt(0);//RightAccesory 60-63
		pb.putInt(0);//LeftAccesory 64 - 67
		pb.putInt(0);//Mount type 68-71
		pb.putInt(0);//Unknown 72 - 75
		pb.putInt(0);//Mount armor 76 - 79
		pb.putShort(0);//HP 80, 81
		pb.putShort(0);//mob level 82, 83
		pb.putShort(Hair); //84, 85
		pb.putShort(X); //86, 87
		pb.putShort(Y); //88, 89
		pb.putByte(direction); //90
		pb.putByte(action); //91
		pb.putShort(0);//Unknown 92, 93
		pb.putInt(0);//Unknown 94 - 97
		pb.putByte(reborn); // 98
		pb.putShort(level); // 99, 100
		pb.putByte(0);//Unknown 101
		pb.putInt(0);//away status? 102 - 105
		pb.putULong(0); // 106 - 113
		pb.putInt(0); // 114 - 117
		pb.putByte(0);//118
		pb.putByte(0);//Nobility 119
		pb.putShort(0); //120, 121
		pb.putByte(0); // 122
		pb.putShort(0);//ArmorColor 123, 124
		pb.putShort(0);//Shieldcolor 125,126
		pb.putShort(0);//Helm color 127, 128
		pb.putInt(0);// 129 - 132
		pb.putByte(0);//Mount+ 133
		pb.putInt(0);// 134 - 137
		pb.putByte(0); // 138
		pb.putInt(0);//Mountcolor? 139 - 142
		pb.putULong(0);//143 - 150
		pb.putULong(0);//151 - 158
		pb.putULong(0);//159 - 166
		pb.putULong(0);//167 - 174
		pb.putInt(0);// 175 - 178
		pb.putShort(0);//179, 180
		pb.putByte(0);//181 BOSS
		pb.putInt(0);//HelmArtifact 182 - 185
		pb.putInt(0);//ArmorArtifact 186 - 189
		pb.putInt(0);//WeaponRArt 190 - 193
		pb.putInt(0);//WeaponLArt 194 - 197
		pb.putULong(0);//198 - 205
		pb.putULong(0);//206 - 213 210 = profession
		pb.putInt(0);//214 - 217
		pb.putByte(showname);// 
		pb.putByte(nameLength);
		pb.putString(Name);
		return pb.seal();
	}
}
class GeneralPacket {
	ushort Size;
	ushort Type;
	uint ID;
	uint ValueA;
	uint ValueB;
	uint Timer;
	ushort DataType;
	ushort Unknown;
	ushort X;
	ushort Y;
	uint ValueC;
	uint ValueD;
	byte ValueE;
	this(uint _id, uint a, ushort b, ushort c, ushort dtype) {
		Size = 37;
		Type = 10010;
		ID = _id;
		ValueA = a;
		X = b;
		Y = c;
		Timer = cast(uint)Clock.currSystemTick().length;
		DataType = dtype;
		Unknown = 0;
		ValueB = 0;
		ValueC = 0;
		ValueD = 0;
		ValueE = 0;
	}
	
	ubyte[] create() {
		PacketBuilder pb = new PacketBuilder(Size, Type);
		pb.putInt(ID);//4,5,6,7
		pb.putInt(ValueA);//8,9,10
		pb.putInt(ValueB);
		pb.putInt(Timer);
		pb.putShort(DataType);
		pb.putShort(Unknown);
		pb.putShort(X);
		pb.putShort(Y);
		pb.putInt(ValueC);
		pb.putInt(ValueD);
		pb.putByte(ValueE);
		return pb.seal();
	}
}
class DateTimePacket {
	ushort Size;
	ushort Type;
	uint Unknown;
	uint Year;
	uint Month; 
	uint dayYear;
	uint dayMonth;
	uint hour;
	uint min;
	uint sec;
	this() {
		Size = 36;
		Type = 1033;
		auto curTime = Clock.currTime();
		Unknown = 0;
		Year = curTime.year - 1900;
		Month = curTime.month - 1;
		dayYear = 171;
		dayMonth = curTime.day;
		hour = curTime.hour;
		min = curTime.minute;
		sec = curTime.second;
	}
	
	ubyte[] create() {
		PacketBuilder pb = new PacketBuilder(Size, Type);
		pb.putInt(Unknown);
		pb.putInt(Year);
		pb.putInt(Month);
		pb.putInt(dayYear);
		pb.putInt(dayMonth);
		pb.putInt(hour);
		pb.putInt(min);
		pb.putInt(sec);
		return pb.seal();
	}
}
class QuestPacket {
	ushort Size;
	ushort Type;
	ushort Action;
	ushort Amount;
	this() {
		Size = 8;
		Type = 1134;
		Action = 3;
		Amount = 0;
	}
	
	ubyte[] create() {
		PacketBuilder pb = new PacketBuilder(Size, Type);
		pb.putShort(Action);
		pb.putShort(Amount);
		return pb.seal();
	}
}

class HeroInfoPacket {
	ushort Size;
	ushort Type;
	uint UID;
	uint model;
	ushort hair;
	uint cash;
	uint cps;
	ulong exp;
	uint unknown1;
	ushort str;
	ushort dex;
	ushort vit;
	ushort spi;
	ushort statpoints;
	ushort hp;
	ushort mp;
	ushort pkpoints;
	ubyte level;
	ubyte job;
	ubyte reborn;
	ubyte namedisplay;
	uint quizPoints;
	uint enlighten;
	ushort unknown2;
	uint unknown3;
	ubyte stringCount;
	string firstName;
	string secondName;
	string spouse;
	this(c3Char charStor) {
		Size = cast(ushort)(112 + charStor.name.length);
		Type = 1006;
		UID = charStor.UID;
		model = charStor.model;
		hair = cast(ushort)charStor.hair;
		cash = charStor.curCurrency.getMoney;
		cps = charStor.curCurrency.getCPs;
		exp = charStor.curExp;
		unknown1 = 0;
		str = cast(ushort)charStor.curVitals.getStr;
		dex = cast(ushort)charStor.curVitals.getDex;
		vit = cast(ushort)charStor.curVitals.getVit;
		spi = cast(ushort)charStor.curVitals.getSpi;
		statpoints = cast(ushort)charStor.curVitals.getStatPoints;
		hp = cast(ushort)charStor.curVitals.getCurHP;
		mp = cast(ushort)charStor.curVitals.getCurMP;
		pkpoints = 10;
		level = cast(ubyte)charStor.curLevel;
		job = cast(ubyte)charStor.job;
		reborn = cast(ubyte)charStor.rebornCount;
		namedisplay = 1;
		quizPoints = 0;
		enlighten = 0;
		unknown2 = 0;
		unknown3 = 0;
		firstName = charStor.name;
		spouse = charStor.spouse;
	}
	
	ubyte[] create() {
		PacketBuilder pb = new PacketBuilder(Size, Type);
		pb.putInt(UID);//4,5,6,7
		pb.putShort(0);//8,9
		pb.putInt(model);//10,11,12,13
		pb.putShort(hair);//14,15
		pb.putInt(cash);//16,17,18,19
		pb.putInt(cps);//20,21,22,23
		pb.putULong(exp);//24,25,26,27,28,29,30,31
		pb.putInt(unknown1);//32,33,34,35
		pb.putInt(unknown1);//36,37,38,39
		pb.putInt(unknown1);//40,41,42,43
		pb.putInt(unknown1);//44,45,46,47
		pb.putInt(unknown1);//48,49,50,51
		pb.putShort(str);//52,53
		pb.putShort(dex);//54,55
		pb.putShort(vit);//56,57
		pb.putShort(spi);//58,59
		pb.putShort(statpoints);//60,61
		pb.putShort(hp);//62,63
		pb.putShort(mp);//64,65
		pb.putShort(pkpoints);//66,67
		pb.putByte(level);//68
		pb.putByte(job);//69
		pb.putByte(reborn);//70
		pb.putInt(0);//names display 71,72,73,74
		pb.putShort(0);//Unk 75,76
		//pb.putByte(namedisplay);
		pb.putInt(quizPoints);//77.78.79.80
		pb.putInt(enlighten);//81,82,83,84
		pb.putInt(unknown3);//85,86,87,88
		pb.putShort(unknown2);//89,90
		pb.putShort(0);//Title 91,92
		pb.putInt(0);//93,94,95,96
		pb.putInt(0);//97,98,99,100
		pb.putInt(0);//101,102,103,104
		pb.putInt(0);//105,106,107,108
		pb.putByte(0);
		pb.putByte(1);//String count first, second, spouse
		pb.putByte(cast(ubyte)firstName.length);
		pb.putString(firstName);
		//pb.putByte(0);//second len
		//pb.putByte(cast(ubyte)spouse.length);
		//pb.putString(spouse);
		return pb.seal();
	}
}
class ChatPacket {
	ushort Size;
	ushort Type;
	uint ChatColor;
	uint ChatType;
	uint ChatID;
	uint UnknownA;
	uint UnknownB;
	ubyte StringCount;
	ubyte FromLength;
	string From;
	ubyte ToLength;
	string To;
	ubyte SuffixLength;
	string Suffix;
	ubyte MessageLength;
	string Message;
	this(uint color, uint type, uint id, string _from, string _to, string _message) {
		Type = 1004;
		ChatColor = color;
		ChatType = type;
		ChatID = id;
		UnknownA = UnknownB = 0;
		StringCount = 4;
		From = _from; FromLength = cast(ubyte)From.length;
		To = _to; ToLength = cast(ubyte)To.length;
		SuffixLength = 0; Suffix = "";
		Message = _message; MessageLength = cast(ubyte)Message.length;
		Size = 29 + FromLength + ToLength + MessageLength + SuffixLength;
	}
	this(ubyte[] data) {
		ChatType = c3Core.readUint32(data, 6);
		int Pos = 23;
		FromLength = cast(uint)data[Pos];
		From = c3Core.readString(data, Pos+1, FromLength);
		Pos += FromLength + 1;
		ToLength = cast(uint)data[Pos];
		To = c3Core.readString(data, Pos+1, ToLength);
		Pos += ToLength + 1;
		SuffixLength = cast(uint)data[Pos];
		Suffix = c3Core.readString(data, Pos+1, SuffixLength);
		Pos += SuffixLength + 1;
		MessageLength = cast(uint)data[Pos];
		Message = c3Core.readString(data, Pos+1, MessageLength);
	}
	
	ubyte[] create() {
		PacketBuilder pb = new PacketBuilder(Size, Type);
		pb.putInt(ChatColor);
		pb.putInt(ChatType);
		pb.putInt(ChatID);
		pb.putInt(UnknownA);
		pb.putInt(UnknownB);
		pb.putByte(StringCount);
		pb.putByte(FromLength);
		pb.putString(From);
		pb.putByte(ToLength);
		pb.putString(To);
		pb.putByte(SuffixLength);
		pb.putByte(MessageLength);
		pb.putString(Message);
		return pb.seal();
	}
};

class Unknown2079 {
	ushort Size;
	ushort Type;
	uint Data;
	this(uint d) {
		Size = 8;
		Type = 2079;
		Data = d;
	}
	
	ubyte[] create() {
		PacketBuilder pb = new PacketBuilder(Size, Type);
		pb.putInt(Data);
		return pb.seal();
	}
};
class WalkPacket {
	ushort Size;
	ushort Type;
	uint direction;
	uint UID;
	uint movetype;
	uint Timer;
	uint Unknown;
	this(ubyte[] data) {
		UID = c3Core.readUint32(data, 6);
		direction = c3Core.readUint32(data, 2);
		movetype = c3Core.readUint32(data, 10);
		if(movetype < 2)
			direction = direction % 8;
		else if(movetype > 1)
			direction = direction % 24;
	}
}
class Unknown2078 {
	ushort Size;
	ushort Type;
	uint Data;
	ubyte[256] garb;
	this(uint d) {
		Size = 264;
		Type = 2078;
		Data = d;
	}
	
	ubyte[] create() {
		PacketBuilder pb = new PacketBuilder(Size, Type);
		pb.putInt(Data);
		for(int i=0; i<garb.length; i++)
			pb.putByte(garb[i]);
		return pb.seal();
	}
};