public without sharing class WhatsappBotUtils {
    public class CurrentDayTypeOutput{

        @InvocableVariable
        public Boolean  isBusinessDayWithinBusinessHours;
        @InvocableVariable
        public String  firstMessage;

        public CurrentDayTypeOutput( Boolean isBusinessDayWithinBusinessHours, String firstMessage ) {
            this.isBusinessDayWithinBusinessHours  = isBusinessDayWithinBusinessHours ;
            this.firstMessage = firstMessage?.toLowerCase();

        }
 
    }

    

    @InvocableMethod(Label ='Get Current Day Type' description='Define if today is Workday or Holiday')
    public static List<CurrentDayTypeOutput> getCurrentDayType(List<String> firstMessages)
    {
        List<CurrentDayTypeOutput> res = new List<CurrentDayTypeOutput>();
        List<BusinessHours> bhList  = [SELECT Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime FROM BusinessHours WHERE Name = 'Default' LIMIT 1];
        BusinessHours bh = bhList?.get(0);

        //BusinessHoursCalculator bhCalculator = new BusinessHoursCalculator(bh, System.now());

        for(String firstMessage : firstMessages) {

            CurrentDayTypeOutput cdto = new CurrentDayTypeOutput(
                BusinessHours.isWithin(bh.id, System.now()),
                firstMessage
            );

            res.add(cdto);
        }

        return  res;
    }

}