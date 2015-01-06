<!--- TODO:  Add support for resizing all columns --->
<cffunction name="SpreadsheetAutoSizeColumn" returntype="void" output="false"
		hint="Adjusts the width of the specified column to fit the contents. This can be slow on large sheets. Normally it should normally be called once per column, at the end of processing ">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="column" type="numeric" required="true" hint="Column to resize" />
	<cfargument name="useMergedCells" type="boolean" default="false" hint="Whether to use the contents of merged cells when calculating the width of the column"/>
	
	<cfset arguments.spreadsheet.autoSizeColumn( argumentCollection=arguments ) />
</cffunction>
