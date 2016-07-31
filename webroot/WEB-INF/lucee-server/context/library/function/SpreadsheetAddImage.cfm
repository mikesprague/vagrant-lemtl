<cffunction name="SpreadsheetAddImage" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="arg2" type="any" required="false" />
	<cfargument name="arg3" type="string" required="false" />
	<cfargument name="arg4" type="string" required="false" />
	
	<cfset var args = StructNew() />
	
	<cfif not StructKeyExists(arguments, "arg4")>
		<!--- if 3 arguments are passed, order is spreadsheet, imageFilePath, anchor --->
		<cfset args.filePath = arguments.arg2 />
		<cfset args.anchor = arguments.arg3 />
	<cfelseif StructKeyExists(arguments, "arg4")>
		<!--- if 4 arguments are passed, order is spreadsheet, imageData, imageType, anchor --->
		<cfset args.imageData = arguments.arg2 />
		<cfset args.imageType = arguments.arg3 />
		<cfset args.anchor = arguments.arg4 />
	<cfelse>
		<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet" 
					message="Invalid Argument Combination" 
					detail="SpreadsheetAddImage() takes either 3 or 4 parameters" />
	</cfif>
	
	<cfset arguments.spreadsheet.addImage(argumentcollection = args) />
</cffunction>