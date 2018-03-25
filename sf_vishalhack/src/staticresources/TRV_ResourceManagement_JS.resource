//2016-11-01 - vishal.bandari@cdk.com - added Non-Billable Reason - RQ-07935
//2017-04-13 - lalitha.adduru@cdk.com - add "Software Install" date to the tooltip - RQ-08761
var vrRole = '';
var vrStatus = '';
var vrResource = '';
var vrLocation = '';
var vrExpertiseMajor = '';
var vrExpertiseMinor = '';
var vrSkillMajor = '';
var vrSkillMinor = '';
var previousClickId;
var isDBClickAttached = false;
var isSchedularInit = false;
var refreshCalendar = false;

var ApplyFilterRole = function(strRole, strStatus, strResource, strLocation, strExpertiseMajor, strExpertiseMinor, strSkillMajor, strSkillMinor) 
{
    if(strRole != null && strRole != '') {
        vrRole = strRole.getAttribute('value'); 
    }
    
    if(strStatus != null && strStatus != '') {
        vrStatus = strStatus.getAttribute('value'); 
    }
    
    if(strResource != null && strResource != '') {
        vrResource = strResource; 
    }
    //else { vrResource = ''; }

    if(strLocation != null && strLocation != '') {
        vrLocation = strLocation.getAttribute('value'); 
    }

    if(strExpertiseMajor != null && strExpertiseMajor != '') {
        vrExpertiseMajor = strExpertiseMajor.getAttribute('value');
        vrSkillMajor = '';
    }

    if(strExpertiseMinor != null && strExpertiseMinor != '') {
        vrExpertiseMinor = strExpertiseMinor.getAttribute('value');
        vrSkillMinor = '';
    }

    if(strSkillMajor != null && strSkillMajor != '') {
        vrSkillMajor = strSkillMajor.getAttribute('value');
    }

    if(strSkillMinor != null && strSkillMinor != '') {
        vrSkillMinor = strSkillMinor.getAttribute('value');
    }

    if(strExpertiseMajor == null || vrExpertiseMajor == '') {
        loadData(vrRole, vrStatus, vrResource, vrLocation, vrExpertiseMajor, vrExpertiseMinor, vrSkillMajor, vrSkillMinor, false);
    }
}

