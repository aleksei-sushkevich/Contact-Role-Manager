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
}
