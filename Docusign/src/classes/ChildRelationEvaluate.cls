public class ChildRelationEvaluate
{
    public static Boolean evl(String operand, String Operator, String value, String ParentId, String ParentObjectName)
    {
        List<Boolean> results = new List<Boolean>();
        String fieldName = operand.split('\\.')[1];
        string childRelName = operand.split('\\.')[0];
        List<Sobject> slist = Database.query('select id, '+'(select id,'+fieldName+' from '+childRelName+' )'+' from '+ParentObjectName+' where id = \''+ParentId+'\'');
        for(Sobject s: slist[0].getSobjects(childRelName))
        {
            if(CustomSettings.Expression(String.valueof(s.get(fieldName)), Operator, value))
            {
                results.add(true);
            }
            else
            {
                results.add(false);
            }
        }
        return String.valueof(results).contains('true');
    }
}