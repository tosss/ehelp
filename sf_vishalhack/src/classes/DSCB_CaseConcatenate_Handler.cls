//created - Siva.Pragada@cdk.com
//2017-02-17 - siva.pragada@cdk.com - added added Yext Partner Prodcut functionality for RQ-08653
public class DSCB_CaseConcatenate_Handler 
{
    public static map<string, ALL_Template_Values__c> allTemplateValuesMap = ALL_Template_Values__c.getAll();
    
    public static void ConcatenateTheFieldValues(list<Case> concatenateCases)
    {
        GlobalSettings__c gs = GlobalSettings__c.getInstance();
        
        if(gs.Launch_Onboarding_Switch__c)
        {
            list<ALL_Template_Decisionbox__c> allTemplateDecisionBoxSettings = ALL_Template_Decisionbox__c.getAll().Values();
            
            set<ID> launchIDset = new set<ID>();
            
            for(Case currentCase: concatenateCases)
            {
                launchIDset.add(currentCase.Launch__c);
            }
            
            map<ID, Launch__c> launchMap = new map<ID, Launch__c>([
                Select Id, Name, RecordType.Name, Product_Type__c, Add_Ons__c, Critical_Notes__c, Launch_Comments__c, Oracle_Order_Number__c,
                Monthly_Recurring_Total__c, Budget_Amount__c, Core_Budget__c, New_Flex_Budget__c, S_P_Flex_Budget__c, Used_Flex_Budget__c,
                Tires_Budget__c, Maintenance_Repair_Budget__c, Parts_Accessories_Budget__c, Body_Shop_Budget__c, WebID__c, WebID__r.Name,
                Account__c, Account__r.Name, Account__r.Dealer_Group_Name2__c, Brand__c, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone,
                Account_Advocate__c, Account_Advocate__r.Name, Email_Marketing_Specialist__c, Email_Marketing_Specialist__r.Name, Owner_Marketing_Id__c,
                Account__r.CBLTBillState__c, Order_Type__c, Status__c, Activation_OM__c, Activation_OM__r.Name, Partner_Products__c
                
                From Launch__c
                Where ID
                IN :launchIDset
            ]);
            
            system.debug(launchMap);
            
            if(launchMap != null && !launchMap.isEmpty())
            {   
                
                for(Case currentCase: concatenateCases)
                { 
                    Launch__c currentLaunch = launchMap.get(currentCase.Launch__c);
                    
                    system.debug(currentLaunch);
                    
                    if(currentLaunch != null)
                    {
                        if(!allTemplateDecisionBoxSettings.isEmpty())
                        {
                            for(ALL_Template_Decisionbox__c atd: allTemplateDecisionBoxSettings)
                            {
                                boolean conditionCheck = ALL_UtilitiesLogic.getcompositeExpressionsEvaluatedValue(atd.Condition_Check__c, currentLaunch);
                                
                                system.debug(atd.Condition_Check__c);
                                system.debug(conditionCheck);
                                if(conditionCheck)
                                {
                                    string concatenatedString = DSCB_CaseConcatenate_Handler.concatenateFieldValues(atd.Value_Assignment__c, currentLaunch);
                                    currentCase.Description = concatenatedString;
                                }
                            }
                        }
                        
                        string LaunchProductType, CaseProductCategory, LaunchAddOns;
                        LaunchProductType = currentLaunch.Product_Type__c == null ? '' : currentLaunch.Product_Type__c;
                        CaseProductCategory = currentCase.Product_Category__c != null ? currentCase.Product_Category__c : '';
                        LaunchAddOns = currentLaunch.Add_Ons__c != null ? currentLaunch.Add_Ons__c: '';
                        string subject = 'Onboarding - ' + LaunchProductType + '; ' +LaunchAddOns;
                        
                        boolean yextConditionsMet = false;
                        
                        ID onboardPowerSEORecID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Onboarding - PowerSEO');
                        
                        
                        if(currentLaunch.Status__c == 'Closed' && 
                           currentLaunch.recordType.Name == 'A La Carte Launch' &&
                           currentCase.Partner_Products__c != null && currentCase.Partner_Products__c.equalsIgnoreCase('Yext') &&
                           currentCase.recordTypeID == onboardPowerSEORecID                            
                          )
                        {
                            yextConditionsMet = true;
                        }
                        
                        if(yextConditionsMet)
                        {
                            subject = 'Onboarding - ' + currentLaunch.Partner_Products__c;
                        }
                        
                        if(subject.length() > 255)
                        {
                            subject = subject.substring(0,254);
                        }
                        currentCase.Subject = subject;
                    }
                }
                //system.debug(concatenateCases);
            }
        }
    }
    
    public static string concatenateFieldValues(string valueAssignmentString, Launch__c currentLaunch)
    {
        list<string> Identifiers = valueAssignmentString.split('AND');
        string concatenatedString = '';
        
        if(Identifiers != null && !Identifiers.isEmpty())
        {
            for(integer i=0; i<Identifiers.size(); i++)
            {
                string s = Identifiers[i];
                s = s.normalizeSpace();
                ALL_Template_Values__c atv = allTemplateValuesMap.get(s);
                
                if(atv != null && atv.Label__c != 'next line' && atv.Label__c != 'Link to Launch')
                {
                    string fieldName = atv.Field_Name__c;
                    if(fieldName != null && fieldName.contains('.'))
                    {
                        object fieldValue = All_UtilitiesData.GetDataFromNestedFields(FieldName, currentLaunch);
                        string stringFieldValue = fieldValue != null ? string.valueOf(fieldValue) : '';
                        concatenatedString = concatenatedString + atv.Label__c + ': ' + stringFieldValue + ' \r\n';
                    }
                    else
                    {
                        object fieldValue = currentLaunch.get(fieldName);
                        string stringFieldValue = fieldValue != null ? string.valueOf(fieldValue) : '';
                        concatenatedString = concatenatedString + atv.Label__c + ': ' + stringFieldValue + ' \r\n';
                    }
                }
                if(atv != null && atv.Label__c == 'next line')
                {
                    concatenatedString = concatenatedString + ' \r\n';
                }
                if(atv != null && atv.Label__c == 'Link to Launch')
                {
                    string salesforceBaseURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/';                   
                    concatenatedString = concatenatedString + atv.Label__c + ': ' + salesforceBaseURL + currentLaunch.ID;
                    concatenatedString = concatenatedString + ' \r\n';
                }
                
            }
        }
        
        return concatenatedString;
    }
    
}