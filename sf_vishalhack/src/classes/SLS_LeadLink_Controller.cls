//2016-03-16- anirudh.singh@cdk.com- Created this class for SLS_LeadLink Lightning Component for Request RQ-06471 NADA Leads Process - Work My Leads.
//2016-05-26- anirudh.singh@cdk.com- Modified this class for RQ-06983 Work My Leads - Shared Contacts Mods.
public class SLS_LeadLink_Controller
{
    @AuraEnabled
    public static LeadAndLeadMatchesWrapper fetchLeadAndLeadMatches(String leadId)
    {
        system.debug('Start fetchLeadAndLeadMatches---->');
        try
        {
            LeadAndLeadMatchesWrapper leadAndLeadMatchesRecord=new LeadAndLeadMatchesWrapper();
            Lead leadRecord=[
                SELECT Id, RecordType.Name, Status, SLS_Reason__c, OwnerId, Owner.Name, 
                Name, Lead_Type__c, Title, ADP_Campaign__r.Name, ADP_Campaign__c, Company, LeadSource, Email, Phone, 
                Current_Account__c, Contact__c
                FROM Lead 
                WHERE Id=:leadId
            ];
            
            if(leadRecord!=Null)
            {
                leadAndLeadMatchesRecord.leadRecord=leadRecord;
                leadAndLeadMatchesRecord.leadMatchesList=fetchLeadMatchesList(leadId);
            }
            
            system.debug('End fetchLeadAndLeadMatches---->');
            return leadAndLeadMatchesRecord;
        }
        catch(Exception ex)
        {
            system.debug('Exception---->'+ex.getMessage()+' at '+ex.getLineNumber());
            system.debug('End fetchLeadAndLeadMatches---->');
            return Null;
        }
    }
    
