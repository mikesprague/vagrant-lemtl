<!--- 
	There is no ACF equivalent to this function. But having no 
	method for deleting sheets by position seemed odd ...  
--->
<cffunction name="SpreadsheetRemoveSheetNumber" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="sheetNumber" type="numeric" required="true" hint="Remove the sheet at this position" />
	
	<cfset arguments.spreadsheet.deleteSheet( sheetIndex=arguments.sheetNumber ) />
</cffunction>