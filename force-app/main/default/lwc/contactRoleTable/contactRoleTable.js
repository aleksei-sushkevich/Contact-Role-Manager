import { LightningElement, api, track} from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createNewContactRole from '@salesforce/apex/ContactRoleManagerController.createNewContactRole';
import deleteContactRole from '@salesforce/apex/ContactRoleManagerController.deleteContactRole';
import findContactByName from '@salesforce/apex/ContactRoleManagerController.findContactByName';
import editContactRole from '@salesforce/apex/ContactRoleManagerController.editContactRole';
import LightningConfirm from 'lightning/confirm';

const ERROR_TITLE   = 'Error';
const ERROR_VARIANT = 'error';
const SUCCESS_VARIANT = 'success';

export default class ContactRoleTable extends LightningElement {
    //table
    @api tableData;
    @api objId;
    @api notCaseTab;
    @api notOppTab;
    editMode = false;
    editRecords = [];
    

    //modal
    @track isModalOpen = false;
    @api roleOptions;
    editRoleOptions;
    isPrimary = false;
    selectedRole = '';
    disabledSave = true;

    //contact search
    @api accountValue;
    @api fromOptions;
    @api contacts = [];
    @track contactOptions;
    searchPlace;
    placeholder = 'Select a Contact';
    searchString = '';
    selectedContact = '';
    selectedName = '';
    showDropdown = false;

    handleNew(){
        this.isModalOpen = true;
        this.contactOptions = this.contacts.map(el =>{
            return{
                label : el.Name,
                value : el.Id,
                isVisible : true
            }
        });
    }

    closeModal(){
        this.isModalOpen = false;
        this.searchString = '';
        this.selectedContact = '';
        this.selectedName = '';
        this.selectedRole = '';
        this.disabledSave = true;
        this.isPrimary = false;
        this.placeholder = 'Select a Contact';
    }

    showOptions() {
        this.showDropdown = true;
        if(this.selectedName !== ''){
            this.searchString = '';
            this.placeholder = this.selectedName;
        }
    }

    blurEvent() {
        this.showDropdown = false;
        if(this.selectedName !== ''){
            this.searchString = this.selectedName;
            this.placeholder = '';
        }
        for(var i = 0; i < this.contactOptions.length; i++) {
            this.contactOptions[i].isVisible = true;
        }
    }

    selectItem(event){
        this.selectedContact = event.currentTarget.dataset.id;
        this.selectedName = event.currentTarget.textContent;
        this.searchString = event.currentTarget.textContent;
        this.showDropdown = false;
        this.checkDesable();
    }

    filterOptions(event) {
        this.searchString = event.target.value;
        if(this.searchPlace !== 'All'){
            this.searchFun();
        }else{
            findContactByName({searchTerm : this.searchString})
            .then(data=>{
                this.contactOptions = data.map(el=>{
                    return{
                        label : el.Name,
                        value : el.Id,
                        isVisible : true
                    }
                })
            })
            .catch(error=>{
                this.catchFun(error);
            });
        }
    }

