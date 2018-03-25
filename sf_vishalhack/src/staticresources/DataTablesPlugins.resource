// Datatables Output Date sorting plugin 
jQuery.fn.dataTableExt.oSort['us_date-asc'] = function(a,b) {
    var ad = getOutputValue(a), bd = getOutputValue(b); 
    var x = (ad != null && ad != "") ? new Date(ad) : null, 
        y = (bd != null && bd != "") ? new Date(bd) : null; 
    //console.log(x + " ? " + y);
    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
}; 

jQuery.fn.dataTableExt.oSort['us_date-desc'] = function(a,b) {
    var ad = getOutputValue(a), bd = getOutputValue(b); 
    var x = (ad != null && ad != "") ? new Date(ad) : null, 
        y = (bd != null && bd != "") ? new Date(bd) : null; 
    //console.log(x + " ? " + y);
    return ((x < y) ? 1 : ((x > y) ? -1 : 0));
};
// end Datatables Output Date sorting plugin 

// Datatables Input Date sorting plugin 
jQuery.fn.dataTableExt.oSort['us_date_input-asc'] = function(a,b) {
    var ad = getInputValue(a), bd = getInputValue(b); 
    var x = (ad != null && ad != "") ? new Date(ad) : null, 
        y = (bd != null && bd != "") ? new Date(bd) : null; 
    //console.log(x + " ? " + y);
    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
};

jQuery.fn.dataTableExt.oSort['us_date_input-desc'] = function(a,b) {
    var ad = getInputValue(a), bd = getInputValue(b); 
    var x = (ad != null && ad != "") ? new Date(ad) : null, 
        y = (bd != null && bd != "") ? new Date(bd) : null; 
    //console.log(x + " ? " + y);
    return ((x < y) ? 1 : ((x > y) ? -1 : 0));
};
// end Datatables Input Date sorting plugin 

// Datatables Input, Textarea, Select sorting plugin 
jQuery.fn.dataTableExt.oSort['input-asc'] = function(a,b) {
    var x = getInputValue(a), y = getInputValue(b); 
    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
};

jQuery.fn.dataTableExt.oSort['input-desc'] = function(a,b) {
    var x = getInputValue(a), y = getInputValue(b); 
    return ((x < y) ? 1 : ((x > y) ? -1 : 0));
};
// end Datatables Input, Textarea, Select sorting plugin 

function getOutputValue(x) {
    var d = jQuery(x).findDeepest().html().trim().replace(/&nbsp;/g, ''); return d;
    if(!d) { return x; }
}

function getInputValue(x) {
    if (x.indexOf('input') >= 0 || x.indexOf('select') >= 0 || x.indexOf('textarea') >= 0) {
        return jQuery(x).find("input,select,textarea").val().trim().replace(/&nbsp;/g, ''); }         
    return x;
}

// custom datatable function to get filtered nodes
jQuery.fn.dataTableExt.oApi.fnGetFilteredNodes = function ( oSettings )
{
	var anRows = [];
	for ( var i=0, iLen=oSettings.aiDisplay.length ; i<iLen ; i++ )
	{
		var nRow = oSettings.aoData[ oSettings.aiDisplay[i] ].nTr;
		anRows.push( nRow );
	}
	return anRows;
};

// when a table is redrawn, use the values from the filtering inputs
jQuery.fn.dataTableExt.afnFiltering.push(
	function( oSettings, aData, iDataIndex ) 
	{
		// only clear if the filtering is changed on the Campaign Account Members Table
		if(oSettings && oSettings.sTableId && oSettings.sTableId == "CampaignAccountMembersTable") 
		{
			//console.log(oSettings);
			
			SelectedCampaignAccountMembers = [];
			jQuery("#SelectedCampaignAccountMembers").children().each(function(){jQuery(this).remove();});
			jQuery("#SelectedCampaignAccountMembersLabel").css("display","");
			
			var ReturnValue = false;
			
			var StateFilter = false;
			var StartsWithFilter = false;
			var StatusFilter = false;
			
			var AccountState = jQuery("#AccountState").val();
			var AccountStartsWith = jQuery("#AccountStartsWith").val();
			var AccountMemberStatus = jQuery(jQuery("#AccountMemberStatus").val());
			
			var TableAccountName = aData[1]; 
			var TableAccountMemberStatus = aData[2];
			var TableState = aData[4];
			
			if ((!AccountState || AccountState == "" || AccountState == "--None--")
			&&  (!AccountStartsWith || AccountStartsWith == "")
			&&  (jQuery("#AccountMemberStatus option").length == jQuery(jQuery("#AccountMemberStatus")).val().length)) { return true; }
			
			if ((!AccountState || AccountState == "" || AccountState == "--None--") || AccountState && TableState == AccountState) { StateFilter = true; }
			if ((!AccountStartsWith || AccountStartsWith == "") || 
				AccountStartsWith && jQuery(TableAccountName).html().toLowerCase().match("^"+AccountStartsWith.toLowerCase())) { StartsWithFilter = true; }
			
			if (jQuery("#AccountMemberStatus option").length != jQuery(jQuery("#AccountMemberStatus")).val().length) { 
				AccountMemberStatus.each( function(index,value) { if(TableAccountMemberStatus == value){ StatusFilter = true; } } ); }
			else { StatusFilter = true; }
			
			if(StateFilter && StartsWithFilter && StatusFilter) { ReturnValue = true; }
			
			return ReturnValue;
		}
	}
);