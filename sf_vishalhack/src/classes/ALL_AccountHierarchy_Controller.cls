//Author: Anirudh Singh
//Created Date: 2015-07-10
//Description: Customizable columns Account Hierarchy View.
//2017-02-22 ragashalini.koka@cdk.com - Added the variable filterCondition and applyFilterCriteria method to filter the Accounts for CPQ.
//2017-04-10 ragashalini.koka@cdk.com - Added a method addAdditionalColumns for RQ-09015.
public class ALL_AccountHierarchy_Controller
{
    //This String is used to hold the id of the Account on which the Account Hierarchy button was clicked.
    private static String currentAccountId;
    
    //This List is used to hold the Ids of the Account.
    private static Set<Id> accountIdsSet;
    
    //String to hold the columns to be queried.
    private static String columnsToQuery;
    
    //This list holds the names of the fields to be displayed on the visualforce page.
    private static List<ColumnNameLabelWrapper> columnNamesLabelList;
    
    //This list holds the name of relationship columns on visualforce page.
    private static List<String> remainingColumns=new List<String>();
    
    //This Wrapper Map contains the Map of Account Ids and the Account Records for the corresponding Ids.
    private static Map<Id, Account> allAccountsMap;
    
    //This String holds the name of the Account on which the Account Hierarchy button was clicked.
    //It is used to display the Account Name at the top of the page.
    public static String currentAccountName{get; set;}
    
    //This list is used to display the Accounts on the visualforce page.
    private static List<HierarchyWrapper> allAccountsWrapperList;
    
    //This is used to set the margin for the Account record.
    private static Final Integer MARGIN=25;
    
    //This holds the condition to filter the Accounts for CPQ.
    private static String filterCondition;
    
    //This property is used to display the columns on the visualforce page.
    public List<ColumnNameLabelWrapper> displayColumnNamesLabelList
    {
        get
        {
            return columnNamesLabelList;
        }
        set;
    }
    
    //This property is used to display the relationship columns on the visualforce page.
    public List<String> displayRemainingColumns
    {
        get
        {
            return remainingColumns;
        }
        set;
    }
    
    //This property is used to display all the Account records for the hierarchy.
    public List<HierarchyWrapper> displayAccountsList
    {
        get
        {
            return allAccountsWrapperList;
        }
        set;
    }
    
    //This method is directly invoked from the visualforce page.
    //It is the initial method which is used for processing Account Hierarchy.
    public static void processAccountHierarchy()
    {
        system.debug('Start processAccountHierarchy---->');
        
        //This String is used to hold the id of the Account on which the Account Hierarchy button was clicked.
        currentAccountId=ApexPages.currentPage().getParameters().get('id');
        
        //Initializing the set to hold the account Ids.
        accountIdsSet=new Set<Id>();
        
        //Go to the Top of the hierarchy and fetch the account Ids into accountIdsSet for further processing.
        accountIdsSet.add(AccountHierarchyTools.recursivelyFetchTopParentAccountId(currentAccountId));
        
        if(ApexPages.currentPage().getParameters().get('filterHierarchy') == 'yes')
        {
            applyFilterCriteria();
        }
        
        //This list holds the names of the fields to be displayed on the visualforce page.
        columnNamesLabelList=new List<ColumnNameLabelWrapper>();
        
        //The Wrapper Map is intialized.
        allAccountsMap=new Map<Id, Account>();
        
        //This method is invoked to fetch all the Accounts for the hierarchy.
        fetchAccounts(accountIdsSet);
        
        //The Wrapper List is intialized.
        allAccountsWrapperList=new List<HierarchyWrapper>();
        
        //Parent Account Id is sent as Null, as the topmost parent will not have any parent record.
        Set<Id> parentAccId=new Set<Id>();
        
        //This method is invoked to form the Hierarchy Wrapper List.
        accountHierarchyFilter(parentAccId);
        system.debug('End processAccountHierarchy---->');
    }
    
