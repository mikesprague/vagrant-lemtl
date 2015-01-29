<cffunction name="SpreadsheetSetActiveSheet" returntype="void" output="false"
			Hint="Sets the given sheetName as the currently active sheet">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" hint="Target Spreadsheet" />
	<cfargument name="sheetName" type="string" required="true" hint="Name of an existing sheet within the spreadsheet" />
	
	<cfset arguments.spreadsheet.setActiveSheet( argumentCollection=arguments ) />
</cffunction>