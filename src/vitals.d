module Co3mu.Vitals;

private class c3Vital {
	private uint curHP;
	@property
	public uint getCurHP() {
		return curHP;
	}
	public void setCurHP(uint val) {
		curHP = val;
	}
	private uint curMP;
	@property
	public uint getCurMP() {
		return curMP;
	}
	public void setCurMP(uint val) {
		curMP = val;
	}
	private uint baseHP;
	@property
	public uint getBaseHP() {
		return baseHP;
	}
	public void setBaseHP(uint val) {
		baseHP = val;
	}
	private uint baseMP;
	@property
	public uint getBaseMP() {
		return baseMP;
	}
	public void setBaseMP(uint val) {
		baseMP = val;
	}
	private uint Strength;
	@property
	public uint getStr() {
		return Strength;
	}
	public void setStr(uint val) {
		Strength = val;
	}
	private uint Dexterity;
	@property
	public uint getDex() {
		return Dexterity;
	}
	public void setDex(uint val) {
		Dexterity = val;
	}
	private uint Spirit;
	@property
	public uint getSpi() {
		return Spirit;
	}
	public void setSpi(uint val) {
		Spirit = val;
	}
	private uint Vitality;
	@property
	public uint getVit() {
		return Vitality;
	}
	public void setVit(uint val) {
		Vitality = val;
	}
	private uint StatPoints;
	@property
	public uint getStatPoints() {
		return StatPoints;
	}
	public void setStatPoints(uint val) {
		StatPoints = val;
	}
	private uint curStam;
	@property
	public uint getCurStam() {
		return curStam;
	}
	public void setCurStam(uint val) {
		curStam = val;
	}
	private uint baseMinAttack;
	@property
	public uint getBaseMinAttack() {
		return baseMinAttack;
	}
	public void setBaseMinAttack(uint val) {
		baseMinAttack = val;
	}
	private uint baseMaxAttack;
	@property
	public uint getBaseMaxAttack() {
		return baseMaxAttack;
	}
	public void setBaseMaxAttack(uint val) {
		baseMaxAttack = val;
	}
	private uint baseMagicAttack;
	@property
	public uint getBaseMagicAttack() {
		return baseMagicAttack;
	}
	public void setBaseMagicAttack(uint val) {
		baseMagicAttack = val;
	}
	private uint curMinAttack;
	@property
	public uint getCurMinAttack() {
		return curMinAttack;
	}
	public void setCurMinAttack(uint val) {
		curMinAttack = val;
	}
	private uint curMaxAttack;
	@property
	public uint getCurMaxAttack() {
		return curMaxAttack;
	}
	public void setCurMaxAttack(uint val) {
		curMaxAttack = val;
	}
	private uint curMagicAttack;
	@property
	public uint getCurMagicAttack() {
		return curMagicAttack;
	}
	public void setCurMagicAttack(uint val) {
		curMagicAttack = val;
	}
	private uint Defense;
	@property
	public uint getDefense() {
		return Defense;
	}
	public void setDefense(uint val) {
		Defense = val;
	}
	private uint MagicDefense;
	@property
	public uint getMDefense() {
		return MagicDefense;
	}
	public void setMDefense(uint val) {
		MagicDefense = val;
	}
	private double attackMultipler;
	@property
	public double getAttackMultiplier() {
		return attackMultipler;
	}
	public void setAttackMultipler(double val) {
		attackMultipler = val;
	}
	private double defenseMultipler;
	@property
	public double getDefenseMultipler() {
		return defenseMultipler;
	}
	public void setDefenseMultipler(double val) {
		defenseMultipler = val;
	}
	private double blessMultipler;
	@property
	public double getBlessMultipler() {
		return blessMultipler;
	}
	public void setBlessMultipler(uint val) {
		blessMultipler = val;
	}
	
}