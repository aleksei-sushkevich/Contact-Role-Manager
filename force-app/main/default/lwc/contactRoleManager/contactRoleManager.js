import { LightningElement, track } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccordionData from '@salesforce/apex/ContactRoleManagerController.getAccordionData';
import getContactRolesByObjId from '@salesforce/apex/ContactRoleManagerController.getContactRolesByObjId';
import getNewContactRoleData from '@salesforce/apex/ContactRoleManagerController.getNewContactRoleData';

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
    @track tabs = [ACC, OPP, CASES, CONTR];
    tabName = ACC.label;
    notAccountTab = false;
    notCaseTab = true;
    labelForInptut = '';

    //accordion
    @track accData;
    @track initialData;
    @track filteredData;
    selectedSection = false;
    previousSectionValue = '';
    downloadedData = true;
    searchStringAccName = '';
    searchStringLabel = '';

    //pagination
    nextDisabled;
    previousDisabled;
    page;
    totalPage;
    startingRecord = 1;
    endingRecord = 0;
    totalRecountCount;
    pageSize = 10;

    //table
    @track accountValue;
    @track tableData;
    @track contacts;
    @track roleOptions;
    @track fromOptions;
    recordId;
    accountId;
    showValues = 'All';

    //utility
    get showValue() {
        return 'All';
    }
    get showOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'There are contact roles', value: 'There are contact roles' },
            { label: 'There are no contact roles', value: 'There are no contact roles' },
        ];
    }

    connectedCallback(){
        this.getAccordionData();
    }


    async onSelectTabClick(event){
        this.tabName = event.currentTarget.textContent;
        if(this.tabName === ACC.label){
            this.notAccountTab = false;
            this.labelForInptut = '';
            this.notCaseTab = true;
        }else if(this.tabName === OPP.label){
            this.notAccountTab = true;
            this.labelForInptut = 'Opportunity Name:';
            this.notCaseTab = true;
        }else if(this.tabName === CASES.label){
            this.notAccountTab = true;
            this.labelForInptut = 'Case Number:';
            this.notCaseTab = false;
        }else if(this.tabName === CONTR.label){
            this.notAccountTab = true;
            this.labelForInptut = 'Contract Number:';
            this.notCaseTab = true;
        }
        this.tabs.forEach(element => {
            element.liClass = SLDS_NAV_ITEM;
            element.selected = "false";
            if(element.label === this.tabName){
                element.liClass += ' ' + SLDS_IS_ACTIVE;
                element.selected = "true";
            }
        });
        this.selectedSection = false;
        await this.getAccordionData();
        this.filterShow();
    }

    getAccordionData(){
        return getAccordionData({tabName : this.tabName})
        .then(data => {
            this.accData = data.map(el=>{
                return{
                    Id : el.Id,
                    Label : el.Label,
                    Icon : "utility:chevronright",
                    isVisible : false,
                    Class : "accordion",
                    isSpin : false,
                    notAcc : el.NotAcc,
                    accName : el.AccountName !== undefined ? el.AccountName : '',
                    accId : el.AccountId !== undefined ? el.AccountId : '',
                    hasConRole : el.HasConRoles
                }
            });
            this.initialData = this.accData;
            this.processRecords(this.accData);
        }).catch(error => {
            this.catchFun(error);
        });
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
        this.closeSections();
    }

    nextHandler() {
        if(this.page < this.totalPage && this.page !== this.totalPage){
            this.page++;
            this.displayRecordPerPage();            
        }
        this.disableButtons();
        this.closeSections();
    }

    closeSections(){
        this.accData.forEach(el => {
            el.Icon = "utility:chevronright";
            el.isVisible = false;
            el.Class = "accordion";
        });
    }

    disableButtons(){
        this.nextDisabled = this.page === this.totalPage ? true : false;
        this.previousDisabled = this.page === 1 ? true : false;
    }

    displayRecordPerPage(){
        this.startingRecord = (this.page -1) * this.pageSize;
        this.endingRecord = this.pageSize * this.page;
        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord; 
        if(this.searchStringAccName === '' && this.searchStringLabel === ''){
            this.accData = this.initialData.slice(this.startingRecord, this.endingRecord);
        }else{
            this.accData = this.filteredData.slice(this.startingRecord, this.endingRecord);
        }
    }

    async handleToggleSection(event){
        if(this.downloadedData){
            this.recordId = event.currentTarget.dataset.id;
            this.accountId = event.currentTarget.id.substring(0, event.currentTarget.id.length - 4);
            const label = event.currentTarget.textContent;
            if(!this.selectedSection){
                await this.showTable(label);
            }else{
                if(this.previousSectionValue === label){
                    this.closeTable();
                }else{
                    await this.showTable(label);
                }
            }
        }
    }

    getContactRoles(){
        return getContactRolesByObjId({objId : this.recordId})
        .then(data => {
            let baseUrl = 'https://'+location.host+'/';
            if(data != null && data.length !== 0){
                this.tableData = data.map(el=>{
                    return{
                        id : el.Id,
                        namelabel : el.Name,
                        namehref : baseUrl + el.ContactId,
                        title : el.Title,
                        emailhref : "mailto:" + el.Email,
                        emaillabel : el.Email,
                        phonelabel : el.Phone,
                        phonehref : "tel:" + el.Phone,
                        role : el.Role,
                        primary : el.Primary,
                        showDropdownRole : false
                    }
                });
            }else{
                this.tableData = undefined;
            }
        })
        .catch(error => {
            this.catchFun(error);
        });
    }

    async showTable(label){
        this.previousSectionValue = label;
        this.downloadedData = false;
        this.accData.forEach(el => {
            if(el.Id === this.recordId){
                el.Icon = el.Icon === "utility:chevrondown" ? "utility:chevronright" : "utility:chevrondown";
                el.isSpin = el.isSpin ? false : true;
                el.Class = el.Class === "accordion" ? "selected-accordion" : "accordion";
            }else{
                el.Icon = "utility:chevronright";
                el.isSpin = false;
                el.isVisible = false;
                el.Class = "accordion";
            }
        });
        await this.getContactRoles();
        await this.getNewContactRoleData();
        this.accData.forEach(el => {
            if(el.Id === this.recordId){
                el.isVisible = el.isVisible ? false : true;
                el.isSpin = false;
            }else{
                el.isVisible = false;
            }
        });
        this.accountValue = this.recordId;
        this.downloadedData = true;
        this.selectedSection = true;
    }

    closeTable(){
        this.accData.forEach(el => {
            el.Icon = "utility:chevronright";
            el.isSpin = false;
            el.isVisible = false;
            el.Class = "accordion";
        });
        this.selectedSection = false;
    }

    getNewContactRoleData(){
        return getNewContactRoleData({objId : this.recordId, accId : this.accountId})
        .then(data => {
            this.contacts = data.Contacts;
            this.fromOptions = [{label : data.AccountName, value : this.recordId}, {label : 'All', value: 'All'}];
            this.roleOptions = data.Roles.map(el=>{
                return{
                label : el,
                value : el
                };
            });
        })
        .catch(error => {
            this.catchFun(error);
        });
    }

    catchFun(error){
        this.error = error;
        this.errorMessage = reduceErrors(this.error);
        this.dispatchEvent(
            new ShowToastEvent({
            title: ERROR_TITLE,
            message: this.errorMessage.toString(),
            variant: ERROR_VARIANT
            })
        );
    }

    searchByAccName(event){
        if(event !== undefined){
            this.searchStringAccName = event.target.value;
        }
        let parseData = [];
        if(this.showValues === 'All' || event === undefined){
            parseData = JSON.parse(JSON.stringify(this.initialData));
        }else{
            this.filterShow();
            parseData = JSON.parse(JSON.stringify(this.filteredData));
        }
        let newData = [];
        for(var i = 0; i < parseData.length; i++){
            if(parseData[i].accName.toLowerCase().trim().startsWith(this.searchStringAccName.toLowerCase().trim())){
                newData.push(parseData[i]);
            }
        }
        this.page = 1;
        this.filteredData = newData;
        this.processRecords(newData);
    }

    searchByLabel(event){
        if(event !== undefined){
            this.searchStringLabel = event.target.value;
        }
        let parseData = [];
        if(this.showValues === 'All' || event === undefined){
            parseData = JSON.parse(JSON.stringify(this.initialData));
        }else{
            this.filterShow();
            parseData = JSON.parse(JSON.stringify(this.filteredData));
        }
        let newData = [];
        for(var i = 0; i < parseData.length; i++){
            if(parseData[i].Label.toLowerCase().trim().startsWith(this.searchStringLabel.toLowerCase().trim())){
                newData.push(parseData[i]);
            }
        }
        this.page = 1;
        this.filteredData = newData;
        this.processRecords(newData);
    }

    async handleChangeShow(event){
        this.showValues = event.target.value;
        await this.getAccordionData();
        this.filterShow();
    }

    filterShow(){
        let parseData = [];
        if(this.searchStringAccName === '' && this.searchStringLabel === ''){
            parseData = JSON.parse(JSON.stringify(this.initialData));
        }else if(this.searchStringAccName !== '' && this.searchStringLabel === ''){
            this.searchByAccName();
            parseData = JSON.parse(JSON.stringify(this.filteredData));
        }else if(this.searchStringAccName === '' && this.searchStringLabel !== ''){
            this.searchByLabel();
            parseData = JSON.parse(JSON.stringify(this.filteredData));
        }else if(this.searchStringAccName !== '' && this.searchStringLabel !== ''){
            this.searchByAccName();
            this.searchByLabel();
            parseData = JSON.parse(JSON.stringify(this.filteredData));
        }
        let newData = [];
        if(this.showValues === 'There are contact roles'){
            for(var i = 0; i < parseData.length; i++){
                if(parseData[i].hasConRole){
                    newData.push(parseData[i]);
                }
            }
            this.filteredData = newData;
            this.processRecords(newData);
        }else if(this.showValues === 'There are no contact roles'){
            for(var i = 0; i < parseData.length; i++){
                if(!parseData[i].hasConRole){
                    newData.push(parseData[i]);
                }
            }
            this.filteredData = newData;
            this.processRecords(newData);
        }else{
            for(var i = 0; i < parseData.length; i++){
                newData.push(parseData[i]);
            }
            this.filteredData = newData;
            this.processRecords(newData);
        }
    }
}