    private static List<Lead_Match__c> fetchLeadMatchesList(String leadId)
    {
        system.debug('Start fetchLeadMatchesList---->');
        List<Lead_Match__c> leadMatchesList=new List<Lead_Match__c>();
        
        try
        {
            //Get all the Lead Link Criterias.
            List<SLS_LeadLinkCriteria__c> linkCriteriasList=SLS_LeadLinkCriteria__c.getAll().values();
            
            //Delete the previous Lead Match Records.
            List<Lead_Match__c> oldLeadMatchesList=[Select Id From Lead_Match__c Where Lead__r.Id=:leadId];
            delete oldLeadMatchesList;
            
            Set<String> leadFields=new Set<String>();
            Set<String> contactFields=new Set<String>();
            
            //Loop through Custom Settings for link/match criteria.
            for(SLS_LeadLinkCriteria__c linkCriteria: linkCriteriasList)
            {
                if(linkCriteria.Active__c)
                {
                    leadFields.add(linkCriteria.Lead_Field__c);
                    contactFields.add(linkCriteria.Contact_Field__c);
                }
            }
            
            String leadQueryFields=fetchQueryFields(leadFields);
            String contactQueryFields=fetchQueryFields(contactFields);
            
            //Create Lead Query.
            String leadQuery='Select Id, '+leadQueryFields+' From Lead Where Id=\''+leadId+'\'';
            
            //Query the Lead Record.
            sObject leadRecord=Database.query(leadQuery);
            
            Map<Decimal, List<String>> conditionsMap=new Map<Decimal, List<String>>();
            
            //Build the conditions map.
            for(SLS_LeadLinkCriteria__c linkCriteria: linkCriteriasList)
            {
                if(linkCriteria.Active__c)
                {
                    if(!conditionsMap.keyset().contains(linkCriteria.Group__c))
                    {
                        conditionsMap.put(linkCriteria.Group__c, new List<String>());
                    }
                    
                    String leadValue='';
                    leadValue=String.valueOf(leadRecord.get(linkCriteria.Lead_Field__c));
                    
                    if(leadValue!=Null && linkCriteria.Regex_Modifier__c!=Null && linkCriteria.Regex_Modifier__c!='')
                    {
                        String regexReplacement='';
                        if(linkCriteria.Regex_Replacement__c!=Null)
                        {
                            regexReplacement=linkCriteria.Regex_Replacement__c;
                        }
                        
                        String regexModifier=linkCriteria.Regex_Modifier__c;
                        Pattern regexModifierPattern=Pattern.compile(regexModifier);
                        
                        Matcher swipeValueMatcher=regexModifierPattern.matcher(leadValue);
                        leadValue=swipeValueMatcher.replaceAll(regexReplacement);
                    }
                    
                    conditionsMap.get(linkCriteria.Group__c).add(leadValue);
                }
            }
            
            List<String> groupsList=new List<String>();
            
            //Build the search query.
            if(!conditionsMap.isEmpty())
            {
                for(Decimal key: conditionsMap.keyset())
                {
                    List<String> conditionsList=conditionsMap.get(key);
                    
                    String modifiedGroupValue='';
                    Integer counter=0;
                    
                    if(conditionsList.size()>0)
                    {
                        modifiedGroupValue='(';
                        
                        for(Integer i=0; i<conditionsList.size(); i++)
                        {
                            if(conditionsList[i]!=Null)
                            {
                                if(counter>0)
                                {
                                    modifiedGroupValue+=' and ';
                                }
                                
                                //Remove special characters (except wildcards ? and *)
                                modifiedGroupValue+='\"' + conditionsList[i].replaceAll(
                                    '([\\&\\|\\!\\{\\}\\[\\]\\(\\)\\^\\~\\:\\\"\\\'\\+\\-\\\\]{1})','\\\\$1') + '\"';
                                
                                //Increment counter
                                counter++;
                            }
                        }
                        
                        modifiedGroupValue+=')';
                    }
                    
                    if(modifiedGroupValue!='' && counter>0)
                    {
                        groupsList.add(modifiedGroupValue);
                    }
                }
            }
            
            //2016-05-26- anirudh.singh@cdk.com- Changed the retuning object from Contact to Contact Relationship.
            //2016-05-26- anirudh.singh@cdk.com- Also, removed the query field AccountId and added Account__c and Contact__c fields.
            //Create query String.
            String queryString=''
                +'FIND {'+String.join(groupsList,' or ')+'} ' 
                +'Returning Contact_Relationship__c(Id, Name, Account__c, Contact__c, '+contactQueryFields+' '+'Where No_Longer_There__c=false)';
            system.debug('queryString---->'+queryString);
            
            //Execute Search Query.
            List<List<sObject>> objectList=search.query(queryString);
            
            //Add all search results to the Matches list.
            for(sObject obj: objectList[0])
            {
                //2016-05-26- anirudh.singh@cdk.com- Added Contact_Relationship__c field.
                leadMatchesList.add(new Lead_Match__c(Lead__c=leadId, Contact__c=(Id)obj.get('Contact__c'), Contact_Relationship__c=obj.Id));
            }
            
            //Insert the Lead Matches.
            insert leadMatchesList;
            
            //2016-05-26- anirudh.singh@cdk.com- Removed the Contact__r.Salutation field as it was not being used.
            //2016-05-26- anirudh.singh@cdk.com- Account fields are now brought from Contact Relationship instead of Contact which was used earlier.
            //2016-05-26- anirudh.singh@cdk.com- Earlier fields were Contact__r.AccountId, Contact__r.Phone, Contact__r.Account.Name, Contact__r.Account.BillingStreet, 
            //Contact__r.Account.BillingCity, Contact__r.Account.BillingState, Contact__r.Account.BillingPostalCode, Contact__r.Account.Site_Type__r.Name
            //Query the Matches to get the full data set.
            leadMatchesList=[
                Select Id, Lead__c, 
                Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact_Relationship__r.Phone__c, 
                Contact_Relationship__r.Account__c, Contact_Relationship__r.Account__r.Name, Contact_Relationship__r.Account__r.BillingStreet, 
                Contact_Relationship__r.Account__r.BillingCity, Contact_Relationship__r.Account__r.BillingState, 
                Contact_Relationship__r.Account__r.BillingPostalCode, Contact_Relationship__r.Account__r.Site_Type__r.Name
                From Lead_Match__c 
                Where Id IN :leadMatchesList
                ORDER BY Contact_Relationship__r.Account__r.Name, Contact__r.LastName, Contact__r.FirstName
            ];
        }
        catch(Exception ex)
        {
            leadMatchesList=new List<Lead_Match__c>();
            system.debug('Exception---->'+ex.getMessage()+' at '+ex.getLineNumber());
        }
        
        system.debug('End fetchLeadMatchesList---->');
        return leadMatchesList;
    }
    
