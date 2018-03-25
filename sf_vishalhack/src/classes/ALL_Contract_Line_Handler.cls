//2016-10-04 - ragashalini.koka@cdk.com - RQ-07945 - Created this class
//2016-11-17 - ragashalini.koka@cdk.com - RQ-08207 - added updateWebId to set WebId__c on Contract Line
//2016-12-26 - ragashalini.koka@cdk.com - populated Schedule_Type__c field on Contract Line
//2017-01-11 - ragashalini.koka@cdk.com - RQ-07943 - added updateContractAudit method to keep track of changes
public class ALL_Contract_Line_Handler 
{ 
    //sets the Product_Current__c and Product__c using the PartNumber__c field as reference
    //Product__c updates only if it is null
    public static void populateCurrentProduct(List<ALL_Contract_Line__c> oldList, List<ALL_Contract_Line__c> newList, Boolean isInsert) 
    {
        Set<String> partNumberSet = new Set<String>();
        
        for(Integer i = 0;i < newList.size();i++) 
        {
            String partNumber = newList[i].Part_Number__c;
            if(isInsert || partNumber != oldList[i].Part_Number__c)
            {
                if(partNumber != null)
                {
                    partNumberSet.add(partNumber);
                }
                else
                {
                    newList[i].Product_Current__c = null;
                }
            }
            
        }
        if(partNumberSet.size() > 0)
        {
            List<Product2> productList = [SELECT Id, Name, Schedule_Type__c FROM Product2 WHERE Name IN :partNumberSet];
            Map<String,Product2> nameToProductMap = new Map<String,Product2>();
            for(Product2 product : productList) 
            {
                nameToProductMap.put(product.Name, product);
            }
            
            for(Integer i = 0;i < newList.size();i++) 
            {
                String partNumber = newList[i].Part_Number__c;
                if(isInsert || partNumber != oldList[i].Part_Number__c) 
                {
                    Product2 product = nameToProductMap.get(partNumber);
                    newList[i].Product_Current__c = product != null ? product.Id : null;
                    if(newList[i].Product__c == null || String.valueOf(newList[i].Product__c).length() == 0)
                    {
                        newList[i].Product__c = product != null ? product.Id : null;
                    }
                    newList[i].Schedule_Type__c = product != null ? product.Schedule_Type__c : null;
                }
            }
        }
        
        
    }
    
    //sets the WebId__c field on the Contract Line with reference to WebId_Text__c field
    public static void updateWebId(List<ALL_Contract_Line__c> oldList, List<ALL_Contract_Line__c> newList, Boolean isInsert) 
    {
        Set<String> webIdNameSet = new Set<String>();
        Set<Id> contractLineIdSet = new Set<Id>();
        for(Integer i = 0;i < newList.size();i++) 
        {
            String currentWebIdText = newList[i].WebId_Text__c;
            if(currentWebIdText != null) 
            {
                if(isInsert || oldList[i].WebId_Text__c != currentWebIdText)
                {
                    contractLineIdSet.add(newList[i].Id);
                    webIdNameSet.add(currentWebIdText);
                }
            }
            else 
            {
                newList[i].WebId__c = null;
            }
        }
        
        List<WebId__c> webIdList = [SELECT Id, Name FROM WebId__c WHERE Name IN : webIdNameSet];
        Map<String,Id> webIdNameToIdMap = new Map<String,Id>();
        for(WebId__c webId : webIdList) 
        {
            webIdNameToIdMap.put(webId.Name, webId.Id);
        }
        
        for(ALL_Contract_Line__c contractLine : newList) 
        {
            if(contractLineIdSet.contains(contractLine.Id)) 
            {
                contractLine.WebId__c = webIdNameToIdMap.get(contractLine.WebId_Text__c);
            }
        }
    }
    
    //keeps track of changes in Quantity_Lost__c and Quantity_Cancelled__c using Contract_Audit__c object
    public static void updateContractAudit(Map<Id,ALL_Contract_Line__c> oldMap, Map<Id,ALL_Contract_Line__c> newMap) 
    {
        Map<Id,Id> contractLineToContractIdMap = new Map<Id,Id>();
        List<Contract_Audit__c> contractAuditList = new List<Contract_Audit__c>();
        
        for(Id contractLineId : newMap.keySet()) 
        {
            ALL_Contract_Line__c oldRecord = oldMap.get(contractLineId);
            ALL_Contract_Line__c newRecord = newMap.get(contractLineId);
            if(newRecord.Quantity_Lost__c != oldRecord.Quantity_Lost__c || newRecord.Quantity_Cancelled__c != oldRecord.Quantity_Cancelled__c)
            {
                contractLineToContractIdMap.put(contractLineId, newRecord.Contract__c);
            }
        }
        
        Map<Id,Contract> contractMap = new Map<Id,contract>([
            SELECT 
            Id, Chosen_Alternative__c, Event__c, Reason_Code__c, Scenario__c 
            FROM Contract 
            WHERE Id IN :contractLineToContractIdMap.values()
        ]);
        
        for(Id contractLineId : contractLineToContractIdMap.keySet()) 
        {
            Contract contractRecord = contractMap.get(contractLineToContractIdMap.get(contractLineId));
            ALL_Contract_Line__c newContractLineRecord = newMap.get(contractLineId);
            ALL_Contract_Line__c oldContractLineRecord = oldMap.get(contractLineId);
            Contract_Audit__c contractAudit = new Contract_Audit__c();
            contractAudit.Contract__c = contractRecord.Id;
            contractAudit.Contract_Line__c = contractLineId;
            contractAudit.Chosen_Alternative__c = contractRecord.Chosen_Alternative__c;
            contractAudit.Comments__c = newContractLineRecord.Comments__c;
            contractAudit.Event__c = contractRecord.Event__c;
            contractAudit.Reason_Code__c = contractRecord.Reason_Code__c;
            contractAudit.Scenario__c = contractRecord.Scenario__c;
            if(newContractLineRecord.Quantity_Lost__c != oldContractLineRecord.Quantity_Lost__c)
            {
                contractAudit.New_Value__c = newContractLineRecord.Quantity_Lost__c;
                contractAudit.Previous_Value__c = oldContractLineRecord.Quantity_Lost__c;
            }
            else if(newContractLineRecord.Quantity_Cancelled__c != oldContractLineRecord.Quantity_Cancelled__c)
            {
                contractAudit.New_Value__c = newContractLineRecord.Quantity_Cancelled__c;
                contractAudit.Previous_Value__c = oldContractLineRecord.Quantity_Cancelled__c;
            }
            
            contractAuditList.add(contractAudit);
        }
        
        insert contractAuditList;
        
    }
    
  
}