import { LightningElement, api, track } from 'lwc';

export default class MobilityCollapsibleFilterWidget extends LightningElement {
    /** @type {string[]} */
    @api options = [];
    @api label = '';
    @api allSelectedLabel = 'Tutti';
    @api noneSelectedLabel = '-';
    @api
    get value() { return this._value; };
    set value(v) { return this._value = Array.isArray(v) ? [...v] : []; };

    /** @type {string[]} */
    @track _value = [];
    @track showDropdown = false;
    @track _searchFilter = '';

    get selectedValuesText() {
        if (this._value.length === 0) {
            return this.noneSelectedLabel;
        }

        if (this._value.length === 1) {
            return this._value[0];
        }

        if (this._value.length < 4) {
            return this._value.join(", ");
        }

        if (this.isAllSelected) {
            return this.allSelectedLabel;
        }

        return `${this._value.length} Elementi`;
    }

    get isAllSelected() {
        return this._value.length === this.options.length
    }

    get optionsChecked() {
        const dataset = this._searchFilter
            ? this.options.filter(x => x.toLowerCase().indexOf(this._searchFilter) !== -1)
            : this.options;

        const result = dataset.slice(0, 200).map((id) => ({
            id,
            checked: this._value.indexOf(id) !== -1,
            disabled: false
        }));

        if (dataset.length > 200) {
            result.push({
                id: `Ci sono altri ${dataset.length - 200} elementi`,
                checked: false,
                disabled: true
            })
            result.push({
                id: `Usa la ricerca per raffinare il risultato`,
                checked: false,
                disabled: true
            })
        }

        return result;
    }

    /** @param {MouseEvent} event  */
    handleSearch(event) {
        /** @type {HTMLInputElement} */
        const target = event.currentTarget;

        this._searchFilter = target.value.toLowerCase();
    }

    /** @param {MouseEvent} event  */
    clearSearch(event) {
        event.preventDefault();
        event.stopPropagation();

        this._searchFilter = "";
    }
    
    /** @param {MouseEvent} event  */
    noop(event) {
        event.preventDefault();
        event.stopPropagation();
    }

    /** @param {MouseEvent} event  */
    openDropdown(event) {
        if (this.showDropdown) {
            this.closeDropdown(event);

            return;
        }
        
        this.showDropdown = true;
        event.preventDefault();
        event.stopPropagation();
        
        document.addEventListener('click', this.closeDropdown, { once: true })
    }
    
    /** @param {MouseEvent} event  */
    closeDropdown = (event) => {
        this.showDropdown = false;
        event.preventDefault();
        event.stopPropagation();
        document.removeEventListener(this.closeDropdown);
    }

    /** @param {MouseEvent} event  */
    toggleAll(event) {
        event.preventDefault();
        event.stopPropagation();

        if (!this.isAllSelected) {
            this._value = [...this.options];
        } else {
            this._value = [];
        }

        this.sendSelectedEvent();
    }

    /** @param {MouseEvent} event  */
    toggleItem(event) {
        event.preventDefault();
        event.stopPropagation();

        /** @type {HTMLDivElement} */
        const target = event.currentTarget;
        const id = target.dataset.id;
        const index = this._value.indexOf(id);
        if (index === -1) {
            this._value.push(id);
        } else {
            this._value.splice(index, 1);
        }

        this.sendSelectedEvent();
    }

    sendSelectedEvent() {
        const selectedEvent = new CustomEvent("selected", { detail: [...this._value] });
        this.dispatchEvent(selectedEvent);
    }
}