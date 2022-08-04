@isTest
public with sharing class ContactRoleManagerControllerTest {

    @TestSetup
    static void makeData(){
        Date today = Date.today();
        Account acc = new Account(
            Name = 'Test'
        ); 
        insert acc;
        Contact con = new Contact(
            AccountId = acc.Id,
            LastName = 'Test'
        );
        insert con;
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Test',
            CloseDate = today,
            StageName = 'Prospecting'
        );
        insert opp;
        Case cas = new Case(
            AccountId = acc.Id,
            Origin = 'Phone'
        );
        insert cas;
        Contract cont = new Contract(
            AccountId = acc.Id,
            Status = 'Draft',
            StartDate = today,
            ContractTerm = 1
        );
        insert cont;
        AccountContactRole conRole1 = new AccountContactRole(
            ContactId = con.Id,
            AccountId = acc.Id
        );
        insert conRole1;
        OpportunityContactRole conRole2 = new OpportunityContactRole(
            ContactId = con.Id,
            OpportunityId = opp.Id
        );
        insert conRole2;
        CaseContactRole conRole3 = new CaseContactRole(
            ContactId = con.Id,
            CasesId = cas.Id
        );
        insert conRole3;
        ContractContactRole conRole4 = new ContractContactRole(
            ContactId = con.Id,
            ContractId = cont.Id
        );
        insert conRole4;
    }

    @isTest
    static void getAccordionDataTest(){
        List<ContactRoleManagerController.AccordionDataWrapper> wrap = ContactRoleManagerController.getAccordionData('Accounts');
        System.AssertEquals(wrap[0].AccountName, 'Test');
        System.AssertNotEquals(wrap[0].AccountName, 'Tests');
        wrap = ContactRoleManagerController.getAccordionData('Opportunities');
        System.AssertEquals(wrap[0].AccountName, 'Test');
        System.AssertNotEquals(wrap[0].AccountName, 'Tests');
        wrap = ContactRoleManagerController.getAccordionData('Cases');
        System.AssertEquals(wrap[0].AccountName, 'Test');
        System.AssertNotEquals(wrap[0].AccountName, 'Tests');
        wrap = ContactRoleManagerController.getAccordionData('Contracts');
        System.AssertEquals(wrap[0].AccountName, 'Test');
        System.AssertNotEquals(wrap[0].AccountName, 'Tests');
    }

    @isTest
    static void getContactRolesByObjIdTest(){
        List<Account> lAccs = [SELECT Id FROM Account];
        List<Opportunity> lOpps = [SELECT Id FROM Opportunity];
        List<Case> lCases = [SELECT Id FROM Case];
        List<Contract> lContracts = [SELECT Id FROM Contract];
        List<ContactRoleManagerController.ContactRoleWrapper> wrap = ContactRoleManagerController.getContactRolesByObjId(lAccs[0].Id);
        System.AssertEquals(wrap[0].Name, 'Test');
        System.AssertNotEquals(wrap[0].Name, 'Tests');
        wrap = ContactRoleManagerController.getContactRolesByObjId(lOpps[0].Id);
        System.AssertEquals(wrap[0].Name, 'Test');
        System.AssertNotEquals(wrap[0].Name, 'Tests');
        wrap = ContactRoleManagerController.getContactRolesByObjId(lCases[0].Id);
        System.AssertEquals(wrap[0].Name, 'Test');
        System.AssertNotEquals(wrap[0].Name, 'Tests');
        wrap = ContactRoleManagerController.getContactRolesByObjId(lContracts[0].Id);
        System.AssertEquals(wrap[0].Name, 'Test');
        System.AssertNotEquals(wrap[0].Name, 'Tests');
    }

    @isTest
    static void getNewContactRoleDataTest(){
        List<Account> lAccs = [SELECT Id FROM Account];
        List<Opportunity> lOpps = [SELECT Id FROM Opportunity];
        List<Case> lCases = [SELECT Id FROM Case];
        List<Contract> lContracts = [SELECT Id FROM Contract];
        ContactRoleManagerController.NewContactRoleWrapper wrap = ContactRoleManagerController.getNewContactRoleData(lAccs[0].Id, lAccs[0].Id);
        System.AssertEquals(wrap.AccountName, 'Test');
        System.AssertNotEquals(wrap.AccountName, 'Tests');
        wrap = ContactRoleManagerController.getNewContactRoleData(lOpps[0].Id, lAccs[0].Id);
        System.AssertEquals(wrap.AccountName, 'Test');
        System.AssertNotEquals(wrap.AccountName, 'Tests');
        wrap = ContactRoleManagerController.getNewContactRoleData(lCases[0].Id, lAccs[0].Id);
        System.AssertEquals(wrap.AccountName, 'Test');
        System.AssertNotEquals(wrap.AccountName, 'Tests');
        wrap = ContactRoleManagerController.getNewContactRoleData(lContracts[0].Id, lAccs[0].Id);
        System.AssertEquals(wrap.AccountName, 'Test');
        System.AssertNotEquals(wrap.AccountName, 'Tests');
    }

    @isTest
    static void findContactByNameTest(){
        List<Contact> cons = ContactRoleManagerController.findContactByName('Tes');
        System.AssertEquals(cons[0].Name, 'Test');
        System.AssertNotEquals(cons[0].Name, 'Tests');
    }

    @isTest
    static void deleteAndCreateContactRoleTest(){
        List<Account> lAccs = [SELECT Id FROM Account];
        List<Opportunity> lOpps = [SELECT Id FROM Opportunity];
        List<Case> lCases = [SELECT Id FROM Case];
        List<Contract> lContracts = [SELECT Id FROM Contract];
        List<AccountContactRole> lAccsR = [SELECT Id FROM AccountContactRole];
        List<OpportunityContactRole> lOppsR = [SELECT Id FROM OpportunityContactRole];
        List<CaseContactRole> lCasesR = [SELECT Id FROM CaseContactRole];
        List<ContractContactRole> lContractsR = [SELECT Id FROM ContractContactRole];
        ContactRoleManagerController.deleteContactRole(lAccs[0].Id, lAccsR[0].Id);
        lAccsR = [SELECT Id FROM AccountContactRole];
        System.AssertEquals(lAccsR.size(), 0);
        System.AssertNotEquals(lAccsR.size(), 1);
        ContactRoleManagerController.deleteContactRole(lOpps[0].Id, lOppsR[0].Id);
        lOppsR = [SELECT Id FROM OpportunityContactRole];
        System.AssertEquals(lOppsR.size(), 0);
        System.AssertNotEquals(lOppsR.size(), 1);
        ContactRoleManagerController.deleteContactRole(lCases[0].Id, lCasesR[0].Id);
        lCasesR = [SELECT Id FROM CaseContactRole];
        System.AssertEquals(lCasesR.size(), 0);
        System.AssertNotEquals(lCasesR.size(), 1);
        ContactRoleManagerController.deleteContactRole(lContracts[0].Id, lContractsR[0].Id);
        lContractsR = [SELECT Id FROM ContractContactRole];
        System.AssertEquals(lContractsR.size(), 0);
        System.AssertNotEquals(lContractsR.size(), 1);
        
        List<Contact> lCons = [SELECT Id FROM Contact];
        ContactRoleManagerController.createNewContactRole(lAccs[0].Id, true, lCons[0].Id, null);
        lAccsR = [SELECT Id, Role FROM AccountContactRole];
        System.AssertEquals(lAccsR[0].Role, null);
        System.AssertNotEquals(lAccsR[0].Role, 'Test');
        ContactRoleManagerController.createNewContactRole(lOpps[0].Id, true, lCons[0].Id, null);
        lOppsR = [SELECT Id, Role FROM OpportunityContactRole];
        System.AssertEquals(lOppsR[0].Role, null);
        System.AssertNotEquals(lOppsR[0].Role, 'Test');
        ContactRoleManagerController.createNewContactRole(lCases[0].Id, true, lCons[0].Id, null);
        lCasesR = [SELECT Id, Role FROM CaseContactRole];
        System.AssertEquals(lCasesR[0].Role, null);
        System.AssertNotEquals(lCasesR[0].Role, 'Test');
        ContactRoleManagerController.createNewContactRole(lContracts[0].Id, true, lCons[0].Id, null);
        lContractsR = [SELECT Id, Role FROM ContractContactRole];
        System.AssertEquals(lContractsR[0].Role, null);
        System.AssertNotEquals(lContractsR[0].Role, 'Test');
        ContactRoleManagerController.createNewContactRole(null, true, lCons[0].Id, null);
    }

    @isTest
    static void editContactRoleTest(){
        List<AccountContactRole> lAccsR = [SELECT Id, Role FROM AccountContactRole];
        lAccsR[0].Role = 'Other';
        ContactRoleManagerController.editContactRole(lAccsR);
        lAccsR = [SELECT Id, Role FROM AccountContactRole];
        System.AssertEquals(lAccsR[0].Role, 'Other');
        System.AssertNotEquals(lAccsR[0].Role, 'Test');
    }


}
