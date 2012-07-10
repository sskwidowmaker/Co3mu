module Co3mu.XML;

import std.stdio, std.xml, std.file, std.conv, std.array, Co3mu.Core, Co3mu.Character, Co3mu.Enums;

public class XMLOp { 
	public const string baseDir = "C:\\home-andrew\\andrew\\Co3mu\\dat\\";
	public const string fileExt = ".xml";
	public const string NO_CHARACTER = "@__-NEED_CREATE-__!";
	public static bool accountExists(string account) {
		account = baseDir ~ "accounts\\" ~ account ~ fileExt;
		return exists(account);
	}
	
	public static bool passwordCorrect(string account, string password) { 
		account = baseDir ~ "accounts\\" ~ account ~ fileExt;
		string s = cast(string)std.file.read(account);
		auto xml = new DocumentParser(s);
		string correctPass = "";
		xml.onStartTag["account"] = (ElementParser xml) {
			xml.onEndTag["password"] = (in Element e) { correctPass = e.text(); };
			xml.parse();
		}; 
		xml.parse();
		return (password == correctPass);
	}
	
	public static bool hasCharacter(string account) {
		account = baseDir ~ "accounts\\" ~ account ~ fileExt;
		string s = cast(string)std.file.read(account);
		auto xml = new DocumentParser(s);
		string char_name = "";
		xml.onStartTag["account"] = (ElementParser xml) {
			xml.onEndTag["character"] = (in Element e) { char_name = e.text(); };
			xml.parse();
		}; 
		xml.parse();
		return (NO_CHARACTER != char_name);
	}
	
	public static string getCharName(string account) {
		account = baseDir ~ "accounts\\" ~ account ~ fileExt;
		string s = cast(string)std.file.read(account);
		auto xml = new DocumentParser(s);
		string char_name = "";
		xml.onStartTag["account"] = (ElementParser xml) {
			xml.onEndTag["character"] = (in Element e) { char_name = e.text(); };
			xml.parse();
		}; 
		xml.parse();
		return char_name;
	}
	
	public static c3Char loadCharacter(string account) {
		c3Char charStor = new c3Char();
		charStor.name = getCharName(account);
		string name = baseDir ~ "characters\\" ~ charStor.name ~ fileExt;
		auto xml = new DocumentParser(cast(string)std.file.read(name));
		xml.onStartTag["character"] = (ElementParser xml) { 
			xml.onEndTag["charName"] = (in Element e) { charStor.name = e.text(); };
			xml.onEndTag["str"] = (in Element e) { charStor.curVitals.Strength = to!int(e.text()); };
			xml.onEndTag["dex"] = (in Element e) { charStor.curVitals.Dexterity = to!int(e.text()); };
			xml.onEndTag["spi"] = (in Element e) { charStor.curVitals.Spirit = to!int(e.text()); };
			xml.onEndTag["vit"] = (in Element e) { charStor.curVitals.Vitality = to!int(e.text()); };
			xml.onEndTag["hairStyle"] = (in Element e) { charStor.hair = to!int(e.text()); };
			xml.onEndTag["model"] = (in Element e) { charStor.model = to!int(e.text()); };
			xml.onEndTag["job"] = (in Element e) { charStor.job = to!int(e.text()); };
			xml.onEndTag["UID"] = (in Element e) { charStor.UID = to!int(e.text()); };
			xml.onEndTag["spouse"] = (in Element e) { charStor.spouse = e.text(); };
			xml.onEndTag["mapID"] = (in Element e) { charStor.curLoc.MapID = to!int(e.text()); };
			xml.onEndTag["dynMapID"] = (in Element e) { charStor.curLoc.DynID= to!int(e.text()); };
			xml.onEndTag["curX"] = (in Element e) { charStor.curLoc.X= to!int(e.text()); };
			xml.onEndTag["curY"] = (in Element e) { charStor.curLoc.Y= to!int(e.text()); };
			xml.onEndTag["curHP"] = (in Element e) { charStor.curVitals.curHP = to!int(e.text()); };
			xml.onEndTag["curMP"] = (in Element e) { charStor.curVitals.curMP = to!int(e.text()); };
			xml.onEndTag["statPoints"] = (in Element e) { charStor.curVitals.StatPoints = to!int(e.text()); };
			xml.onEndTag["money"] = (in Element e) { charStor.curCurrency.Money = to!int(e.text()); };
			xml.onEndTag["cps"] = (in Element e) { charStor.curCurrency.CPs = to!int(e.text()); };
			xml.onEndTag["vps"] = (in Element e) { charStor.curCurrency.VirtuePoints = to!int(e.text()); };
			xml.onEndTag["level"] = (in Element e) { charStor.curLevel = to!int(e.text()); };
			xml.onEndTag["reborn"] = (in Element e) { charStor.rebornCount = to!int(e.text()); };
			xml.onEndTag["exp"] = (in Element e) { charStor.curExp = to!ulong(e.text()); };
			xml.parse();
		};
		xml.parse();
		return charStor;
	}
	
