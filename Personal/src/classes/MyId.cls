public class MyId {
   List<Contact> cts = [Select id,name from Contact 
                       where id='003900000116a6jAAA'];
    //system.debug(cts[0].Id);
}