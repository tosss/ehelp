public class ChartController {
    public String myData {get;set;}
    public ChartController()
    {
        getMyData();
    }
    public String getMyData(){
        if(myData == null){
            myData = '["data1", 50, 55, 65, 75, 85, 95,100]';
                }
        
        return myData;
    }
    
}