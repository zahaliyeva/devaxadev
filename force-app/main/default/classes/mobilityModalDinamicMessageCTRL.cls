/** 
* @description mobilityModalDinamicMessageCTRL class
*/
public with sharing class mobilityModalDinamicMessageCTRL {
    
    /** 
     * @description getLayoutDefinitionModal method
     * @param layoutName
     * @param  reportLink
     * @return 'MobilityCustomLayoutWrapper'
     */
    @AuraEnabled
    public static MobilityCustomLayoutWrapper getLayoutDefinitionModal(String layoutName,String reportLink) {
        List < MobilityCustomLayout.Section > sectionMDTList = MobilityCustomLayout.getConfig(layoutName, null, null, null);//Modal non ha bisogno d altro 
        MobilityCustomLayoutWrapper wrapper = new MobilityCustomLayoutWrapper();
        wrapper.sections = new  List<MobilityCustomLayoutWrapper.SectionItem> ();
        List<MobilityCustomLayoutWrapper.FieldItem> listFieldsBySection = new  List<MobilityCustomLayoutWrapper.FieldItem> ();

        for (MobilityCustomLayout.Section section: sectionMDTList) {

            for (CustomPageLayoutField__mdt item: section.fields) {
                MobilityCustomLayoutWrapper.FieldItem fieldTemp = new MobilityCustomLayoutWrapper.FieldItem();
                fieldTemp.labelName = item.FieldLabel__c;
                fieldTemp.redirectURL = item.BaseUrl__c;
                fieldTemp.type = item.APIName__c;
                listFieldsBySection.add(fieldTemp);
            }
            MobilityCustomLayoutWrapper.SectionItem sectionTemp = new MobilityCustomLayoutWrapper.SectionItem();
            sectionTemp.isUsingIcon = section.data.isUsingIcon__c;
            sectionTemp.Icon = section.data.Icon__c;
            sectionTemp.name = section.data.SectionName__c;
            sectionTemp.subName = section.data.SectionSubName__c;
            sectionTemp.underSubName = section.data.SectionUnderSubName__c;
            sectionTemp.isUsingLink = section.data.isUsingLink__c;
            sectionTemp.link = section.data.Link__c;
            sectionTemp.fields = new List<MobilityCustomLayoutWrapper.FieldItem>();
            sectionTemp.fields.addAll(listFieldsBySection);

            wrapper.sections.add(sectionTemp);
        }
        return wrapper;
    }

}