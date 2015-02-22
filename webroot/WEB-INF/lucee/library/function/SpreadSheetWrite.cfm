<!--- 
	NOTE: This version differs from ACF which also supports a "password" argument
--->
<cffunction name="SpreadsheetWrite" returntype="void" output="false"
			Hint="Write a spreadsheet to disk.">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" hint="Target Spreadsheet" />
	<cfargument name="filePath" type="string" required="true" hint="Full path to the output file" />
	<cfargument name="overwrite" type="boolean" default="false" hint="Specify true to overwrite the file if it already exists." />
	
	<!--- 
	TODO: Look into adding support for "password" for binary spreadsheets.
	SpreadSheet.write() does implement password handling. But it does 
	not seem to	have any affect. 
	
	Note: Currently POI does not support passwords for the xlsx format. 
	--->	
	<cfif structKeyExists(arguments, "password") or structCount(arguments) gt 3>
		<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet" 
					message="Invalid or Unsupported Arguments" 
					detail="SpreadsheetWrite only supports the following arguments: SpreadSheet, FileName and Overwrite" />
	</cfif>

	<cfset arguments.spreadsheet.writeToFile( argumentCollection=arguments ) />
</cffunction>