function loadData(role, status, resource, location, expertiseMajor, expertiseMinor, skillMajor, skillMinor, isOnload) 
{
    scheduler.clearAll();
    
    // 2016-12-28 matt.keefe@cdk.com - formatted code... RQ-08389
    TRV_ResourceManagement_Controller.getB4BCoaching( 
        role, status, resource, location, expertiseMajor, expertiseMinor, skillMajor, skillMinor, isOnload,
        function(result, event)
        {
            var records = result;
            
            var sections = [];
            //var intCount = 0;
            var objScheduler = [];
            var lstUniqueResource = [];
            
            for(var i=0; i < records.length; i++) 
            {    
                if(!$.isEmptyObject(records[i].objB4BCoaching)) {
                    
                    // 2016-12-28 matt.keefe@cdk.com - added variables for shorthand references - RQ-08389
                    var TraverProjectRecordId = records[i].objB4BCoaching.Traver_Project__c;
                    var TraverProjectRecord = records[i].objB4BCoaching.Traver_Project__r;
                    //console.log(TraverProjectRecord.TRV_PSC__c);
                    var DeliveryLocationId = records[i].objB4BCoaching.Delivery_Location__c;
                    var DeliveryLocation = records[i].objB4BCoaching.Delivery_Location__r;
                    
                    var date = new Date(records[i].objB4BCoaching.Visit_Start_Date__c);
                    var traverDays;
                    var traverDaysCount;
                    var deliveryLocations; deliveryLocations = '';
                    var city;
                    var state;
                    
                    // 2016-12-28 matt.keefe@cdk.com - added error handling - RQ-08389
                    if(DeliveryLocationId != undefined && DeliveryLocation != undefined)
                    {
                        city = DeliveryLocation.BillingCity == undefined ? '' : DeliveryLocation.BillingCity + ', ';
                        state = DeliveryLocation.BillingState == undefined ? '' : DeliveryLocation.BillingState;
                        deliveryLocations = city + state;
                    }
                    else if(TraverProjectRecord != undefined && TraverProjectRecord.Account__r != undefined)
                    {
                        city = TraverProjectRecord.Account__r.BillingCity == undefined ? '' : TraverProjectRecord.Account__r.BillingCity + ', ';
                        state = TraverProjectRecord.Account__r.BillingState == undefined ? '' : TraverProjectRecord.Account__r.BillingState;
                        deliveryLocations = city + state;
                    }
                    
                    if(records[i].objB4BCoaching.RecordType.DeveloperName == 'PSC_Visit')
                    {
                        traverDays = records[i].objB4BCoaching.Number_of_Days_PSG__c ? records[i].objB4BCoaching.Number_of_Days_PSG__c - 1 : 0;
                        traverDaysCount = records[i].objB4BCoaching.Number_of_Days_PSG__c ? records[i].objB4BCoaching.Number_of_Days_PSG__c : 0;
                    }
                    else if(records[i].objB4BCoaching.RecordType.DeveloperName == 'Non_Billable')
                    {
                        traverDays= records[i].objB4BCoaching.TRV_Number_Of_Days_NonBillable__c ? records[i].objB4BCoaching.TRV_Number_Of_Days_NonBillable__c - 1 : 0;
                        traverDaysCount = records[i].objB4BCoaching.TRV_Number_Of_Days_NonBillable__c ? records[i].objB4BCoaching.TRV_Number_Of_Days_NonBillable__c : 0;
                    }
                        else
                        {
                            traverDays= records[i].objB4BCoaching.Number_of_Days_Traver__c ? records[i].objB4BCoaching.Number_of_Days_Traver__c - 1 : 0;
                            traverDaysCount = records[i].objB4BCoaching.Number_of_Days_Traver__c ? records[i].objB4BCoaching.Number_of_Days_Traver__c : 0
                        }
                    
                    if( lstUniqueResource.indexOf(records[i].objB4BCoaching.TRV_Completed_By__r.TRV_Resource__c) <= -1 ) 
                    {
                        lstUniqueResource.push(records[i].objB4BCoaching.TRV_Completed_By__r.TRV_Resource__c);
                        sections.push({
                            key: records[i].objB4BCoaching.TRV_Completed_By__c,
                            label: records[i].objB4BCoaching.TRV_Completed_By__r.TRV_Resource__r.Name,
                            city: records[i].objB4BCoaching.TRV_Completed_By__r.TRV_Location_City__c ? records[i].objB4BCoaching.TRV_Completed_By__r.TRV_Location_City__c + (records[i].objB4BCoaching.TRV_Completed_By__r.TRV_Location_State__c ? ',' : '') : '',
                            state: records[i].objB4BCoaching.TRV_Completed_By__r.TRV_Location_State__c ? records[i].objB4BCoaching.TRV_Completed_By__r.TRV_Location_State__c : ''
                        }); 
                    }
                    var installdate = TraverProjectRecordId && TraverProjectRecord.Software_Install__c ? new Date(TraverProjectRecord.Software_Install__c) : '';
                    objScheduler.push({
                        start_date: date.getUTCFullYear()+'-'+(date.getUTCMonth()+1)+'-'+date.getUTCDate()+' 00:00',
                        end_date: date.getUTCFullYear()+'-'+(date.getUTCMonth()+1)+'-'+(date.getUTCDate()+traverDays)+' 23:59',
                        //consulting_project: records[i].objSkillSet.B4B_Coaching__r.Traver_Project__c ? records[i].objSkillSet.B4B_Coaching__r.Traver_Project__r.Name : '',
                        EPC: TraverProjectRecordId && TraverProjectRecord.TRV_EPC__c ? TraverProjectRecord.TRV_EPC__r.Name : '',
                        PSC: TraverProjectRecordId && TraverProjectRecord.TRV_PSC__c ? TraverProjectRecord.TRV_PSC__r.Name : '',
                        text: records[i].objB4BCoaching.Project_Account__c ? records[i].objB4BCoaching.Project_Account__c : '',  
                        textB4BName: records[i].objB4BCoaching.Name,
                        NonBillableReason : records[i].objB4BCoaching.TRV_NonBillable_Reason__c, //2016-11-01 - vishal.bandari@cdk.com - added Non-Billable Reason - RQ-07935
                        b4bId: records[i].objB4BCoaching.Id,
                        projectId: TraverProjectRecordId ? TraverProjectRecordId : '',
                        recordType: records[i].objB4BCoaching.RecordType ? records[i].objB4BCoaching.RecordType.Name : '',
                        contact: TraverProjectRecordId && TraverProjectRecord.Contact__r ? TraverProjectRecord.Contact__r.Name : '',
                        //manager: records[i].objSkillSet.B4B_Coaching__r.Traver_Project__c && records[i].objSkillSet.B4B_Coaching__r.Traver_Project__r.Manager__c ? records[i].objSkillSet.B4B_Coaching__r.Traver_Project__r.Manager__r.Name : '',
                        section_id: records[i].objB4BCoaching.TRV_Completed_By__c,
                        color: records[i].b4bColorValue,
                        traverCount: traverDaysCount,
                        deliveryLocation: deliveryLocations,
                        SoftwareInstallDate: installdate != '' ? (installdate.getMonth()+1) + '/' + installdate.getDate() + '/' + installdate.getFullYear() : ''
                    });
                }
                else {
                    
                    if( lstUniqueResource.indexOf(records[i].resource.TRV_Resource__c) <= -1 ) {
                        
                        lstUniqueResource.push(records[i].resource.TRV_Resource__c);
                        
                        sections.push({
                            key: records[i].resource.Id,
                            label: records[i].resource.TRV_Resource__r.Name,
                            city: records[i].resource.TRV_Location_City__c ? records[i].resource.TRV_Location_City__c + (records[i].resource.TRV_Location_State__c ? ',' : '') : '',
                            state: records[i].resource.TRV_Location_State__c ? records[i].resource.TRV_Location_State__c : ''
                        }); 
                    }
                }
            }
            
            if(!isSchedularInit) {
                
                scheduler.locale.labels.timeline_tab = "Timeline";
                scheduler.locale.labels.section_custom="Section";
                scheduler.config.details_on_create=true;
                scheduler.config.details_on_dblclick=true;
                scheduler.config.xml_date="%Y-%m-%d %H:%i";
                scheduler.config.dblclick_create = false;
                scheduler.config.drag_resize= false; // for stopping dragging of events
                //scheduler.config.drag_highlight = true;
                //scheduler.config.multisection = false; 
                scheduler.config.drag_create = false; // To avoid create event on drag
                
                var scheduler_container = document.getElementById("scheduler_here");
                var scheduler_container_divs = scheduler_container.getElementsByTagName("div");
                var dhx_cal_data = scheduler_container_divs[scheduler_container_divs.length-1];
                
                scheduler.dhtmlXTooltip.isTooltipTarget = function(target) {
                    while (target.parentNode && target != dhx_cal_data) {
                        var css = target.className.split(" ")[0];
                        
                        if (css == "dhx_matrix_scell" || css == "dhtmlXTooltip") {
                            return { classname: css };
                        }
                        target = target.parentNode;
                    }
                    return false;
                };
                
                scheduler.attachEvent("onMouseMove", function(id, e) {
                    
                    var timeline_view = scheduler.matrix[scheduler.getState().mode];
                    if (id || !timeline_view) {
                        return;
                    }
                    
                    e = e||window.event;
                    var target = e.target||e.srcElement;
                    
                    var tooltip = scheduler.dhtmlXTooltip;
                    var tooltipTarget = tooltip.isTooltipTarget(target);
                    if (tooltipTarget) {
                        if (tooltipTarget.classname == "dhx_matrix_scell") {
                            
                            var section_id = scheduler.getActionData(e).section;
                            var section = timeline_view.y_unit[timeline_view.order[section_id]];
                            
                            
                            var text = section.label+"<br/>"+section.city+' '+section.state;
                            tooltip.delay(tooltip.show, tooltip, [e, text]);
                        }
                        if (tooltipTarget.classname == "dhtmlXTooltip") {
                            
                            dhtmlxTooltip.delay(tooltip.show, tooltip, [e, tooltip.tooltip.innerHTML]);
                        }
                    }
                }); 
                
                scheduler.attachEvent("onBeforeDrag", function(){
                    
                    if (scheduler._mode == "timeline") return true;
                    return false;
                });
                
                scheduler.attachEvent("onBeforeEventChanged", function(ev, e, is_new, original){
                    
                    $('#loadingScreenId #el_loading').css('display','block');
                    var b4BCoachingId = original.b4bId;
                    var resourceId = ev.section_id;
                    var dateUpdatedTo = new Date(ev.start_date);
                    
                    var dateEndDate = new Date(ev.end_date);
                    var dtHours = dateUpdatedTo.getHours();
                    
                    var schedulerEvent = scheduler.getEvent(ev.id);
                    
                    var dtStart;
                    var endDate;
                    
                    if(dtHours >= 12){
                        
                        var dateSUpdatedTo = new Date(dateUpdatedTo.setDate(dateUpdatedTo.getDate() + 1));
                        dtStart = dateSUpdatedTo.getFullYear()+'/'+(dateSUpdatedTo.getMonth()+1)+'/'+(dateSUpdatedTo.getDate())+' 00:00';
                        endDate = dateEndDate.getFullYear()+'/'+(dateEndDate.getMonth()+1)+'/'+(dateEndDate.getDate())+' 23:59';
                        schedulerEvent.start_date = new Date(dtStart);
                        schedulerEvent.end_date = new Date(endDate);
                        
                    }
                    else if(ev.traverCount == 0 || ev.traverCount == 1){
                        dtStart = dateUpdatedTo.getFullYear()+'/'+(dateUpdatedTo.getMonth()+1)+'/'+(dateUpdatedTo.getDate())+' 00:00';
                        endDate = dateUpdatedTo.getFullYear()+'/'+(dateUpdatedTo.getMonth()+1)+'/'+(dateUpdatedTo.getDate())+' 23:59';
                        schedulerEvent.start_date = new Date(dtStart);
                        schedulerEvent.end_date = new Date(endDate);
                        
                    }
                        else{
                            
                            dtStart = dateUpdatedTo.getFullYear()+'/'+(dateUpdatedTo.getMonth()+1)+'/'+(dateUpdatedTo.getDate())+' 00:00';
                            var dateCUpdatedTo = new Date(dateUpdatedTo.setDate(dateUpdatedTo.getDate() + ev.traverCount-1));
                            
                            endDate = dateCUpdatedTo.getFullYear()+'/'+(dateCUpdatedTo.getMonth()+1)+'/'+(dateCUpdatedTo.getDate())+' 23:59';
                            schedulerEvent.start_date = new Date(dtStart);
                            schedulerEvent.end_date = new Date(endDate);
                        }
                    
                    
                    scheduler.updateEvent(ev.id);  
                    
                    var dtStartDate = new Date(ev.start_date);
                    var dtYear = dtStartDate.getFullYear();
                    var dtMonth = dtStartDate.getMonth() + 1;
                    var dtDate = dtStartDate.getDate();
                    var visitStartDate = dtYear+'-'+dtMonth+'-'+dtDate;
                    
                    TRV_ResourceManagement_Controller.updateB4BCoachingRecord( 
                        b4BCoachingId, resourceId, visitStartDate, function(result, event)
                        { 
                            if(!result){
                                alert('The B4B record cannot be assigned to the User!');
                                //document.location.reload(true);
                                $('#loadingScreenId #el_loading').css('display','none');
                                var newEvent = scheduler.getEvent(ev.id);
                                
                                newEvent.start_date = new Date(original.start_date);
                                newEvent.end_date = new Date(original.end_date);
                                newEvent.section_id = original.section_id;
                                newEvent._sorder = original._sorder;
                                newEvent._dhx_changed = false;
                                scheduler.updateEvent(ev.id);
                                scheduler.updateView();
                            }
                            else
                                $('#loadingScreenId #el_loading').css('display','none');
                        }
                    );
                    return true;
                });
                
                Date.prototype.toInputFormat = function() {
                    var yyyy = this.getFullYear().toString();
                    var mm = (this.getMonth()+1).toString(); // getMonth() is zero-based
                    var dd  = this.getDate().toString();
                    return yyyy + "-" + (mm[1]?mm:"0"+mm[0]) + "-" + (dd[1]?dd:"0"+dd[0]); // padding
                };
                
                scheduler.showLightbox = function(id){}             
                
                scheduler.templates.tooltip_text = function(start,end,ev){
                    
                    return "<b>Account Name:</b>" + ev.text + "<br/>" + 
                        "<b>Contact:</b> " + ev.contact + "<br/>" +
                        "<b>EPC:</b> " + ev.EPC + "<br/>" + 
                        "<b>PSC:</b> " + ev.PSC + "<br/>" +
                        "<b>Software Install Date:</b> " + ev.SoftwareInstallDate + "<br/>" +
                        "<b>B4B Coaching Record Type:</b> " + ev.recordType + "<br/>" +
                        //2016-11-01 - vishal.bandari@cdk.com - added Non-Billable Reason - RQ-07935
                        (ev.NonBillableReason !=null && ev.NonBillableReason != "" && ev.NonBillableReason != undefined ? "<b>Non-Billable Reason: </b>" + ev.NonBillableReason+"<br/> " : "") + 
                        "<b>Delivery Location:</b> " + ev.deliveryLocation;
                    
                };
                
                //var dbClickId = scheduler.attachEvent("onDblClick", function (id, e){
                //    window.open('../'+scheduler._events[id].b4bId, '_blank');
                //    return true;
                //});
                
                //if(!isDBClickAttached)
                //{ 
                //    var dbClickId = scheduler.attachEvent("onDblClick", function (id, e){
                //        console.log('====onDblClick==id==', id, '==e==', e);
                //        if(previousClickId == dbClickId) {
                //            scheduler.detachEvent(previousClickId);
                //        }
                //        else {
                //            previousClickId = dbClickId;
                //            window.open('../'+scheduler._events[id].b4bId, '_blank');
                //            return true;
                //        }
                //        
                //        window.open('../'+scheduler._events[id].b4bId, '_blank');
                //        return true;
                //    });
                //}    
                //
                //isDBClickAttached = true;
                
                scheduler.attachEvent(
                    "onClick", function (id, e)
                    {
                        //any custom logic here
                        window.open('../'+scheduler._events[id].b4bId, '_blank');
                        return true;
                    }
                );
                
                scheduler.attachEvent(
                    "onEmptyClick", 
                    function ( date , e ) {
                        
                        var timeline_view = scheduler.matrix[scheduler.getState().mode];
                        
                        var time_y_property = timeline_view.y_unit[timeline_view.order[scheduler.getActionData(e).section]];
                        
                        var userId = time_y_property.key;
                        
                        var dt = new Date(date);
                        var dtYear = dt.getFullYear();
                        var dtMonth = dt.getMonth() + 1;
                        var dtDate = dt.getDate();
                        var targetClicked = e.target['className'];
                        
                        if(targetClicked == 'dhx_matrix_scell') {
                            
                            window.open('../'+userId);
                            return true;
                        }
                        
                        var expertiseMajor = $('[id$=expertiseMajorId]').val();
                        var expertiseMinor = $('[id$=expertiseMinorId]').val();
                        var skillLevelMajor = $('[id$=skillLevelMajorId]').val();
                        var skillLevelMinor = $('[id$=skillLevelMinorId]').val();
                        var dateVariable = dtYear+'-'+dtMonth+'-'+dtDate;
                        
                        expertiseMinor = encodeURI(expertiseMinor).indexOf('_%01_') != -1 ? '' : expertiseMinor;
                        skillLevelMajor = encodeURI(skillLevelMajor).indexOf('_%01_') != -1 ? '' : skillLevelMajor;
                        skillLevelMinor = encodeURI(skillLevelMinor).indexOf('_%01_') != -1 ? '' : skillLevelMinor;
                        
                        window.open('../apex/TRV_ResourceManagementAutoComplete?visitStartDate='+dateVariable+'&ExMajor='+expertiseMajor+'&ExMinor='+expertiseMinor+'&skLevMajor='+skillLevelMajor+'&skLevMinor='+skillLevelMinor+'&resourceId='+userId, '_target'); //,'width=800,height=600'
                        return true;
                    }
                );            
            }
            
            isSchedularInit = true;
            
            scheduler.createTimelineView({
                name:   "timeline",
                x_unit: "day",
                x_date: "%D %n/%d",
                x_step: 1,
                x_size: 10,
                x_start: 0,
                dx:150,
                y_unit: sections,
                y_property: "section_id",
                render:"bar"
            });
            
            scheduler.config.lightbox.sections=[
                {name:"description", height:130, map_to:"text", type:"textarea" , focus:true},
                {name:"custom", height:23, type:"select", options:sections, map_to:"section_id" },
                {name:"time", height:72, type:"time", map_to:"auto"}
            ];
            
            if(refreshCalendar){
                var dt = new Date(scheduler.getState().date);
                var dtYear = dt.getFullYear();
                var dtMonth = dt.getMonth();
                var dtDate = dt.getDate();
                
                scheduler.init('scheduler_here', new Date(dtYear, dtMonth, dtDate), scheduler.getState().mode);
                refreshCalendar = false;
                $('#loadingScreenId #el_loading').css('display','none');
            }
            else {
                scheduler.init('scheduler_here', new Date(), "timeline");
            }
            
            scheduler.parse(objScheduler,"json");
        }
    );    
}

