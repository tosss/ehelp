body {
	font-family: Sans-serif;
    font-size: 0.8em;
}

table { 
    width: 100%; 
}

.ProductName {
    page-break-before: always; 
}

.labelCol, .dataCol { 
    width: 25%; 
    padding: 3px 10px; 
} 

.labelCol { 
    font-weight: bold; 
}

.pbSubheader { 
    border-width: 1px 0 0; 
    border-style: solid; 
    border-color: #CCC; 
    margin-top: 10px; 
}

@page {
 @bottom-right {
 content: "Page " counter(page) " of " counter(pages);
 }
}