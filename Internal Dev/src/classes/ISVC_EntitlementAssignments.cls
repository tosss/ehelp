// GLOBIT-3994: Entitlement Assignment - Trigger
//
// 2017-10-25 marta.malinowska@cdk.com Created
public class ISVC_EntitlementAssignments {

    public static void assignEntitlementsToCases(List<Case> cases){
        Entitlement internalSupportSLAEntitlement = getInternalSupportSLAEntitlement();
        if(String.isNotBlank(internalSupportSLAEntitlement.Id)){
            for(Case cas : cases){
                cas.EntitlementId = internalSupportSLAEntitlement.Id;
            }
        }
    }

    private static Entitlement getInternalSupportSLAEntitlement(){
        ISVC_EntitlementSetting__mdt internalSupportEntitlementSetting = ALL_CustomSettings_Utility.getInternalSupportEntitlementSetting();
        Entitlement internalSupportSLA = new Entitlement();
        if(String.isNotBlank(internalSupportEntitlementSetting.Entitlement_Name__c)){
            try {
                internalSupportSLA = [
                        SELECT Id FROM Entitlement
                        WHERE Name = :internalSupportEntitlementSetting.Entitlement_Name__c
                        AND EndDate >= TODAY AND StartDate <= TODAY];
            } catch(QueryException ex){}
        }
        return internalSupportSLA;
    }
}