	public static void saveCharacter(c3Char charStor, string account) {
		auto doc = new Document(new Tag("Co3Character"));
		auto element = new Element("character");
		element ~= new Element("charName", charStor.name);
		element ~= new Element("charAccount", account);
		element ~= new Element("str", to!string(charStor.curVitals.Strength));
		element ~= new Element("dex", to!string(charStor.curVitals.Dexterity));
		element ~= new Element("spi", to!string(charStor.curVitals.Spirit));
		element ~= new Element("vit", to!string(charStor.curVitals.Vitality));
		element ~= new Element("hairStyle", to!string(charStor.hair));
		element ~= new Element("model", to!string(charStor.model));
		element ~= new Element("job", to!string(charStor.job));
		element ~= new Element("UID", to!string(charStor.UID));
		element ~= new Element("spouse", charStor.spouse);
		element ~= new Element("mapID", to!string(charStor.curLoc.MapID));
		element ~= new Element("dynMapID", to!string(charStor.curLoc.DynID));
		element ~= new Element("curX", to!string(charStor.curLoc.X));
		element ~= new Element("curY", to!string(charStor.curLoc.Y));
		element ~= new Element("curHP", to!string(charStor.curVitals.curHP));
		element ~= new Element("curMP", to!string(charStor.curVitals.curMP));
		element ~= new Element("statPoints", to!string(charStor.curVitals.StatPoints));
		element ~= new Element("money", to!string(charStor.curCurrency.Money));
		element ~= new Element("cps", to!string(charStor.curCurrency.CPs));
		element ~= new Element("vps", to!string(charStor.curCurrency.VirtuePoints));
		element ~= new Element("level", to!string(charStor.curLevel));
		element ~= new Element("reborn", to!string(charStor.rebornCount));
		element ~= new Element("exp", to!string(charStor.curExp));
		doc ~= element;
		string name = baseDir ~ "characters\\" ~ charStor.name ~ fileExt;
		std.file.write(name, doc.toString());
	}
	
	public static bool charExists(string charName) {
		charName = baseDir ~ "characters\\" ~ charName ~ fileExt;
		return exists(charName);
	}
	
	public static bool createCharacter(string name, int model, int job, string account) {
		if(!charExists(name)) {
			if(!hasCharacter(account)) {
				auto doc = new Document(new Tag("Co3Character"));
				auto element = new Element("character");
				element ~= new Element("charName", name);
				element ~= new Element("charAccount", account);
				element ~= new Element("str", to!string(10));
				element ~= new Element("dex", to!string(10));
				element ~= new Element("spi", to!string(10));
				element ~= new Element("vit", to!string(10));
				element ~= new Element("hairStyle", to!string(10));
				element ~= new Element("model", to!string(model));
				element ~= new Element("job", to!string(job));
				element ~= new Element("UID", to!string(c3Core.getNextUID()));
				element ~= new Element("spouse", "none");
				element ~= new Element("mapID", to!string(1002));
				element ~= new Element("dynMapID", "0");
				element ~= new Element("curX", "438");
				element ~= new Element("curY", "377");
				element ~= new Element("curHP", "100");
				element ~= new Element("curMP", "0");
				element ~= new Element("statPoints", "0");
				element ~= new Element("money", "0");
				element ~= new Element("cps", "0");
				element ~= new Element("vps", "0");
				element ~= new Element("level", "1");
				element ~= new Element("reborn", "0");
				element ~= new Element("exp", "0");
				doc ~= element;
				characterToAccount(name, account);
				name = baseDir ~ "characters\\" ~ name ~ fileExt;
				std.file.write(name, doc.toString());
			} else
				return false;
		} else
			return false;
		return true;
	}
	
	public static void characterToAccount(string charName, string account) {
		account = baseDir ~ "accounts\\" ~ account ~ fileExt;
		string s = cast(string)std.file.read(account);
		auto xml = new DocumentParser(s);
		string password, user;
		xml.onStartTag["account"] = (ElementParser xml) {
			xml.onEndTag["password"] = (in Element e) { password = e.text(); };
			xml.onEndTag["username"] = (in Element e) { user = e.text(); };
			xml.parse();
		}; 
		xml.parse();
		saveAccount(user, password, charName);
	}
	
	public static uint getNextUID() {
		uint largestID = 1100000;
		foreach(string file; dirEntries(baseDir ~ "characters\\", SpanMode.shallow)) {
			auto xml = new DocumentParser(file);
			uint curUID = 0;
			xml.onStartTag["character"] = (ElementParser xml) {
				xml.onEndTag["UID"] = (in Element e) { curUID = to!int(e.text()); };
				xml.parse();
			};
			xml.parse();
			if(curUID > largestID)
				largestID = curUID;
		}
		return ++largestID;
	}
	
	public static void saveAccount(string user, string pass, string cName) {
		auto doc = new Document(new Tag("Co3Account"));
		auto element = new Element("account");
		element ~= new Element("username", user);
		element ~= new Element("password", pass);
		element ~= new Element("character", cName);
		doc ~= element;
		user = baseDir ~ "accounts\\" ~ user ~ fileExt;
		std.file.write(user, doc.toString());
	}
	
	public static void createAccount(string account, string password) {
		auto doc = new Document(new Tag("Co3Account"));
		auto element = new Element("account");
		element ~= new Element("username", account);
		element ~= new Element("password", password);
		element ~= new Element("character", NO_CHARACTER);
		doc ~= element;
		account = baseDir ~ "accounts\\" ~ account ~ fileExt;
		std.file.write(account, doc.toString());
	}
} 