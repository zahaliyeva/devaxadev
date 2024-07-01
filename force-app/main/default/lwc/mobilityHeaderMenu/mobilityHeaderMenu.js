import {
  LightningElement,
  track,
  api,
  wire
} from 'lwc';
import {MobilityAbstract} from "c/mobilityAbstract";
import getVisibility from '@salesforce/apex/MobilityHeaderMenu.getVisibility';

export default class MobilityHeaderMenu extends MobilityAbstract {
  @track records = {};
  @api showMenu = false;

  constructor(data) {
    super(data);
    this.records = [
      {
        href: this._label.menu_Home_Href,
        label: this._label.menu_Home_Button,
        authorized: getVisibility({
          menuItemLabel: 'menu_Home_Button'
        }).then((result) => {
          return result;
        }).catch((err) => {
          console.log("err", err);
          return true;
        }),
        authorizedValue: null,
      },
      // {
      //   href: this._label.menu_Dac_Href,
      //   label: this._label.menu_Dac_Button,
      //   authorized: getVisibility({
      //     menuItemLabel: 'menu_Dac_Button'
      //   }).then((result) => {
      //     return result;
      //   }).catch((err) => {
      //     console.log("err", err);
      //     return true;
      //   }),
      //   authorizedValue: null,
      // },
      {
        href: this._label.menu_Opportunity_Href,
        label: this._label.menu_Opportunity_Button,
        authorized: getVisibility({
          menuItemLabel: 'menu_Opportunity_Button'
        }).then((result) => {
          return result;
        }).catch((err) => {
          console.log("err", err);
          return true;
        }),
        authorizedValue: null,
      },
      {
        href: this._label.menu_Report_Href,
        label: this._label.menu_Report_Button,
        authorized: getVisibility({
          menuItemLabel: 'menu_Report_Button'
        }).then((result) => {
          return result;
        }).catch((err) => {
          console.log("err", err);
          return true;
        }),
        authorizedValue: null,
      },
      {
        href: this._label.menu_Dashboard_Href,
        label: this._label.menu_Dashboard_Button,
        authorized: getVisibility({
          menuItemLabel: 'menu_Dashboard_Button'
        }).then((result) => {
          return result;
        }).catch((err) => {
          console.log("err", err);
          return true;
        }),
        authorizedValue: null,
      },
      {
        href: this._label.menu_Monitoraggio_Href,
        label: this._label.menu_Monitoraggio_Button,
        authorized: getVisibility({
          menuItemLabel: 'menu_Monitoraggio_Button'
        }).then((result) => {
          return result;
        }).catch((err) => {
          console.log("err", err);
          return true;
        }),
        authorizedValue: null,
      },
      {
        href: this._label.menu_Knowledge_Href,
        label: this._label.menu_Knowledge_Button,
        authorized: getVisibility({
          menuItemLabel: 'menu_Knowledge_Button'
        }).then((result) => {
          return result;
        }).catch((err) => {
          console.log("err", err);
          return true;
        }),
        authorizedValue: null,
      },
      {
        href: this._label.menu_Black_List_Href,
        label: this._label.menu_Black_List_Button,
        authorized: getVisibility({
          menuItemLabel: 'menu_Black_List_Button'
        }).then((result) => {
          return result;
        }).catch((err) => {
          console.log("err", err);
          return true;
        }),
        authorizedValue: null,
      }
      ,
      {
        href: this._label.menu_Svalidazione_Campagne_href,
        label: this._label.menu_Svalidazione_Campagne_Button,
        authorized: getVisibility({
          menuItemLabel: 'menu_Svalidazione_Campagne_Button'
        }).then((result) => {
          return result;
        }).catch((err) => {
          console.log("err", err);
          return true;
        }),
        authorizedValue: null,
      },
      {
        href: this._label.menu_Riforma_2024_href,
        label: this._label.menu_Riforma_2024_Button,
        authorized: getVisibility({
          menuItemLabel: 'menu_Riforma_2024_Button'
        }).then((result) => {
          return result;
        }).catch((err) => {
          console.log("err", err);
          return true;
        }),
        authorizedValue: null,
      }
    ];
  }

  get allData() {
    return this.records.filter(item => item.authorized.then((result) => {
      item.authorizedValue = result;
    }));
  }

  onShowMenu = e => {
    e.preventDefault();
    
    this.showMenu = !this.showMenu;
  }
}