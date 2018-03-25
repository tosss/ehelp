/*------------------------------------------------------------
Author:      Jerick Laurio
Company:     Cloud Sherpas
Description: A collection of wrapper classes that is used by the generic data table component
Test Class:  
History
02/04/15     Jerick Laurio          Created
03/20/15     Jerick Laurio          Cleaned and refactored
------------------------------------------------------------*/
global with sharing class IMP_Library {
    
    // Wrapper Class for Datatable component
    global class fieldAPILabelWrapper{
        public String apiName{get;set;}
        public String label{get;set;}
        public String type{get;set;}
        public Boolean isMultiPicklist{get;set;}
        public List<SelectOption> picklistValues{get;set;}
    }
    
    // Wrapper Class for Datatable component   
    global class genericSObjectWrapper{
        public String objName{get;set;}
        public String objLabel{get;set;}
        public String customMessage{get;set;}
        public List<sObject> sObjList{get;set;}
        public List<genericSelectSObjectWrapper> selectSObjList {get; set;}
        public Integer sObjListsize{get;set;}
        public List<fieldAPILabelWrapper> fieldList{get;set;}
    }

    // Wrapper Class for Datatable component
    global class genericSelectSObjectWrapper implements Comparable {
        public Boolean isSelected {get; set;}
        public SObject sObj {get; set;}
        public Integer weight {get; set;}
        public Boolean isFollowed { get; set; }

        global Integer compareTo(Object compareTo) {
            // Cast argument to genericSelectSObjectWrapper
            genericSelectSObjectWrapper compareToOppy = (genericSelectSObjectWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (weight < compareToOppy.weight) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (weight > compareToOppy.weight) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }

    // Wrapper Class for Datatable component
    global class genericDataTableAttributeWrapper{
        public Integer index {get;set;}
        public String objectLabelName {get;set;}
        public String objectApiName {get;set;}
        public String objectIdPrefixCode {get;set;}
        public String objectEntityId {get;set;}

        public String queryString {get;set;}
        public String whereClauseString {
            get 
            {
                if (whereClauseString == null) 
                {
                    if (this.whereClauseWithValues != null) 
                    {
                        // the KEY is the where clause with placeholders
                        String alternateWhereClause = new List<String>(this.whereClauseWithValues.keySet())[0];

                        // the VALUE is a map of strings, where the key is an integer (this will match the number in the placeholder) 
                        // and the value is the actual value to replace the placeholder
                        Map<Integer, String> paramValues = this.whereClauseWithValues.get(alternateWhereClause); 

                        Integer ctr = 0;
                        Matcher myMatcher = this.getMatcher('\\{[' + ctr + ']+\\}', alternateWhereClause);

                        if (myMatcher.find() == true)
                        {
                            do 
                            {
                                // replace all instances of the placeholder with the actual parameter values
                                whereClauseString = myMatcher.replaceAll(paramValues.get(ctr));

                                ctr++;
                                myMatcher = this.getMatcher('\\{[' + ctr + ']+\\}', whereClauseString);
                            } while (myMatcher.find() == true);
                        }
                    }
                }
                return whereClauseString;
            }
            set;
        }

        private Matcher getMatcher (String interpolationRegex, String stringToSearch) 
        {
            Pattern myPattern = Pattern.compile(interpolationRegex);
            return myPattern.matcher(stringToSearch);
        }

        public Integer queryLimit {get;set;}
        public String orderClause {get;set;}

        public Boolean showDebug {get;set;}
        public Boolean showEditLink {get;set;}
        public Boolean showNewButton {get;set;}
        public Boolean showFollowLink {get;set;}
        public Boolean selectable {get;set;}
        public Boolean allowMultiSelect {get;set;}
        public Boolean objectConsoleOpenInSubTab {get;set;}
        public Integer rowsPerPage {get;set;}
        public String tableColumnFieldsetName {get;set;}
        public Boolean showFilterSection {get;set;}
        public String filterObjectFieldsetName {get;set;}

        public Boolean showEditAllAttr { get; set; }
        public Boolean allowInlineEditing { get; set; }
        public Map<String, Map<Integer, String>> whereClauseWithValues { get; set; }
    }

}