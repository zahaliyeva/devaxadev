public with sharing class APIT00_EnviromentController {

	public String UrlParameterJSON {set;get;}

    public APIT00_EnviromentController() {
    	this.UrlParameterJSON = JSON.serialize(ApexPages.currentPage().getParameters());
    }
}