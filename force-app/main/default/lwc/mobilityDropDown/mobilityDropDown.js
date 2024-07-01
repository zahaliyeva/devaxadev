/* eslint-disable @lwc/lwc/no-async-operation */
import {
    MobilityAbstract
} from 'c/mobilityAbstract';
import {
    api,
    track
} from 'lwc';

export default class MobilityDropDown extends MobilityAbstract {
    @api icon;
    @api label;
    @api selectCallback
    @api values = [];

    @track showContain = false;

    toggle() {
        this.showContain = !this.showContain;
    }

    toggleOut() {
        setTimeout(() => {
            this.showContain = false;
        }, 3000);
    }

    get dropDownClass() {
        let classes = ['dropdown-menu'];
        if (this.showContain) classes.push('show');

        return classes.join(' ');
    }

    onClick(e) {
        let value = e.currentTarget.dataset.value;
        if (this.selectCallback) this.selectCallback(value);
    }
}