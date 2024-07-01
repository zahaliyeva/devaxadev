@isTest
public without sharing class WABot_CreateCase_TEST {
    
    @isTest
    public static void test_createCase() {
        List<MessagingChannel> channelList = [SELECT Id FROM MessagingChannel WHERE MessageType = 'Whatsapp'];
        if(channelList != null && channelList.size() > 0) {
            MessagingChannel channel = channelList.get(0);
            MessagingEndUser user = new MessagingEndUser(Name='WhatsAppTest', MessagingChannelId=channel.Id, MessageType='WhatsApp', MessagingPlatformKey='WhatsAppTest');
            insert user;
            MessagingSession session = new MessagingSession(MessagingEndUserId = user.Id, MessagingChannelId=channel.Id, Status='Waiting');
            insert session;

            WABot_CreateCase.CreateCaseInput input = new WABot_CreateCase.CreateCaseInput(session.Id, user.Id, 'Open', 'Contatto Whatsapp Preventivatore Auto Fuori Orario');

            List<WABot_CreateCase.CreateCaseOutput> output = WABot_CreateCase.createCase(new List<WABot_CreateCase.CreateCaseInput>{input});

            System.assertEquals(1, output.size());
            System.assert(String.isNotBlank(output[0].newCaseId));
        }

    }
}