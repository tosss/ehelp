@IsTest
public class DS_LaserCatalogNumberPreventDup_Test
{
    public static testmethod void SaveNewLaserCatalogNumber() 
    {
        Laser_Ordered_Forms_Catalog_Numbers__c CatalogNumber1 = new Laser_Ordered_Forms_Catalog_Numbers__c();
        CatalogNumber1.Name = '12345';
        insert CatalogNumber1;
    }
}