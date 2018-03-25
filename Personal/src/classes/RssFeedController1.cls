public class RssFeedController1{
public List<Case> caseList {get;set;}
public RssFeedController1(){
caseList = [SELECT Id, CaseNumber, Subject, Priority from Case limit 20];
}
}