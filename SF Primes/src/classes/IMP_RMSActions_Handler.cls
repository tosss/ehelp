/*------------------------------------------------------------
Author:      Samuel Oberes 
Company:     Cloud Sherpas
Description: Contain methods that cater to the needs of the RMS integration.
History
07/13/15     Samuel Oberes     Created
------------------------------------------------------------*/
public class IMP_RMSActions_Handler 
{
    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: ONLY USE ON TRIGGERS. Gets values from the current record's definition object, then stamps it to the record's fields. Fields needed to get stamped are listed inside the fieldset named 'RMS_Related_Fields'.
    Inputs:      Schema.DescribeSObjectResult -- where the fieldset will come from | Set of Definition IDs | List of records that needs to get stamped
    Returns:     n/a
    History
    07/13/15     Samuel Oberes       Created
    09/21/15     Samuel Oberes       Added error for missing definitions (IMP_String_Utility.MISSING_DEFINITION)
    ------------------------------------------------------------*/
    public static void stampFieldsWithDefinitionValues(Schema.DescribeSObjectResult describedDefinitionSObject, Set<Id> contextDefinitionIdsSet, List<SObject> recordsToGetStampedList) 
    {
        // processing is not needed if there are no definition objects to get values from, and if there are no records to stamp (obviously)
        if ((describedDefinitionSObject != null) && (contextDefinitionIdsSet != null && contextDefinitionIdsSet.size() > 0) && (recordsToGetStampedList != null && recordsToGetStampedList.size() > 0))
        {
            // these are the rms related fields of the definition object of the current trigger context

            // if there are no fieldsets for the object at hand, skip processing. (null value might never happen. a map with 0 size might always be the case instead of null.)
            Map<String, Schema.FieldSet> fieldsetMap = describedDefinitionSObject.fieldSets.getMap();
            if (fieldsetMap == null || fieldsetMap.size() == 0) 
            {
                // return nothing
                return; 
            }

            // if there is no fieldset by the name of 'RMS_Related_Fields', skip processing
            Schema.FieldSet fieldSet = fieldsetMap.get('RMS_Related_Fields');
            if (fieldSet == null)
            {
                // return nothing
                return; 
            }

            // if there are not fieldsetmembers, skip processing
            List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
            if (fieldSetMembers == null || fieldSetMembers.size() == 0)
            {
                // return nothing
                return; 
            }

            String definitionObject = describedDefinitionSObject.getName();

            Map<Id, SObject> definitionRecordsList = new Map<Id, SObject>(IMP_Project_Utility.queryRelatedRecords(fieldSetMembers, 
                                                                                                                  definitionObject, 
                                                                                                                  IMP_Project_Utility.QUERY_NAME_ID, 
                                                                                                                  null, 
                                                                                                                  contextDefinitionIdsSet, 
                                                                                                                  null, 
                                                                                                                  null, 
                                                                                                                  true, 
                                                                                                                  0));
            
            // loop through all the (e.g milestone, activity, task, etc.)
            for (SObject currentRecord : recordsToGetStampedList)
            {
                if (definitionRecordsList.get( (Id)currentRecord.get(definitionObject) ) == null)
                {
                    currentRecord.addError(IMP_String_Utility.MISSING_DEFINITION);
                }
                else
                {
                    // loop through all the fields in the fieldsetmember. objective here is to get the field name (in string value) and use it as the 1st parameter of the currentRecord.put method.
                    // the idea: 1st parameter is a field name, 2nd parameter is the value that we are stamping to the corresponding field stated in the 1st parameter
                    for (Schema.FieldSetMember fsm : fieldSetMembers)
                    {
                        currentRecord.put(fsm.getFieldPath(), definitionRecordsList.get( (Id)currentRecord.get(definitionObject) ).get( fsm.getFieldPath() ));
                    }
                }
            }
        }

    }

}