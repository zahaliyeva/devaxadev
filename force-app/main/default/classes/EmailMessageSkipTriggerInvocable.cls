public with sharing class EmailMessageSkipTriggerInvocable {
        public static Boolean skipTrigger;
        @InvocableMethod(Label = 'Disable Trigger on EmailMessage'description = 'for Disable trigger  Email Message running on flow or proc builder')
        public static void SetDisableTriggerOnEmailMessage (){
            EmailMessageSkipTriggerInvocable.skipTrigger = true;
            //ZA BUGFIX

        }
}