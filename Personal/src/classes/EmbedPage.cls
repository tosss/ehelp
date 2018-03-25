public class EmbedPage {
    public Map<String,String> pageList{get;set;}
    public String i{get;set;}
    public EmbedPage()
    {
        pageList = new Map<String,String>();
        pageList.put('0','Sample');
        pageList.put('1','Sample2');
    }
}