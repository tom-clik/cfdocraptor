<cfscript>
/**
 * Run a docraptor demo 
 * 
 */
cfparam( default="pdf", name="url.type" );
cfparam( default="1", name="url.test" type="boolean" );

cfinclude( template="docraptor_test_include.cfm" );

docraptorObj = new cfdocraptor.docraptor(apikey=settings.apikey);

switch ( url.type ) {
	case  "pdf":
		FileName = ExpandPath("sample_forpdf.html");
		break;
	case  "xls":
		FileName = ExpandPath("sample_forxls.html");
		break;
	default:
		throw( message="Only pdf,xls tests configured" );
		break;
}

try {

	myoutPut =  docraptorObj.convert(FileName=FileName,test=1,type=url.type);

	if ( myoutput.success ) {
		writeOutput("<p>File converted:#myoutPut.outputfile#</p>");
	} else {
		throw("Conversion error");
	}
}

catch (any e) {
	local.extendedinfo = {"tagcontext"=e.tagcontext,"FileName"=FileName,"test"=url.test,"type"=url.type};

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