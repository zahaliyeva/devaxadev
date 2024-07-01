import { MobilityAbstract } from "c/mobilityAbstract";
import { api } from 'lwc';

export default class MobilityHeader extends MobilityAbstract {
    @api titlePar;

    get headerTitle() {
        if(!this.params && !this.titlePar) return '';
        let title;

        if (this.titlePar) {
            title = this.titlePar;
            return title;
        }

        title = this.params.title;

        if(!title) return '';

        return title;
    }

    get classString(){
        let classes = ["header-nav", "fixed-top"];

        if(this.params && this.params.showContain){
            classes.push('show-contain');
        }else{
            classes.push('show-simple');
        }

        return classes.join(' ');
    }

    close = () => {
        window.close();
        window.history.back();
    }
}