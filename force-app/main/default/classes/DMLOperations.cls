/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Jonathan Lyles
 */


public with sharing class DMLOperations {

    public class CustomDMLException extends Exception {
    }

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account acc = new Account(Name = 'Random Name');
        // Set some fields on the Account
        acc.AccountNumber = '123';
        acc.Active__c = 'Yes';
        acc.Phone = '416-444-4400';
        acc.YearStarted = '2015';
        // Insert the Account into the database
        insert acc;
        // Return the Id of the newly created Account
        return acc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account acc = new Account(Name = name, Industry = industry);
        // Insert the Account
        insert acc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact con = new Contact(FirstName = 'John', LastName = 'Smith');
        // Set some fields on the Contact 
        con.MailingCity = 'Toronto';
        con.MailingCountry = 'Canada';
        con.MailingState = 'ON';
        con.MailingStreet = '3 Beatrice Street';
        con.MailingPostalCode = 'M3C 3T9';
        con.Phone = '416-967-1111';         
        // Set the AccountId field to the given accountId
        con.AccountId = accountId;
        // Insert the Contact into the database
        insert con;
        // Return the Id of the newly created Contact
        return con.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        Contact con = [SELECT Id FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        con.LastName = newLastName;
        // Update the Contact in the database
        update con;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        opp.StageName = newStage;
        // Update the Opportunity in the database
        update opp;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
        // Update the Account with the given Id with the new name and industry
        acc.Name = newName;
        acc.Industry = newIndustry;
        update acc;
    }


    /*
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for(Opportunity opp : opportunities){
            // Set the Opportunity's Stage to Qualification
            opp.StageName = 'Qualification';
            // Set the Opportunity's Close Date to 3 months from today
            opp.CloseDate = Date.today().addMonths(3);
            // Set the Opportunity's Amount to 50000
            opp.Amount = 50000;
        }
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {        
        /**
         * The new account if @param accountName does not exist
         * @var Account
         */
        Account newAcc = new Account(Name = accountName);
        /**
         * The existing account if @param accountName does exist
         * @var Account
         */
        Account existingAcc;
        /**
         * List to hold existing opportunities where opportunity name is in @param oppNames, if they exist.
         * @var List<Opportunity>
         */
        List<Opportunity> existingOpps = new List<Opportunity>();
        /**
         * If existingOpps is not empty, this list is created to hold the opportunity names that are in @param oppNames
         * @var List<String>
         */
        List<String> existingOppNames = new List<String>();

        /**
         * Checks if an account already exists matching the name of @param accountName. 
         * If nothing is returned @var existingAcc is set to null. 
         */
        existingAcc = [SELECT Id FROM Account WHERE Name = :newAcc.Name LIMIT 1] ?? null;
        /**
         * If @var existingAcc is not null, an account was found
         * Check for related opportunities of this account with names found in @param oppNames
         * Results are saved in @var existingOpps. Set to null if no opportunities are found.
         */    
        if(existingAcc != null){
            existingOpps = [SELECT Id, Name FROM Opportunity WHERE Name IN :oppNames] ?? null;             
        }else{
        /**
         * If @var existingAcc is null insert @var newAcc
         * No need to check for related opportunities if account does not exist.
         */
            insert newAcc;
            existingAcc = newAcc;
        }
        /**
         * If @var existingOpps is not empty, get the list of opportunity names and save in @var existingOppNames
         * Check if each oppName from @param oppNames is in existingOppNames
         * If oppName is in existingOppNames, then no action is required
         * If oppName is not in existingOppNames, create the Opportunity and add it to existingOpps
         */
        if(existingOpps != null){
            for(Opportunity existingOpp : existingOpps){
                existingOppNames.add(existingOpp.Name);
            }
            for(String oppName : oppNames){
                if(!existingOppNames.contains(oppName)){
                    Opportunity newOpp = new Opportunity(Name = oppName, StageName = 'Prospecting', CloseDate = Date.today(), AccountId = existingAcc.Id);
                    existingOpps.add(newOpp);
                }
                //no action required if an opportunity with this name already exists for this account.
            }
        }
        upsert existingOpps;    
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        Account upsertedAccount = new Account();

		// if the Account exists, update the description
        if(!accounts.isEmpty()){
            upsertedAccount = accounts[0];
            upsertedAccount.Description = 'Updated Account';
        }else{
            upsertedAccount.Description = 'New Account';
            upsertedAccount.Name = accountName;
        }
        upsert upsertedAccount;
		// Upsert the Account
		return upsertedAccount;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        // Create a map to store accounts by their name for quick lookup
        Map<String, Id> accountMap = new Map<String, Id>();
        //This list will hold the account which will be upserted
        List<Account> accList = new List<Account>();
        //This list will be used for comparison against last names
        List<String> accNames = new List<String>();
        //This list will be used for comparison against Account names
        List<String> lnames = new List<String>();
        //This list will hold the updated contact list which will be upserted at the end
        List<Contact> conList = new List<Contact>();
        //Get the last names and add to lnames list
        for(Contact contactToUpsert : contactsToUpsert){
            lnames.add(contactToUpsert.Lastname);
        }
        //for each lastname check if there's an account with that name
        //if not, create the account
        accList = [SELECT Id, Name FROM Account WHERE Name IN :lnames];
        for(Account acc : accList){
            accNames.add(acc.Name);
        } 
        for(String lname : lnames){
                If(!accNames.contains(lname)){
                    Account newAcc = new Account(Name = lname);
                    accList.add(newAcc);
                }
        upsert accList;
            }   
        // Populate the map with account names as keys
        for (Account acc : accList) {
            accountMap.put(acc.Name, acc.Id);                
        }
        for (Contact con : contactsToUpsert) {
            if (accountMap.containsKey(con.LastName)) {
                Id matchedId = accountMap.get(con.LastName);
                con.AccountId = MatchedId;
                conList.add(con);
        }
        upsert conList;
    }
}   
    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name
        List<Lead> newLeads = new List<Lead>();
        for(String leadName : leadNames){
            Lead newLead = new Lead(LastName = leadName, Company = leadName);
            newLeads.add(newLead);
        }
        // Insert the Leads
        insert newLeads;
        // Delete the Leads
        delete newLeads;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases
        List<Case> newCases = new List<Case>();
        for(Integer i = 0; i < numOfCases ; i++){
            Case newCase = new Case(AccountId = accountId, Status = 'New', Origin = 'Web');
            newCases.add(newCase);
        }
        insert newCases;
        // Delete the cases
        delete newCases;
    }
}