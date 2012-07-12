module Co3mu.Currency;

public class c3Currency {
	private uint Money;
	private uint CPs;
	private uint VirtuePoints;
	@property
	public uint getMoney() {
		return Money;
	}
	public void setMoney(uint val) {
		Money = val;
	}
	@property
	public uint getCPs() {
		return CPs;
	}
	public void setCPs(uint val) {
		CPs = val;
	}
	@property
	public uint getVPs() {
		return VirtuePoints;
	}
	public void setVPs(uint val) {
		VirtuePoints = val;
	}
}