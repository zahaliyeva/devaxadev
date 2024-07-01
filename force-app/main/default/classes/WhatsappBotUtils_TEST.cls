@isTest
public without sharing class WhatsappBotUtils_TEST {
    @isTest
    public static void test_getCurrentDayType() {
        List<WhatsappBotUtils.CurrentDayTypeOutput> res = WhatsappBotUtils.getCurrentDayType(new List<String>{'Prosegui'});

        System.assertEquals(1, res.size());
        System.assert(res[0].isBusinessDayWithinBusinessHours != null);
        System.assertEquals('prosegui', res[0].firstMessage);
    }
}