import {
    MobilityAbstract
} from 'c/mobilityAbstract';
import { api, track } from 'lwc';

import {
    MobilityPaginationModel
} from 'c/mobilityPaginationModel';

export default class MobilityPagination extends MobilityAbstract {
    /**
     * Classi CSS da utilizzare per logiche:
     * active - pagina corrente
     * disabled - bottone disabilitato
     */
    @track hasNextPage = false;
    @track hasPrevPage = false;
    @track _pagination = new MobilityPaginationModel();

    @api changePage;

    @api
    get pagination() {
        return this._pagination;
    }
    set pagination(value) {
        this._pagination = new MobilityPaginationModel(this.proxyData(value));
    }

    onNextPage(){
        if(this.changePage) this.changePage(this._pagination.page + 1);
    }

    onPrevPage(){
        if(this.changePage) this.changePage(this._pagination.page - 1);
    }

    onChangePage(e){
        if(this.changePage) this.changePage(e.currentTarget.dataset.page);
    }
}