@isTest
public with sharing class TelephoneWithPrefixAdapterTest {
    
    @TestSetup
    static void makeData(){
        TelephoneNumberPrefix__c pfx1 = new TelephoneNumberPrefix__c(Name = '0039');
        TelephoneNumberPrefix__c pfx2 = new TelephoneNumberPrefix__c(Name = '+39');
        insert new List<TelephoneNumberPrefix__c>{pfx1, pfx2};
    }

    @isTest
    public static void test_conversion() {
        TelephoneWithPrefixAdapter adapter1 = new TelephoneWithPrefixAdapter('Num1', '+393433938374');
        adapter1.addTelephoneNumber('Num2', '3354345675');

        TelephoneWithPrefix tel1 = adapter1.getTelephoneWithPrefix('Num1');

        System.assertEquals('+39', tel1.prefix);
        System.assertEquals('3433938374', tel1.telephoneNumber);

        TelephoneWithPrefix tel2 = adapter1.getTelephoneWithPrefixByKeys().get('Num2');

        System.assert(String.isBlank(tel2.prefix));
        System.assertEquals('3354345675', tel2.telephoneNumber);
    }

    @isTest
    public static void test_conversion_2() {
        Map<String, String> nums1 = new Map<String, String>{'Num1' => '+393433938374', 'Num2' => '3354345675'};
        Map<String, String> nums2 = new Map<String, String>{'Num3' => '+393433934567', 'Num4' => '00397267653746'};
        TelephoneWithPrefixAdapter adapter1 = new TelephoneWithPrefixAdapter(nums1);
        adapter1.addTelephoneNumber(nums2);

        TelephoneWithPrefix tel3 = adapter1.getTelephoneWithPrefix('Num3');
        TelephoneWithPrefix tel4 = adapter1.getTelephoneWithPrefix('Num4');

        System.assertEquals('0039', tel4.prefix);
        System.assertEquals('7267653746', tel4.telephoneNumber);

        Map<String, TelephoneWithPrefix> allTel = adapter1.getTelephoneWithPrefixByKeys();

        TelephoneWithPrefixAdapter adapter2 = new TelephoneWithPrefixAdapter('Num3', tel3);
        adapter2.addTelephoneWithPrefix('Num4', tel4);

        System.assertEquals('+393433934567', adapter2.getTelephoneNumberByKeys().get('Num3'));
        System.assertEquals('00397267653746', adapter2.getTelephoneNumber('Num4')); 

        TelephoneWithPrefixAdapter adapter3 = new TelephoneWithPrefixAdapter(allTel);

        adapter3.addTelephoneWithPrefix(allTel);

        System.assertEquals(4,adapter3.getTelephoneNumberByKeys().size() );
    }

    @isTest
    public static void test_equals() {
        Map<String, String> nums1 = new Map<String, String>{'Num1' => '+393433938374', 'Num2' => '3354345675'};
        Map<String, String> nums2 = new Map<String, String>{'Num3' => '+393433938374', 'Num4' => '00397267653746'};
        
        Map<String, TelephoneWithPrefix> tel1 = new TelephoneWithPrefixAdapter(nums1).getTelephoneWithPrefixByKeys();
        Map<String, TelephoneWithPrefix> tel2 = new TelephoneWithPrefixAdapter(nums2).getTelephoneWithPrefixByKeys();

        System.assert(tel1.get('Num1') == tel2.get('Num3'));
        System.assert(tel1.get('Num2') != tel2.get('Num4'));
    }
}