@IsTest
public class DataTablesControllerTest
{
    public static testmethod void Test()
    {
    	sObject s = new Account(Name='Test'); insert s;
    	
    	DataTablesController dtc = new DataTablesController();
        DataTablesController.DataWithSelection dws = new DataTablesController.DataWithSelection(s);
        
        dtc.DisplayDataInitialized = false;
        dtc.DisplayCheckboxes = false;
        dtc.DisplayColumns = 'Id,Name';
        dtc.OriginalData = new sObject[]{s};
    }
}