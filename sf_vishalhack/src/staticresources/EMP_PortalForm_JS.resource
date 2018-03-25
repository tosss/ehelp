j$(document).ready(function(){
    
    // fix checkboxes
    j$('input[type="checkbox"]')
    .wrap(j$('<div>').addClass('form-control').css("border",'0').css('box-shadow','none').css('-webkit-box-shadow','none'))
    .removeClass('form-control')
    .css('transform','scale(1.5,1.5)');
    
    // handle lookups
    j$('[id$="_mlktp"], [for$="_mlktp"]').val("User").css("display","none");
    j$("div[fieldtype$='reference']").removeClass("form-control");
    j$('[id$="_lkwgt"]').html("<i class='fa fa-search'></i>").wrap("<span class='input-group-btn'></span>").removeClass("form-control").addClass("btn btn-default");
    j$('.lookupInput').addClass('input-group').children("input:first-child").addClass('form-control');
    
    // default RecordType Id
    j$(".RecordTypeId").val("{!$CurrentPage.parameters.RecordTypeId}");
    
    // handle message styling
    var PageMessages = j$("[id$='PageMessages']");
    if(PageMessages.children().length > 0) { PageMessages.addClass("alert alert-info"); }
    else { PageMessages.removeClass("alert alert-info alert-dismissable"); }
    
    // automatically set fields from querystring
    var urlParams = getUrlVars();
    j$(".form-group input[type='text'], .form-group select, .form-group textarea").each(
        function(i, v) {
            var fieldname = j$(v).attr("fieldname");
            if(urlParams[fieldname]) {
                j$(v).val(urlParams[fieldname]);
            }
        }
    );
    
});

function retURL() {
    var urlParams = getUrlVars();
    
    if(urlParams['retURL']) {
        window.location.href = decodeURIComponent(urlParams['retURL']);
    }
    
}

function getUrlVars() {
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}