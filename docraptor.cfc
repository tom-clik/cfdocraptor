<!---

# Docraptor

Use the docraptor conversion service to convert HTML to PDF



--->
component name="docraptor" {

	/**
	 * Pseudo constructor
	 *
	 * @apikey   Your docraptor api key.
	 */
	public docraptor function init(required apikey) {
		variables.user_credentials = arguments.apikey;
		return this;
	}

	/**
	 * Convert doc using docraptor. Returns struct with {success,outputfile,error_message,error_detail}
	 *
	 * @filename   File to send to docraptor
	 * @html       HTML to send to docraptor if no file specified
	 * @outputfile File to save to. Required if no html, otherwise default is filename with PDF extension
	 * @test       Run docraptor in test mode
	 * @type       pdf|xls
	 * @return struct with {success,outputfile,error_message,error_detail}
	 */
	public struct function convert(filename, html, outputfile, boolean test="0", type="pdf") {
		
		var docResponse = false;
		var returnStr = {"success"=0};
		
		checkType(arguments.type);

		if ( !IsDefined("arguments.html") ) {
			if ( !StructKeyExists(arguments,"filename") ) {
				throw( message="html or filename must be defined when using docraptor" );
			}
			if ( !StructKeyExists(arguments,"outputfile") || arguments.outputfile == "" ) {
				arguments.outputfile = REReplace(arguments.filename, "#ListLast(arguments.filename,".")#$",arguments.type);
			}
			if ( IsDefined("server.utils") ) {
				arguments.html = server.utils.fnReadFile(arguments.filename);
			} else {
				try {
					arguments.html = fileRead(arguments.filename);
				} catch (any cfcatch) {
					throw( message="Unable to read #arguments.filename#" );
				}
			}
		} 
		else {
			if ( !StructKeyExists(arguments,"outputfile") ) {
				throw( message="outputfile must be defined when passing html to docraptor" );
			}
		}
		
		returnStr["outputfile"]=arguments.outputfile;
		//  strict on boolean 
		arguments.test = 1 && arguments.test;
		local.docname = ListLast(arguments.outputfile,"\/");
		cfhttp( throwonerror=true, url="http://docraptor.com/docs?user_credentials=#variables.user_credentials#", result="docResponse", method="post" ) {
			cfhttpparam( name="doc[document_content]", type="formfield", value=arguments.html );
			cfhttpparam( name="doc[document_type]", type="formfield", value=arguments.type );
			cfhttpparam( name="doc[name]", type="formfield", value=local.docname );
			cfhttpparam( name="doc[test]", type="formfield", value=arguments.test );
		}
		saveResult(docResponse=docResponse,outputfile=arguments.outputfile,returnStr=returnStr);

		return returnStr;
		
	}

	/**
	 * Convert web pafe doc using docraptor. Returns struct with {success,outputfile,error_message,error_detail}
	 */
	public struct function convertWeb(surl, outputfile, boolean test="0", type="pdf") {
		var docResponse = false;
		var returnStr = {};
		returnStr["success"]=0;
		checkType(arguments.type);

		if ( !StructKeyExists(arguments,"outputfile") || arguments.outputfile == "" ) {
			arguments.outputfile = REReplace(arguments.filename, "#ListLast(arguments.surl,".")#$","pdf");
		}
		
		returnStr["outputfile"]=arguments.outputfile;
		//  strict on boolean 
		arguments.test = 1 && arguments.test;
		local.docname = ListLast(arguments.outputfile,"\/");

		cfhttp( url="http://docraptor.com/docs?user_credentials=#variables.user_credentials#", result="docResponse", method="post" ) {
			cfhttpparam( name="doc[document_url]", type="formfield", value=arguments.surl );
			cfhttpparam( name="doc[document_type]", type="formfield", value=arguments.type );
			cfhttpparam( name="doc[name]", type="formfield", value=local.docname );
			cfhttpparam( name="doc[test]", type="formfield", value=arguments.test );
		}
		saveResult(docResponse=docResponse,outputfile=arguments.outputfile,returnStr=returnStr);

		return returnStr;

	}
	/**
	 * Save the pdf document from Docraptor
	 * 
	 * @docResponse   result from cfhttp call
	 * @returnStr  Pass in return struct to update
	 */
	private void function saveResult(docResponse,outputFile,returnStr) {

		if ( !IsDefined("arguments.docResponse.Responseheader.Status_Code") || arguments.docResponse.Responseheader.Status_Code != 200 ) {
			arguments.returnStr["success"]=0;
			savecontent variable="arguments.returnStr.error_detail" {
				writeDump( var=arguments.docResponse );
			}
			if ( IsDefined("arguments.docResponse.Responseheader.Status_Code")
				 && arguments.docResponse.Responseheader.Status_Code == 422 ) {
				arguments.returnStr.error_message = "There == an unparseable entity in the code = e.g. a bare &amp; sign.";
			} else {
				arguments.returnStr.error_message = "Unable to convert HTML. See also doc raptor error logs <a href=""http://docraptor.com/doc_logs"">http://docraptor.com/doc_logs</a>";
			}
		} else {
			/*  
				// Used to have issues with ACF here. Seem to be fixed in Lucee. TBC
				local.binaryObj = docResponse.fileContent.toByteArray();
			 */
			cffile( output=arguments.docResponse.fileContent, file=arguments.outputFile, action="write" );
			arguments.returnStr["success"]=1;
		}
		
	}

	private void function checkType(type) {
			if ( !listFindNoCase("pdf,xls", arguments.type) ) {
			throw( 
				message="Invalid type:#arguments.type#", 
				detail="Type must be either PDF or XLS for docraptor conversion" 
			);
		}	
	}

}