    private static String fetchQueryFields(Set<String> objectFields)
    {
        system.debug('Start fetchQueryFields---->');
        String objectQueryFields='';
        
        if(!objectFields.isEmpty())
        {
            List<String> objectFieldsList=new List<String>();
            objectFieldsList.addAll(objectFields);
            
            for(Integer i=0; i<objectFieldsList.size(); i++)
            {
                objectQueryFields+=((i>0)? ', ' : '')+objectFieldsList[i];
            }
        }
        
        system.debug('End fetchQueryFields---->');
        return objectQueryFields;
    }
    
    @AuraEnabled
    public static String linkLeadAndRedirect(Id leadMatchId, Id leadId)
    {
        system.debug('Start linkLeadAndRedirect---->');
        
        try
        {
            //2016-05-26- anirudh.singh@cdk.com- Changed the Contact__r.AccountId to Contact_Relationship__r.Account__c.
            Lead_Match__c leadMatchRecord=[
                SELECT Id, Contact_Relationship__r.Account__c, Contact__c, Lead__c
                FROM Lead_Match__c
                WHERE Id=:leadMatchId
            ];
            
            Lead leadRecord=new Lead();
            leadRecord.Id=leadId;
            //2016-05-26- anirudh.singh@cdk.com- Changed the Contact__r.AccountId to Contact_Relationship__r.Account__c.
            leadRecord.Current_Account__c=leadMatchRecord.Contact_Relationship__r.Account__c;
            leadRecord.Contact__c=leadMatchRecord.Contact__c;
            Database.SaveResult updateLeadResult=Database.update(leadRecord, false);
            
            if(!updateLeadResult.isSuccess())
            {
                system.debug('End linkLeadAndRedirect---->');
                return fetchErrorMessages(updateLeadResult.getErrors());
            }
            
            system.debug('End linkLeadAndRedirect---->');
            return 'Link Success';
        }
        catch(Exception ex)
        {
            system.debug('End linkLeadAndRedirect---->');
            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static String matchSelectedAccountRecord(Id accountRecordId, Id leadId)
    {
        system.debug('Start matchSelectedAccountRecord---->');
        
        try
        {
            Lead leadRecord=[
                SELECT Id, FirstName, LastName, Phone, Fax, Email, Title, 
                Street, City, State, PostalCode, Country, Current_Account__c, Contact__c
                FROM Lead
                WHERE Id=:leadId
            ];
            system.debug(leadRecord);
            
            Contact newContact=new Contact();
            newContact.AccountId=accountRecordId;
            newContact.FirstName=leadRecord.FirstName;
            newContact.LastName=leadRecord.LastName;
            //2016-05-26- anirudh.singh@cdk.com- Commented Phone and Fax.
            //newContact.Phone=leadRecord.Phone;
            //newContact.Fax=leadRecord.Fax;
            newContact.Email=leadRecord.Email;
            newContact.Title=leadRecord.Title;
            newContact.MailingStreet=leadRecord.Street;
            newContact.MailingCity=leadRecord.City;
            newContact.MailingState=leadRecord.State;
            newContact.MailingPostalCode=leadRecord.PostalCode;
            newContact.MailingCountry=leadRecord.Country;
            
            //2016-05-26- anirudh.singh@cdk.com- Commented the below line. Instead using the insertContact method from ALL_SharedContact_Helper.
            //Database.SaveResult insertContactResult=Database.insert(newContact, false);
            Map<string, ALL_SharedContact_Helper.duplicateCheckWrapper> resultMap=ALL_SharedContact_Helper.insertContact(newContact, '', leadRecord.Phone, leadRecord.Fax);
            ALL_SharedContact_Helper.duplicateCheckWrapper contactResult=resultMap.get('Contact');
            
            if(contactResult.insertedRecordIds.isEmpty())
            {
                if(contactResult.errorMsg=='Duplicate Error')
                {
                    String duplicateContactId=new List<Id>(contactResult.existingRecordIdToNewRecordMap.keySet())[0];
                    
                    system.debug('End matchSelectedAccountRecord---->');
                    return 'A Contact to the selected Account already exists.\nNew possible match is : '
                        +' <a href=\''+URL.getSalesforceBaseUrl().toExternalForm()+'/'+duplicateContactId+'\' target=\'_blank\'>Existing Contact</a>';
                }
                else
                {
                    return contactResult.errorMsg.replace(', ', '\n')+'\n Please Contact Administrator for Help!';
                }
            }
            else
            {
                //Updating the lead record.
                leadRecord.Current_Account__c=accountRecordId;
                leadRecord.Contact__c=new List<Id>(contactResult.insertedRecordIds)[0];
                Database.SaveResult updateLeadResult=Database.update(leadRecord, false);
                
                if(!updateLeadResult.isSuccess())
                {
                    system.debug('End matchSelectedAccountRecord---->');
                    return fetchErrorMessages(updateLeadResult.getErrors());
                }
                
                system.debug('End matchSelectedAccountRecord---->');
                return 'Link Success';
            }
            
            //2016-05-26- anirudh.singh@cdk.com- Commented the below line.
            //if(insertContactResult.isSuccess())
            //{
            //    leadRecord.Current_Account__c=accountRecordId;
            //    leadRecord.Contact__c=insertContactResult.getId();
            //    Database.SaveResult updateLeadResult=Database.update(leadRecord, false);
            //    
            //    if(!updateLeadResult.isSuccess())
            //    {
            //        system.debug('End matchSelectedAccountRecord---->');
            //        return fetchErrorMessages(updateLeadResult.getErrors());
            //    }    
            //    system.debug('End matchSelectedAccountRecord---->');
            //    return 'Link Success';
            //}
            //else
            //{
            //    system.debug('End matchSelectedAccountRecord---->');
            //    return fetchErrorMessages(insertContactResult.getErrors());
            //}
        }
        catch(Exception ex)
        {
            system.debug('----Exception-----'+ex);
            system.debug('End matchSelectedAccountRecord---->');
            return ex.getMessage() + ' at ' + ex.getLineNumber();
        }
    }
    
    @AuraEnabled
    public static String matchSelectedContactRecord(Id contactRecordId, Id leadId, Id accountRecordId)
    {
        system.debug('Start matchSelectedContactRecord---->');
        
        //2016-05-26- anirudh.singh@cdk.com- Removed the try catch block as it is not needed now.
        //try
        //{
        //2016-05-26- anirudh.singh@cdk.com- Commented the below line.
        //Contact contactRecord=[SELECT Id, Name, AccountId FROM Contact WHERE Id=:contactRecordId];
            
        Lead leadRecord=new Lead();
        leadRecord.Id=leadId;
        //2016-05-26- anirudh.singh@cdk.com- Commented the below line.
        //leadRecord.Current_Account__c=contactRecord.AccountId;
        leadRecord.Current_Account__c=accountRecordId;
        leadRecord.Contact__c=contactRecordId;
        Database.SaveResult updateLeadResult=Database.update(leadRecord, false);
        
        if(!updateLeadResult.isSuccess())
        {
            system.debug('End matchSelectedContactRecord---->');
            return fetchErrorMessages(updateLeadResult.getErrors());
        }
        
        system.debug('End matchSelectedContactRecord---->');
        return 'Link Success';
        
        //}
        //catch(Exception ex)
        //{
        //    system.debug('End matchSelectedContactRecord---->');
        //    return ex.getMessage();
        //}
    }
    
    private static String fetchErrorMessages(List<Database.Error> errorsGenerated)
    {
        system.debug('Start fetchErrorMessages---->');
        String errMessage='';
        
        for(Database.Error err: errorsGenerated)
        {
            errMessage+=((errMessage!='' && !errMessage.contains(err.getMessage()))? '\n' : '')+err.getMessage();
        }
        
        system.debug('End fetchErrorMessages---->');
        return errMessage;
    }
    
    public class LeadAndLeadMatchesWrapper
    {
        @AuraEnabled
        public Lead leadRecord{get; set;}
        
        @AuraEnabled
        public List<Lead_Match__c> leadMatchesList{get; set;}
    }
}