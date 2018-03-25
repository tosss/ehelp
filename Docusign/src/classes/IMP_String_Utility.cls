/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: String utility for IMP classes.
History
12/11/14    Kimiko Roberto      Created
02/06/15    Samuel Oberes       Updated error message SUBPROJECT_SITE_EXISTING
05/06/15    Samuel Oberes       Added NO_BYPASS_TODELETE_TASK, NO_BYPASS_TODELETE_ACTIVITY, and NO_BYPASS_TODELETE_MILESTONE
------------------------------------------------------------*/
public class IMP_String_Utility
{
    
    //IMP_SiteWorkbook_Extension
    public static final String NO_TARGET_SITE_FOUND = 'No Target Site record found. Please select a Target Site';
    public static final String NO_SITE_FOUND = 'No Site record found. Please select a Site.';
    public static final String NO_PROJECT_FOUND = 'No Project record found.';
    public static final String NO_SOURCE_SITE_FOUND = 'No Source Site record found. Please select a Source Site';
    
    
    //IMP_CheckListView_Controller
    //IMP_CheckList_Controller
    public static final String NO_PROJECT_ID_FOUND = 'No Project Id Found';
    
    //IMP_CloneWorkbook_Helper
    //IMP_CloneWorkbook_Test
    public static final String WORKBOOK_ALREADY_EXISTING = 'The Site you have chosen already has a workbook for this project.  Please utilize it to continue your discovery, or if you intended to select a different site, please try selecting again.';
    public static final String NO_SITE_CREATED = 'No Site has been created';
    public static final String NO_WORKBOOK_CAT_FOUND = 'No Workbook Category Found';
    
    
    //IMP_ConfirmSiteinDealerGroupHandler_Test
    //IMP_ConfirmSiteinDealerGroup_Handler
    public static final String DEALER_GROUP_BELONGS_TO_SUBPROJECT = 'A site can only be added if it belongs to the Dealer Group specified on the subproject';
    public static final String NO_DEALER_GROUP_OR_PROJECT_TYPE = 'Either there is no specified Dealer Group Hierarchy in the SubProject, or no specified Project Type.  Please update the SubProject to ensure both fields have values';
    public static final String SUBPROJECT_SITE_EXISTING = 'A Subproject Site for the same Account already exists. Please use the Apply CMF to Existing Site button on the SubProject related list to add CMF for the same Subproject Site.';
    
    //IMP_GenerateMilestones_Controller
    //IMP_GenerateMilestones_Controller_Test
    public static final String NO_MILESTONES_FOUND_BASED_ON_CRITERIA = 'No standard Milestones found based on SubProject criteria';
    public static final String EID_CANNOT_BE_SET_TO_PAST = 'Estimated Install Date cannot be set to the past';
    
    //IMP_MilestonePopupExtension_Test
    //IMP_MilestonePopup_Extension
    public static final String NO_TERMINAL_TASK_POPUP = 'Activity:{0} - At least 1 Task should be marked as a Terminal Task';
    public static final String MANY_TERMINAL_TASK_POPUP = 'Activity:{0} - No more than 1 Task can be marked as a Terminal Task at a time';
    public static final String NO_TERMINAL_ACTIVITY_POPUP = 'At least 1 Activity should be marked as a Terminal Activity';
    public static final String MANY_TERMINAL_ACTIVITY_POPUP = 'No more than 1 activity can be marked as a Terminal Activity at a time';
    
    public static final String NO_TASK_POPUP = 'Activity:{0} - Activity should have at least 1 Task';
    public static final String DML_ACTIVITY_ERROR_POPUP = 'Activity:{0} - {1}';
    //IMP_AddMilestones_Controller    NO_MILESTONES_SELECTED 
    public static final String NO_MILESTONES_SELECTED = 'No Milestone selected';
    public static final String ONE_TERMINAL_ACTIVITY_AT_A_TIME = 'No more than 1 activity can be marked as a Terminal Activity at a time';
    public static final String MILESTONE_AT_LEAST_ONE_ACTIVITY = 'Milestone should have at least 1 Activity';
    public static final String TERMINAL_ACTIVITY_CANNOT_BE_END_DATED = 'Terminal activity can not be end-dated, if a Milestone has 1 or more non-terminal activities which have not yet been end-dated.';
    
    //IMP_MilestonesCollapseController
    public static final String NO_MILESTONE_RECORDS = 'No Milestone records';
    public static final String NO_SELECTED_MILESTONE_RECORDS = 'No selected Milestone records';
    
    //IMP_ProjectUtility_Test
    public static final String MILESTONE_STATUSES_SHOULD_BE_COMPLETE = 'All Milestone Statuses should be Complete before SubProject Status can be set to Complete.';
    
    //IMP_ReParentingSubProject_Test
    public static final String CANNOT_CHANGE_PROJECT_VALUE_IF_STATUS_CLOSED = 'You cannot change the Project value to a project with a closed status.';
    
