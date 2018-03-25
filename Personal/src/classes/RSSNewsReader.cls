public class RSSNewsReader {
     
    public String rssQuery {get;set;}
    private String rssURL {get;set;}
     
    public RSSNewsReader() {
         
        rssURL = 'http://feeds.abcnews.com/abcnews/topstories';
        rssQuery = ''; //default on load
         
    }
     
    public RSS.channel getRSSFeed() {
        return RSS.getRSSData(rssURL + EncodingUtil.urlEncode(rssQuery,'UTF-8'));
    }
     
 
}