<!--- TODO: null pointer exception issue --->
<cffunction name="SpreadsheetInfo" returntype="struct" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />

	<!--- Returns a struct containing the following keys:
			* author
			* category
			* comments
			* company
			* creationdate
			* keywords
			* lastauthor
			* lastedited
			* lastsaved
			* manager
			* sheetnames
			* sheets
			* spreadsheettype
			* subject
			* title
	--->
	
	<cfreturn arguments.spreadsheet.getInfo() />
</cffunction>