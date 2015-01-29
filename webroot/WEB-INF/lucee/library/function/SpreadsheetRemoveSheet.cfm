<!--- 
	Spreadsheets must always contain at least one (1) sheet. Attempting to
	delete the last sheet (or an invalid sheet name) will generate an error. 
--->
<cffunction name="SpreadsheetRemoveSheet" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="sheetName" type="string" required="true" hint="Name of the sheet to remove" />
	
	<cfset arguments.spreadsheet.deleteSheet( sheetName=arguments.sheetName ) />
</cffunction>