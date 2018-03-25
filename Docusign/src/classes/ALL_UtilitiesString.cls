global class ALL_UtilitiesString 
{ 
    // Createdby Matt.Keefe@cdk.com
    global static string ListToInclusiveCondition( string WhereOrAnd, string FieldName, List<string> Values ) 
    {
        string WhereOrAndLower = WhereOrAnd != null ? WhereOrAnd.ToLowerCase() : null;
        
        // validation
        if( WhereOrAndLower != 'where' && WhereOrAndLower != 'and' 
        || FieldName.length() < 1 
        || Values == null 
        || Values.IsEmpty() ) { 
            return ''; 
        }
        
        if( Values.size() == 1 ) { return WhereOrAnd + ' ' + FieldName + ' = ' + ListToCSV( Values ); }
        else { return WhereOrAnd + ' ' + FieldName + ' IN ' + ListToParenthesesCsv( Values ); }
    }
    
    // Createdby Matt.Keefe@cdk.com
    global static string ListToParenthesesCsv( List<string> Values ) 
    {
        if( Values == null ) { return ''; } // no values
        
        string Csv = ListToCSV( Values );
        return '( ' + Csv + ' )'; // values with parentheses
    }
    
    // createdby Matt.keefe@cdk.com
    global static string ListToEnclosedCsv( List<string> Values, string EncloseChar )
    {
        string CSV = '';
        
        if( Values.size() > 0 ) {
            for( Integer i=0; i<Values.size(); i++ ) {
                CSV += ( i != 0 ? ',' + EncloseChar : EncloseChar ) + Values[i] + EncloseChar; } }
        
        return CSV;
    }
    
    // Createdby Matt.Keefe@cdk.com
    global static string ListToCSV( List<string> Values ) 
    { 
        return ListToEnclosedCsv( Values, '\'' ); 
    }
    
    // Createdby Matt.Keefe@cdk.com   
    global static string ListToString( List<string> Values ) 
    { 
        return ALL_UtilitiesString.ListToCSV( Values );
    }
	// 2015/07/24 - lalitha.adduru@cdk.com This method takes a Delimited String ( which may contain duplicates ) and returns a Delimited String of unique values.    
    global static string removeDuplicatesFromDelimitedString( String delimitedString, String delimiter )
    {
        Set<String> noDuplicatesStringSet = new Set<String>();
        List<String> stringToList = new List<String>();
        stringToList = delimitedStringToList( delimitedString,delimiter );
        noDuplicatesStringSet.addAll( stringToList );
        stringToList.clear();
        stringToList.addall( noDuplicatesStringSet );
        String uniqueValuedString = ListToDelimitedString( stringToList,delimiter );
        system.debug('removeDuplicatesFromDelimitedString result -- >' +uniqueValuedString );
        return uniqueValuedString;
    }
    
    
	// 2015/07/24 - lalitha.adduru@cdk.com - This method takes a Delimited String ( which may contain duplicates ) and returns List containing each of the values in the string. 
    global static List<String> delimitedStringToList( String delimitedString, String delimiter  )
    {
        List<String> listOfValues = new List<String>();
        if( delimitedString != null  )
        {
            // This step is essential because, the split function treats the inside null as another substring
            // and returns it as a substring. ( not a null )
            delimitedString = removeNullsFromDelimitedString( delimitedString,delimiter );
            listOfValues.addAll(  delimitedString.split( delimiter ) );
        }
        system.debug('delimitedStringToList result -- >' +listOfValues );
        return listOfValues;
    }
    
    // 2015-07-24 lalitha.adduru@cdk.com - This method takes a Delimited String and removes all null values
    global static string removeNullsFromDelimitedString( String delimitedString, String delimiter )
    {
        // possiblities
        String firstPossibility = Delimiter+null;
        String secondPossiblity = null+Delimiter;
        String thirdPossibility = null+'';
        
        //list of strings to be removed
        List<String> stringsToBeRemoved = new List<String>();
        stringsToBeRemoved.add( firstPossibility  );
        stringsToBeRemoved.add( secondPossiblity  );
        stringsToBeRemoved.add( thirdPossibility );
        
        delimitedString = removeListOfStringsFromString( delimitedString,stringsToBeRemoved  );
        system.debug('removeNullsFromDelimitedString result -- >'+delimitedString);

        return delimitedString; 
    }
        
    // 2015-07-02 lalitha.adduru@cdk.com - This method takes a Delimited String and removes a list of strings from it
    global static string removeListOfStringsFromString( String fullString, List<String> stringsToBeRemoved )
    {
        if( fullString != null && stringsToBeRemoved!=null && stringsToBeRemoved.size() > 0 )
        {
            for( String str : stringsToBeRemoved )
            {
                if( fullstring != null && fullstring != '' && fullString.contains( str ) )
                {
                    fullString = fullString.remove( str );
                }
            }
        }
        system.debug('removeListOfStringsFromString result --> '+fullString);
        return fullString;
    }
    
    // Createdby: Siva.Pragada@cdk.com
	// Updated: 2015-07-02 lalitha.adduru@cdk.com - To make sure it works fine even if the list has null or blank strings
    global static string ListToDelimitedString( List<string> Values, string Delimiter )
    {
        string DelimitedString = '';
        system.debug('values -->'+values);
        if( values!= null && values.size() > 0 )
        {
            for( Integer i=0; i<Values.size(); i++ ) 
            {
                if( Values[i] != '' )
                {
                    DelimitedString += values[i] + ( i == ( values.size()-1 ) ? '' : Delimiter );
                }
            }
            system.debug('ListToDelimitedString Intermediate result -->'+delimitedString);
            if( DelimitedString.endsWith( Delimiter )  )
            {
                DelimitedString = DelimitedString.substring( 0, DelimitedString.length()-Delimiter.length() );
            }
            DelimitedString = removeNullsFromDelimitedString( DelimitedString,Delimiter );
        }
        system.debug('ListToDelimitedString result -->'+delimitedString);
        return DelimitedString;
    }

}