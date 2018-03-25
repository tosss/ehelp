/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Assigns value to the MigrationId field by getting the Definition Name and the SFInstanceIdentifier from Custom_Settings__c
Test Class: IMP_SetMigrationIDtoDefinitions_Test
History
07/23/2015    Kimiko Roberto    Created
------------------------------------------------------------*/
public class IMP_SetMigrationIDtoDefinitions_Handler
{

    public static void setMigrationId(List<sObject> definitionList, Schema.DescribeSObjectResult objectApiName, String SFInstanceIdentifier)
    {
        //generic list for the definitions
        List<Sobject> sObjectList = new List<sObject>();
        
        if(objectApiName != null)
        {
            //Identify the correct definition object type through Schema.DescribeSObjectResult
            String queryDetails = 'SELECT Name,Migration_ID__c FROM ' + objectApiName.getSobjectType() + ' WHERE Id IN: definitionList';
            sObjectList = database.Query(queryDetails);
        }
        
        //Assign migration id for the definition
        if(SFInstanceIdentifier != null && SFInstanceIdentifier != '')
        {
            
            if(sObjectList != null && !sObjectList.isEmpty())
            {
                
                for(sObject def : sObjectList)
                {
                    if (def.get('Migration_ID__c') == null)
                    {
                        //concatenate the Name of the definition and SFInstanceIdentifier separated by a collon
                        def.put('Migration_ID__c',def.get('Name') + ':' + SFInstanceIdentifier);
                    }
                    
                }
                //update the definition
                update sObjectList;
            }
        }   
    }
}