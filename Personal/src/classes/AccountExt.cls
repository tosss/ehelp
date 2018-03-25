public class AccountExt {
    public List<string> listvalues{
        get{
            return listvalues;
        }
        set{
            listvalues = value;
        }
    }
    public string shownvalues{
        get{
            return shownvalues;
        }
        set{
            shownvalues = value;
        }
    }
    private final Account sample;
    public AccountExt(ApexPages.StandardController controller)
    {
        sample = (Account)controller.getRecord();
        listvalues = new List<string>();
        listvalues.add('abc');
        listvalues.add('gnd');
    }
}