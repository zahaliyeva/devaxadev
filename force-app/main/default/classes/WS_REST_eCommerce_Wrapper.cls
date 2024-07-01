global with sharing class WS_REST_eCommerce_Wrapper {

	global String FirstName;
    global String LastName;
    global String Company;
    global String Phone;
    global String Email;
    global String PostalCode;
    global Boolean StateCodeFraud;
    global String Notes;
    global String CountryCode;
    global String StateCode;
    global String City;
    global String Street;
    global Date BirthDate;
    global String FiscalCode;
    global String VATNumber;
    global String Gender;
    global Boolean AlreadyCustomer;
    global String BirthCity;
    global String BirthStateCode;
    global String NDG;
    global Portals Portals;
    global Quotations Quotations;
    global Consensus Consensus;

    global with sharing class Portals {
    	global String AXACompany;
	    global String LeadSource;
	    global String LeadStepStatus;
	    global String AgreementCode;
	    global String AgencyCampaign;
	    global String AgencyCode;
	    global String SubAgencyCode;
	    global String SessionId;
	    global String LandingPage;
	    global Boolean isEcommerce;
	    global String ProductName;
	    global String ASA;
	    global String SubASA;
	    global String OriginUrl;
	    global String Source;
    }

    global with sharing class Quotations {
    	global Datetime QuotationTimestamp;
		global Date QuotationDate;
		global String QuickQuoteCode;
		global String QuoteCode;
		global String ProposalCode;
		global String PolicyCode;
		global GoodFactors[] GoodFactors;
		global Decimal Premium;
		global Decimal DiscountedPremium;
		global Warranties[] Warranties;
		global String Fractionation;
		global Date PriceQuotationDueDate;
		global Date PriceProposalDueDate;
		global Date PricePolicyDueDate;
		global String PaymentResult;
        global String Recoverability;
        global String LicensePlate;
        global Date PurchasableFromDate;
    }

    global with sharing class Consensus {
    	global String CommercialActivityConsensus;
		global String MarketResearchConsensus;
		global String PartnerActivityConsensus;
		global String DigitalDocumentationConsensus;
		global Boolean LeadConsensus;
    }

    global with sharing class GoodFactors {
    	global String Name;
    	global String Value;
    }

    global with sharing class Warranties {
    	global String Name;
		global String Limits;
		global String Exemption;
		global Decimal InsuredQuantity;
		global Decimal Price;
		global Decimal OriginalPrice;

    }

    global with sharing class Response {

        global String UserId;
        global String LeadId;
        global String StatusCode;
        global String StatusMessage;
        global Datetime Timestamp;

    }

    global with sharing class DeduplicateObject {

        global Response response;
        global List<Lead> leads;

    }

}