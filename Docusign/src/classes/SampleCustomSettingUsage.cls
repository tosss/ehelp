public class SampleCustomSettingUsage 
{
    List<Sobject> o;
    List<Boolean> results;
    public SampleCustomSettingUsage(String type, List<String> Ids, String sobjectName)
    {
        ALL_Docusign_Contacts__c cs =ALL_Docusign_Contacts__c.getall().get(type);
        results = new List<Boolean>();
        List<Boolean> resultList = new List<boolean>();
        String fieldNames= ''; 
        for(Integer i=1;i<4;i++)
        {
            if(cs.get('condition_'+i+'__c') != 'N/A')
            {
                List<String> booleans = CustomSettings.breakExpressionToOperands(String.valueof(cs.get('condition_'+i+'__c')));
                if(!booleans[0].contains('[]'))
                {
                    fieldNames += booleans[0]+',';
                }
                else
                {
                    fieldNames += 'Account.Id,';
                }
            }
        }
        o = Database.Query('Select '+fieldNames+'Id from '+sobjectName+' where id in: Ids');
        for(integer j=0;j<o.size();j++)
        {
        for(Integer i=1;i<4;i++)
        {
            Boolean setValue = false;
            if(cs.get('condition_'+i+'__c') != 'N/A')
            {
                List<String> booleans = CustomSettings.breakExpressionToOperands(String.valueof(cs.get('condition_'+i+'__c')));
                String fieldName =booleans[0].trim();
                Boolean resultofCondition1;
                if(!fieldName.contains('.'))
                {
                    resultofCondition1 = CustomSettings.Expression(String.valueof(o[j].get(fieldName)), booleans[1].trim(), booleans[2].trim());
                }
                else
                {
                    if(fieldName.split('\\.',2)[0].endswith('[]'))
                    {
                        resultList.add( ChildRelationEvaluate.evl(fieldName.replace('[]',''), booleans[1].trim(),booleans[2].trim(), String.valueof(o[j].get('Id')), String.valueOf(o[j].getSObjectType())));
                    	setValue = true;
                    }
                            
                    Sobject sobjectDesc = o[j].getSobject(fieldName.split('\\.',2)[0]);
                    fieldName= fieldName.split('\\.',2)[1];
                    while(fieldName.contains('.') && !setValue)
                    {
                        if(fieldName.split('\\.',2)[0].endswith('[]'))
                        {
                            resultofCondition1 = ( ChildRelationEvaluate.evl(fieldName.replace('[]',''), booleans[1].trim(),booleans[2].trim(), String.valueof(sobjectDesc.get('Id')), String.valueOf(sobjectDesc.getSObjectType())));
                        	setValue = true;
                        }
                        else
                        {
                            sobjectDesc = sobjectDesc.getSobject(fieldName.split('\\.',2)[0]);
                            fieldName = fieldName.split('\\.',2)[1]; 
                        }
                    }
                    if(!setValue)
                    {
                        resultofCondition1 = CustomSettings.Expression(String.valueof(sobjectDesc.get(fieldName)), booleans[1].trim(), booleans[2].trim());
                    }
                }
                resultList.add(resultofCondition1);
                
            }
            else
            {
                resultList.add(false);
            }
        }
        results.add(EvaluateBooleanExpression.evaluateInfixExpression(CustomSettings.conditionsToinfixExpression(resultList,cs.criteria__c)));
        }
        System.debug(results);
    }
}