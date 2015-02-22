<!--- TODO: when a new workbook is created, the summary info objects are null so this 
			and SpreadsheetInfo both bomb --->
<cffunction name="SpreadsheetAddInfo" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="properties" type="struct" required="true" />

	<!--- Valid struct keys are: 
		* author
		* category
		* comments
		* company
		* keywords
		* lastauthor
		* manager
		* subject
		* title
	--->
	
	<cfset arguments.spreadsheet.addInfo(arguments.properties) />
</cffunction>