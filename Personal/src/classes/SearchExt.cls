public class SearchExt {
    
    public final Account accsample;
    private List<Account> accTemp;
    public List<SelectOption> accList
    {
        get
        {
            accTemp = [Select Id, Name From Account];
            
            accList = new List<SelectOption>();
            
            for(Account temp : accTemp)
            {
                accList.add(new SelectOption(temp.Id, temp.Name));
            }
            return accList;
        }
        set;
    }

    public SearchExt(ApexPages.StandardController controller) {
        accsample = (Account)controller.getrecord();
    }
    

}