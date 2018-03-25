function underline(element)
{
    element.style.textDecoration = "underline";
} 

function removeUnderline(element)
{
    element.style.textDecoration = "none";
}

function newTab(url,isGroup)
{
    if(!isGroup||(url.indexOf('/005')==0))
    {
        
        window.open(url,'_blank','height=400,width=600,left=10,top=10,scrollbars=yes,menubar=no');
    }
    else
    { 
        url=url.replace('/','');
        window.open('/p/own/Queue/d?id='+url,'_blank','height=400,width=600,left=10,top=10,scrollbars=yes,menubar=no');
    }
}
