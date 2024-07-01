import { MobilityAbstract } from 'c/mobilityAbstract';

export default class MobilityWidgetDashboard extends MobilityAbstract {
    componentView = 'MobilityWidgetDashboard';

    connectedCallback() {
        super.connectedCallback();
    }

    refreshCallback(){
        //OVERRIDE
        console.log('refresh', this.componentView);
    }
}