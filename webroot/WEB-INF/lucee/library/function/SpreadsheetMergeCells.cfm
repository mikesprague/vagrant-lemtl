<!--- Modified the argument order for ACF compatibility. But the original
	order made more sense. --->
<cffunction name="SpreadsheetMergeCells" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="startRow" type="numeric" required="true" />
	<cfargument name="endRow" type="numeric" required="true" />
	<cfargument name="startColumn" type="numeric" required="true" />
	<cfargument name="endColumn" type="numeric" required="true" />

	<cfset arguments.spreadsheet.mergeCells(arguments.startRow, arguments.endRow, 
											arguments.startColumn, arguments.endColumn) />
</cffunction>