import {
    Model,
    ModelCollection
} from "c/mobilityAbstractModel";

export class MobilityPaginationCollection extends ModelCollection {
    _childType() {
        return MobilityPaginationModel;
    }
}

export class MobilityPaginationModel extends Model {

    _model() {
        return {
            cachedMode: false,
            maxRecords: -1,
            lengthList: [],
            // Precedente
            prevPage: 0, // Pulsante
            hasPrevPage: false, // Disattivata
            prevPages: [], // Elenco

            // Successivo
            nextPage: 0, // Pulsante
            hasNextPage: false, // Disattivato
            nextPages: [], // Elenco

            page: 0, // Pagina Corrente
            startPage: 0,
            endPage: 0,

            total: 0, // Record Totali
            maxPage: 0, // ultima Pagina
            perPage: 0, // record per pagina
            elements: [], // records
            elementsCached: [], // records
            length: 0, // record per pagina visualizzata

            columns: [],
            labels: {},
        };
    }

    get hasNotPrevPage() {
        return !this.hasPrevPage;
    }

    get hasNotNextPage() {
        return !this.hasNextPage;
    }

    get viewFirstPage() {
        return this.hasPrevPage && this.page > this.lengthList
    }

    get viewLastPage() {
        return this.hasNextPage && this.page < this.maxPage - this.lengthList;
    }

    get disabledStylePrev() {
        let style = ['page-item', 'page-item-border', 'mr-auto', 'prev'];
        if (!this.hasPrevPage) style.push('disabled')
        return style.join(' ');
    }

    get disabledStyleNext() {
        let style = ['page-item', 'page-item-border', 'ml-auto', 'next'];
        if (!this.hasNextPage) style.push('disabled')
        return style.join(' ');
    }

    get arrowleft() {
        if (this.hasPrevPage) return 'icon-arrow-left-blue';
        return 'icon-arrow-left';
    }
    get arrowright() {
        if (this.hasNextPage) return 'icon-arrow-right-blue';
        return 'icon-arrow-right';
    }

    get pageString(){
        return this.page + 1;
    }

    get maxPageString(){
        return this.maxPage + 1;
    }

    get prevPagesData(){
        return this.pageStructure(this.prevPages);
    }

    get nextPagesData(){
        return this.pageStructure(this.nextPages);
    }

    get startPageString(){
        return this.startPage + 1;
    }

    get endPageString(){
        return this.endPage - (this.perPage - this.length);
    }

    refresh(page){
        page = Number(page);
        
        let prevPage = page - 1;
        if(prevPage < 0) prevPage = 0;

        let hasPrevPage = page > 0;

        let maxPage = parseInt((this.elementsCached.length - 1) / this.perPage);

        if(prevPage > maxPage) prevPage = maxPage;

        let nextPage = page + 1;
        if(nextPage > maxPage) nextPage = maxPage;

        let hasNextPage = page < maxPage;

        let start = page * this.perPage;
        let end = start + this.perPage;

        let elements = this.elementsCached.slice(start, end);
        let length = elements.length;
        let total = this.elementsCached.length;

        let prevPages = [];
        let prevPagesMax = page-this.lengthList;
        if(prevPagesMax<0)prevPagesMax=0;
        for(let i = prevPagesMax; i <= page-1; i++) prevPages.push(i);

        let nextPages = [];
        let nextPagesMax = page+this.lengthList;
        if(nextPagesMax>maxPage)nextPagesMax=maxPage;
        for(let i = page+1; i <= nextPagesMax; i++) nextPages.push(i);

        this.prevPage           = prevPage;
        this.nextPage           = nextPage;
        this.maxPage            = maxPage;
        this.page               = page;
        //this.perPage            = perPage;
        this.hasPrevPage        = hasPrevPage;
        this.hasNextPage        = hasNextPage;
        this.length             = length;
        this.total              = total;
        this.elements           = elements;
        this.prevPages          = prevPages;
        this.nextPages          = nextPages;
    }

    pageStructure(pages){
        let result = [];

        pages.forEach((page)=>{
            result.push({
                index: page,
                label: page + 1
            })
        })

        return result;
    }
}