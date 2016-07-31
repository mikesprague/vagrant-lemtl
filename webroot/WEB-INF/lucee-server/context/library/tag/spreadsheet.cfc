<cfcomponent name="cfspreadsheet">
	<!--- Meta data --->
	<cfset this.metadata.hint="Handles spreadsheets">
	<cfset this.metadata.attributetype="fixed">
	<cfset this.metadata.attributes = {
		action : { required:true, type:"string", hint="<strong>read</strong>:Reads the contents of an XLS format file. <strong>update</strong>: Adds a new sheet to an existing XLS file. You cannot use the update action to change an existing sheet in a file. For more information, see Usage. <strong>write</strong>: Writes a new XLS format file or overwrites an existing file." } 
		, filename : { required:false, type:"any", hint="The pathname of the file that is written." }
		, excludeHeaderRow : { required:false, type:"any", hint="If set to true, excludes the headerrow from being included in the query results.The attribute helps when you read Excel as a query. When you specify the headerrow attribute, the column names are retrieved from the header row. But they are also included in the first row of the query. To not include the header row, set true as the attribute value." }
		, name : { required:false, type:"any", hint="read action: The variable in which to store the spreadsheet file data. Specify name or query. write and update actions: A variable containing CSV-format data or an ColdFusion spreadsheet object containing the data to write. Specify the name or query." }
		, query : { required:false, type:"any", hint="read action: The query in which to store the converted spreadsheet file. Specify format, name, or query. write and update actions: A query variable containing the data to write. Specify name or query." }
		, src : { required:false, type:"any", hint="The pathname of the file to read." }
		, columns : { required:false, type:"any", hint="Column number or range of columns. Specify a single number, a hypen-separated column range, a comma-separated list, or any combination of these; for example: 1,3-6,9." }
		, columnnames : { required:false, type:"any", hint="Comma-separated column names." }
		, format : { required:false, type:"any", hint="Format of the data represented by the name variable. All: csv On read, converts an XLS file to a CSV variable. On update or write, Saves a CSV variable as an XLS file. Read only: html Converts an XLS file to an HTML variable. The cfspreadsheet tag always writes spreadsheet data as an XLS file. To write HTML variables or CSV variables as HTML or CSV files, use the cffile tag." }
		, headerrow : { required:false, type:"any", hint="Row number that contains column names." }
		, overwrite : { required:false, type:"any", hint="A Boolean value specifying whether to overwrite an existing file." }
		, password : { required:false, type:"any", hint="Set a password for modifying the sheet. Note: Setting a password of the empty string does no unset password protection entirely; you are still prompted for a password if you try to modify the sheet." }
		, rows : { required:false, type:"any", hint="The range of rows to read. Specify a single number, a hypen-separated row range, a comma-separated list, or any combination of these; for example: 1,3-6,9." }
		, sheet : { required:false, type:"any", hint="Number of the sheet. For the read action, you can specify sheet or sheetname." }
		, sheetname : { required:false, type:"any", hint="Name of the sheet For the read action, you can specify sheet or sheetname. For write and update actions, the specified sheet is renamed according to the value you specify for sheetname." }
		, sheetNameConflict: { required:false, type:"any", default="error", hint="Applies only to action 'Update'. Action to take if the requested sheetName alread exists. <ul><li><strong>Error:</strong> Stop processing and return an error</li><li><strong>Overwrite:</strong> Replace the existing sheet. All data within the sheet is deleted.</li></ul>" }
		, readAllSheets: { required:false, type:"any", default="false", hint="Applies only to action 'Read'. If true, read all sheets in the workbook and ignore 'SheetName' and 'Sheet' values" }
		, columnFormats: { required:false, type:"struct", hint="Applies only when using a query with action 'Write' or 'Update'. A structure of structures containing custom formats for one or more query columns" }
	}>
	
	<cffunction name="init" output="no" returntype="void" hint="invoked after tag is constructed">
		<cfargument name="hasEndTag" type="boolean" required="yes">
		<cfargument name="parent" type="component" required="no" hint="the parent cfc custom tag, if there is one">
		<cfset variables.hasEndTag = arguments.hasEndTag />
		<cfset variables.parent = arguments.parent />
		<cfset variables.ooxmlExtensions = "xlsx" />
	</cffunction>

	<cffunction name="onStartTag" output="yes" returntype="boolean">
		<cfargument name="attributes" type="struct" />
		<cfargument name="caller" type="struct" />
 		<cfset variables.attributes = arguments.attributes />
		<cfset var args 			= "" />
		<cfset var key 				= "" />
		<cfset var index			= "" />
		<cfset var spreadsheet		= "" />
		<cfset var isModifyAction 	= ( listFindNoCase("write,update", getAttribute("action")) ? true : false ) />
		<cfset var fileExtension	= "" />
		<cfset var isXmlFormat		= "" />
		
		<!--- before we go any further, ensure the action is valid --->
		<cfif not listFindNoCase("read,write,update", getAttribute("action"))>
			<cfthrow type="application" message="Invalid or Missing Action Attribute"  detail="Valid actions are 'read', 'update', or 'write'." />
		</cfif>
		
		<!--- query and format are mutually exclusive in ACF --->
		<cfif attributeExists('name') and attributeExists('query')>
			<cfthrow type="application"  message="Invalid Attribute Combination" detail="Only one of either 'name' or 'query' may be provided, not both" />
		</cfif>
		
		<!--- name or query are required for all operations --->
		<cfif not attributeExists('name') and not attributeExists('query')>
			<cfthrow type="application" message="A 'name' or 'query' Attribute Is Required"  detail="Either 'name' or 'query' must be provided" />
		</cfif>

		<!--- sheet only applies to action 'read' --->
		<cfif getAttribute("action") neq "read" and attributeExists("sheet")>
			<cfthrow type="application" message="Invalid Attribute Combination"  detail="'Sheet' attribute only applies to action 'read'" />
		</cfif>
		
		<!--- common validation for "write" and "update" actions (only) --->
		<cfif isModifyAction>

			<cfif attributeExists("sheetNameConflict") and not listFindNoCase("error,overwrite", attributes.sheetNameConflict)>
				<cfthrow type="application" message="Invalid 'SheetNameConflict'"  detail="Allowed values for 'SheetNameConflict' are: Error or Overwrite" />
			</cfif>
		
			<cfif not attributeExists("filename")>
				<cfthrow type="application" message="Filename Attribute is Required"  detail="The 'filename' attribute must be provided for write and update actions" />
			<cfelse>
				<!--- use the file extension to determine if the format is ooxml --->
				<cfset fileExtension = listLast( trim(attributes.filename), ".") />
				<cfset isXmlFormat   = listFindNoCase(variables.ooxmlExtensions, fileExtension) ? true : false />
			</cfif>
			
			<cfif attributeExists("query")>
                <cfset var loc = {}>
                <cftry>
                  <cfset loc.qry = getVariable("caller.#attributes.query#")>
                <cfcatch type="any"/>
                </cftry>
                <cfif not (structKeyExists(loc, 'qry') and IsQuery(loc.qry))>
				  <!--- not a valid query variable --->
				  <cfthrow type="application" message="Invalid 'Query' Attribute"  detail="The specified query [#attributes.query#] was not found or is not a query object" />
                </cfif>
			</cfif>

			<cfif attributeExists("columnFormats") and not attributeExists("query")>
				<!--- not a valid query variable --->
				<cfthrow type="application" message="Invalid Attribute Combination"  detail="The 'columnFormats' attribute can only be used in conjunction with a 'query' object" />
			</cfif>

			<cfif attributeExists("name")>
				<cfset var loc = {}>
				<cftry>
					<cfset loc.name = getVariable("caller.#attributes.name#")>
				<cfcatch type="any"/>
				</cftry>
				<cfif not (structKeyExists(loc, 'name'))>
				<!--- not a valid csv variable --->
				<cfthrow type="application" message="Invalid 'Name' Attribute"  detail="The specified variable [#attributes.name#] was not found" />
				</cfif>
