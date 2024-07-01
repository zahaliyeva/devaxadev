({
    doInit: function(component, event, helper) {    
        helper.manageAddress(component);   
        helper.manageBulletPrivacy(component);
        helper.manageBulletClienteDigitale(component);
        helper.manageBulletPreferenze(component);
    },

    showToolTipPrivacy : function(c, e, h) {
        c.set("v.tooltipPrivacy" , true);
        h.manageBulletPrivacy(c);
        
    },
    HideToolTipPrivacy : function(c,e,h){
        c.set("v.tooltipPrivacy" , false);
    },
    showToolTipPreferenze : function(c, e, h) {
        c.set("v.tooltipPreferenze" , true);
        h.manageBulletPreferenze(c);
        
    },
    HideToolTipPreferenze : function(c,e,h){
        c.set("v.tooltipPreferenze" , false);
    },

    showToolTipClienteDigitale : function(c, e, h) {
        c.set("v.tooltipClienteDigitale" , true);
        h.manageBulletClienteDigitale(c);
        
    },
    HideToolTipClienteDigitale : function(c,e,h){
        c.set("v.tooltipClienteDigitale" , false);
    }    
})