public class compositionExample{

    String name;
    Integer age;
    String meal;
    String color;
    public String page{get;set;}
        public List<String> stValue{get;set;}
    
    Boolean showGreeting = false;
    public compositionExample()
    {
        stValue = new List<String>();
        stValue.add('Sample2');
        stValue.add('Sample');
    }
    public PageReference save() {
        showGreeting = true;
        return null;
    }
    
    public void setNameField(String nameField) {
        name = nameField;
    }
    
    public String getNameField() {
        return name;
    }
    
    public void setAgeField(Integer ageField) {
        age= ageField;
    }
    
    public Integer getAgeField() {
        return age;
    }
    
    public void setMealField(String mealField) {
        meal= mealField;
    }
    
    public String getMealField() {
        return meal;
    }   
         
    public void setColorField(String colorField) {
        color = colorField;
    }
    
    public String getColorField() {
        return color;
    }       
    
    public Boolean getShowGreeting() {
        return showGreeting;
    }
}