    //This method is invoked to fetch all the Accounts for the hierarchy.
    private static void fetchAccounts(Set<Id> accountIdsToBeFetchedSet)
    {
        system.debug('Start fetchAccounts---->');
        
        Set<Id> newAccIdsAfterQuery=new Set<Id>();
        Set<Id> accIdsInMap=allAccountsMap.keySet();
        
        String queryString='SELECT ';
        
        if(columnsToQuery==Null)
        {
            queryString+=fetchColumnsToQuery();
        }
        else
        {
            queryString+=columnsToQuery;
        }
        
        queryString+=' FROM Account';
        
        queryString+=' WHERE (';
        
        String condition;
        for(Id accId: accountIdsToBeFetchedSet)
        {
            if(condition==Null)
            {
                condition='Id=\''+accId+'\'';
            }
            else
            {
                condition+=' OR Id=\''+accId+'\'';
            }
            condition+=' OR ParentId=\''+accId+'\'';
            condition+=' OR Parent.ParentId=\''+accId+'\'';
            condition+=' OR Parent.Parent.ParentId=\''+accId+'\'';
            condition+=' OR Parent.Parent.Parent.ParentId=\''+accId+'\'';
            condition+=' OR Parent.Parent.Parent.Parent.ParentId=\''+accId+'\'';
            condition+=' OR Parent.Parent.Parent.Parent.Parent.ParentId=\''+accId+'\'';
        }
        
        queryString+=condition+')';
        
        queryString+=' AND ( Id NOT IN: accIdsInMap )';
        
        //2017-02-22 ragashalini.koka@cdk.com - Added the below line to append the filter condition to the query
        queryString+=filterCondition!=null && filterCondition.length()>0 ? filterCondition : '';
        
        try
        {
            for(Account acc: Database.query(queryString))
            {
                allAccountsMap.put(acc.Id, acc);
                
                if(!accountIdsSet.contains(acc.Id))
                {
                    newAccIdsAfterQuery.add(acc.Id);
                }
                
                if(acc.Id==currentAccountId)
                {
                    //This String holds the name of the Account on which the Account Hierarchy button was clicked.
                    //It is used to display the Account Name at the top of the page.
                    currentAccountName=acc.Name;
                }
            }
            
            if(newAccIdsAfterQuery.size()>0)
            {
                system.debug('Refetch the remaining accounts---->');
                fetchAccounts(newAccIdsAfterQuery);
            }
        }
        catch(Exception ex)
        {
            ApexPages.Message errMsg=new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(errMsg);
        }
        system.debug('End fetchAccounts---->');
    }
    
    //This method is invoked from fetchAccounts to get the queryString for the columns to be queried.
    //Also, the list of columns to be displayed on the visualforce page is created in this method.
    private static String fetchColumnsToQuery()
    {
        system.debug('Start fetchColumnsToQuery---->');
        Set<String> uniqueColumns=new Set<String>();
        
        for(ALL_AccountHierarchy__c ach: [SELECT Id, Fields_To_Be_Displayed__c, Position__c FROM ALL_AccountHierarchy__c ORDER By Position__c NULLS LAST])
        {
            if(columnsToQuery==Null)
            {
                columnsToQuery=ach.Fields_To_Be_Displayed__c;
            }
            else
            {
                columnsToQuery+=', '+ach.Fields_To_Be_Displayed__c;
            }
            
            uniqueColumns.add(ach.Fields_To_Be_Displayed__c);
        }
        
        columnsToQuery=addAdditionalColumns('ParentId');
        columnsToQuery=addAdditionalColumns('PartyID__c');
        
        fetchColumnsToDisplay(uniqueColumns);
        
        system.debug('End fetchColumnsToQuery---->');
        return columnsToQuery;
    }
    
    private static String addAdditionalColumns(String fieldAPI) 
    {
        String strAtFirstPosition=fieldAPI+',';
        String strAtMiddlePosition=' '+fieldAPI+',';
        String strAtLastPosition=' '+fieldAPI;
        
        if(columnsToQuery==Null)
        {
            columnsToQuery=fieldAPI;
        }
        else if(columnsToQuery!=Null && !(columnsToQuery.toLowerCase().indexOf(strAtFirstPosition.toLowerCase())==0) 
                && !(columnsToQuery.toLowerCase().indexOf(strAtMiddlePosition.toLowerCase())>0)
                && !(columnsToQuery.toLowerCase().indexOf(strAtLastPosition.toLowerCase())>0))
        {
            columnsToQuery+=', '+fieldAPI;
        }
        
        return columnsToQuery;
    }
    
    //This method is used to form the list of columns to be displayed on the visualforce page.
    private static void fetchColumnsToDisplay(Set<String> uniqueColumns)
    {
        system.debug('Start fetchColumnsToDisplay---->');
        //Getting the object Schema to get the field labels.
        Map<String, Schema.SObjectField> accountFieldMap=Schema.SObjectType.Account.fields.getMap();
        
        //The below list will hold the relationship field names, which could not be resolved by accountFieldMap.
        remainingColumns=new List<String>();
        
        for(String str: uniqueColumns)
        {
            for(Integer i=0; i<accountFieldMap.values().size(); i++)
            {
                if(str==String.valueOf(accountFieldMap.values()[i]))
                {
                    ColumnNameLabelWrapper ref=new ColumnNameLabelWrapper();
                    ref.columnName=str;
                    ref.columnLabel=accountFieldMap.values()[i].getDescribe().getLabel();
                    columnNamesLabelList.add(ref);
                    break;
                }
                else if((i+1)==accountFieldMap.values().size())
                {
                    remainingColumns.add(str);
                }
            }
        }
        system.debug('End fetchColumnsToDisplay---->');
    }
    
