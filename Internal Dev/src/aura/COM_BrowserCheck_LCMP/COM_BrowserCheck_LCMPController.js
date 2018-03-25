({
    doInit : function(component, event, helper) {
        
        //Used the article http://www.kb.blackbaud.com/articles/Article/111626
       
        try{
        var ua= navigator.userAgent, template, 
            match= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
        if(/trident/i.test(match[1])){
            template=  /\brv[ :]+(\d+)/g.exec(ua) || [];
            return 'IE '+(template[1] || '');
        }
        if(match[1]=== 'Chrome'){
            template= ua.match(/\b(OPR|Edge)\/(\d+)/);
            if(template!= null) return template.slice(1).join(' ').replace('OPR', 'Opera');
        }
        match= match[2]? [match[1], match[2]]: [navigator.appName, navigator.appVersion, '-?'];
        if((template= ua.match(/version\/(\d+)/i))!= null) match.splice(1, 1, template[1]);
        if((match[0]=='Chrome' && match[1]<=21)||
           (match[0]=='MSIE' && match[1]<=10) || 
           (match[0]=='Firefox' && match[1]<=26) ||
           (match[0]=='Safari' && match[1]<=6) ||
           (match[0]=='Opera' && match[1]<=13)
          )
        {
            component.set('v.showMessage',true);
        }
        }
        catch(err)
        {
            alert('Your current Internet browser (Internet Explorer, Chrome, Firefox, or Safari) is not compatible with this site. \r\nPlease upgrade to the latest version or contact IT Support for assistance by visiting the '+
                        'Employee Intranet/Portal and clicking the \'Need IT Support\' link or by calling 1-866-995-4700');
        }
    },
    hideModal : function(component, event, helper)
    {
        component.set('v.showMessage',false);
    }
})