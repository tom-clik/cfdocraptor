<cfscript>
/*  

# Docraptor convert web file

Convert a file on the web to PDF

## Usage

*/

cfinclude( template="docraptor_test_include.cfm" );

cfparam( default="pdf", name="url.type" );
cfparam( default="https://www.digitalmethod.co.uk/index.html", name="url.surl" );
cfparam( default=1, name="url.test", type="boolean" );

docraptorObj = new cfdocraptor.docraptor(apikey=settings.apikey);

switch ( url.type ) {
	case  "pdf": case "xls":
		break;
	default:
		throw( message="Only pdf,xls tests configured" );
		break;
}

outputfile = ExpandPath(ListFirst(ListLast(url.surl,"/"),".") & ".pdf");

try { 	
	myoutPut =  docraptorObj.convertWeb(surl=surl,outputfile=outputfile,test=url.test,type=url.type);

	if ( myoutput.success ) {
		writeOutput("<p>File converted:#outputfile#</p>");
	} else {
		throw("Conversion error");
	}
}
catch (any e) {
	local.extendedinfo = {"tagcontext"=e.tagcontext,"url"=surl,"outputfile"=outputfile,"test"=url.test,"type"=url.type};
	if (isDefined("myoutPut")) {
		local.extendedinfo["myoutPut"] = myoutPut;
	}
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "Unable to convert data:" & e.message, 
		detail       = e.detail	
	);
}

</cfscript>