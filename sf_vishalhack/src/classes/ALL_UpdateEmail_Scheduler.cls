/*******************************************************************************
*  2016-08-12 ragashalini.koka@cdk.com - RQ-07383 Created this class 
* *****************************************************************************/

global class ALL_UpdateEmail_Scheduler implements Schedulable {
    
    global void execute(SchedulableContext context) {
        new ALL_UpdateEmail_Controller();
    }

}