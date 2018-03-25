global class ALL_UtilitiesData 
{
    //createdby Matt.Keefe@cdk.com
    global static Object GetDataFromNestedFields( string FieldName, sObject ParseObject )
    {
        //system.debug( FieldName );
        //system.debug( ParseObject );
        
        Object FieldValue = null;
        
        // if nested query fields, get the nested field value
        if( FieldName.contains( '.' ) )
        {
            List<string> NestedFields = FieldName.split( '\\.' ); system.debug( NestedFields );
            sObject RelationshipSObject = ParseObject.getSObject( NestedFields[0] ); //system.debug( RelationshipSObject );
            
            for( Integer j=1; j<NestedFields.size()-1; j++ ) {
                RelationshipSObject = RelationshipSObject.getSObject( NestedFields[j] ); //system.debug( RelationshipSObject ); 
            }
            
            if( RelationshipSObject != null ) 
            {
                string NestedFieldName = NestedFields[NestedFields.size()-1];
                
                //try { // try to get the value, but if error do not set the FieldValue ( return null )
                FieldValue = NestedFieldName.toLowerCase().endsWith( '__r' ) ? 
                    RelationshipSObject.getSObject( NestedFieldName ) :
                RelationshipSObject.get( NestedFieldName );
                //}
                //catch( Exception e ) { system.debug( e ); }
            }
        }
        // otherwise, get the field value directly
        else 
        { 
            //try { // try to get the value, but if error do not set the FieldValue ( return null )
            FieldValue = FieldName.toLowerCase().endsWith( '__r' ) ? 
                ParseObject.getSObject( FieldName ) : 
            ParseObject.get( FieldName ); 
            //}
            //catch( Exception e ) { system.debug( e ); }
        }
        
        return FieldValue;
    }
    
    //createdby Matt.Keefe@cdk.com
    global static sObject PutDataInNestedFields( string FieldName, sObject OverrideSObject, Object ReplacementFieldValue )
    {
        // if nested replacement fields, get the nested sObject
        system.debug( OverrideSObject + ' - ' + FieldName + ReplacementFieldValue );
        if( FieldName.contains( '.' ) ) 
        {
            List<string> NestedFields = FieldName.split( '\\.' ); //system.debug( NestedFields );
            sObject RelationshipSObject = OverrideSObject.getSObject( NestedFields[0] );
            
            for( Integer j=1; j<NestedFields.size()-1; j++ ) {
                RelationshipSObject = RelationshipSObject.getSObject( NestedFields[j] ); }
            
            RelationshipSObject.put( NestedFields[NestedFields.size()-1], ReplacementFieldValue );
        }
        // otherwise, put the field value directly
        else { OverrideSObject.put( FieldName, ReplacementFieldValue ); }
        
        return OverrideSObject;
    }
    
    //createdby Siva.Pragada@cdk.com
    public Static void SerializesObjectList( List<sObject> TobeDMLdsObjectList, string dmlOperation )
    {
        List<sObject> oldList; map<Id, sObject> oldMap; map<Id, sObject> newMap;
        DS_EncapsulationHelperClass TobeInsertedTaskEncapsule = new DS_EncapsulationHelperClass( 
            TobeDMLdsObjectList, oldList, oldMap, newMap );
        
        string SerializedTasksToInsert = JSON.Serialize( TobeInsertedTaskEncapsule );
        
        if( !System.isBatch() && !System.isFuture() && !System.isScheduled() && 
           TobeDMLdsObjectList != null && !TobeDMLdsObjectList.isEmpty() ) 
        {
            ALL_UtilitiesData.FutureUpdateORinsertsObjects( SerializedTasksToInsert, dmlOperation );
        }  
    }
    
    @future //createdby Siva.Pragada@cdk.com
    public static void FutureUpdateORinsertsObjects( String Serialized, string dMLOperation )
    {
        try
        {
            
            DS_EncapsulationHelperClass Unserialized = null;      
            
            Unserialized = ( DS_EncapsulationHelperClass )JSON.deserialize( serialized, DS_EncapsulationHelperClass.class );
            List<sObject> sObjectListToInsertORUpdate = Unserialized.newSObjectList;
            map<string, sObject> UpdateMap = new map<string, sObject>();
            
            if( sObjectListToInsertORUpdate != null && !sObjectListToInsertORUpdate.isEmpty() )
            {
                for( sObject sObj: sObjectListToInsertORUpdate )
                { 
                    if( sObj.ID != null )
                    { 
                        UpdateMap.put( sObj.ID, sObj );
                    }
                    else
                    { 
                        UpdateMap.put( string.ValueOf( ALL_UtilitiesRandom.CryptoRandom() ), sObj );
                    }
                    
                }
            }
            
            if( sObjectListToInsertORUpdate != null && !sObjectListToInsertORUpdate.isEmpty() )   
            {  
                list<Database.SaveResult> saveResults;
                
                if( dMLOperation.equalsIgnoreCase( 'insert' ) )
                { 
                    saveResults = Database.Insert( UpdateMap.values(), false ); 
                }
                
                if( dMLOperation.equalsIgnoreCase( 'update' ) )
                { 
                    saveResults = Database.Update( UpdateMap.values(), false ); 
                }
                
                if( dMLOperation.equalsIgnoreCase( 'delete' ) )
                { 
                    list<Database.DeleteResult> deleteResults = Database.Delete( UpdateMap.values(), false );                    
                }
                
                if(saveResults != null)
                {
                    All_UtilitiesMiscellaneous.logDmlFailedRecords(saveResults);
                }
            }        
            
        }
        Catch(Exception Exp)
        {
            ALL_UtilitiesMiscellaneous.logException(Exp); 
        }
    }
    
    //createdby Siva.Pragada@cdk.com
    public static map<string, map<string, string>> OrganizeFieldValueConditionsInaMap()
    {
        List<Field_Value_Conditions__c> FVC = Field_Value_Conditions__c.getAll().Values();
        map<string, map<string, string>> FieldValuesOrganizedMap = new map<string, map<string, string>>();       
        
        for(Field_Value_Conditions__c fv: FVC) 
        {
            map<String, string> FieldNamesMap = FieldValuesOrganizedMap.get('FieldNames');
            if(FieldNamesMap == null ){ FieldNamesMap = new map<string, string>();}
            FieldNamesMap.put(fv.Identifier__c, fv.Field_Name__c);
            FieldValuesOrganizedMap.put('FieldNames', FieldNamesMap);
            
            map<String, string> FieldValuesMap = FieldValuesOrganizedMap.get('FieldValues');
            if(FieldValuesMap == null ){ FieldValuesMap = new map<string, string>();}
            FieldValuesMap.put(fv.Identifier__c, fv.Field_Value__c);
            FieldValuesOrganizedMap.put('FieldValues', FieldValuesMap);
        }
        
        return FieldValuesOrganizedMap;
    }
    
    //createdby Siva.Pragada@cdk.com
    public static boolean CompareTheValues(String IdentifierString, sObject sObj)
    {        
        map<string, map<string, string>> FieldValuesOrganizedMap = ALL_UtilitiesData.OrganizeFieldValueConditionsInaMap(); 
        
        map<string, string> FieldNamesMap = FieldValuesOrganizedMap.get('FieldNames');
        map<string, string> FieldValuesMap = FieldValuesOrganizedMap.get('FieldValues');
        
        boolean ValuesMatch = null;
        
        list<string> Values = new list<string>();
        if(IdentifierString != null && IdentifierString.contains('AND'))
        {
            Values = IdentifierString.split('AND');
        }
        else 
        {
            Values.add(IdentifierString);
        }
        set<string> FieldValuesSetFromCustomSettings = new set<string>();
        set<string> FieldValuesOnCurrentRecord = new set<string>();
        
        for(string s: Values)
        {    
            s = s.normalizeSpace();
            FieldValuesSetFromCustomSettings.add(FieldValuesMap.get(s));
            
            
            if(FieldNamesMap.get(s) != null)
            {
                if(FieldValuesMap.get(s).equalsIgnoreCase('not null') && 
                   sObj.get(FieldNamesMap.get(s)) != null)
                {
                    FieldValuesOnCurrentRecord.add('Not Null');
                }
                else if(FieldValuesMap.get(s).equalsIgnoreCase('null') && 
                        string.valueOf(sObj.get(FieldNamesMap.get(s))) == null)
                {
                    FieldValuesOnCurrentRecord.add('Null');
                }
                else
                {
                    FieldValuesOnCurrentRecord.add(string.ValueOf(sObj.get(FieldNamesMap.get(s))));
                }
            }
        }  
        
        ValuesMatch = !FieldValuesOnCurrentRecord.isEmpty() && FieldValuesOnCurrentRecord.equals(FieldValuesSetFromCustomSettings);
        
        return ValuesMatch;
    }
}