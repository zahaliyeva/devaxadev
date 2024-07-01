public class GaranzieError {
	public String code;
	public String developerMessage;

	public static GaranzieError  parse(String json) {
		return (GaranzieError) System.JSON.deserialize(json, GaranzieError.class);
	}
    
}