    //This method is used to form the Hierarchy Wrapper List.
    private static void accountHierarchyFilter(Set<Id> parentAccountIds)
    {
        system.debug('Start accountHierarchyFilter---->');
        List<Id> parentAccountIdsList=new List<Id>();
        parentAccountIdsList.addAll(parentAccountIds);
        
        Set<Id> newParentIds=new Set<Id>();
        Integer positionOfChild=0;
        
        List<Account> allAccountsList=new List<Account>();
        allAccountsList.addAll(allAccountsMap.values());
        allAccountsList.sort();
        
        //For Topmost Parent.
        if(parentAccountIdsList.size()==0)
        {
            for(Integer i=0; i<allAccountsList.size(); i++)
            {
                if(allAccountsList[i].ParentId==Null)
                {
                    //Adding a Hierarchy Record.
                    HierarchyWrapper record=new HierarchyWrapper();
                    record.accountRec=allAccountsList[i];
                    record.marginVar=0*MARGIN;
                    allAccountsWrapperList.add(record);
                    
                    newParentIds.add(allAccountsList[i].Id);
                    break;
                }
            }
        }
        //For rest of the account records.
        else if(parentAccountIdsList.size()>0)
        {
            for(Integer j=0; j<parentAccountIdsList.size(); j++)
            {
                for(Integer i=0; i<allAccountsList.size(); i++)
                {
                    if(allAccountsList[i].ParentId==parentAccountIdsList[j])
                    {
                        Map<Integer, Integer> positionMarginOfParentMap=new Map<Integer, Integer>();
                        positionMarginOfParentMap.putAll(fetchPositionMarginOfParent(parentAccountIdsList[j]));
                        
                        if(positionOfChild==0)
                        {
                            positionOfChild=new List<Integer>(positionMarginOfParentMap.keySet())[0]+1;
                        }
                        else
                        {
                            positionOfChild=positionOfChild+1;
                        }
                        
                        HierarchyWrapper record=new HierarchyWrapper();
                        record.accountRec=allAccountsList[i];
                        record.marginVar=positionMarginOfParentMap.values()[0]+MARGIN;
                        if(allAccountsWrapperList.size()<positionOfChild+1)
                        {
                            allAccountsWrapperList.add(new HierarchyWrapper());
                        }
                        
                        if(allAccountsWrapperList.get(positionOfChild).accountRec==Null)
                        {
                            
                            allAccountsWrapperList.set(positionOfChild, record);
                        }
                        else
                        {
                            allAccountsWrapperList.add(positionOfChild, record);
                        }
                        
                        newParentIds.add(allAccountsList[i].Id);
                    }
                }
                positionOfChild=0;
            }
        }
        
        if(newParentIds.size()>0)
        {
            accountHierarchyFilter(newParentIds);
        }
        system.debug('End accountHierarchyFilter---->');
    }
    
    //This method return a map of Position and Margin of the Parent record.
    private static Map<Integer, Integer> fetchPositionMarginOfParent(Id parentId)
    {
        system.debug('Start fetchPositionMarginOfParent---->');
        Map<Integer, Integer> positionMarginMap=new Map<Integer, Integer>();
        
        for(Integer i=0; i<allAccountsWrapperList.size(); i++)
        {
            if(allAccountsWrapperList[i].accountRec.Id==parentId)
            {
                positionMarginMap.put(i, allAccountsWrapperList[i].marginVar);
                break;
            }
        }
        
        system.debug('End fetchPositionMarginOfParent---->');
        return positionMarginMap;
    }
    
    //This method adds the filter criteria to show Account Hierarchy on CPQ Mass Add Page
    private static void applyFilterCriteria()
    {
        GlobalSettings__c settings = GlobalSettings__c.getOrgDefaults();
        String userName = settings.Admin_Integration_Username__c;
        filterCondition = ' AND (Key_Rep__r.UserName != \'' + userName + '\') AND (Duplicate__c = false) AND (Key_Rep__r.Non_Interactive_User__c = false)';
    }
    
    //This class is used to wrap Account Record and the margin.
    //Margin is used to display the account shifted right from the Parent Account.
    public class HierarchyWrapper
    {
        public Account accountRec{get; set;}
        public Integer marginVar{get; set;}
    }
    
    //This class is used wrap Column API Name and Label to be displayed on the Visualforce page.
    public class ColumnNameLabelWrapper
    {
        public String columnName{get; set;}
        public String columnLabel{get; set;}
    }
}