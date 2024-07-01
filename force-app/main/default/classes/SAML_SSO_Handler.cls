/*
**********************************************************************************************
----------------------------------------------------------------------------------------------
-- - Name          : SAML_SSO_Handler
-- - Author        : Marco Moscatelli
-- - Description   : Class used to provide logic for inbound just-in-time provisioning of 
-- -                 single sign-on users in Salesforce
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ---------------------------------------------------------------------
-- 20-11-2017   1.0     
----------------------------------------------------------------------------------------------
**********************************************************************************************
*/
global class SAML_SSO_Handler implements Auth.SamlJitHandler
{
    private class JitException extends Exception{}

    //The method retrieves all the attributes contained in the SAML assertion that refer to the User visibility and
    //updates the user accordingly 
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) 
    {

        String AOL_profile = '';
        String VOL_profile  = '';
        String REOL_profile  = '';
        String CIF_profile  = '';
        String node ='';
        String UserCurrentSetupStr = '';
        String currentNode = '';
        String UserCurrentNode='';
        Boolean ModifiedVOL = false;
        Boolean ModifiedAOL = false;
        Boolean ModifiedREOL = false;
        Boolean ModifiedCIF = false;

        String decodedAssertion = EncodingUtil.base64Decode(assertion).toString();
        System.Debug(JSON.serialize(decodedAssertion));

        Dom.Document doc = new Dom.Document();
        doc.load(decodedAssertion);

        for (Dom.XMLNode attributeNode : doc.getRootElement()
                             .getChildElement('Assertion', 'urn:oasis:names:tc:SAML:2.0:assertion')
                             .getChildElement('AttributeStatement', 'urn:oasis:names:tc:SAML:2.0:assertion').getChildElements())
        {
            system.debug('##Attribute: '+attributeNode.getAttribute('Name', ''));

            for (Dom.XMLNode attributeValueNode : attributeNode.getChildElements())
            {
                if(attributeNode.getAttribute('Name', '') =='AOL_profile')               
                    AOL_profile = attributeValueNode.getText();
                
                else if(attributeNode.getAttribute('Name', '') =='VOL_profile')
                    VOL_profile = attributeValueNode.getText();                 
                
                else if(attributeNode.getAttribute('Name', '') =='REOL_profile')
                    REOL_profile = attributeValueNode.getText(); 

                else if(attributeNode.getAttribute('Name', '') =='CIF_profile')
                    CIF_profile = attributeValueNode.getText();

                 else if(attributeNode.getAttribute('Name', '') =='node')
                    node = attributeValueNode.getText();
             }                    
        }
       
        system.debug('##AOL_profile: '+AOL_profile);
        system.debug('##VOL_profile: '+VOL_profile);
        system.debug('##REOL_profile: '+REOL_profile);
        system.debug('##CIF_profile: '+CIF_profile);
        system.debug('##NODE: '+node);

        for(String s : AOL_profile.split('\\^'))
        {
            if(s.startsWith(node))
            {
                AOL_profile = 'AOL_profile='+s;
                ModifiedAOL = true;
            }
        }

        for(String s : VOL_profile.split('\\^'))
        {
            if(s.startsWith(node))
            {
                VOL_profile = 'VOL_profile='+s;
                ModifiedVOL = true;
            }
        }

        for(String s : REOL_profile.split('\\^'))
        {
            if(s.startsWith(node))
            {
                REOL_profile = 'REOL_profile='+s;
                ModifiedREOL = true;
            }
        }

        for(String s : CIF_profile.split('\\^'))
        {
            if(s.startsWith(node))
            {
                CIF_profile = 'CIF_profile='+s;
                ModifiedCIF = true;
            }
        }

        AOL_profile     = (ModifiedAOL)?AOL_profile:'AOL_profile=';
        VOL_profile     = (ModifiedVOL)?VOL_profile:'VOL_profile=';
        REOL_profile    = (ModifiedREOL)?REOL_profile:'REOL_profile=';
        CIF_profile     = (ModifiedCIF)?CIF_profile:'CIF_profile=';

        UserCurrentSetupStr = ''+AOL_profile + '&' + VOL_profile + '&' + REOL_profile + '&' +CIF_profile;

        system.debug('##UserCurrentSetupStr: '+UserCurrentSetupStr);


        currentNode = ''+ padSingleNode(node);       

        if (currentNode.length()==12) 
        {
            UserCurrentNode = currentNode;
        }
        else
            UserCurrentNode='';

        system.debug('##UserCurrentNode: '+UserCurrentNode);

        u.UserCurrentSetup__c=UserCurrentSetupStr;
        u.UserCurrentNode__c=UserCurrentNode;

        update u;
    }

    public string padSingleNode(string singleNode) {
        if (singleNode.length()>12) {
            return ''; //something went wrong, the node should not be longer than 12 characters
        } else if (singleNode.length()>6) {//this should be the case of a sub node 5(subnode) + AgencyNode (4?)
            string subnode = '0'+singleNode.right(5);
            string AgencyNode = singleNode.removeEnd(singleNode.right(5));
            while (AgencyNode.length()<6) {
                AgencyNode='0'+AgencyNode;
            }
            system.debug('++++++++++subnode'+subnode);
            system.debug('++++++++++AgencyNode'+AgencyNode);
            return AgencyNode+subnode;
            
        } else {//should be an agency node
            while (singleNode.length()<6) {
                singleNode='0'+singleNode;
            }
            system.debug('+++++inputNodePadded'+singleNode);
            return singleNode;
        }
    } 

    //If a user having a federationIdentifier equal to the one provided by the IDP doesn't exist, the SSO is not executed
    //but the creation of a new User is avoided
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {

        system.debug('##No user correponds to the provided federationIdentifier');
        throw new JitException('No user');

        return null;
    }

    //If a user having a federationIdentifier equal to the one provided by the IDP exists, the SSO the handler automatically
    //invokes the updateUser method
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        system.debug('##Entered in updateuser');
        User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];

        handleJit(false, u, samlSsoProviderId, communityId, portalId,federationIdentifier, attributes, assertion);
    }
}