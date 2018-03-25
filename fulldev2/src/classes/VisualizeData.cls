public class VisualizeData 
{
  @RemoteAction
    public static List<Visualize> visualize(String objectName, String Field, String whereclause)
    {
        List<AggregateResult> allsobject = new List<AggregateResult>();
        Datetime newDate = DateTime.now().addYears(-1);
        allsobject = Database.query('SELECT count(Id), '+Field+' FROM '+ objectName+(whereclause!=null && whereclause!=''?' where '+whereclause:'')+' group by '+Field);
        List<Visualize> vList = new List<Visualize>();
        for(AggregateResult ag : allsobject)
        {
            Visualize vobj = new Visualize((String)ag.get(Field),(Integer)ag.get('expr0'));
            vList.add(vobj);
        }
        return vList;
    }
    public class Visualize
    {
        String columnName;
        Integer value;
        public Visualize(String field,Integer count)
        {
            columnName = field;
            value = count;
        }
    }
}