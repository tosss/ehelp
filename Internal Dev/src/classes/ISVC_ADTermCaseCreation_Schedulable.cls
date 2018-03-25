// GLOBIT-6230 Auto create termination cases

// 2017-11-14 stephen.li@cdk.com Created
public class ISVC_ADTermCaseCreation_Schedulable implements Schedulable {
   public void execute(SchedulableContext sc) {
      database.executebatch(new ISVC_ADTermCaseCreation_Batch());
   }
}