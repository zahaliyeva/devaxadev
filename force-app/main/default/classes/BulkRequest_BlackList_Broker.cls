/*------------------------------------------------------------------------
Author:        Nicolò Torreggiani
Company:       Deloitte
Class:         BulkRequest_BlackList_Broker 
Description:   Class that updates accounts with the latest blacklist broker options
History

20/11/2018     Created - N.T.

----------------------------------------------------------------------------*/

public class BulkRequest_BlackList_Broker implements BulkRequestHandler{ 

    //These are the attributes to be used for the update START
    public boolean broker {get;set;}
    //These are the attributes to be used for the update END
    
    public List<String> process(List<Sobject> scope){
        List<String> errors = new List<String>();
            System.debug('processing scope');
            
            //Expecting Account instance
            List<Account> accToUpdate = (List<Account>)scope;
    
            Map<Id,List<String>> accountToNodesCodesMap = new Map<Id,List<String>>();
            for (Account acc : accToUpdate){
                if (acc.Nodes__c!= null && acc.Nodes__c != ''){   
                    List <String> tempNodesList = acc.Nodes__c.split(';');
                    accountToNodesCodesMap.put(acc.Id,tempNodesList);
                }   
            }
    
            for (Account a : accToUpdate) {
                System.debug(' ===> broker: ' + broker);
                System.debug(' ===> accountToNodesCodesMap.get(a.Id): ' + accountToNodesCodesMap.get(a.Id));
                System.debug(' ===> accountToNodesCodesMap.get(a.Id).size(): ' + accountToNodesCodesMap.get(a.Id).size());
                if(broker){
                    a.BlackList_Broker__c = broker;
                } else {
                    if(accountToNodesCodesMap.get(a.Id).size() <= 2){
                        a.BlackList_Broker__c = broker;
                    }
                }
            }
            
            system.debug('++++ updating');
            List<Database.SaveResult> saveResult = Database.update(accToUpdate, false);
            return BulkRequestManager.getErrors(saveResult, accToUpdate, errors);
            
        }  
    

    
    }