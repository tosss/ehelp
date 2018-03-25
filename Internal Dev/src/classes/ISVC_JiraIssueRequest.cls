// GLOBIT-4804 Create JIRA Issue from Salesforce

// 2017-10-30 Marta.Malinowska@cdk.com
public class ISVC_JiraIssueRequest {
	
	public Fields fields;

	/**
	 * Create an instance of hte JIRA Issue request with the generic attributes
	 */
    public ISVC_JiraIssueRequest(String projectKey, String summary, String description, String issueTypeName){
    		fields = new Fields();
    		fields.project = new Project();
    		fields.project.key = projectKey;
    		fields.summary = summary;
    		fields.description = description;
    		fields.issuetype = new IssueType();
    		fields.issuetype.name = issueTypeName;
    }
    
    /**
     * Create an instance of hte JIRA Issue request with the CDK specific attributes
     */
    public ISVC_JiraIssueRequest(String projectKey, String summary, String description, String issueTypeName,string customfield_11500){
    		this(projectKey, summary, description, issueTypeName);
    		// The following lines of code are only needed if we are connecting to a JIRA
    		// with the CDK Configuration:
    		// fields.ITTeam = new ITTeam();
    		// fields.ITTeam.customfield_11500 = customfield_11500; // 
    }

    public class Fields {
    		public Project project;
    		public String summary;
    		public String description;
    		public IssueType issuetype;
    		// The following lines of code are only needed if we are connecting to a JIRA
    		// with the CDK Configuration:
    		// public ITTeam ITTeam;
    }

    public class Project {
        public String key;
    }

    public class IssueType {
        public String name;
    }
  
  	// The following lines of code are only needed if we are connecting to a JIRA
	// with the CDK Configuration:
   	//public class ITTeam {
    //    public String customfield_11500;
    //}Class customfield_11500 {
//public String value
//public ChildObj child
//}
// Class ChildObj {
//public String value;
//}
}