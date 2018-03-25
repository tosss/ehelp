public class All_IdeaList {
    public transient List<Idea> allIdeas{get;set;}
    public All_IdeaList()
    {
        allIdeas = [SELECT id, title,CreatorName,CreatedDate, creatorsmallphotourl from Idea Limit 10];
    }
}