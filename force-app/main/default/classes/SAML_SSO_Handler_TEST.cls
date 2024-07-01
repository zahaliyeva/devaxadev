/*
**********************************************************************************************
----------------------------------------------------------------------------------------------
-- - Name          : SAML_SSO_Handler_TEST
-- - Author        : Marco Moscatelli
-- - Description   : Test Class used to simulate the execution of an inbound single sign-on 
-- -                 access via SAML from Salesforce's users
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ---------------------------------------------------------------------
-- 20-11-2017   1.0     
----------------------------------------------------------------------------------------------
**********************************************************************************************
*/

@isTest
private class SAML_SSO_Handler_TEST
{  
    @testSetup
    private static void testSetup() {
        
        
        User userAdmin = new User(Username = 'testusrfake@testfake.com',
                                  LastName = 'testuser',
                                  LanguageLocaleKey = 'en_US',
                                  FirstName = 'test',
                                  Email = 'test@test.com',
                                  Alias = 'test',
                                  TimeZoneSidKey = 'Europe/Dublin',
                                  LocaleSidKey = 'en_US',
                                  EmailEncodingKey = 'UTF-8',
                                  ProfileId = AP_Constants.getProfileAdminId(),
                                  FederationIdentifier='testUsr'
                                 );
        
        insert userAdmin;
        
    }    
    
