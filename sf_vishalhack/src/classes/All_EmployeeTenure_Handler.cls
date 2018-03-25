//------------------------------------------------------------------
//	Author	 : 	Lalitha Adduru
//	Date	 :	20th august 2015
//	Description	: Handler Class for All_EmployeeTenure Trigger
//------------------------------------------------------------------

public class All_EmployeeTenure_Handler {
    
    
    // this method updates the coresponding parent Employee Information record manager and regions fields
    // irrespective of their previous values
    public void updateEmployeeInfo(List<Employee_Tenure__c> empTenureListNew, Map<id,Employee_Tenure__c> empTenureMapOld)
    {
        Map<id,Employee_Information__c> empInfoMap = new Map<id,Employee_Information__c>();
        
        Employee_Information__c empInfo;
        for(Employee_Tenure__c empTenure : empTenureListNew)
        {
            if(empTenureMapOld == null)
            {
                empInfo = new Employee_Information__c(id=empTenure.Employee_Name__c);
                empInfo.Manager__c = empTenure.Manager__c;
                empInfo.region__c = empTenure.Region__c;
                empInfoMap.put(empInfo.id, empInfo);
            }
            else
            {
                if( empTenure.Manager__c != empTenureMapOld.get(empTenure.id).Manager__c || empTenure.Region__c != empTenureMapOld.get(empTenure.id).Region__c)
                {
                    system.debug('correct update');
                    empInfo = new Employee_Information__c(id=empTenure.Employee_Name__c);
                    empInfo.Manager__c = empTenure.Manager__c;
                    empInfo.region__c = empTenure.Region__c;
                    empInfoMap.put(empInfo.id, empInfo);                    
                }                
            }
        }        
        
        if(empInfoMap.size() > 0)
        {
            update empInfoMap.values();
        }
    }

}