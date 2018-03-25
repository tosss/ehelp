//2016-06-16      venkata.shrivol@cdk.com - added CR test records after account and contact insertion.
@IsTest
Public Class DS_LaserRollupTriggerHandler_Test 
{
    static testMethod void TestLaserOrderedForms() 
    {
        Laser_Artwork_Order__c Lao = DS_TestObjects.NewLaserArtworkOrder_Inserted();
        Laser_Artwork_Order__c thisLAO = [select Contact__c, Ship_CMF_Info__r.Account__c from Laser_Artwork_Order__c limit 1];
        Contact_Relationship__c crt = IMP_TEstFActory_Helper.buildContactRelationship(thisLAO.Ship_CMF_Info__r.Account__c, thisLAO.Contact__c);
        insert crt;
        
        List<Laser_Ordered_Forms__c> Lof = new List<Laser_Ordered_Forms__c>();
        list<Laser_Ordered_Forms_Catalog_Numbers__c> CatalogNumbers = new list<Laser_Ordered_Forms_Catalog_Numbers__c>();
        
        for(integer i=0; i<10; i++)
        {
            if(i==3 || i==6)
            {
                CatalogNumbers.add(new Laser_Ordered_Forms_Catalog_Numbers__c(
                    Name='catalog'+i, Exclude_from_SO_Total__c=true, Exclude_from_Total_Number_Of_Forms__c=true));
            }else if(i==4)
            {            
                CatalogNumbers.add(new Laser_Ordered_Forms_Catalog_Numbers__c(Name='catalog'+i, Exclude_from_Quote__c=true));
            }else
            {
                CatalogNumbers.add(new Laser_Ordered_Forms_Catalog_Numbers__c(Name='catalog'+i));
            }
        }
        
        insert CatalogNumbers;
        
        for(Integer i = 0; i < CatalogNumbers.size(); i++) 
        {
            lof.add(new Laser_Ordered_Forms__c( 
                Laser_Artwork_Order__c = lao.id, catalog_number__c=CatalogNumbers[i].ID, Quantity__c = i + 1, Unit_Price_Override__c = i + 2));
        }
        insert Lof; 
        
        lof[0].Quantity__c = 1;
        lof[0].Unit_Price_Override__c = 10;
        
        Update lof[0];       
        
        lof[3].Unit_Price_Override__c = null;        
        Update lof[3];
        
        delete Lof[0];

    }
}