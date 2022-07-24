import { LightningElement, track } from 'lwc';
import getAccordionData from '@salesforce/apex/ContactRoleManagerController.getAccordionData';

const SLDS_IS_ACTIVE = "slds-is-active";
const SLDS_NAV_ITEM = "slds-vertical-tabs__nav-item";

const ERROR_TITLE   = 'Error';
const ERROR_VARIANT = 'error';
const SUCCESS_VARIANT = 'success';

const ACC = {
    key : "acc",
    label : "Accounts",
    liClass : SLDS_IS_ACTIVE + ' ' + SLDS_NAV_ITEM,
    icon : "standard:account",
    iconclass : "slds-icon_container slds-icon-standard-account",
    aria : "slds-vertical-tabs-0",
    ariaId : "slds-vertical-tabs-0__nav",
    selected: "false",
    index : "0",
    title : "Standard icon for accounts"
};
const OPP = {
    key : "opp",
    label : "Opportunities",
    liClass : SLDS_NAV_ITEM,
    icon : "standard:opportunity",
    iconclass : "slds-icon_container slds-icon-standard-opportunity",
    aria : "slds-vertical-tabs-1",
    ariaId : "slds-vertical-tabs-1__nav",
    selected: "false",
    index : "-1",
    title : "Standard icon for opportunities"
};
const CASES = {
    key : "cases",
    label : "Cases",
    liClass : SLDS_NAV_ITEM,
    icon : "standard:case",
    iconclass : "slds-icon_container slds-icon-standard-case",
    aria : "slds-vertical-tabs-2",
    ariaId : "slds-vertical-tabs-2__nav",
    selected: "false",
    index : "-1",
    title : "Standard icon for cases"
};
const CONTR = {
    key : "contr",
    label : "Contracts",
    liClass :  SLDS_NAV_ITEM,
    icon : "standard:contract",
    iconclass : "slds-icon_container slds-icon-standard-contract",
    aria : "slds-vertical-tabs-3",
    ariaId : "slds-vertical-tabs-3__nav",
    selected: "false",
    index : "-1",
    title : "Standard icon for contracts"
};

export default class ContactRoleManager extends LightningElement {

    //tabs
    @track tabs;
    tabName = 'Accounts';

    //accordion
    @track accData;
    @track initialData;
    activeSection = [];

    //pagination
    nextDisabled;
    previousDisabled;
    page;
    totalPage;
    startingRecord = 1;
    endingRecord = 0;
    totalRecountCount;
    pageSize = 10;


    connectedCallback(){
        this.tabs = [ACC, OPP, CASES, CONTR];
        this.getAccordionData();
    }

    onSelectTabClick(event){
        this.tabName = event.currentTarget.textContent;
        this.tabs.forEach(element => {
            element.liClass = SLDS_NAV_ITEM;
            element.selected = "false";
            if(element.label === this.tabName){
                element.liClass += ' ' + SLDS_IS_ACTIVE;
                element.selected = "true";
            }
        });
        this.getAccordionData();
    }

    getAccordionData(){
        getAccordionData({tabName : this.tabName})
        .then(data => {
            this.accData = data;
            this.initialData = this.accData;
            this.processRecords(this.accData);
        }).catch(error => {
           this.error = error;
           this.errorMessage = reduceErrors(this.error);
           this.dispatchEvent(
                new ShowToastEvent({
                    title: ERROR_TITLE,
                    message: this.errorMessage.toString(),
                    variant: ERROR_VARIANT
                })
            );
       });
       this.activeSection = [];
    }

    processRecords(data){
        this.page = 1;
        this.totalRecountCount = data.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.endingRecord = this.pageSize;
        this.accData = data.slice(0,this.pageSize);
        this.disableButtons();
    }

    previousHandler() {
        if (this.page > 1) {
            this.page--;
            this.displayRecordPerPage();
        }
        this.disableButtons();
        this.activeSection = [];
    }

    nextHandler() {
        if(this.page < this.totalPage && this.page !== this.totalPage){
            this.page++;
            this.displayRecordPerPage();            
        }
        this.disableButtons();
        this.activeSection = [];
        
    }

    disableButtons(){
        this.nextDisabled = this.page === this.totalPage ? true : false;
        this.previousDisabled = this.page === 1 ? true : false;
    }

    displayRecordPerPage(){
        this.startingRecord = (this.page -1) * this.pageSize;
        this.endingRecord = this.pageSize * this.page;

        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord; 

        this.accData = this.initialData.slice(this.startingRecord, this.endingRecord);

    }
}