<!--
 - Created by Augens on 15/10/2018.
 -->
<aura:application description="CustomerHistoryAccountApp" access="GLOBAL" extends="ltng:outApp">
    <aura:dependency resource="force:navigateToURL" type="EVENT"/>       
    <!--aura:dependency resource="c:ContactHistoryAccountMainCmp"/-->
    <aura:dependency resource="c:ContactHistoryMainCmp"/>
    <!--c:ContactHistoryMainCmp /-->
    <!--ltng:require styles="{!$Resource.LDS+'/assets/styles/salesforce-lightning-design-system.css'}"/-->
    <!-- Add the "scoping" element to activate SLDS on components
         that we add inside it. -->
    <div class="slds">

    </div>
    <!-- / SLDS SCOPING DIV -->
</aura:application>