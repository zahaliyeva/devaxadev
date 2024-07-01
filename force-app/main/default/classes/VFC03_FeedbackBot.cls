public  without sharing class VFC03_FeedbackBot {
   
    //*-+ 2022 feedback chatbot 
    public String chatDetails {get;set;}
    public String transcript {get;set;}
    public String attachedRecords {get;set;}
    public String chatKey {get;set;}
    public Boolean showFeedback {get;set;}
    public Boolean showComment {get;set;}
    public Boolean showInfoEnd {get;set;}
    public Boolean showInfoEndFeedback {get;set;}
    public Boolean showError {get;set;}
    public Boolean showErrorGenerale {get;set;}
    public String feedbackRisposta {get;set;}
    public String caseFeedbakRelated {get;set;}
    
    public String NPS {get;set;}

    private String textdata = null;
    public String getTextData() { return textdata; }
    public void setTextData(String data) { textdata = data; }

    public VFC03_FeedbackBot() {
        try {
            showComment = false;
            showInfoEnd = true;
            showError = false;
            showInfoEndFeedback = false;
            showErrorGenerale = false;
            feedbackRisposta = 'Risposta inizial - 0';

            //*-+ 2022 feedback chatbot 
            chatDetails = ApexPages.currentPage().getParameters().get('chatDetails');
            attachedRecords = ApexPages.currentPage().getParameters().get('attachedRecords');
            transcript = ApexPages.currentPage().getParameters().get('transcript');
            chatKey = ApexPages.currentPage().getParameters().get('chatKey');

            Map < String, Object > chatDetailsMapa = (Map < String, Object > ) JSON.deserializeUntyped(chatDetails);
            Map < String, Object > attachedRecordsmapa = (Map < String, Object > ) JSON.deserializeUntyped(attachedRecords);
            //if transfer equsl 0 is chatbot agent , diferent 0 is been transfer at least one time -> show feedback
            showFeedback = isTransferAgentNonBot(chatDetailsMapa);
            if (showFeedback) {
                caseFeedbakRelated = getCaseIdRelated(attachedRecordsmapa, chatKey);
                showInfoEnd = false;
            }
        } catch (Exception err) {
            System.debug(err.getStackTraceString());
            this.showComment = false;
            this.showError = false;
            this.showInfoEnd = false;
            this.showErrorGenerale = true;
        }
    }
    // *-+ 2022 feedback chatbot
    public String getFileContents() {
        String chatFormatTxt, ChatTempTxt;
        try {
            ChatTempTxt = this.transcript != null ? this.transcript : '*chat vuoto*';
            chatFormatTxt = getTranscriptFormat(ChatTempTxt);
        } catch (Exception err) {
            System.debug(err.getStackTraceString());
            chatFormatTxt = 'Si � verificato un problema. Riprova pi� tardi.';
        }
        return EncodingUtil.base64Encode(Blob.valueOf(chatFormatTxt));
    }
    public Boolean isTransferAgentNonBot(Map < String, Object > chatDetailsMapa) {

        String[] lista = String.valueof(chatDetailsMapa.get('agent')).split(',');
        for (String temp: lista)
            if (temp.containsIgnoreCase('transfer') && temp.split('=')[1] != null)
                if (!temp.split('=')[1].equalsIgnoreCase('0'))
                    return true;
        return false;
    }
    public PageReference vota() {
        try {
            if (Integer.valueof(this.NPS) >= 6) {
                this.feedbackRisposta = 'Ci fa piacere che tu abbia apprezzato il nostro supporto. Se vuoi, puoi lasciarci un commento per raccontarci cosa hai apprezzato';
                this.showComment = true;
            } else {
                this.feedbackRisposta = 'Ci dispiace che tu non abbia apprezzato il nostro supporto. Lasciaci pure un commento per aiutarci a capire dove possiamo migliorare';
                this.showComment = true;
            }
            this.showFeedback = false;

        } catch (Exception err) {
            System.debug(err.getStackTraceString());
            this.showComment = false;
            this.showError = false;
            this.showInfoEnd = false;
            this.showErrorGenerale = true;
        }

        PageReference currentPage = ApexPages.currentPage();
        currentPage.getParameters().put('chatKey', this.chatKey);

        return currentPage;
    }
    public PageReference commenta() {

        try {

            if (this.textdata != null && String.isNotBlank(this.textdata) || Integer.valueof(this.NPS) >= 6) {
                this.showComment = false;
                this.showError = false;
                this.showInfoEnd = false;
                this.showInfoEndFeedback = true;

                Id recordTypeId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByName().get(AP_Constants.rtChatSurveyFeedback).getRecordTypeId();

                Feedback__c feedback = new Feedback__c(Survey_Origin__c = 'Chat',
                    RecordTypeId = recordTypeId,
                    FeedbackComments__c = this.textdata,
                    Complaint__c = this.caseFeedbakRelated,
                    NPS__c = Integer.valueof(this.NPS));

                feedback.Rating1__c = Integer.valueof(this.NPS);
                feedback.Rating2__c = Integer.valueof(this.NPS);
                feedback.Rating3__c = Integer.valueof(this.NPS);
                feedback.Rating4__c = Integer.valueof(this.NPS);

                insert feedback;
            } else
                this.showError = true;

        } catch (Exception err) {
            System.debug(err.getStackTraceString());
            this.showComment = false;
            this.showError = false;
            this.showInfoEnd = false;
            this.showErrorGenerale = true;
        }
        return null;
    }
    public String getCaseIdRelated(Map < String, Object > attachedRecords, String chatkey) {
        List < LiveChatTranscript > chatRelatedToCase = new List < LiveChatTranscript > ();
        String response = '';
        try {
            if (!attachedRecords.containsKey('CaseId'))
                chatRelatedToCase = [select CaseId from LiveChatTranscript where chatKey =: chatKey];

            response = chatRelatedToCase.size() != 0 ? chatRelatedToCase[0].CaseId : String.valueOf(attachedRecords.get('CaseId'));

        } catch (Exception err) {
            response = 'Si � verificato un problema. Riprova pi� tardi.';
        }
        return response;
    }
    public String getTranscriptFormat(String transcript) {
        String response = '';
        try {
            response = transcript.replace('[object Object]', 'Selezionando...');
            response = response.replace('): ', '):\n');
        } catch (Exception err) {
            response = 'Si � verificato un problema. Riprova pi� tardi.';
        }
        return response;
    }
}