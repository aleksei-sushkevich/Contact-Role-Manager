public with sharing class ContactRoleManagerController {

    public class AccordionDataWrapper{
        @AuraEnabled
        public String Label { get; set; }
        @AuraEnabled
        public String Id { get; set; }
    }

    @AuraEnabled
    public static List<AccordionDataWrapper> getAccordionData(String tabName){
        List<AccordionDataWrapper> lToReturn = new List<AccordionDataWrapper>();
        switch on tabName {
            when 'Accounts' {
                List<Account> lAccounts = [SELECT Name, Id FROM Account];
                for(Account acc : lAccounts){
                    AccordionDataWrapper accData = new AccordionDataWrapper();
                    accData.Label = acc.Name;
                    accData.Id = acc.Id;
                    lToReturn.add(accData);
                }
            }
            when 'Opportunities' {
                List<Opportunity> lOpportunities = [SELECT Name, AccountId, Id FROM Opportunity];
                for(Opportunity opp : lOpportunities){
                    AccordionDataWrapper accData = new AccordionDataWrapper();
                    accData.Label = opp.Name;
                    accData.Id = opp.Id;
                    lToReturn.add(accData);
                }
            }
            when 'Cases' {
                List<Case> lCases = [SELECT CaseNumber, AccountId, Id FROM Case];
                for(Case cas : lCases){
                    AccordionDataWrapper accData = new AccordionDataWrapper();
                    accData.Label = cas.CaseNumber;
                    accData.Id = cas.Id;
                    lToReturn.add(accData);
                }
            }
            when 'Contracts' {
                List<Contract> lContracts = [SELECT ContractNumber, AccountId, Id FROM Contract];
                for(Contract con : lContracts){
                    AccordionDataWrapper accData = new AccordionDataWrapper();
                    accData.Label = con.ContractNumber;
                    accData.Id = con.Id;
                    lToReturn.add(accData);
                }
            }
        }
        return lToReturn;
    }
    
    public class ContactRoleWrapper{
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public String Title { get; set; }
        @AuraEnabled
        public String Email { get; set; }
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
            when else{
                lToReturn = null;
            }
        }
        return lToReturn;
    }

    private static List<ContactRoleWrapper> getConRolesFromAcc(Id accId){
        List<AccountContactRole> lAccConRoles = [SELECT Id, 
                                                        Contact.Name, 
                                                        Contact.Email, 
                                                        Contact.Title, 
                                                        Contact.Phone, 
                                                        IsPrimary,
                                                        Role
                                                FROM    AccountContactRole 
                                                WHERE   AccountId = :accId];

        List<ContactRoleWrapper> lConRoleWrap = new List<ContactRoleWrapper>();

        for(AccountContactRole item : lAccConRoles){
            ContactRoleWrapper conRolWrap = new ContactRoleWrapper();
            conRolWrap.Id = item.Id;
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
