html, body{
    margin:0;
    padding:0;
    height:100%;
    overflow:hidden;
}  

.colAdd{
    padding: 10px;
    width: 1%;
}

.miniCalendar{
    right: 57%;
    margin-top: -12px;
}

.refreshClass{
    margin-top: 10px;
    right: 58%;
    position: absolute;
    cursor: pointer;
}

@media only screen and (min-width: 1369px){
    .miniCalendar {
        right: 55%;
        margin-top: -12px;    
    }
    
}

@media only screen and (min-width: 1369px) and (max-width: 1700px){
    
    .refreshClass{
        right: 58%;
        position: absolute;
        margin-top: 10px;
        cursor: pointer;
    }
    
}

@media only screen and (min-width: 1701px){
    .refreshClass{
        right: 56.5%;
        position: absolute;
        margin-top: 10px;
        cursor: pointer;
    }
    
}