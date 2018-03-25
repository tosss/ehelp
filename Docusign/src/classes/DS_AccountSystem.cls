public class DS_AccountSystem {
    public String acctId='';
    public String accountName='';
    public String city='';
    public String state='';
    public String phone='';
    public String campStatus='';
    public String vendorSystem='';
    public String soldVendorSystem='';
    public String boxOnsite='';
    public String age='';
    public String installDate='';
    public String doNotSolicit='';
    
    public String getAcctId(){
        return acctId;
    }
    public void setAcctId(String x){
        acctId=x;
    }
    public String getAccountName(){
        return accountName;
    }
    public void setAccountName(String x){
        accountName=x;
    }
    public String getCity(){
        return city;
    }
    public void setCity(String x){
        acctId=x;
    }
    public String getState(){
        return state;
    }
    public void setState(String x){
        state=x;
    }
    public String getPhone(){
        return phone;
    }
    public void setPhone(String x){
        phone=x;
    }
    public String getCampStatus(){
        return campStatus;
    }
    public void setCampStatus(String x){
        campStatus=x;
    }
    public String getVendorSystem(){
        return vendorSystem;
    }
    public void setVendorSystem(String x){
        vendorSystem=x;
    }
    public String getSoldVendorSystem(){
        return soldVendorSystem;
    }
    public void setSoldVendorSystem(String x){
        soldVendorSystem=x;
    }
    public String getBoxOnsite(){
        return boxOnsite;
    }
    public void setBoxOnsite(String x){
        boxOnsite=x;
    }
    public String getAge(){
        return age;
    }
    public void setAge(String x){
        age=x;
    }
    public String getInstallDate(){
        return installDate;
    }
    public void setInstallDate(String x){
        installDate=x;
    }
    public String getdoNotSolicit(){
        return doNotSolicit;
    }
    public void setdoNotSolicit(String x){
        doNotSolicit=x;
    }
    
    testMethod static void opportunityController(){
        DS_AccountSystem asys = new DS_AccountSystem();
        asys.getAcctId();
        asys.setAcctId('x');
        asys.getAccountName();
        asys.setAccountName('x');
        asys.getCity();
        asys.setCity('x');
        asys.getState();
        asys.setState('x');
        asys.getPhone();
        asys.setPhone('x');
        asys.getCampStatus();
        asys.setCampStatus('x');
        asys.getVendorSystem();
        asys.setVendorSystem('x');
        asys.getSoldVendorSystem();
        asys.setSoldVendorSystem('x');
        asys.getBoxOnsite();
        asys.setBoxOnsite('x');
        asys.getAge();
        asys.setAge('x');
        asys.getInstallDate();
        asys.setInstallDate('x');
        asys.getdoNotSolicit();
        asys.setdoNotSolicit('x');
    
     }
}