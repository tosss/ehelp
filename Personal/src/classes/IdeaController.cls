public class IdeaController {
    public Idea ide{get;set;}
    public List<IdeaComment> cms{get;set;}
    public List<AggregateResult> vts{get;set;}
    public IdeaController()
    {
        ide=[select id, title,body,isHtml,votescore from idea where id='08790000000LVXW'];
        cms=[select id, commentbody,isHtml from ideacomment where ideaid = '08790000000LVXW'];
        vts= [select count(id) vtcount, type from vote where parentid = '08790000000LVXW' group by type];
    }
    
    
}