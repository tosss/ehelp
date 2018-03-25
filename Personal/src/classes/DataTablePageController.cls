public with sharing class DataTablePageController
{
    //Author     : Anirudh Singh
    //Date       : 4th Dec, 2014
    //Description: This controller is used for the DataTablePage Visualforce page for DataTable POC.
    
    private List<Account> accountList;
    
    public List<Account> displayAccountList
    {
        get
        {
            return accountList;
        }
        set
        {
            accountList=value;
        }
    }
    
    public DataTablePageController()
    {
        accountList=[SELECT Id, Name, ParentId FROM Account LIMIT 200];
    }
    
    @RemoteAction
    public static PageReference save(String SelectedIds)
    {
        system.debug('SelectedIds---->'+SelectedIds);
        return Null;
    }
}