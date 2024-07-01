/** 
 * @author	Reply
 * @date	1/03/2023
 * @description Class controller del LWC mobilityCaseOrFeedbackList
 */
public with sharing class mobilityCaseOrFeedbackController extends MobilityAbstract {
    public mobilityCaseOrFeedbackController () {

    }
    /** 
    * @param	perPage Case condiviso per il recordId del LWC chiamante
    * @return	TablePagination del aggiornamento sul case andato OK 
    * @description Restituisce una tabella con i campi dichiarati nel fieldset sia dei case che feedback
    */
    @AuraEnabled(cacheable = true)
    public static SObjectTable.TablePagination getCase( Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
        
        SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
        strategy.fieldsSet = new Set < String > {
            'Id',
            'CaseNumber',
            'CreatedDate',
            'ClosedDate',
            'Owner.Name',
            'Owner.Profile.Name',
            'Origin',
            'LOB__c',
            'Category__c'
        };

        strategy.sobjectName = 'Case';

        strategy.searchColumns = new Set < String > {
            
            'CaseNumber',
            'CreatedDate',
            'ClosedDate',
            'Owner',
            'Origin',
            'LOB__c',
            'Category__c'
        };

        //setOrderDesc
        //setOrderAsc
        strategy.setOrderDesc('CreatedDate');

        //INPUT DATA
        strategy.perPage = perPage;
        strategy.searchString = search;
        strategy.setOrder(orderField, orderName, true);
        strategy.addFilters(filters, true);

        /**
         * Retrieve Current User
         */
       
        List<AAI_Code_Variables__c> Lista=[Select value__c from AAI_Code_Variables__c where Name='mobilityCaseListRT']; // NOPMD custom settings for RTs
        if(!Lista.isEmpty()){
            String values=lista.get(0).Value__c;
            if(String.isNotBlank(values)){
                Set<Object> listaSet= new Set<Object>();
                for(String s:values.split(';')){
                    ListaSet.add(s);
                }
                strategy.addFilter('RecordType.DeveloperName', ListaSet);
            }
            
        }
        //RESPONSE
        SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
        tableElement.columns = new List < String > {
            
            'CaseNumber',
            'CreatedDate',
            'ClosedDate',
            'Owner',
            'Origin',
            'LOB__c',
            'Category__c'
        };

        tableElement.labels = new Map < String, String > {
            
            'CaseNumber'=>'Numero Case',
            'CreatedDate'=>'Data apertura',
            'ClosedDate'=>'Data chiusura',
            'Owner'=>'Titolare Case',
            'Origin'=>'Origine',
            'LOB__c'=>'Area',
            'Category__c'=>'Categoria'
        };

        Debug('tableElement', tableElement);
        DebugEnd();
        return tableElement;
    }

    @AuraEnabled(cacheable = true)
    public static SObjectTable.TablePagination getFeedBacks( Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
        
        SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
        strategy.fieldsSet = new Set < String > {
            'Id',
            'Name',
            'Survey_Origin__c',
            'CreatedDate',
            'CTL_Case__r.Owner.Name',
            'CTL_Case__r.CaseNumber',
            'CTL_Case__r.Owner.Profile.Name'
            
        };

        strategy.sobjectName = 'Feedback__c';


        //setOrderDesc
        //setOrderAsc
        strategy.setOrderDesc('CreatedDate');
        

        //INPUT DATA
        strategy.perPage = perPage;
        strategy.searchString = search;
        strategy.setOrder(orderField, orderName, true);
        strategy.addFilters(filters, true);

    

        /**
         * Retrieve Current User
         */
        
        List<AAI_Code_Variables__c> Lista=[Select value__c from AAI_Code_Variables__c where Name='mobilityFeedbackListRT'];// NOPMD custom settings for RTs
        if(!Lista.isEmpty()){
            String values=lista.get(0).Value__c;
            if(String.isNotBlank(values)){
                Set<Object> listaSet= new Set<Object>();
                for(String s:values.split(';')){
                    ListaSet.add(s);
                }
                strategy.addFilter('RecordType.DeveloperName', ListaSet);
            }
            
        }

        //RESPONSE
        SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
        tableElement.columns = new List < String > {
            
            'Name',
            'Survey_Origin__c',
            'CreatedDate',
            'Id',
            'CTL_Case__r'
        };

        tableElement.labels = new Map < String, String > {
            'Name' => 'Numero Feedback',
            'Survey_Origin__c'=>'Canale',
            'CreatedDate' => 'Data creazione',
            'Id'=>'CTL Case',
            'CTL_Case__r'=> 'Titolare del case'
        };

        Debug('tableElement', tableElement);
        DebugEnd();
        return tableElement;
    }   
}