    //IMP_RESTProjectController_Test
    
    
    //IMP_StatusReportGeneration_Controller
    //IMP_StatusReportGeneration_Test
    public static final String NO_RELATED_SUBPROJECTS_FOUND = 'No related SubProjects found';
    public static final String AT_LEAST_ONE_SUBPROJECT_SELECTED = 'At least 1 SubProject should be selected';
    
    //IMP_ActualEndDatesValidationHandler
    public static final String NO_ACTUAL_END_DATES_IN_THE_PAST = 'Actual End Date cannot be in the past.';
    
    //IMP_Milestones_Controller
    public static final String NO_ASSOCIATE_SUBPROJECT_RECORD = 'SubProject Id is not associated with any records!';
    public static final String NO_PERMISSION_TO_DELETE_MILESTONES = 'You have no permission to delete Milestone records.';
    public static final String NO_TERMINAL_ACTIVITY = '{0} - At least 1 Activity should be marked as a Terminal Activity';
    public static final String MANY_TERMINAL_ACTIVITY = '{0} - No more than 1 activity can be marked as a Terminal Activity at a time';
    public static final String NO_TERMINAL_TASK = 'Milestone:{0}, Activity:{1} - At least 1 Task should be marked as a Terminal Task';
    public static final String MANY_TERMINAL_TASK = 'Milestone:{0}, Activity:{1} - No more than 1 Task can be marked as a Terminal Task at a time';
    public static final String DELETE_TERMINAL_ACTIVITY = '{0} - Cannot delete selected Activity, Milestone should have at least 1 Activity';
    public static final String DELETE_ALL_ACTIVITY = '{0} -  At least 1 Activity should be marked as a Terminal Activity';
    public static final String DELETE_TERMINAL_TASK = 'Milestone:{0}, Activity:{1} - Cannot delete selected Task, Activity should have at least 1 Task';
    public static final String DELETE_ALL_TASK = 'Milestone:{0}, Activity:{1} -  At least 1 Task should be marked as a Terminal Task';
    public static final String DML_MILESTONE_ERROR = 'Milestone: {0};   Error: {1}';
    public static final String DML_ACTIVITY_ERROR = 'Activity: {0};   Error: {1}';
    public static final String DML_TASK_ERROR = 'Task: {0};   Error: {1}';

    //IMP_ViewAllTasks_Controller
    public static final String DATATABLE_UNSPECIFIC_ERROR = 'The custom data table for the object "{0}" encountered a problem. Please check your custom settings.';

    //ALL_DataTableComponent_Controller
    public static final String ERROR_STANDARDSETCONTROLLER_INITIALIZATION = 'There was an error encountered while initializing the StandardSetController. Please Contact your Administrator. Error:';
    public static final String DATATABLE_SELECT_QUERY_MISSING = 'Data table select query missing: Initial setup was not completed. Please Contact your Administrator.';
    public static final String ERROR_FIELDSET_INITIALIZATION = 'There was an error encountered while retrieving the FieldSet. Please Contact your Administrator. Error:';
    public static final String ERROR_FILTER_OBJECT_INITIALIZATION = 'There was an error encountered while initializing object for filter. Please Contact your Administrator. Error:';
    public static final String DATATABLE_COLUMN_FIELDSET_MISSING = 'Data table fieldsets missing: Initial setup was not completed. Please Contact your Administrator.';
    public static final String FILTER_COLUMN_FIELDSET_MISSING = 'Filter fieldsets missing: Initial setup was not completed. Please Contact your Administrator.';
    //IMP_FollowedRecords_Controller
    public static final String FOLLOWED_RECORDS_CUSTOM_SETTING_MISSING = 'Followed Records Data Table SObject Setup missing: Initial setup was not completed. Please Contact your Administrator.';
    //IMP_EnhancedListComponent_Controller
    public static final String ENHANCED_LIST_CUSTOM_SETTING_MISSING = 'Enhanced List SObject Setup missing: Initial setup was not completed. Please Contact your Administrator.';
    
    //IMP_PostFeedToAsignee_Handler
    public static final String ERR_MSG_NO_START_DATE_ASSIGNED = 'No Start Date assigned';
    public static final String ERR_MSG_NO_END_DATE_ASSIGNED = 'No End Date assigned';
    
    //IMP_ProjectTask Trigger
    public static final String NO_BYPASS_TOUPDATE_TASK = 'Cannot Update Task Record that is already complete!';
    public static final String NO_BYPASS_TODELETE_TASK = 'Task: {0};   Error: Cannot Delete Task Record that is already complete!';

    //IMP_ProjectActivity Trigger
    public static final String NO_BYPASS_TODELETE_ACTIVITY = 'Activity: {0};   Error: Cannot Delete Activity Record that is already complete!';

    //IMP_ProjectMilestone Trigger
    public static final String NO_BYPASS_TODELETE_MILESTONE = 'Milestone: {0};   Error: Cannot Delete Milestone Record that is already complete!';

}