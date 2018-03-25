//2016-04-12 lalitha.adduru@cdk.com created RQ-08028
//2017-06-05 lalitha.adduru@cdk.com updated
//2017-06-05 matt.keefe@cdk.com - updated formatting, task query
public class MyTasks_Controller 
{
    public List<Task> taskList{set; get;}
    public string sortingOrder{set; get;}
    public string columnToBeSorted{set; get;}
    public string dateFilter{Set; get;}
    public string dateFilterSelected{Set; get;}
    
    public MyTasks_Controller()
    {
        sortingOrder='ASC';
        columnToBeSorted = 'ActivityDate';
        cookie dateFilterCookie = ApexPages.currentPage().getCookies().get('dateFilter');
        system.debug('dateFilterCookie in constructor -- >'+dateFilterCookie);
        
        if(dateFilterCookie == null)
        {
            dateFilter = 'ActivityDate=Today';
            dateFilterCookie = new Cookie('dateFilter',dateFilter,null,-1,false);
            ApexPages.currentPage().setCookies(new Cookie[]{dateFilterCookie});
        }
        else
        {
            dateFilter = dateFilterCookie.getValue();            
        }
        //dateFilter = 'ActivityDate=Today';
        fetchTasks();
    }
    
    
    public string fetchColumnToBeSorted
    {
        get
        {
            return columnToBeSorted;
        }
        set
        {
            if(system.currentPageReference().getParameters().get('column') == columnToBeSorted)
            {
                sortingOrder = (sortingOrder == 'ASC') ? 'DESC' :'ASC';
            }
            else
            {
                columnToBeSorted = system.currentPageReference().getParameters().get('column');
                sortingOrder = 'ASC';
            }
        }
    }
    
    
    public void fetchTasks()
    {
        Cookie dateFilterCookie = new Cookie('dateFilter',dateFilter,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{dateFilterCookie});
        system.debug('dateFilterCookie -- > in fetch tasks'+dateFilterCookie);
        
        String createdById = UserInfo.getUserId();
        String completed = 'Completed';       
        String query = 
            'SELECT ID, Status, Subject, AccountId, Account.Name, WhatId, What.Name, ActivityDate, Primary_Account__c, Primary_Account__r.Name, Priority ' + 
            'FROM Task ' + 
            'WHERE OwnerId = \''+createdById+'\' ' + 
            'AND '+datefilter+' ' + 
            'AND Status !=\''+Completed+'\' ' + 
            'ORDER BY '+columnToBeSorted+' '+sortingOrder;
        
        taskList = new List<Task>();
        taskList = database.query(query);
        
        if(taskList.isEmpty())
        {
            taskList=null;
        }
    }
    
}