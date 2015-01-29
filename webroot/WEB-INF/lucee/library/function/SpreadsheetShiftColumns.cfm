<cffunction name="SpreadsheetShiftColumns" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="start" type="numeric" required="true" />
	<cfargument name="end" type="numeric" required="false" />
	<cfargument name="columns" type="numeric" required="false" />
	
	<cfset var args = StructNew() />
	
	<cfset args.startColumn = arguments.start />
	
	<cfif StructKeyExists(arguments, "end")>
		<cfset args.endColumn = arguments.end />
	</cfif>
	
	<cfif StructKeyExists(arguments, "columns")>
		<cfset args.offset = arguments.columns />
	</cfif>
	
	<cfset arguments.spreadsheet.shiftColumns(argumentcollection = args) />
</cffunction>