$(document).ready(function() {
    
    TRV_ResourceManagement_Controller.getFilterPreferences(function(result){

        vrRole = result.TRV_Role__c ? result.TRV_Role__c : '';
        vrStatus = result.TRV_Resource_Status__c ? result.TRV_Resource_Status__c : '';
        vrResource = result.TRV_Resource__c ? result.TRV_Resource__c : '';
        vrLocation = result.TRV_Resource_Location__c ? result.TRV_Resource_Location__c : '';
        vrExpertiseMajor = result.TRV_Expertise_Major__c ? result.TRV_Expertise_Major__c : '';
        vrExpertiseMinor = result.TRV_Expertise_Minor__c ? result.TRV_Expertise_Minor__c : '';
        vrSkillMajor = result.TRV_Skill_Level_Major__c ? result.TRV_Skill_Level_Major__c : '';
        vrSkillMinor = result.TRV_Skill_Level_Minor__c ? result.TRV_Skill_Level_Minor__c : '';
        
        loadData(vrRole, vrStatus, vrResource, vrLocation, vrExpertiseMajor, vrExpertiseMinor, vrSkillMajor, vrSkillMinor, true);
    });

    var windowheight = window.innerHeight;
    var filterHeight = $('#filterSectionId').height();
    var ganttHeight = parseInt(windowheight) - parseInt(filterHeight);
    
    $('#scheduler_here').css('height', ganttHeight);
});

