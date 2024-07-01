/** 
* @description mobilityDashboardPaginationController class
*/
public without sharing class mobilityDashboardPaginationController {
    
    /** 
    * @description mobilityDashboardPaginationController.configuration class
    */
    public class configuration{
        /** 
         * @description mobilityDashboardPaginationController.configuration.Title field 
         */
        @AuraEnabled
        public string Title;
        /** 
         * @description mobilityDashboardPaginationController.configuration.Description field 
         */
        @AuraEnabled
        public string Description;
        /** 
         * @description mobilityDashboardPaginationController.configuration.actions field 
         */
        @AuraEnabled
        public List<actionWrapper> actions;
        /** 
         * @description mobilityDashboardPaginationController.configuration.SubTitle field 
         */
        @AuraEnabled
        public string SubTitle;
    }


    /** 
    * @description mobilityDashboardPaginationController.actionWrapper class
    */
    public class actionWrapper{
        /** 
         * @description mobilityDashboardPaginationController.actionWrapper.Label field 
         */
        @AuraEnabled
        public string Label;
        /** 
         * @description mobilityDashboardPaginationController.actionWrapper.Type field 
         */
        @AuraEnabled
        public string Type;
        /** 
         * @description mobilityDashboardPaginationController.actionWrapper.Value field 
         */
        @AuraEnabled
        public string Value;


        /** 
         * @description mobilityDashboardPaginationController.actionWrapper controller
         * @param Label
         * @param Type
         * @param Value
         */
        public actionWrapper(string Label, string Type, string Value){

            this.Label = Label;
            this.Type = Type;
            this.Value = Value;
        }
    }

    /** 
     * @description getConfiguration method
     * @param cardType
     * @return 'mobilityDashboardPaginationController.configuration'
     */
    @AuraEnabled
    public static configuration getConfiguration(String cardType){
        
        List<MobilityCardsPaginationSetting__mdt> config = [Select 
            Type__c, Title__c, SubTitle__c, Description__c, Actions_Label__c, 
            Actions_Type__c, Actions_Value__c 
            from MobilityCardsPaginationSetting__mdt where Type__c =: cardType];
        configuration toRet = new configuration();
        if(!config.isEmpty()){
            MobilityCardsPaginationSetting__mdt conf = config.get(0);
            toRet.Title = conf.Title__c;
            toRet.Description = conf.Description__c;
            toRet.SubTitle = conf.SubTitle__c;
            List<String> labels = conf.Actions_Label__c.split(';');
            List<String> types = conf.Actions_Type__c.split(';');
            List<String> values = conf.Actions_Value__c.split(';');
            
            toRet.actions = new List<actionWrapper>();

            for(integer i = 0; i < labels.size(); i++){
                actionWrapper temp = new actionWrapper(labels.get(i), types.get(i), values.get(i));

                toRet.actions.add(temp);
            }
        }
        
        return toRet;

    }

    /** 
     * @description getPagination method
     * @param page
     * @param perPage
     * @param total
     * @return 'SObjectTable.TablePagination'
     */
    @AuraEnabled 
	public static SObjectTable.TablePagination getPagination(Integer page, Integer perPage, Integer total ) {
        //SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
        SObjectTable.TablePagination tableElement = new SObjectTable.TablePagination();
        tableElement.cachedMode = true;
        tableElement.lengthList = 2;
        tableElement.page = page;
        tableElement.perPage = perPage;

        tableElement.total = total;


        tableElement.prevPage = page - 1;
        if (tableElement.prevPage < 0) tableElement.prevPage = -1;

        tableElement.hasPrevPage = (page > 0);

        tableElement.maxPage = Integer.valueOf((total - 1) / tableElement.perPage);

        if (tableElement.prevPage > tableElement.maxPage) tableElement.prevPage = tableElement.maxPage;

        tableElement.nextPage = page + 1;
        if (tableElement.nextPage > tableElement.maxPage) tableElement.nextPage = -1;

        tableElement.hasNextPage = page < tableElement.maxPage;

        tableElement.startPage = page * tableElement.perPage;
        tableElement.endPage = tableElement.startPage + tableElement.perPage;

        tableElement.prevPages = new List < Integer > ();
        Integer prevPagesMax = page - 2;
        if (prevPagesMax < 0) prevPagesMax = 0;
        for (Integer i = prevPagesMax; i <= page - 1; i++) tableElement.prevPages.add(i);

        tableElement.nextPages = new List < Integer > ();
        Integer nextPagesMax = page + 2;
        if (nextPagesMax > tableElement.maxPage) nextPagesMax = tableElement.maxPage;
        for (Integer i = page + 1; i <= nextPagesMax; i++) tableElement.nextPages.add(i);

        
        return tableElement;
    }


}