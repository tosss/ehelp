/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Schedulable Apex for Project Activity Detail Capture job
Test Class: IMP_ProjectActivityCaptureScheduler_Test
History
09/24/14    Michael Lasala      Created
09/25/14    Michael Lasala      Added recordTypeName variable
------------------------------------------------------------*/
global class IMP_ProjectActivityCapture_Scheduler implements Schedulable {
    
    //Used for dynamic handling for the handler calss
    global String recordTypeNameString;
    
    global void execute(SchedulableContext sc){
        
       
    }
}