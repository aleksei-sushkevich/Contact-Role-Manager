import { LightningElement, api, track} from 'lwc';

export default class ContactRoleTable extends LightningElement {
    @api tableData;
    @track isModalOpen = false;
    @track isEdit = true;

    handleNew(){
        this.isModalOpen = true;
    }
}