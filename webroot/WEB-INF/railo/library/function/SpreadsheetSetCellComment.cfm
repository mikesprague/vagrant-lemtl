<!--- The comment struct may contain the following keys:
		* anchor
		* author
		* bold
		* color
		* comment
		* fillcolor
		* font
		* horizontalalignment
		* italic
		* linestyle
		* linestylecolor
		* size
		* strikeout
		* underline
		* verticalalignment
		* visible
--->
<cffunction name="SpreadsheetSetCellComment" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="comment" type="struct" required="true" />
	<cfargument name="row" type="numeric" required="true" />
	<cfargument name="column" type="numeric" required="true" />
	
	<cfset arguments.spreadsheet.setCellComment(arguments.comment, arguments.row, arguments.column) />
</cffunction>