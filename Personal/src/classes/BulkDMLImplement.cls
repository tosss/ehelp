global class BulkDMLImplement extends BulkDML{
    public static void st(){
        List<account> acc= new List<Account>();
        for(integer i=0;i<100;i++)
        {
            Account a = new Account();
            a.name='sched'+i;
            acc.add(a);
        }
        BulkDML.start(acc, new BulkDMLImplement());
    }
    global override void execute(List<sobject> s){
        insert s;
    }
}