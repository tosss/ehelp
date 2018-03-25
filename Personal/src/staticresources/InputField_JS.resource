var j$ = jQuery.noConflict();
j$(document).ready(function(){
    j$('.ClickedLookup').hide();
});
j$(document).on('mousedown','.InitialLookup',function(){
    j$(this).hide();
    j$('.ClickedLookup').show();
});
j$(document).on('click','.row',function(){
    
    var value=j$(this).html();
    var value2=j$(this).attr('id');
    j$('#valueHolder').val(value);
     j$('#valueHolderId').val(value2);
    j$('#container').hide();
});
j$(document).on('mouseup','.ClickedLookup',function(){
    j$(this).hide();
    j$('#container').show();
    j$('.InitialLookup').show();
});