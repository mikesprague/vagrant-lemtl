<cffunction name="IsSpreadsheetObject" returntype="boolean" output="false"
			Hint="Returns true if the supplied object is an instance of org.cfpoi.spreadsheet.Spreadsheet">
	<cfargument name="testObject" type="any" required="true" />
	
	<cfreturn IsInstanceOf(arguments.testObject, "org.cfpoi.spreadsheet.Spreadsheet") />
</cffunction>