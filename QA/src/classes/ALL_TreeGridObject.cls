/************************************************************************************************
* Author: Ragashalini.Koka@cdk.com
* Description: Wrapper Class for Angular TreeGrid implementation
* Test Class: NA
* History  
* 2016-03-01    RagaShalini.Koka@cdk.com    added a new variable relationshipName_c
* 2016-03-07    RagaShalini.Koka@cdk.com    added a new variable keyPrefix_c
* 2016-04-11    RagaShalini.Koka@cdk.com    added a variable to determine the sort sequence
* 2016-04-13    RagaShalini.Koka@cdk.com    added logic to get the picklist values 
* ************************************************************************************************* */
global class ALL_TreeGridObject {
   	public String objectAPIName_c;
    public String parentName_c;
    public String childRelationshipName_c;
    public String displayName_c;
    public String parentAPIName_c;
    public String parentRelationshipName_c;
    public String treegridIdentifier_c;
    public String keyPrefix_c;
    public String sortSequence_c;
    public Map<String,ALL_TreeGridFields> fieldsMap;
    public Map<String,List<ALL_AngularInputFields_Controller.Picklist>> picklistValuesMap;
    
    public ALL_TreeGridObject(String objectName,String treeIdentifier) {
        List<ALL_Treegrid_Object__c> treeGridObjectList = ALL_Treegrid_Object__c.getAll().values();
      	fieldsMap = new Map<String,ALL_TreeGridFields>();
       
        
        //identifies the object with given name and tree identifier
        for(ALL_Treegrid_Object__c treeGridObject : treeGridObjectList ) {
            
            if(treeGridObject.ObjectAPIName__c.equalsIgnoreCase(objectName) && treeGridObject.TreegridIdentifier__c.equalsIgnoreCase(treeIdentifier)) {
               
                Schema.DescribeSObjectResult sObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
                objectAPIName_c = treeGridObject.ObjectAPIName__c;
                parentName_c = treeGridObject.ParentName__c;
                childRelationshipName_c = treeGridObject.ChildRelationShipName__c;
                displayName_c = sObjectResult.getLabelPlural(); 
                parentAPIName_c = treeGridObject.ParentAPIName__c;
                parentRelationshipName_c = treeGridObject.ParentRelationShipName__c;
                treegridIdentifier_c = treeGridObject.TreegridIdentifier__c;
                keyPrefix_c = sObjectResult.getKeyPrefix();
               	Map<string,Schema.SObjectField> fieldMap = sObjectResult.fields.getMap();
				ALL_TreeGrid_Field__c treegridFields= ALL_TreeGrid_Field__c.getValues(treeGridObject.Name);
                sortSequence_c = IMP_Project_Utility.getOrderColumns(sObjectResult.fieldSets.getMap().get(treegridFields.Sort_Fieldset__c).getFields(), true);
                picklistValuesMap = new Map<String,List<ALL_AngularInputFields_Controller.Picklist>>();
                List<Schema.FieldSetMember> fieldSetMemberList = sObjectResult.fieldSets.getMap().get(treegridFields.FieldSetName__c).getFields();
              
                for(Schema.FieldSetMember field : fieldSetMemberList ) {
                    ALL_TreeGridFields treeGridField = new ALL_TreeGridFields(fieldMap,field,treegridFields.ObjectAPIName__c);
                    if(treeGridField != null) {
                        fieldsMap.put(treeGridField.fieldAPIName_c, treeGridField);
                        if(treeGridField.pickList != null && treeGridField.pickList.size() > 0) {
                            picklistValuesMap.put(objectAPIName_c + '-' + treeGridField.fieldAPIName_c , treeGridField.pickList);
                        }
                    }
                }
               
                break;
                
            }
        }
        
       
        
        
    }
    
       global class ALL_TreeGridFields {
        
        public String fieldAPIName_c;
        public String fieldOf_c;
        public String fieldType_c;
        public Boolean isAccessible_c;
        public Boolean isCreateable_c;
        public Boolean isDependent_c;
        public Boolean isFormula_c;
        public Boolean isNillable_c;
        public Boolean isUpdateable_c;
        public String label_c;
        public String referenceTo_c;
        public String relationshipName_c;   
        public List<ALL_AngularInputFields_Controller.Picklist> pickList;
        
         //fetching picklist values if the type is Picklist
        public ALL_TreeGridFields(Map<string,Schema.SObjectField> fieldMap, Schema.FieldSetMember field,String fieldOf) {
            Schema.DescribeFieldResult fieldRes = fieldMap.get(field.getFieldPath()).getDescribe();
            fieldAPIName_c = field.getFieldPath();
            fieldOf_c = fieldOf;
            fieldType_c = String.ValueOf(fieldRes.getType());
            isNillable_c =   fieldRes.isNillable();
            isUpdateable_c = fieldRes.isUpdateable();
            isAccessible_c = fieldRes.isAccessible();
            isDependent_c =  fieldRes.isDependentPicklist();
            label_c = fieldRes.getLabel();
            isFormula_c = fieldRes.isCalculated();
            isCreateable_c = fieldRes.isCreateable();
            
            if(fieldRes.getType() == Schema.DisplayType.REFERENCE) {
                referenceTo_c  = fieldRes.getReferenceTo()[0].getDescribe().getName();
                relationshipName_c = fieldRes.getRelationshipName();
            }
            
            else if(fieldRes.getType() == Schema.DisplayType.PICKLIST) {
         
               pickList =  ALL_AngularInputFields_Controller.getPicklistValues(fieldOf, fieldAPIName_c);
                
               
                
            }
            
            
            
            
        }
        
        
        
        
    }

}