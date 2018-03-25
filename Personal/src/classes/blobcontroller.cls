public class blobcontroller {
    public FeedItem f{get;set;}
    public String b{get;set;}
    public String b2{get;set;}
    public blobcontroller()
    {
        f = [select id, ContentType,title, ContentData, Body from feeditem where Id='0D59000001thaBuCAI'];
        b = EncodingUtil.Base64Encode(f.ContentData);
        f = [select id, ContentType,title, ContentData,ContentSize, Body from feeditem where Id='0D59000001xCAZPCA4'];
        b2 = EncodingUtil.Base64Encode(f.ContentData);
    }
}