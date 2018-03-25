@isTest
public class All_UtilitiesString_Test 
{
    //added by Lalitha Adduru
    public static testmethod void removeListOfStringsFromString() {        
    	List<String> strings  = ALL_UtilitiesString_Test.NewStringList(); 
        String resultString = ALL_UtilitiesString.removeListOfStringsFromString('SampleString',strings,',');
        system.assertEquals('SmplString', resultString);
    }
    
    //added by Lalitha Adduru
    public static testmethod void ListToDelimitedString(){
        List<String> strings = ALL_UtilitiesString_Test.NewStringList();
        strings.add('');
        String delimitedString = ALL_UtilitiesString.ListToDelimitedString(strings,',');
    	system.assertEquals('a,b,c,d,e', delimitedString);
    } 
    
    //added by Lalitha Adduru
    public static testmethod void removeDuplicatesFromDelimitedString()
    {
        String testString = 'test, test, test, testone';
        testString = ALL_UtilitiesString.removeDuplicatesFromDelimitedString(testString, ', ');
        system.assertEquals('test, testone', testString);                
    }
    
    //added by Lalitha Adduru
    public static testmethod void delimitedStringToList()
    {
        String testString = 'test, test1, test2, '+null;
        List<String> resultList = new List<String>();
        resultList = ALL_UtilitiesString.delimitedStringToList(testString, ', ');
        List<string> expectedList = new List<String>{'test','test1','test2'};
        system.assertEquals(expectedList, resultList);
    }
    
    //added by Lalitha Adduru
    public static testmethod void removeNullsFromDelimitedString()
    {
        String testString = 'test, test1, test2, '+null+', test3, '+null;
        testString  = ALL_UtilitiesString.removeNullsFromDelimitedString(testString, ', ');
        system.assertEquals('test, test1, test2, test3', testString);
    }
    
    public static testmethod List<String> NewStringList() { return new List<String>{'a','b','c','d','e'}; }
    
    //Createdby Matt.Keefe@cdk.com
    public static testmethod void ListToInclusiveCondition() 
	{
		List<String> strings = All_UtilitiesString_Test.NewStringList(); 
		ALL_UtilitiesString.ListToInclusiveCondition('test','',null);
		string actual1 = ALL_UtilitiesString.ListToInclusiveCondition('where','id',new List<String>{'a'});
        system.assertEquals('where id = \'' + 'a\'', actual1);
		ALL_UtilitiesString.ListToInclusiveCondition('where','id',strings);
        
	}
    
    //Createdby Matt.Keefe@cdk.com
    public static testmethod void ListToParenthesisCsv() 
    {  
		List<String> strings = All_UtilitiesString_Test.NewStringList(); ALL_UtilitiesString.ListToParenthesesCsv(strings); 
    }
    
    //Createdby Matt.Keefe@cdk.com
    public static testmethod void ListToEnclosedCsv() 
    {  
		List<String> strings = All_UtilitiesString_Test.NewStringList(); ALL_UtilitiesString.ListToEnclosedCsv(strings, '$'); 
    }
    
    //Createdby Matt.Keefe@cdk.com
    public static testmethod void ListToCSV() 
    {
		List<String> strings = All_UtilitiesString_Test.NewStringList(); ALL_UtilitiesString.ListToCsv(strings); 
    }
    
    //Createdby Matt.Keefe@cdk.com
    public static testmethod void ListToString() 
    {
		List<String> strings = All_UtilitiesString_Test.NewStringList(); ALL_UtilitiesString.ListToString(strings); 
    }

}