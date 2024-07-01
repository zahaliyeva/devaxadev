@isTest
private class TreeGridController_Test {
 
    static testMethod void testFindHierarchyData() {

        Knowledge__kav granParent = new Knowledge__kav(Title='test granParent', UrlName='testarticleurl1', Summary = 'test from apex' );
        insert granParent;
        Knowledge__kav parent = new Knowledge__kav(Parent_Article__c = granParent.Id ,Title='test granParent', UrlName='testarticleurl2', Summary = 'test from apex' );
        insert parent;
        Knowledge__kav child = new Knowledge__kav(Parent_Article__c = parent.Id ,Title='test granParent', UrlName='testarticleurl3', Summary = 'test from apex' );
        insert child;



        String recId  = child.Id;
        String parentFieldAPIName ='Parent_Article__c';
        String objectAPIname= 'Knowledge__kav';
        List<String> columnLabelList = new List<String>  {'Titolo articolo','Riepilogo','Numero articolo','Data pubblicazione','Stato pubblicazione'};
        List<String> fieldAPINameList = new List<String> {'Title','Summary','ArticleNumber','FirstPublishedDate','PublishStatus' };
        String hyperlinkColumn= 'Title';
        String order= 'LastPublishedDate DESC';
       
        TreeGridController.findHierarchyData(recId,parentFieldAPIName, objectAPIname,columnLabelList, fieldAPINameList,hyperlinkColumn,order);
    }
}