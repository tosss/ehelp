public class AutosearchController {
    @RemoteAction
    public static List<Account> searchResult(String pattern)
    {
    	pattern =pattern + '%';
        List<Account> accList = [select id , Name from account where name like: pattern Limit 5];
		System.debug(accList +pattern);
        return accList;
    }
}