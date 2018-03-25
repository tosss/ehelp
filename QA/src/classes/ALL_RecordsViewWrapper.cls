public class ALL_RecordsViewWrapper
{
    //Author Name: Anirudh Singh
    //Dated: 5th May, 2015
    //Description: This is a wrapper class to be used as a collection of all the attributes to be passed to the Parent Child Component.
    
    //This String is used to hold the Parent API Name.
    public String parentAPIName{get; set;}
    
    //This String is used to hold the Child API Name.
    public String childAPIName{get; set;}
    
    //This String is used to hold the relationship name of the Child Object.
    public String childRelationshipName{get; set;}
    
    //The String holds the Parent Column API Names.
    public String parentColumnNames{get; set;}
    
    //The String holds the Child Column API Names.
    public String childColumnNames{get; set;}
    
    //This Boolean is used to determine whether the Child Search Panel should be enabled or not.
    public Boolean childSearchEnabled{get; set;}
    
    //This String is used as a condition on Parent records.
    public String filterConditionParent{get; set;}
    
    //This String is used as a condition on Child records.
    public String filterConditionChild{get; set;}
    
    //This String is used as a condition on Parent records.
    public String mode{get; set;}
    
    //This String is used as a condition on Child records.
    public String redirectURL{get; set;}
    
    //25th May, 2015- Anirudh Singh- Commented the below parameter because there is new parameter defined for the same named parentFieldSortOrderAPINames.
    //This String is used for specifying the parent column name according to which the sort should happen.
    //public String parentSortColumnName{get; set;}
    
    //This Boolean variable is used to display the Create New Child button.
    public Boolean createNewChildEnabled{get; set;}
    
    //This property is used for setting the Parent Column Widths.
    public String parentColumnWidths{get; set;}
    
    //This property is used for setting the Child Column Widths.
    public String childColumnWidths{get; set;}
    
    //This Boolean is used to determine whether the Edit button should be enabled or not.
    public Boolean editEnabled{get; set;}
    
    //This Boolean is used to determine whether the Quick Save button should be enabled or not.
    public Boolean quickSaveEnabled{get; set;}
    
    //This Boolean is used to determine whether the Save button should be enabled or not.
    public Boolean saveEnabled{get; set;}
    
    //This Boolean is used to determine whether the Delete button should be enabled or not.
    public Boolean deleteEnabled{get; set;}
    
    //This Boolean is used to determine whether the Mass Update button should be enabled or not.
    public Boolean massUpdateEnabled{get; set;}
    
    //This Boolean if set to true is used to display datatables; if set to false is used to display error message.
    public Boolean dataAvailable{get; set;}
    
    // 2015-05-13 PH DATE Rey Austral - rename the variable and delete the childCreateEnabled
    //This Boolean attribute will determine whether the Create button exists at the parent level, and will be based upon both of the following being true
    public Boolean createNewParentEnabled{get; set;}
    
    //2015-05-13 IST Date Anirudh Singh
    //This Boolean attribute when set to true will require the user to save atleast 1 child record for the newly created parent record.
    public Boolean parentRequiresChildren{get; set;}
    
    //21st May, 2015- Anirudh Singh
    //This String is used to hold the relationship Field Name On Parent, through which the Parent should be linked.
    public String grandparentRelationshipField{get; set;}
    
    //2015-05-22 Karl Simon
    //The String holds the Parent Column API Names for just the sort columns to include in the Order By clause during query construction.
    public String parentFieldSortOrderAPINames{get; set;}
    
    //2015-05-22 Karl Simon
    //The String holds the Child Column API Names for just the sort columns to include in the Order By clause during query construction.
    public String childFieldSortOrderAPINames{get; set;}
    
    //25th May, 2015- Anirudh Singh
    //This String is used to hold the field Name to be displayed in the picklist for the grandparent.
    public String grandparentDisplayFieldName{get; set;}
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This String will hold the API Names of the Child Fields that need to be disabled for editing.
    public String childFieldsToDisableForRow{get; set;}
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This String will hold the API Names of the Parent Fields that need to be disabled for editing.
    public String parentFieldsToDisableForRow{get; set;}
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This String will hold the API Name of the Child Field whose value will determine- 
    //for which records the fields specified in childFieldsToDisableForRow should be disabled.
    public String childDisableCheckField{get; set;}
    
    //2015-07-29- anirudh.singh@cdk.com- Added this parameter.
    //This String will hold the API Name of the Parent Field whose value will determine- 
    //for which records the fields specified in parentFieldsToDisableForRow should be disabled.
    public String parentDisableCheckField{get; set;}
    
    public Boolean rerenderDatatable{get; set;}
    
    public String parentrelationshipFieldName{get; set;}
}