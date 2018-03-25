/*******************************************************************************
 **RQ-08648 3/1/2017 Created Vijay.manimaran@cdk.com 
 ******************************************************************************** */

({
    fetch_Helper: function(component) {
        var action = component.get("c.fetchPendingTermination");
        var saveContinue = component.find('saveContinue');
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.contactList", response.returnValue);
                $A.util.removeClass(saveContinue, 'manager-form-hide');
            }
        });
        $A.enqueueAction(action);
    },
    
    update_FetchAssociateTermination: function(component, response, helper) {
        var state = response.state;
        var managerForm = component.find('managerForm');
        var resignationForm = component.find('resignationForm');
        var resignationPanel = component.find('resignationPanel');
        var myResignationProgress = component.find('myResignationProgress');
        var lastDayProgress = component.find('lastDayProgress');
        var Oregon = component.find('Oregon');
        var Michigan = component.find('Michigan');
        var washington = component.find('washington');
        var canadaQuestion = component.find('canadaQuestion');
        var involuntaryTermination = component.find('involuntaryTermination_Q');
                var involuntaryHeader = component.find('involuntaryHeader');

        this.onchange_Helper(component);
        console.log(state);
        if (state === "SUCCESS") {
            component.set("v.portalFormsreturn", response.returnValue);
            component.set("v.portalForm", response.returnValue);
            component.set('v.ltng_icon_resignation', 'utility:chevrondown');
            component.set('v.ltng_icon_mycareer', 'utility:chevrondown');
            component.set('v.ltng_icon_lastday', 'utility:chevrondown');
            $A.util.removeClass(managerForm, 'manager-form-hide');
            if (response.returnValue.Mgr_Term_Work_Location__c === 'Oregon') {
                $A.util.removeClass(Oregon, 'manager-form-hide');
            }
            if (response.returnValue.Mgr_Term_Work_Location__c === 'Michigan') {
                $A.util.removeClass(Michigan, 'manager-form-hide');
            }
            if (response.returnValue.Mgr_Term_Work_Location__c === 'Washington') {
                $A.util.removeClass(washington, 'manager-form-hide');
            }
            if (response.returnValue.Mgr_Term_Work_Location__c === 'Canada') {
                $A.util.removeClass(canadaQuestion, 'manager-form-hide');
            }
            if (response.returnValue.Mgr_Term_Involuntary__c === true) {
                this.immediateActionPanel_helper(component, response, helper);
                $A.util.removeClass(involuntaryTermination, 'manager-form-hide');
                $A.util.removeClass(involuntaryHeader, 'manager-form-hide');

            } else {
                if (response.returnValue.Mgr_Term_Q01_myCareer__c === 'No' || response.returnValue.Mgr_Term_Q02_HRBP__c === 'No' ||
                    response.returnValue.Mgr_Term_Q01a_myCareer__c === undefined) {
                    this.onchange_utility(component, '', '', '', '', resignationPanel, resignationForm);
                    this.progressBar_utility(component, myResignationProgress, myResignationProgress, '', '', '', myResignationProgress);
                    this.progressBar_utility(component, myResignationProgress, myResignationProgress, '', '', '', myResignationProgress);
                    this.progressBar_utility(component, lastDayProgress, lastDayProgress, '', '', '', lastDayProgress);
                    $A.util.addClass(involuntaryTermination, 'manager-form-hide');
                    
                    this.onchange_Helper(component, event, helper);
                } else {
                    this.immediateActionPanel_helper(component, response, helper);
                    
                }
            }
        }
    },
    
    immediateActionPanel_helper: function(component, response, helper) {
        var resignationForm = component.find('resignationForm');
        var resignationPanel = component.find('resignationPanel');
        var lastDayForm = component.find('lastDayForm');
        var lastDayPanel = component.find('lastDayPanel');
        var myCareerProgress = component.find('myCareerProgress');
        var myResignationProgress = component.find('myResignationProgress');
        var lastDayProgress = component.find('lastDayProgress');
        var saveContinue = component.find('saveContinue');
        var Submit = component.find('Submit');
        var myCareers_Ques = component.find('myCareer_Q1');
        var myCareer_HRBP = component.find('myCareer_Q2');
        var myCareerContentPanel = component.find('myCareerPanel');
        var employeeCellPhoneQ_invol = component.find('employeeCellPhoneQ_invol');
        var employeeDirectReportQ = component.find('employeeDirectReportQ');
        var involuntaryTermination = component.find('involuntaryTermination_Q');
        var salesEmployeeQ = component.find('salesEmployeeQ');
        var involuntaryHeader = component.find('involuntaryHeader');
        
        /* involuntary code */
        
        console.log('am in immediate action');
        /* involuntary code ends*/
        console.log('response.returnValue.Mgr_Term_Q03_employeeData__c ',response.returnValue.Mgr_Term_Q03_employeeData__c );
        console.log('response.returnValue.Mgr_Term_Q04_employeeFleetVechicle__c',response.returnValue.Mgr_Term_Q04_employeeFleetVechicle__c);
        console.log('response.returnValue.Mgr_Term_Q05_employeeCarAllowance__c ',response.returnValue.Mgr_Term_Q05_employeeCarAllowance__c );
        console.log('response.returnValue.Mgr_Term_Q18_Immigration__c',response.returnValue.Mgr_Term_Q18_Immigration__c);
        if (response.returnValue.Mgr_Term_Q03_employeeData__c === undefined ||
            response.returnValue.Mgr_Term_Q04_employeeFleetVechicle__c === undefined || response.returnValue.Mgr_Term_Q05_employeeCarAllowance__c === undefined ||
            response.returnValue.Mgr_Term_Q18_Immigration__c === undefined) {
            console.log('am in first 3 4 5 18');
            if (response.returnValue.Mgr_Term_Involuntary__c !== true) {
                this.resignationPanel_helper(component, response);
                this.progressBar_utility(component, myResignationProgress, myResignationProgress, '', '', '', myResignationProgress);
                this.onchange_utility(component, '', myCareerProgress, '', '', resignationPanel, resignationForm);
                this.onchange_utility(component, myCareerContentPanel, saveContinue, '', '', Submit, lastDayForm);
                this.progressBar_utility(component, lastDayProgress, lastDayProgress, '', myCareerProgress, '', lastDayProgress);
                $A.util.addClass(employeeCellPhoneQ_invol, 'manager-form-hide');
                $A.util.addClass(employeeDirectReportQ, 'manager-form-hide');
                $A.util.addClass(salesEmployeeQ, 'manager-form-hide');
                $A.util.addClass(involuntaryHeader, 'manager-form-hide');
                $A.util.addClass(involuntaryTermination, 'manager-form-hide');
                
            } else {
                console.log('am here inside first invol blocxk');
                this.onchange_utility(component, saveContinue, '', '', lastDayForm, lastDayPanel, Submit);
                this.onchange_utility(component, '', '', '', '', resignationPanel, resignationForm);
                this.progressBar_utility(component, lastDayProgress, '', myResignationProgress, myResignationProgress, '', lastDayProgress);
                this.onchange_utility(component, '', '', '', myResignationProgress, myCareer_HRBP, myCareers_Ques);
                this.onchange_utility(component, '', '', '', '', '', resignationPanel);
                this.onchange_Helper(component, event, helper);
                $A.util.removeClass(employeeCellPhoneQ_invol, 'manager-form-hide');
                $A.util.removeClass(employeeDirectReportQ, 'manager-form-hide');
                $A.util.removeClass(salesEmployeeQ, 'manager-form-hide');
                $A.util.removeClass(involuntaryHeader, 'manager-form-hide');
                $A.util.removeClass(involuntaryTermination, 'manager-form-hide');
            }
            this.onchange_Helper(component, event, helper);
        } else {
            if (response.returnValue.Mgr_Term_Involuntary__c !== true) {
                this.resignationPanel_helper(component, response, helper);
                $A.util.addClass(involuntaryHeader, 'manager-form-hide');
            } else {
                
                if (response.returnValue.Mgr_Term_Q07_employeeCellPhone__c !== undefined && response.returnValue.Mgr_Term_Q09_employeeDirectReport__c !== undefined &&
                    response.returnValue.Mgr_Term_Q09a_employeeDirectReport__c !== undefined &&
                    response.returnValue.Mgr_Term_Q12_salesEmployee__c !== undefined) {
                    console.log('am here ');
                    this.progressBar_utility(component, myCareerProgress, lastDayProgress, lastDayProgress, lastDayProgress, myCareerProgress, '');
                    this.onchange_utility(component, Submit, lastDayPanel, lastDayForm, saveContinue, '', '');
                    this.onchange_Helper(component, event, helper);
                    component.set('v.ltng_icon_mycareer', 'utility:chevronright');
                    $A.util.addClass(myCareerContentPanel, 'manager-form-hide');
                    $A.util.addClass(myResignationProgress, 'manager-form-hide');
                    $A.util.removeClass(involuntaryHeader, 'manager-form-hide');
                } else {
                    console.log('immediate actin completed');
                    this.onchange_utility(component,Submit,lastDayForm, lastDayPanel,'','', saveContinue);
                    this.onchange_utility(component, '', '', '', '', resignationPanel, resignationForm);
                    this.progressBar_utility(component, '', '', lastDayProgress, myResignationProgress, '','');
                    this.progressBar_utility(component, myCareerProgress, '', myResignationProgress, lastDayProgress, myCareerProgress,'');
                    
                    //this.progressBar_utility(component, myResignationProgress, '', myResignationProgress, lastDayProgress, myResignationProgress, '');
                    //progressBar_utility: function(component, remove_current, remove_complete, remove_incomplete, add_current, add_complete, add_incomplete) 
                    this.onchange_utility(component, '', '', '', myResignationProgress, myCareer_HRBP, myCareers_Ques);
                    this.onchange_utility(component, '', '', '', '', '', resignationPanel);
                    this.onchange_Helper(component, event, helper);
                    $A.util.removeClass(employeeCellPhoneQ_invol, 'manager-form-hide');
                    $A.util.removeClass(employeeDirectReportQ, 'manager-form-hide');
                    $A.util.removeClass(salesEmployeeQ, 'manager-form-hide');
                }
            }
        }
    },
    
    createManagerRecord_helper: function(component, helper) {
        var selectAssociate = component.find('selectAssociate');
        var action = component.get("c.createPortalForms");
        var contactName = component.find('contactName').get("v.value");
        var workLocation = component.find('workLocation').get("v.value");
        
        if (contactName === '' || contactName === null || workLocation === '' || workLocation === null) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error !",
                "message": "Please Select the Associate and work location."
            });
            toastEvent.fire();
            return false;
        }
        action.setParams({
            portalForms: component.get("v.portalForm")
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.portalForms", response.returnValue);
                $A.util.addClass(selectAssociate, 'manager-form-hide');
                component.getContactDetails();
                this.onchange_Helper(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    resignationPanel_helper: function(component, response, helper) {
        var resignationForm = component.find('resignationForm');
        var resignationPanel = component.find('resignationPanel');
        var lastDayForm = component.find('lastDayForm');
        var lastDayPanel = component.find('lastDayPanel');
        var myCareerProgress = component.find('myCareerProgress');
        var myResignationProgress = component.find('myResignationProgress');
        var lastDayProgress = component.find('lastDayProgress');
        var saveContinue = component.find('saveContinue');
        var Submit = component.find('Submit');
        var myCareerContentPanel = component.find('myCareerPanel');
        var resignationcontentPanel = component.find('resignationPanel');
        this.onchange_utility(component, resignationPanel, resignationForm, '', '', '', '');
        this.progressBar_utility(component, myCareerProgress, '', myResignationProgress, myResignationProgress, myCareerProgress, '');
        this.onchange_Helper(component, event, helper);
        component.set('v.ltng_icon_mycareer', 'utility:chevronright');
        $A.util.addClass(myCareerContentPanel, 'manager-form-hide');
        
        if (response.returnValue.Mgr_Term_Q06_employeeAddress__c === undefined || response.returnValue.Mgr_Term_Q07_employeeCellPhone__c === undefined || response.returnValue.Mgr_Term_Q08_employeeExpenseReport__c === undefined ||
            response.returnValue.Mgr_Term_Q09_employeeDirectReport__c === undefined || response.returnValue.Mgr_Term_Q10_employeeeTime__c === undefined ||
            response.returnValue.Mgr_Term_Q12_salesEmployee__c === undefined) {
            this.onchange_utility(component, saveContinue, '', '', Submit, lastDayPanel, lastDayForm);
            this.onchange_utility(component, saveContinue, resignationForm, '', '', '', '');
            this.progressBar_utility(component, lastDayProgress, myResignationProgress, '', '', '', lastDayProgress);
            this.onchange_Helper(component, event, helper);
        } else {
            this.onchange_utility(component, Submit, lastDayPanel, lastDayForm, '', '', saveContinue);
            $A.util.removeClass(lastDayProgress, 'slds-is-incomplete');
            this.progressBar_utility(component, myResignationProgress, '', myResignationProgress, lastDayProgress, myResignationProgress, '');
            this.onchange_Helper(component, event, helper);
            component.set('v.ltng_icon_resignation', 'utility:chevronright');
            $A.util.addClass(resignationcontentPanel, 'manager-form-hide');
        }
    },
    
    onchange_Helper: function(component) {
        var myCareers_selectedvalue = component.find('myCareers').get("v.value");console.log('am here');
        var myCareers_selectedvalue_invol = component.find('myCareers_invol').get("v.value");console.log('am here');
        
        var myCareerHRBP_selectedvalue = component.find('myCareer_HRBP').get("v.value");console.log('am here');
        var carAllowance = component.find('carAllowance').get("v.value");console.log('am here');
        var employeeFleetVechicle = component.find('employeeFleetVechicle').get("v.value");console.log('am here');
        var employeeData = component.find('employeeData').get("v.value");console.log('am here');
        var employeeAddress = component.find('employeeAddress').get("v.value");console.log('am here');
        var employeeCellPhone = component.find('employeeCellPhone').get("v.value");console.log('am here');
        var employeeExpenseReport = component.find('employeeExpenseReport').get("v.value");console.log('am here');
        var employeeeTime = component.find('employeeeTime').get("v.value");console.log('am here');
        var employeeCanada = component.find('employeeCanada').get("v.value");console.log('am here');
        var salesEmployee = component.find('salesEmployee').get("v.value");console.log('am here');
        var salesEmployee_invol = component.find('salesEmployee_invol').get("v.value");console.log('am here');
        // var employeeDirectReportinvol_Q1a = component.find('employeeDirectReportinvol_Q1a').get("v.value");
        var employeeDirectReport = component.find('employeeDirectReport').get("v.value");console.log('am here');
        //var employeeDirectReport_invol = component.find('employeeDirectReport_invol').get("v.value");console.log('am here');
        var employeeDirectReportinvol_Msg = component.find('employeeDirectReportinvol_Msg');console.log('am here');
        var employeeDirectReportQ1a = component.find('employeeDirectReport_Q1a').get("v.value");console.log('am here');
        var allEquipment = component.find('allEquipment').get("v.value");console.log('am here');
        var allEquipment1a = component.find('allEquipment1a').get("v.value");console.log('am here');
        var OregonQ18 = component.find('Oregon_Q18').get("v.value");console.log('am here');
        var washingtonQ18 = component.find('washington_Q18').get("v.value");console.log('am here');
        var MichiganQ18 = component.find('Michigan_Q18').get("v.value");console.log('am here');
        var creditCard = component.find('creditCard').get("v.value");console.log('am here');
        var employeeFacilities = component.find('employeeFacilities').get("v.value");console.log('am here');
        var employeeKeys = component.find('employeeKeys').get("v.value");console.log('am here');
        var clientDocuments = component.find('clientDocuments').get("v.value");console.log('am here');
        var employeeImmigration = component.find('employeeImmigration').get("v.value");console.log('am here');
        var employeeCellPhoneMsg = component.find('employeeCellPhone_Msg');console.log('am here');
        var employeeExpenseReportMsg = component.find('employeeExpenseReport_Msg');console.log('am here');
        var employeeeTimeMsg = component.find('employeeeTime_Msg');console.log('am here');
        var employeeCanadaMsg = component.find('employeeCanada_Msg');console.log('am here');
        var employeeAddressMsg = component.find('employeeAddress_Msg');console.log('am here');
        var salesEmployeeMsg = component.find('salesEmployee_Msg');console.log('am here');
        var salesEmployeeinvol_Msg = component.find('salesEmployeeinvol_Msg');console.log('am here');
        var employeeImmigrationMsg = component.find('employeeImmigration_Msg');console.log('am here');
        var myCareerMsg = component.find('myCareers_Msg');console.log('am here');console.log('am here');
        var myCareerMsg_invol = component.find('myCareersinvol_Msg');console.log('am here');
        
        var myCareerHRBPMsg = component.find('myCareers_HRBPMsg');
        var myCareersHRBPMsgNo = component.find('myCareers_HRBPMsg_No');
        var employeeDataMsg = component.find('employeeData_Msg');
        var myCareerDate = component.find('myCareers_Date');
        var myCareerDate_invol = component.find('myCareersinvol_Date');
        
        var employeeFleetVechicleMsg = component.find('employeeFleetVechicle_Msg');
        var carAllowanceMsg = component.find('carAllowance_Msg');
        var employeeDirectReportMsg = component.find('employeeDirectReport_Msg');
        var employeeDirectReportQ1Msg = component.find('employeeDirectReportQ1_Msg');
        var employeeDirectReportQ1invol_Msg = component.find('employeeDirectReportQ1invol_Msg');
        var allEquipmentMsg = component.find('allEquipment_Msg');
        var allEquipment1aMsg = component.find('allEquipment1a_Msg');
        var allEquipment13a = component.find('allEquipment13a');
        var employeeFacilitiesMsg = component.find('employeeFacilities_Msg');
        var employeeKeysMsg = component.find('employeeKeys_Msg');
        var clientDocumentsMsg = component.find('clientDocuments_Msg');
        var OregonMsg = component.find('Oregon_Msg');
        var washingtonMsg = component.find('washington_Msg');
        var MichiganMsg = component.find('Michigan_Msg');
        var creditCardMsg = component.find('creditCard_Msg');
        var myCareer_invol= component.find('myCareer_invol');
        var involuntaryTermination_invol = component.find('involuntaryTermination_invol').get("v.value");console.log('am here');
        var involuntaryTermination_Msg = component.find('involuntaryTermination_Msg');console.log('am here');
        this.completeFlag_utility(component);
        if (myCareers_selectedvalue === 'Yes') {
            this.onchange_utility(component, myCareerDate, '', '', '', '', myCareerMsg);
        } else {
            this.onchange_utility(component, myCareerMsg, '', '', '', '', myCareerDate);
        }
        if (myCareerHRBP_selectedvalue === 'Yes') {
            this.onchange_utility(component, '', '', '', '', '', myCareerHRBPMsg);
        } else if (myCareerHRBP_selectedvalue === 'No' || myCareerHRBP_selectedvalue === '' || myCareerHRBP_selectedvalue === 'undefined') {
            this.onchange_utility(component, myCareerHRBPMsg, '', '', '', '', '');
        }else{
            this.onchange_utility(component, '', '', '', '', '', myCareersHRBPMsgNo);
        }
        if (myCareerHRBP_selectedvalue === 'No' || myCareerHRBP_selectedvalue === ''|| myCareerHRBP_selectedvalue === 'undefined' ) 
        {
            this.onchange_utility(component, '', '', '', '', '', myCareersHRBPMsgNo);
        } else if(myCareerHRBP_selectedvalue === 'Yes'){
            this.onchange_utility(component, myCareersHRBPMsgNo, '', '', '', '', '');
        }
        if (involuntaryTermination_invol !== 'Reduction in Force') {
            this.onchange_utility(component, myCareer_invol, '', '', '', '',involuntaryTermination_Msg );
        } else {
            this.onchange_utility(component, involuntaryTermination_Msg, '', '', '','', myCareer_invol);
        }
        if (involuntaryTermination_invol === 'Reduction in Force') {
            this.onchange_utility(component, involuntaryTermination_Msg, '', '', '','', myCareer_invol);
        } else {
            this.onchange_utility(component, myCareer_invol, '', '', '', '',involuntaryTermination_Msg );
        }
        if (myCareers_selectedvalue_invol === 'Yes') {
            this.onchange_utility(component, myCareerDate_invol, '', '', '', '', myCareerMsg_invol);
        } else {
            this.onchange_utility(component, myCareerMsg_invol, '', '', '', '', myCareerDate_invol);
        }
        if (myCareers_selectedvalue_invol === 'No') {
            this.onchange_utility(component, myCareerMsg_invol, '', '', '', '', myCareerDate_invol);
        } else {
            this.onchange_utility(component, myCareerDate_invol, '', '', '', '', myCareerMsg_invol);
        }
        if (employeeData === 'Yes') {
            this.onchange_utility(component, employeeDataMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeDataMsg);
        }
        if (employeeFleetVechicle === 'Yes') {
            this.onchange_utility(component, employeeFleetVechicleMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeFleetVechicleMsg);
        }
        if (carAllowance === 'Yes') {
            this.onchange_utility(component, carAllowanceMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', carAllowanceMsg);
        }
        if (employeeAddress === 'Yes') {
            this.onchange_utility(component, employeeAddressMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeAddressMsg);
        }
        if (employeeCellPhone === 'Yes') {
            this.onchange_utility(component, employeeCellPhoneMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeCellPhoneMsg);
        }
        if (employeeExpenseReport === 'No') {
            this.onchange_utility(component, employeeExpenseReportMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeExpenseReportMsg);
        }
        if (salesEmployee === 'Yes') {
            this.onchange_utility(component, salesEmployeeMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', salesEmployeeMsg);
        }
        if (salesEmployee_invol === 'Yes') {
            this.onchange_utility(component, salesEmployeeinvol_Msg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', salesEmployeeinvol_Msg);
        }
        if (employeeCanada === 'Yes') {
            this.onchange_utility(component, employeeCanadaMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeCanadaMsg);
        }
        if (employeeeTime === 'No') {
            this.onchange_utility(component, employeeeTimeMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeeTimeMsg);
        }
        if (employeeDirectReport === 'Yes') {
            this.onchange_utility(component, employeeDirectReportMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeDirectReportMsg);
        }
        /* if (employeeDirectReport_invol === 'Yes') {
            this.onchange_utility(component, employeeDirectReportinvol_Msg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeDirectReportinvol_Msg);
        }*/
        if (employeeDirectReportQ1a === 'No') {
            this.onchange_utility(component, employeeDirectReportQ1Msg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeDirectReportQ1Msg);
        }
        /* if (employeeDirectReportinvol_Q1a === 'No') {
            this.onchange_utility(component, employeeDirectReportQ1invol_Msg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeDirectReportQ1invol_Msg);
        }*/
        if (allEquipment === 'No') {
            this.onchange_utility(component, allEquipmentMsg, '', '', '', '', '');
            this.onchange_utility(component, allEquipment13a, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', allEquipmentMsg);
            this.onchange_utility(component, '', '', '', '', '', allEquipment13a);
        }
        if (allEquipment1a === 'Yes') {
            this.onchange_utility(component, allEquipment1aMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', allEquipment1aMsg);
        }
        if (employeeFacilities === 'No') {
            this.onchange_utility(component, employeeFacilitiesMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeFacilitiesMsg);
        }
        if (employeeKeys === 'No') {
            this.onchange_utility(component, employeeKeysMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeKeysMsg);
        }
        if (clientDocuments === 'No') {
            this.onchange_utility(component, clientDocumentsMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', clientDocumentsMsg);
        }
        if (OregonQ18 === 'Yes') {
            this.onchange_utility(component, OregonMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', OregonMsg);
        }
        if (washingtonQ18 === 'Yes') {
            this.onchange_utility(component, washingtonMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', washingtonMsg);
        }
        if (MichiganQ18 === 'Yes') {
            this.onchange_utility(component, MichiganMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', MichiganMsg);
        }
        if (creditCard === 'Yes') {
            this.onchange_utility(component, creditCardMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', creditCardMsg);
        }
        if (employeeImmigration === 'Yes') {
            this.onchange_utility(component, employeeImmigrationMsg, '', '', '', '', '');
        } else {
            this.onchange_utility(component, '', '', '', '', '', employeeImmigrationMsg);
        }
    },
    
    onchange_utility: function(component, removeClass_1, removeClass_2, removeClass_3, addClass_1, addClass_2, addClass_3) {
        $A.util.removeClass(removeClass_1, 'manager-form-hide');
        $A.util.removeClass(removeClass_2, 'manager-form-hide');
        $A.util.removeClass(removeClass_3, 'manager-form-hide');
        $A.util.addClass(addClass_3, 'manager-form-hide');
        $A.util.addClass(addClass_1, 'manager-form-hide');
        $A.util.addClass(addClass_2, 'manager-form-hide');
    },
    
    progressBar_utility: function(component, remove_current, remove_complete, remove_incomplete, add_current, add_complete, add_incomplete) {
        $A.util.removeClass(remove_current, 'slds-is-current');
        $A.util.removeClass(remove_complete, 'slds-is-complete');
        $A.util.removeClass(remove_incomplete, 'slds-is-incomplete');
        $A.util.addClass(add_current, 'slds-is-current');
        $A.util.addClass(add_complete, 'slds-is-complete');
        $A.util.addClass(add_incomplete, 'slds-is-incomplete');
    },
    
    completeFlag_utility: function(component) {
        if(component.find('termination').get("v.value") === true)
        {
            console.log('am hererere');
            console.log(component.find('employeeData').get("v.value"));
            console.log(component.find('employeeFleetVechicle').get("v.value"));
            console.log( component.find('carAllowance').get("v.value") );
            console.log(component.find('employeeCellPhone_invol').get("v.value") );
            console.log(component.find('employeeImmigration').get("v.value") );
            console.log(component.find('salesEmployee_invol').get("v.value") );
            console.log(component.find('employeeDirectReport').get("v.value"));
            console.log(component.find('allEquipment').get("v.value"));
            console.log( component.find('creditCard').get("v.value"));
            console.log(component.find('employeeFacilities').get("v.value"));
            
            if (component.find('employeeData').get("v.value") !== undefined && 
                component.find('employeeFleetVechicle').get("v.value") !== undefined &&
                component.find('carAllowance').get("v.value") !== undefined &&
                component.find('employeeCellPhone_invol').get("v.value") !== undefined &&
                component.find('employeeImmigration').get("v.value") !== undefined &&
                component.find('salesEmployee_invol').get("v.value") !== undefined && 
                // component.find('employeeDirectReport_invol').get("v.value") !== undefined &&
                component.find('allEquipment').get("v.value") !== undefined && 
                component.find('creditCard').get("v.value") !== undefined &&
                component.find('employeeFacilities').get("v.value") !== undefined &&
                component.find('employeeKeys').get("v.value") !== undefined
                && component.find('clientDocuments').get("v.value") !== undefined) {
                component.set("v.formCompleted", 'true');
            } else {
                component.set("v.formCompleted", 'false');
            }
        }
        else if(component.find('termination').get("v.value") === false){
            if (component.find('myCareers').get("v.value") !== undefined && component.find('myCareer_HRBP').get("v.value") !== undefined &&
                component.find('carAllowance').get("v.value") !== undefined && component.find('employeeFleetVechicle').get("v.value") !== undefined &&
                component.find('employeeData').get("v.value") !== undefined && component.find('employeeAddress').get("v.value") !== undefined &&
                component.find('employeeCellPhone').get("v.value") !== undefined && component.find('employeeExpenseReport').get("v.value") !== undefined &&
                component.find('employeeeTime').get("v.value") !== undefined && component.find('employeeImmigration').get("v.value") !== undefined &&
                component.find('salesEmployee').get("v.value") !== undefined && component.find('employeeDirectReport').get("v.value") !== undefined &&
                component.find('allEquipment').get("v.value") !== undefined && component.find('employeeFacilities').get("v.value") !== undefined &&
                component.find('employeeKeys').get("v.value") !== undefined && component.find('clientDocuments').get("v.value") !== undefined &&
                component.find('creditCard').get("v.value") !== undefined ) {
                component.set("v.formCompleted", 'true');
            } else {
                component.set("v.formCompleted", 'false');
            }
            
        }
    },
    
    hideModal: function() {
        document.getElementById("newClientSectionId").style.display = "none";
    }
    
})