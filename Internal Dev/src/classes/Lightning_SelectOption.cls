/* ****************************************************
**11/10/2017 created vijay.manimaran@cdk.com 
********************************************************* */
public class Lightning_SelectOption {
    public Lightning_SelectOption(String value, String label) {
        this.value = value;
        this.label = label;
        this.disabled = false;
        this.escapeItem = false;
    }

    public Lightning_SelectOption(String value, String label, Boolean isDisabled) {
        this.value = value;
        this.label = label;
        this.disabled = isDisabled;
        this.escapeItem = false;
    }

    @AuraEnabled
    public String label { get;set; }
    @AuraEnabled
    public String value { get;set; }
    @AuraEnabled
    public Boolean disabled { get;set; }
    @AuraEnabled
    public Boolean escapeItem { get;set; }

}