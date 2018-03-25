//2017-06-01- anirudh.singh@cdk.com- Created this class for RQ-09310 and RQ-09228.
global class EMP_DeleteSobjectRecs_Scheduler implements Schedulable
{
    //This is the TIMETOCOMPARE datetime.
    public Final Datetime TIMETOCOMPARE=Datetime.now().addYears(-2);
    
    global void execute(SchedulableContext sc)
    {
        database.delete([
            SELECT Id 
            FROM WorkFlow__c 
            WHERE RecordType.Name='COM - Employees Termination' 
            AND CreatedDate<:TIMETOCOMPARE
        ]);
        
        database.delete([
            SELECT Id 
            FROM Portal_Form__c 
            WHERE RecordType.Name='Manager Termination Form' 
            AND CreatedDate<:TIMETOCOMPARE
        ]);
    }
}