    searchFun(){
        if(this.searchString.length >= 1) {
            for(var i = 0; i < this.contactOptions.length; i++) {
                if(this.contactOptions[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                    this.contactOptions[i].isVisible = true;
                } 
                else {
                    this.contactOptions[i].isVisible = false;
                }
            }
            this.showDropdown = true;
        }else{
            for(var i = 0; i < this.contactOptions.length; i++) {
                this.contactOptions[i].isVisible = true;
            }
        }
    }

    checkDesable(){
        if(this.selectedContact === '' || this.selectedRole === ''){
            this.disabledSave = true;
        }else{
            this.disabledSave = false;
        }
    }

    handleChangePrimary(event){
        this.isPrimary = event.target.checked;
    }

    handleChangeRole(event){
        this.selectedRole = event.target.value;
        this.checkDesable();
    }

    onSave(){
        createNewContactRole({objId : this.objId, isPrimary : this.isPrimary, selectedContact : this.selectedContact, selectedRole: this.selectedRole})
        .then(()=>{
            this.closeModal();
            this.dispatchEvent(
                new ShowToastEvent({
                    message:'Contact Role has been created.',
                    variant: SUCCESS_VARIANT
                })
            );
            this.dispatchEvent(new CustomEvent('updatedata'));
        }).catch(error =>{
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

    handleChangeSearch(event){
        if(event.target.value === 'All'){
            findContactByName({searchTerm : this.searchString})
            .then(data=>{
                this.contactOptions = data.map(el=>{
                    return{
                        label : el.Name,
                        value : el.Id,
                        isVisible : true
                    }
                })
            })
            .catch(error=>{
                this.catchFun(error);
            });
        }else{
            this.contactOptions = this.contacts.map(el =>{
                return{
                    label : el.Name,
                    value : el.Id,
                    isVisible : true
                }
            });
        }
        this.searchPlace = event.target.value;
    }

    async deleteContactRole(event){
        const curId = event.currentTarget.id.substring(0, event.currentTarget.id.length - 4);
        const itemIndex = this.findIndexById(curId);
        let deleteAssignment = 
            `Remove ${this.tableData[itemIndex].namelabel} from ${this.fromOptions[0].label}.`;
        const result = await LightningConfirm.open({
            message: '',
            variant: 'header',
            label: deleteAssignment,
            theme: 'error',
        });
        if(result){
            deleteContactRole({objId: this.objId, id: this.tableData[itemIndex].id})
            .then(()=>{
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: `${this.tableData[itemIndex].namelabel} from ${this.fromOptions[0].label} has been deleted.`,
                        variant: SUCCESS_VARIANT
                    })
                );
                this.dispatchEvent(new CustomEvent('updatedata'));
            })
            .catch(error=>{
                this.catchFun(error);
            });
        }
    }

    findIndexById(id){
        for(var i = 0; i < this.tableData.length; i++) {
            if(id === this.tableData[i].id){
                return i;
            }
        }
        return null;
    }

    onEdit(){
        if(this.tableData.length > 0){
            this.editMode = this.editMode ? false : true;
        }
        if(this.editRecords.length > 0){
            this.editRecords = [];
            this.dispatchEvent(new CustomEvent('updatedata'));
        }
    }

    showRoleOptions(event){
        const curId = event.currentTarget.id.substring(0, event.currentTarget.id.length - 4);
        const itemIndex = this.findIndexById(curId);
        const value = event.currentTarget.textContent;
        this.editRoleOptions = this.roleOptions.map(el=>{
            return{
                label : el.label,
                value : el.value,
                icon  : false
            };
        });
        for(var i = 0; i < this.editRoleOptions.length; i++){
            if(this.editRoleOptions[i].label === value){
                this.editRoleOptions[i].icon = true;
            }
        }
        this.editRoleOptions.sort(function(x,y){ 
            return x.label == value ? -1 : y == value ? 1 : 0; 
        });
        let condition = this.tableData[itemIndex].showDropdownRole;
        let data = this.tableData.map(el=>{
            return{
                id : el.id,
                namelabel : el.namelabel,
                namehref : el.namehref,
                title : el.title,
                emailhref : el.emailhref,
                emaillabel : el.emaillabel,
                phonelabel : el.phonelabel,
                phonehref : el.phonehref,
                role : el.role,
                primary : el.primary,
                showDropdownRole : false
            }
        });
        data[itemIndex].showDropdownRole = condition ? false : true;
        this.tableData = data;
    }

    changeRole(event){
        const value = event.currentTarget.textContent;
        const curId = event.currentTarget.id.substring(0, event.currentTarget.id.length - 4);
        let exist = false;
        let index = 0;
        for(var i = 0; i < this.editRecords.length; i++){
            if(this.editRecords[i].Id === curId){
                exist = true;
                index = i;
            }
        }
        if(exist){
            this.editRecords[index].Role = value;
        }else{
            this.editRecords.push({Id : curId, Role : value});
        }
        const itemIndex = this.findIndexById(curId);
        this.tableData[itemIndex].role = value;
    }

    changePrimary(event){
        const curId = event.currentTarget.id.substring(0, event.currentTarget.id.length - 4);
        const itemIndex = this.findIndexById(curId);
        const value = event.target.checked;
        let data = [];
        if(this.notOppTab){
            data = this.tableData.map(el=>{
                return{
                    id : el.id,
                    namelabel : el.namelabel,
                    namehref : el.namehref,
                    title : el.title,
                    emailhref : el.emailhref,
                    emaillabel : el.emaillabel,
                    phonelabel : el.phonelabel,
                    phonehref : el.phonehref,
                    role : el.role,
                    primary : false,
                    showDropdownRole : false
                }
            });
        }else{
            data = this.tableData.map(el=>{
                return{
                    id : el.id,
                    namelabel : el.namelabel,
                    namehref : el.namehref,
                    title : el.title,
                    emailhref : el.emailhref,
                    emaillabel : el.emaillabel,
                    phonelabel : el.phonelabel,
                    phonehref : el.phonehref,
                    role : el.role,
                    primary : el.primary,
                    showDropdownRole : false
                }
            });
        }
        data[itemIndex].primary = value;
        this.tableData = data;
        let exist = false;
        let index = 0;
        for(var i = 0; i < this.editRecords.length; i++){
            if(this.editRecords[i].IsPrimary !== undefined && this.notOppTab){
                this.editRecords[i].IsPrimary = false;
            }
            if(this.editRecords[i].Id === curId){
                exist = true;
                index = i;
            }
        }
        if(exist){
            this.editRecords[index].IsPrimary = value;
        }else{
            this.editRecords.push({Id : curId, IsPrimary : value});
        }
    }
    
    onSaveEdit(){
        const message = this.editRecords.length > 1 ? `Records have been changed.` : `Record have been changed.`;
        editContactRole({valuesToUpdate : this.editRecords})
        .then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    message: message,
                    variant: SUCCESS_VARIANT
                })
            );
            this.editRecords = [];
            this.editMode = this.editMode ? false : true;
            this.dispatchEvent(new CustomEvent('updatedata'));
        })
        .catch(error=>{
            this.catchFun(error);
        });
    }
}