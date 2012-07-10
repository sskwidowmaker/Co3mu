module Co3mu.Character;

import Co3mu.Location, Co3mu.Vitals, Co3mu.Currency;

public class c3Char {
	public string name;
	public uint UID;
	public uint job;
	public string spouse;
	public c3Location curLoc;
	public c3Vital curVitals;
	public c3Currency curCurrency;
	public uint model;
	public uint hair;
	public uint curLevel;
	public uint rebornCount;
	public ulong curExp;
	this() {
		curLoc = new c3Location();
		curVitals = new c3Vital();
		curCurrency = new c3Currency();
	}
}