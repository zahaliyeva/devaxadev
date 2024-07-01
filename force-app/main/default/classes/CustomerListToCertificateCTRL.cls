public class CustomerListToCertificateCTRL {
    
    public Boolean isInCommunity {get;set;}
    
    public CustomerListToCertificateCTRL(){
         Id siteId = Site.getSiteId(); // take a look at the apex class Site, you may find more useful method concerning site/community
        if (siteId != null) {
            isInCommunity = true;
        }
        isInCommunity = false;
    }
}