    @isTest
    private static void Update_User() 
    {
        User U = [Select Id from User where Username = 'testusrfake@testfake.com'];
        
        final Id userId = U.Id;
        final Id samlSsoProviderId = '0LE000000000000';
        final Id communityId = '0DB000000000000';
        final Id portalId = '0DB000000000000';
        final String federationIdentifier = 'testUsr';
        final Map<String, String> attributes = new Map<String, String> 
        {
            'CRM_profile' => 'GDIR;Direzione_AAI;AAI - Digital Avanzato;false^GDIR;Direzione_AAI;AAI - Digital Avanzato;true',
                'AOL_profile' => 'GDIR;_TA_AGE;_LA_AGE;false',
                'CIF_profile' => 'GDIR;_TC_DIR_FO;_LC_DIR_VISUAL;false',
                'REOL_profile' => 'GDIR;_T_ADMIN_BIZ;_L_ADMIN_BIZ;false',
                'VOL_profile' => 'R001;_T_DIREZIONE;_L_DIR_MONITORING;false^GDIR;_T_DIREZIONE;_L_DIR_BACKOFFICE;false',
                'node' => 'GDIR'
                };
                    
                    final string assertion = ''+
                    '<Response xmlns="urn:oasis:names:tc:SAML:2.0:protocol" Destination="https://axaitalia--devSAML.cs87.my.salesforce.com?so=00D8E000000Cn0p" ID="_283f19f17db5a14d51b6952a603362b2c26f" InResponseTo="_2CAAAAWCODvpwME8wOEUwMDAwMDA0Qzk1AAAA0ssNUWAT2CUoxs88px-T0kGxLD3ROTW21i0mkuVTid4L_P-NbufALD6PEdNMBv5fiNp-Y6Ak-yyApn793EbRqkjupZ2346044IGON79eK1NAbP6vGBFFl_usxrMEK9gcJHVPfvGEfVfjHdHDZ7L8zR6NpLHglhjregdBikr2zeH-3WawFI6O3w6l6wsmLUM9H9JrLTqFX-YSrOs92fY-X_YqEHUDnrU77gmQGbEWLFwX358SJHJaVkd2YpZNFp-AlQ" IssueInstant="2017-11-27T14:24:10Z" Version="2.0">'+
                    '<ns1:Issuer xmlns:ns1="urn:oasis:names:tc:SAML:2.0:assertion" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">https://fws-pp.axa.italia.it</ns1:Issuer>'+
                    ' <Status>'+
                    '<StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success" />'+
                    '</Status>'+
                    '<ns2:Assertion xmlns:ns2="urn:oasis:names:tc:SAML:2.0:assertion" ID="_5aa35ccef2d1edd10199bfe4571aba0f26fd" IssueInstant="2017-11-27T14:24:10Z" Version="2.0">'+
                    '<ns2:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">https://fws-pp.axa.italia.it</ns2:Issuer>'+
                    '<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">'+
                    '  <ds:SignedInfo>'+
                    '   <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />'+
                    '   <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />'+
                    '   <ds:Reference URI="#_5aa35ccef2d1edd10199bfe4571aba0f26fd">'+
                    '     <ds:Transforms>'+
                    '       <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />'+
                    '       <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />'+
                    '     </ds:Transforms>'+
                    '     <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />'+
                    '     <ds:DigestValue>sFcDTebh+VamiJM5k9gbN9ejaAA=</ds:DigestValue>'+
                    '   </ds:Reference>'+
                    '  </ds:SignedInfo>'+
                    '  <ds:SignatureValue>'+
                    '   bSg+DU4R0I8OKTFNXiTT1/kOA3Xvqx+HWZAlJ2epszgc3XYiKShZwNpg33YaJ72G1/QritEz64mw 6hBHJr6RWwzh6/ErGfL2xq7Ht2IX73yoP9CnMzggTmqjhsBtSUvl/5vCXbJFdwpTC0w5wzfGwl+l jJoGR+7Px92IOMp4MmPgIc/CNBTLD2k54BDYOGmP77NN+iOFrHhyxe+xXfHyycFu/RsVsPkEB6ji kZnJcK61mS4HfISgg+XsqKCKHAGX2XgVk2Dg0pqGMOfFUv0dzJVjkOULGbb/rf1gZHA8T6rAMNtG sYA9XmwBxZwEeK7Z7aUHct3kd2ow3/el5tXyBQ== </ds:SignatureValue>'+
                    '  <ds:KeyInfo>'+
                    '   <ds:X509Data>'+
                    '     <ds:X509Certificate> MIIDLDCCAhSgAwIBAgIEV1bHYjANBgkqhkiG9w0BAQUFADBYMQswCQYDVQQGEwJJVDELMAkGA1UE CBMCTUkxDzANBgNVBAcTBk1JTEFOTzEMMAoGA1UEChMDQVhBMQ8wDQYDVQQLDAZBWEFfSVQxDDAK BgNVBAMTA0FYQTAeFw0xNjA2MDcxMzA4NTBaFw0xODA2MDcxMzA4NTBaMFgxCzAJBgNVBAYTAklU MQswCQYDVQQIEwJNSTEPMA0GA1UEBxMGTUlMQU5PMQwwCgYDVQQKEwNBWEExDzANBgNVBAsMBkFY QV9JVDEMMAoGA1UEAxMDQVhBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnFRwcXR6 LL+MD6HwcoZ4/0X+t9V6Sa1s9hsVkuiqYW+PB6itYZBn/GzODJl0FO0KF4RJVywUyZ4e8jABMmQR mQWdfhkVwgy+YeYs75MmqedQwrsNZB37aZn1zHgkBGgOVgVyeKSCkNzN6HGQ15MNA7AA8hzRyqPN GXdUV2Gh8h7ctcjY7e/CJAAbS0ManEI86S5p9tmve4YYbJLYZwYPsfU/iqYQgvXbQytT81dpaKRL XXgM3+RBDL3VwOIS5YqxSo12D22ATvd0dCAac9261HO9a0pe3Gct3z/BRUm7zv3jLqHWXgqw8g31 jjgJtZ9/ZALLc7VAFYcrh3UfcZiOZwIDAQABMA0GCSqGSIb3DQEBBQUAA4IBAQBSHOgIuaquFpww Kzx+ODATQtGErOqT/qY5nVhQlNYJ01YCX9by60ztgtm9LF2Gngsc8Sua3cfSU4pDJoPLT6nd2qZ6 ToBeZf6s9nj74W8rap14p/In0ABVhrW1lWlopaBu95bV31sVLur+oWh6i5bBMnuQg2sWweFCHzx9 SiGm2rLSfyhw7Y3Doxm2qPit1q2clxJqEUlN5X3UQoaUNvMqfA8XKi6khbvA00EcxBJ7bdAUO9kO ztQZ4NB0fxgCnxpc9ZKtUP4xTuvy9jymOaJ2pz0AvNyRNU6OylpRxMbn+UpJmKCQqZfA2xYE4VJ1 8Gsdimbu4NOvf7zK0mhhO8Ut </ds:X509Certificate>'+
                    '   </ds:X509Data>'+
                    '  </ds:KeyInfo>'+
                    '</ds:Signature>'+
                    '<ns2:Subject>'+
                    '  <ns2:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">testUsr</ns2:NameID>'+
                    '  <ns2:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">'+
                    '   <ns2:SubjectConfirmationData InResponseTo="_2CAAAAWCODvpwME8wOEUwMDAwMDA0Qzk1AAAA0ssNUWAT2CUoxs88px-T0kGxLD3ROTW21i0mkuVTid4L_P-NbufALD6PEdNMBv5fiNp-Y6Ak-yyApn793EbRqkjupZ2346044IGON79eK1NAbP6vGBFFl_usxrMEK9gcJHVPfvGEfVfjHdHDZ7L8zR6NpLHglhjregdBikr2zeH-3WawFI6O3w6l6wsmLUM9H9JrLTqFX-YSrOs92fY-X_YqEHUDnrU77gmQGbEWLFwX358SJHJaVkd2YpZNFp-AlQ" NotOnOrAfter="2017-11-27T14:25:40Z" Recipient="https://axaitalia--devSAML.cs87.my.salesforce.com?so=00D8E000000Cn0p" />'+
                    '  </ns2:SubjectConfirmation>'+
                    '</ns2:Subject>'+
                    '<ns2:Conditions NotBefore="2017-11-27T14:23:40Z" NotOnOrAfter="2017-11-27T14:25:40Z">'+
                    '  <ns2:AudienceRestriction>'+
                    '   <ns2:Audience>https://axaitalia--devsaml.cs87.my.salesforce.com</ns2:Audience>'+
                    '  </ns2:AudienceRestriction>'+
                    '  <ns2:AudienceRestriction>'+
                    '   <ns2:Audience>https://axaitalia--devSAML.cs87.my.salesforce.com</ns2:Audience>'+
                    '  </ns2:AudienceRestriction>'+
                    '</ns2:Conditions>'+
                    '<ns2:AuthnStatement AuthnInstant="2017-11-27T14:24:09Z" SessionIndex="z/XVAC2mdpHtsy+LafKzLwpZTA0=YEqVuA==" SessionNotOnOrAfter="2017-11-27T14:25:40Z">'+
                    '  <ns2:AuthnContext>'+
                    '   <ns2:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:Password</ns2:AuthnContextClassRef>'+
                    '  </ns2:AuthnContext>'+
                    '</ns2:AuthnStatement>'+
                    '<ns2:AttributeStatement>'+
                    '  <ns2:Attribute Name="userid_sf" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'+
                    '   <ns2:AttributeValue>badino_ma@axacrm.it.devsaml</ns2:AttributeValue>'+
                    ' </ns2:Attribute>'+
                    '  <ns2:Attribute Name="CRM_profile" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'+
                    '   <ns2:AttributeValue>GDIR;Direzione_AAI;AAI - Digital Avanzato;false^GDIR;Direzione_AAI;AAI - Digital Avanzato;true</ns2:AttributeValue>'+
                    '  </ns2:Attribute>'+
                    '  <ns2:Attribute Name="AOL_profile" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'+
                    '   <ns2:AttributeValue>GDIR;_TA_AGE;_LA_AGE;false</ns2:AttributeValue>'+
                    '  </ns2:Attribute>'+
                    '  <ns2:Attribute Name="CIF_profile" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'+
                    '   <ns2:AttributeValue>GDIR;_TC_DIR_FO;_LC_DIR_VISUAL;false</ns2:AttributeValue>'+
                    ' </ns2:Attribute>'+
                    '  <ns2:Attribute Name="REOL_profile" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'+
                    '   <ns2:AttributeValue>GDIR;_T_ADMIN_BIZ;_L_ADMIN_BIZ;false</ns2:AttributeValue>'+
                    '  </ns2:Attribute>'+
                    '  <ns2:Attribute Name="VOL_profile" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'+
                    '   <ns2:AttributeValue>R001;_T_DIREZIONE;_L_DIR_MONITORING;false^GDIR;_T_DIREZIONE;_L_DIR_BACKOFFICE;false</ns2:AttributeValue>'+
                    '  </ns2:Attribute>'+
                    '  <ns2:Attribute Name="logoutURL" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'+
                    '   <ns2:AttributeValue>https://precrm.axa-italia.it/logout.jsp</ns2:AttributeValue>'+
                    '  </ns2:Attribute>'+
                    '  <ns2:Attribute Name="node" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">'+
                    '   <ns2:AttributeValue>GDIR</ns2:AttributeValue>'+
                    '  </ns2:Attribute>'+
                    '</ns2:AttributeStatement>'+
                    '</ns2:Assertion>'+
                    '</Response>';
        
        final String assertion_1 = EncodingUtil.base64Encode(Blob.valueOf(assertion));
        Test.startTest();
        SAML_SSO_Handler handler = new SAML_SSO_Handler();
        handler.updateUser(userId,samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion_1);
        try{
            handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion_1);
        }
        catch(Exception e) {
            System.assertEquals('No user', e.getMessage());
        }
        Test.stopTest();
    }
}