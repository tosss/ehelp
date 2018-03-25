/*
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: all javascript function that is used in IMP_ChecklistPage
History
12/19/14    Kimiko Roberto         Created
*/

	$j = jQuery.noConflict();
	function hideElement(id) {
		var elementId = $j('[id$="' + id + '"]');    
			elementId.hide();         
	}
	
	function showElement(id) {
		var elementId = $j('[id$="' + id + '"]');    
			elementId.show();  
	}
	
	
	function hideNextElement(elementId) {
		var element = $j(elementId).next();
		element.hide();   
	}
	function showNextElement2(elementId) {
		var element = $j(elementId).next().next();
		element.show();   
	}
	function showNextElement(elementId) {
		var element = $j(elementId).next();
		element.show();   
	}
	
	function showPrevElement(elementId){
		var element = $j(elementId).prev();
		element.show();
	}
	
	function hidePrevElement(elementId){
		var element = $j(elementId).prev();
		element.hide();
	}
	
	function hideComponent(comp){
	   var component = $j(comp); 
	   component.hide();
	}
	
	function manualExpand(element){
		 
		
			document.addEventListener("click",showNextElement2(element));
			document.addEventListener("click",showPrevElement(element));
			document.addEventListener("click",hideComponent(element));
		
		
	}
	
	function manualCollapse(element){
		var tableChklist = $j(element).next().next().next();
		document.addEventListener("click",showNextElement(element));
		tableChklist.hide();
		document.addEventListener("click",hideComponent(element));
		
	}

	function expandBtn(expndId,clpsId,elementId){
		var cllpsId = $j('[id$="' + clpsId + '"]');
		var expId = $j('[id$="' + expndId + '"]');
		
		document.addEventListener("click",showElement(elementId));
		$j('.expndImg').hide();
		$j('.clpsImg').show();
		$j(expId).hide();
		$j(cllpsId).show();  
	}
	function clpsBtn(expndId,clpsId,elementId){
		var cllpsId = $j('[id$="' + clpsId + '"]');
		var expId = $j('[id$="' + expndId + '"]');
		document.addEventListener("click",hideElement(elementId));
		$j('.clpsImg').hide();
		$j('.expndImg').show();
		$j(cllpsId).hide();
		$j(expId).show();    
	}