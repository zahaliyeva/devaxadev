<aura:application access="GLOBAL" extends="ltng:outApp">
  <aura:dependency resource="force:navigateToURL" type="EVENT"/>       
  <aura:dependency resource="c:agencyQueueManagerMainCmp"/>
    
    <!-- Include the SLDS static resource (adjust to match package version) -->
    <ltng:require styles="{!$Resource.LDS+'/assets/styles/salesforce-lightning-design-system.css'}"/>
 
    <!-- Add the "scoping" element to activate SLDS on components
         that we add inside it. -->
    <div class="slds">      
    
    </div>
    <!-- / SLDS SCOPING DIV -->
 
</aura:application>