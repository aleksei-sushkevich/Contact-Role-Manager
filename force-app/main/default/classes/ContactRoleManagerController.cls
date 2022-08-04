public with sharing class ContactRoleManagerController {

    //Accordion 
    public class AccordionDataWrapper{
        @AuraEnabled
        public String Label { get; set; }
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String AccountName { get; set; }
        @AuraEnabled
        public String AccountId { get; set; }
        @AuraEnabled
        public Boolean NotAcc { get; set; }
        @AuraEnabled
        public Boolean HasConRoles { get; set; }
    }

    @AuraEnabled
    public static List<AccordionDataWrapper> getAccordionData(String tabName){
        List<AccordionDataWrapper> lToReturn = new List<AccordionDataWrapper>();
        switch on tabName {
            when 'Accounts' {
                Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Name, Id FROM Account ORDER BY Name]);
                List<AccountContactRole> lConRoles = [SELECT Id, AccountId FROM AccountContactRole WHERE AccountId IN :mAccounts.keySet()];
                Map<Id, Boolean> mAccHasConRol = new Map<Id, Boolean>();
                for(AccountContactRole conRole : lConRoles){
                    mAccHasConRol.put(conRole.AccountId, true);
                }
                for(Account acc : mAccounts.values()){
                    AccordionDataWrapper accData = new AccordionDataWrapper();
                    accData.AccountName = acc.Name;
                    accData.Label = '';
                    accData.AccountId = acc.Id;
                    accData.Id = acc.Id;
                    accData.NotAcc = false;
                    accData.HasConRoles = mAccHasConRol.get(acc.Id) == true ? true : false;
                    lToReturn.add(accData);
                }
            }
            when 'Opportunities' {
                Map<Id, Opportunity> mOpportunities = new Map<Id, Opportunity>([SELECT Name, AccountId, Account.Name, Id FROM Opportunity ORDER BY Account.Name]);
                List<OpportunityContactRole> lConRoles = [SELECT Id, OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN :mOpportunities.keySet()];
                Map<Id, Boolean> mOppHasConRol = new Map<Id, Boolean>();
                for(OpportunityContactRole conRole : lConRoles){
                    mOppHasConRol.put(conRole.OpportunityId, true);
                }
                for(Opportunity opp : mOpportunities.values()){
                    AccordionDataWrapper accData = new AccordionDataWrapper();
                    Map<Boolean, Opportunity> hasToAcc = new Map<Boolean, Opportunity>();
                    accData.Label = opp.Name;
                    accData.Id = opp.Id;
                    accData.AccountId = opp.AccountId;
                    accData.AccountName = opp.Account.Name;
                    accData.HasConRoles = mOppHasConRol.get(opp.Id) == true ? true : false;
                    accData.NotAcc = true;
                    lToReturn.add(accData);
                }
            }
            when 'Cases' {
                Map<Id, Case> mCases = new Map<Id, Case>([SELECT CaseNumber, AccountId, Account.Name, Id FROM Case ORDER BY Account.Name]);
                List<CaseContactRole> lConRoles = [SELECT Id, CasesId FROM CaseContactRole WHERE CasesId IN :mCases.keySet()];
                Map<Id, Boolean> mCaseHasConRol = new Map<Id, Boolean>();
                for(CaseContactRole conRole : lConRoles){
                    mCaseHasConRol.put(conRole.CasesId, true);
                }
                for(Case cas : mCases.values()){
                    AccordionDataWrapper accData = new AccordionDataWrapper();
                    Map<Boolean, Case> hasToAcc = new Map<Boolean, Case>();
                    accData.Label = cas.CaseNumber;
                    accData.Id = cas.Id;
                    accData.AccountName = cas.Account.Name;
                    accData.AccountId = cas.AccountId;
                    accData.HasConRoles = mCaseHasConRol.get(cas.Id) == true ? true : false;
                    accData.NotAcc = true;
                    lToReturn.add(accData);
                }
            }
            when 'Contracts' {
                Map<Id, Contract> mContracts = new Map<Id, Contract>([SELECT ContractNumber, AccountId, Account.Name, Id FROM Contract ORDER BY Account.Name]);
                List<ContractContactRole> lConRoles = [SELECT Id, ContractId FROM ContractContactRole WHERE ContractId IN :mContracts.keySet()];
                Map<Id, Boolean> mContractHasConRol = new Map<Id, Boolean>();
                for(ContractContactRole conRole : lConRoles){
                    mContractHasConRol.put(conRole.ContractId, true);
                }
                for(Contract con : mContracts.values()){
                    AccordionDataWrapper accData = new AccordionDataWrapper();
                    Map<Boolean, Contract> hasToAcc = new Map<Boolean, Contract>();
                    accData.Label = con.ContractNumber;
                    accData.Id = con.Id;
                    accData.AccountName = con.Account.Name;
                    accData.AccountId = con.AccountId;
                    accData.HasConRoles = mContractHasConRol.get(con.Id) == true ? true : false;
                    accData.NotAcc = true;
                    lToReturn.add(accData);
                }
            }
        }
        return lToReturn;
    }
    
    //Exist Contact Role Data
    public class ContactRoleWrapper{
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public String Title { get; set; }
        @AuraEnabled
        public String Email { get; set; }
        @AuraEnabled
        public String ContactId { get; set; }
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Role { get; set; }
        @AuraEnabled
        public String Phone { get; set; }
        @AuraEnabled
        public Boolean Primary { get; set; }
    }

    @AuraEnabled
    public static List<ContactRoleWrapper> getContactRolesByObjId(String objId){
        String objApiName = findObjectAPIName(objId);
        List<ContactRoleWrapper> lToReturn = new List<ContactRoleWrapper>();
        switch on objApiName{
            when 'Account'{
                lToReturn = getConRolesFromAcc(objId);
            }
            when 'Opportunity'{
                lToReturn = getConRolesFromOpp(objId);
            }
            when 'Case'{
                lToReturn = getConRolesFromCase(objId);
            }
            when 'Contract'{
                lToReturn = getConRolesFromContract(objId);
            }
        }
        return lToReturn;
    }

    private static List<ContactRoleWrapper> getConRolesFromAcc(Id accId){
        List<AccountContactRole> lAccConRoles = [SELECT Id,
                                                        ContactId,
                                                        Contact.Name, 
                                                        Contact.Email, 
                                                        Contact.Title, 
                                                        Contact.Phone, 
                                                        IsPrimary,
                                                        Role
                                                FROM    AccountContactRole 
                                                WHERE   AccountId = :accId
                                                ORDER BY Contact.Name];

        List<ContactRoleWrapper> lConRoleWrap = new List<ContactRoleWrapper>();

        for(AccountContactRole item : lAccConRoles){
            ContactRoleWrapper conRolWrap = new ContactRoleWrapper();
            conRolWrap.Id = item.Id;
            conRolWrap.ContactId = item.ContactId;
            conRolWrap.Name = item.Contact.Name;
            conRolWrap.Title = item.Contact.Title;
            conRolWrap.Email = item.Contact.Email;
            conRolWrap.Role = item.Role;
            conRolWrap.Phone = item.Contact.Phone;
            conRolWrap.Primary = item.IsPrimary;
            lConRoleWrap.add(conRolWrap);
        }
        return lConRoleWrap;
    }

    private static List<ContactRoleWrapper> getConRolesFromOpp(Id oppId){
        List<OpportunityContactRole> lAccConRoles = [SELECT Id,
                                                        ContactId,
                                                        Contact.Name, 
                                                        Contact.Email, 
                                                        Contact.Title, 
                                                        Contact.Phone, 
                                                        IsPrimary,
                                                        Role
                                                FROM    OpportunityContactRole 
                                                WHERE   OpportunityId = :oppId
                                                ORDER BY Contact.Name];

        List<ContactRoleWrapper> lConRoleWrap = new List<ContactRoleWrapper>();

        for(OpportunityContactRole item : lAccConRoles){
            ContactRoleWrapper conRolWrap = new ContactRoleWrapper();
            conRolWrap.Id = item.Id;
            conRolWrap.ContactId = item.ContactId;
            conRolWrap.Name = item.Contact.Name;
            conRolWrap.Title = item.Contact.Title;
            conRolWrap.Email = item.Contact.Email;
            conRolWrap.Role = item.Role;
            conRolWrap.Phone = item.Contact.Phone;
            conRolWrap.Primary = item.IsPrimary;
            lConRoleWrap.add(conRolWrap);
        }
        return lConRoleWrap;
    }

    private static List<ContactRoleWrapper> getConRolesFromCase(Id caseId){
        List<CaseContactRole> lAccConRoles = [SELECT Id,
                                                        ContactId,
                                                        Contact.Name, 
                                                        Contact.Email, 
                                                        Contact.Title, 
                                                        Contact.Phone, 
                                                        Role
                                                FROM    CaseContactRole 
                                                WHERE   CasesId = :caseId
                                                ORDER BY Contact.Name];

        List<ContactRoleWrapper> lConRoleWrap = new List<ContactRoleWrapper>();

        for(CaseContactRole item : lAccConRoles){
            ContactRoleWrapper conRolWrap = new ContactRoleWrapper();
            conRolWrap.Id = item.Id;
            conRolWrap.ContactId = item.ContactId;
            conRolWrap.Name = item.Contact.Name;
            conRolWrap.Title = item.Contact.Title;
            conRolWrap.Email = item.Contact.Email;
            conRolWrap.Role = item.Role;
            conRolWrap.Phone = item.Contact.Phone;
            lConRoleWrap.add(conRolWrap);
        }
        return lConRoleWrap;
    }

    private static List<ContactRoleWrapper> getConRolesFromContract(Id conId){
        List<ContractContactRole> lAccConRoles = [SELECT Id,
                                                        ContactId,
                                                        Contact.Name, 
                                                        Contact.Email, 
                                                        Contact.Title, 
                                                        Contact.Phone, 
                                                        IsPrimary,
                                                        Role
                                                FROM    ContractContactRole 
                                                WHERE   ContractId = :conId
                                                ORDER BY Contact.Name];

        List<ContactRoleWrapper> lConRoleWrap = new List<ContactRoleWrapper>();

        for(ContractContactRole item : lAccConRoles){
            ContactRoleWrapper conRolWrap = new ContactRoleWrapper();
            conRolWrap.Id = item.Id;
            conRolWrap.ContactId = item.ContactId;
            conRolWrap.Name = item.Contact.Name;
            conRolWrap.Title = item.Contact.Title;
            conRolWrap.Email = item.Contact.Email;
            conRolWrap.Role = item.Role;
            conRolWrap.Phone = item.Contact.Phone;
            conRolWrap.Primary = item.IsPrimary;
            lConRoleWrap.add(conRolWrap);
        }
        return lConRoleWrap;
    }

    //Contacts and Roles for Create New Contact Role
    public class NewContactRoleWrapper{
        @AuraEnabled
        public List<Contact> Contacts { get; set; }
        @AuraEnabled
        public List<String> Roles { get; set; }
        @AuraEnabled 
        public String AccountName { get; set; }
    }

    @AuraEnabled
    public static NewContactRoleWrapper getNewContactRoleData(String objId, String accId){
        String objApiName = findObjectAPIName(objId);
        NewContactRoleWrapper dataToReturn = new NewContactRoleWrapper();
        switch on objApiName{
            when 'Account'{
                dataToReturn.Contacts = [SELECT Id, Name FROM Contact WHERE AccountId =:objId ORDER BY Name];
                dataToReturn.Roles = getAccountContactRoleValues();
                dataToReturn.AccountName = [SELECT Name FROM Account WHERE Id =:accId LIMIT 1]?.Name;
            }
            when 'Opportunity'{
                dataToReturn.Contacts = [SELECT Id, Name FROM Contact WHERE AccountId =:accId ORDER BY Name];
                dataToReturn.Roles = getOpportunityContactRoleValues();
                dataToReturn.AccountName = [SELECT Name FROM Account WHERE Id =:accId LIMIT 1]?.Name;
            }
            when 'Case'{
                dataToReturn.Contacts = [SELECT Id, Name FROM Contact WHERE AccountId =:accId ORDER BY Name];
                dataToReturn.Roles = getCaseContactRoleValues();
                dataToReturn.AccountName = [SELECT Name FROM Account WHERE Id =:accId LIMIT 1]?.Name;
            }
            when 'Contract'{
                dataToReturn.Contacts = [SELECT Id, Name FROM Contact WHERE AccountId =:accId ORDER BY Name];
                dataToReturn.Roles = getContractContactRoleValues();
                dataToReturn.AccountName = [SELECT Name FROM Account WHERE Id =:accId LIMIT 1]?.Name;
            }
        }
        return dataToReturn;
    }

    @AuraEnabled
    public static List<Contact> findContactByName(String searchTerm){
        String search = searchTerm + '%';
        return [SELECT Id, Name FROM Contact WHERE Name Like :search ORDER BY Name LIMIT 100];
    }

    private static List<String> getAccountContactRoleValues(){
        List<String> picklistValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = AccountContactRole.Role.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistValuesList.add(pickListVal.getLabel());
        }     
        return picklistValuesList;
    }

    private static List<String> getOpportunityContactRoleValues(){
        List<String> picklistValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = OpportunityContactRole.Role.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistValuesList.add(pickListVal.getLabel());
        }     
        return picklistValuesList;
    }

    private static List<String> getCaseContactRoleValues(){
        List<String> picklistValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = CaseContactRole.Role.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistValuesList.add(pickListVal.getLabel());
        }     
        return picklistValuesList;
    }

    private static List<String> getContractContactRoleValues(){
        List<String> picklistValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ContractContactRole.Role.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistValuesList.add(pickListVal.getLabel());
        }     
        return picklistValuesList;
    }

    //Utils
    @AuraEnabled
    public static void deleteContactRole(String objId, String id){
        String objApiName = findObjectAPIName(objId);
        switch on objApiName {
            when 'Account' {
                AccountContactRole newCR = new AccountContactRole();
                newCR.Id = id;
                delete newCR;
            }
            when 'Opportunity' {
                OpportunityContactRole newCR = new OpportunityContactRole();
                newCR.Id = id;
                delete newCR;
            }
            when 'Case' {
                CaseContactRole newCR = new CaseContactRole();
                newCR.Id = id;
                delete newCR;
            }
            when 'Contract' {
                ContractContactRole newCR = new ContractContactRole();
                newCR.Id = id;
                delete newCR;
            }
        }
    }

    @AuraEnabled
    public static void editContactRole(List<sObject> valuesToUpdate){
        if(valuesToUpdate != null && !valuesToUpdate.isEmpty()){
            update valuesToUpdate;
        }
    }

    @AuraEnabled
    public static void createNewContactRole(String objId, Boolean isPrimary, String selectedContact, String selectedRole){
        String objApiName = findObjectAPIName(objId);
        switch on objApiName {
            when 'Account' {
                AccountContactRole newCR = new AccountContactRole();
                newCR.AccountId = objId;
                newCR.ContactId = selectedContact;
                newCR.Role = selectedRole;
                newCR.IsPrimary = isPrimary;
                insert newCR;
            }
            when 'Opportunity' {
                OpportunityContactRole newCR = new OpportunityContactRole();
                newCR.OpportunityId = objId;
                newCR.ContactId = selectedContact;
                newCR.Role = selectedRole;
                newCR.IsPrimary = isPrimary;
                insert newCR;
            }
            when 'Case' {
                CaseContactRole newCR = new CaseContactRole();
                newCR.CasesId = objId;
                newCR.ContactId = selectedContact;
                newCR.Role = selectedRole;
                insert newCR;
            }
            when 'Contract' {
                ContractContactRole newCR = new ContractContactRole();
                newCR.ContractId = objId;
                newCR.ContactId = selectedContact;
                newCR.Role = selectedRole;
                newCR.IsPrimary = isPrimary;
                insert newCR;
            }
        }
    }

    private static String findObjectAPIName(String objId){
        if(objId == null){
            return null;
        }
        String objectAPIName = '';
        String keyPrefix = objId.substring(0,3);
        for(Schema.SObjectType obj : Schema.getGlobalDescribe().Values()){
            String prefix = obj.getDescribe().getKeyPrefix();
            if(prefix == keyPrefix){
                objectAPIName = obj.getDescribe().getName();
                break;
            }
        }
        return objectAPIName;
    }
}