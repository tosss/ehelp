//2016-01-12- anirudh.singh@cdk.com- Created this trigger for bringing up to the Standards as per request RQ-06020.
//2016-01-12- anirudh.singh@cdk.com- The previous trigger with the name DS_CreateCompositeIDforManufacturersAtDealership is removed.
trigger ALL_ManufacturersAtDealership on Manufacturer_at_Dealership__c(after insert, after update)
{
    //2016-01-07- Handler class is invoked for all the processing. All the code has been moved to this DS_ManufacturersAtDealership_Handler class.
    DS_ManufacturersAtDealership_Handler.processRecords(Trigger.New, Trigger.OldMap);
}