<!---			</cfif>
			
			<cfif attributeExists("name") and not ( IsSpreadSheetObject(caller[attributes.name]) or IsSimpleValue(caller[attributes.name]) )> --->
				<cfif not(IsSpreadSheetObject(loc.name) or IsSimpleValue(loc.name))>
					<cfthrow type="application" message="Invalid 'Name' Attribute"  detail="'Name' attribute [#attributes.name#] must contain a CSV string or a Spreadsheet object" />
				</cfif>
			
				<cfif IsSimpleValue(loc.name) and not attributeExists("format")>
					<cfthrow type="application" message="Missing Attribute" detail="Missing required attribute 'format'." />
				</cfif>
			</cfif>
		</cfif>

		<cfswitch expression="#getAttribute('action')#">

			<!---		READ 		--->

			<cfcase value="read">
			
				<cfif not attributeExists('src')>
					<cfthrow type="application" message="Attribute 'src' is Required" detail="The 'src' attribute is required for the read action." />
				</cfif>
				
				<cfif not FileExists( attributes.src ) >
					<cfthrow type="application" message="Invalid 'Src' Attribute" detail="The specified 'src' file does not exist [#attributes.src#]." />
				</cfif>

				<cfif attributeExists("sheet") and attributeExists("sheetname")>
					<cfthrow type="application"  message="Both 'sheet' and 'sheetname' Attributes May Not Be Provided"  detail="Only one of either 'sheet' or 'sheetname' may be provided" />
				</cfif>
				
				<cfif attributeExists("query") and attributeExists("format")>
					<cfthrow type="application"  message="Both 'query' and 'format' Attributes May Not Be Provided"  detail="Only one of either 'query' or 'format' may be provided" />
				</cfif>
				
				<!--- Read file into a CSV/HTML string --->
				<cfif attributeExists("format")>
					<cfset spreadsheet = CreateObject("component", "org.cfpoi.spreadsheet.Spreadsheet").init() />
					<cfset setVariable("caller.#attributes.name#", spreadsheet.read(argumentcollection = attributes)) />
					
				<!--- Read file into a Query object --->
				<cfelseif attributeExists("query")>
					<cfset spreadsheet = CreateObject("component", "org.cfpoi.spreadsheet.Spreadsheet").init() />
                    <cfset setVariable("caller.#attributes.query#", spreadsheet.read(argumentcollection = attributes)) />
				<!--- Read into Spreadsheet object --->
				<cfelse>
					<cfset setVariable("caller.#attributes.name#", SpreadSheetRead( attributes.src )) />
				</cfif>
			</cfcase>

			<!---		WRITE		--->
			
			<cfcase value="write">
				
				<cfset attributes.filepath = attributes.filename />
				
				<!--- Write SpreadSheet Object ---->
				<cfset var loc = {}>
				<cftry>
					<cfset loc.name = getVariable("caller.#attributes.name#")>
				<cfcatch type="any"/>
				</cftry>
				<cfif attributeExists("name") and IsSpreadSheetObject(loc.name)>
						<!--- remove "name" so write function does not mistake it for a CSV string --->
						<cfset args = structCopy( attributes ) />
						<cfset structDelete( args, "name") />
						<cfset loc.name.write(argumentCollection = args) />
						
				<!--- Write CSV/delimited content --->
				<cfelseif attributeExists("name") and IsSimpleValue(loc.name)>
						<cfset attributes.name = loc.name />
						<cfset spreadsheet = CreateObject("component", "org.cfpoi.spreadsheet.Spreadsheet").init() />
						<cfset spreadsheet.write(argumentCollection = attributes) />

				<!--- Write Query content --->
				<cfelseif attributeExists("query")>
					<cfset attributes.query = getVariable("caller.#attributes.query#") />
					<cfset spreadsheet = CreateObject("component", "org.cfpoi.spreadsheet.Spreadsheet").init(useXmlFormat=isXmlFormat) />
					<cfset spreadsheet.write(argumentcollection = attributes) />
				</cfif>

			</cfcase>
		
			<!---		UPDATE		--->
			<cfcase value="update">
				
				<!--- ACF seems to copy an existing sheet from  one workbook into another. Duplicating this
					behavior may not be an easy task. Marking this feature as unsupported for the time being .... --->
				<cfif attributeExists("name") and IsSpreadSheetObject(caller[attributes.name])>
					<cfthrow type="application" message="Unsupported operation"  detail="Action 'update' from a spreadsheet object is not yet supported. Please 'read' in the spreadsheet, then use 'write' or SpreadSheetWrite() to save any modifications." />
				</cfif>

				<cfset attributes.overwrite 	= true />
				<cfset attributes.filepath 		= attributes.filename />
				<cfset attributes.nameConflict 	= attributes.sheetNameConflict />
				
				<!--- CSV/delimited content --->
				<cfif attributeExists("name")>
					<cfset attributes.name = caller[attributes.name] />
				<!--- Query content --->
				<cfelseif attributeExists("query")>
					<cfset attributes.query = getVariable("caller.#attributes.query#") />
				</cfif>

				<!--- If the workbook does not exist yet, this is just a simple 'write' --->
				<cfif NOT FileExists( attributes.filepath )>
					<cfset spreadsheet = CreateObject("component", "org.cfpoi.spreadsheet.Spreadsheet").init(useXmlFormat=isXmlFormat) />
					<cfset spreadsheet.write( argumentCollection=attributes ) />

				<!--- Otherwise, read in the file and update it --->
				<cfelse>
					<cfset spreadsheet = SpreadSheetRead( attributes.filepath ) />
					<cfset spreadsheet.update(argumentcollection = attributes) />
					
				</cfif>
				
			</cfcase>
			
			<!---		CATCH INVALID OR MISSING ATTRIBUTES		--->
			
			<cfdefaultcase>
				<cfthrow type="application" message="Invalid or Missing Action Attribute"  detail="You must provide an action of 'read', 'update', or 'write' for this tag." />
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn true>
	</cffunction>

	<cffunction name="onEndTag" output="yes" returntype="boolean">
		<cfargument name="attributes" type="struct">
		<cfargument name="caller" type="struct">
		
		<cfreturn false>
	</cffunction>


	<!---   attributes   --->
	<cffunction name="getAttribute" output="false" access="private" returntype="any">
		<cfargument name="key" required="true" type="String" />
		<cfreturn variables.attributes[key] />
	</cffunction>

	<cffunction name="attributeExists" output="false" access="private" returntype="boolean">
		<cfargument name="key" required="true" type="String" />
		<cfreturn structKeyExists(variables.attributes, key) />
	</cffunction>

</cfcomponent>
