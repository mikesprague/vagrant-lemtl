<cffunction name="SpreadsheetShiftRows" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="start" type="numeric" required="true" />
	<cfargument name="arg3" type="numeric" required="false" />
	<cfargument name="arg4" type="numeric" required="false" />

	<cfset var args = structNew() />
	<cfset args.startRow = arguments.start />
	
	<!--- if 4 arguments are passed: SpreadsheetShiftRows(spreadsheet, start, end, rows) --->
	<cfif structKeyExists(arguments, "arg4") and structKeyExists(arguments, "arg3")>
		<cfset args.endRow = arg3 />
		<cfset args.offset = arg4 />
	<!--- if only 3 arguments are passed: SpreadsheetShiftRows(spreadsheet, start, rows) --->
	<cfelseif structKeyExists(arguments, "arg3")>	
		<cfset args.offset = arg3 />
	</cfif>

	<cfset arguments.spreadsheet.shiftRows(argumentcollection = args) />
</cffunction>
