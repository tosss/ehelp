public class Account_Extension {

    private final Account accountSample;

    public Account_Extension(ApexPages.StandardController controller)
    {
        accountSample= (Account)controller.getRecord();
    }

    public PageReference connectOffLine()
    {
         PageReference page = new PageReference('https://ap1.salesforce.com/setup/offline/offlinebriefcase.jsp?addId='+accountSample.id);
         page.setRedirect(true);
         return page;  
    }

    public PageReference cancel()
    {
         PageReference page = Apexpages.currentpage();
         page.setRedirect(true);
         return page;  
    }

    public PageReference resetInlineEdit()
    {         
         PageReference page = Apexpages.currentpage();
         page.setRedirect(true);
         return page;  
    }

    public PageReference save()
    {
         upsert accountSample;
         PageReference page = Apexpages.currentpage();
         page.setRedirect(true);
         return page;  
    }
}