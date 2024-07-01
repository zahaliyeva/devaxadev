import { publish, MessageContext, createMessageContext } from 'lightning/messageService';
import operator from '@salesforce/messageChannel/Count_Updated__c';

export class MessageService {

    static messageContext = createMessageContext();

    static setSelection(Type, record){

        var payload = {
            Action: 'set',
            Type: Type,
            record: record
        }

        MessageService.publishMessage(payload);

    }

    static openDashboard(dashboardId, currentPageId){
        var payload = {
            Action: 'openDash',
            recordId: dashboardId,
            pageId: currentPageId
        }

        MessageService.publishMessage(payload);
    }

    static publishMessage(payload){
        publish(MessageService.messageContext, operator, payload);
    }

    static openPage(pageName, hasDash){
        var payload = {
            Action: 'pageOpening',
            hasDash: hasDash
        };
        MessageService.publishMessage(payload);
    }

}