function resetFilters() {

    vrRole = '';
    vrStatus = '';
    vrResource = '';
    vrLocation = '';
    vrExpertiseMajor = '';
    vrExpertiseMinor = '';
    vrSkillMajor = '';
    vrSkillMinor = '';
    loadData(vrRole, vrStatus, vrResource, vrLocation, vrExpertiseMajor, vrExpertiseMinor, vrSkillMajor, vrSkillMinor, false);
}

function exitRM() {

    if(window.history.length === 1) {

        window.close();
    }
    else {

        window.history.back();
    }
}

function refreshTimeLineView(){
    
    $('#loadingScreenId #el_loading').css('display','block');
    refreshCalendar = true;
    
    //scheduler.updateView(new Date(2016,1,3), scheduler.getState().mode);
    loadData(vrRole, vrStatus, vrResource, vrLocation, vrExpertiseMajor, vrExpertiseMinor, vrSkillMajor, vrSkillMinor, false);
    
}

function show_minical(){
            
    if (scheduler.isCalendarVisible()){
        scheduler.destroyCalendar();
    } else {
        scheduler.renderCalendar({
            position:"dhx_minical_icon",
            date:scheduler._date,
            navigation:true,
            handler:function(date,calendar){
                scheduler.setCurrentView(date);
                scheduler.destroyCalendar()
            }
        });
    }
}