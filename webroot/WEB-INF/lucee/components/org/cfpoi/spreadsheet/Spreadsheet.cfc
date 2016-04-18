<cfcomponent
	displayname="Spreadsheet"
	output="false"
	hint="CFC wrapper for the Apache POI project's HSSF (xls) and XSSF (xlsx) classes">

	<!--- define default cell formats for when populating a sheet from a query --->
	<cfset variables.defaultFormats = { DATE = "m/d/yy", TIMESTAMP = "m/d/yy h:mm", TIME = "h:mm:ss" } />

	<cffunction name="loadPoi" access="private" output="false" returntype="any">
		<cfargument name="javaclass" type="string" required="true" hint="I am the java class to be loaded" />

		<cfscript>
			if( NOT structKeyExists( server, "_poiLoader")){
				local.version = val(listFirst(server.lucee.version, "."));

				//create the loader
				local.paths = arrayNew(1);
				// This points to the jar we want to load. Could also load a directory of .class files
				arrayAppend(Local.paths, expandPath('{lucee-web-directory}'&'/lib/poi-3.14-20160307.jar'));
				arrayAppend(Local.paths, expandPath('{lucee-web-directory}'&'/lib/poi-ooxml-3.14-20160307.jar'));
				arrayAppend(Local.paths, expandPath('{lucee-web-directory}'&'/lib/poi-ooxml-schemas-3.14-20160307.jar'));
				if ( !this.isLinux() ) {
					arrayAppend(Local.paths, expandPath('{lucee-web-directory}'&'/lib/ooxml-lib/dom4j-1.6.1.jar'));
				}
				// arrayAppend(Local.paths, expandPath('{lucee-web-directory}'&'/lib/geronimo-stax-api_1.0_spec-1.0.jar'));
				arrayAppend(Local.paths, expandPath('{lucee-web-directory}'&'/lib/xmlbeans-2.6.0.jar'));
				arrayAppend(Local.paths, expandPath('{lucee-web-directory}'&'/lib/poi-export-utility.jar'));

				if( NOT structKeyExists( server, "_poiLoader")){
					server._poiLoader = createObject("component", "javaloader.JavaLoader").init(loadPaths = local.paths, loadColdFusionClassPath=true, trustedSource=true);
				}
			}

			//at this stage we only have access to the class, but we don't have an instance
			// It is up to the calling function to initialize the object
			return server._poiLoader.create( arguments.javaclass );
		</cfscript>
	</cffunction>

	<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" output="false" returntype="Spreadsheet"
				Hint="Creates or loads a workbook from disk. Returns a new Spreadsheet object.">
		<cfargument name="sheetName" type="string" required="false" Hint="Name of the initial Sheet -or- name of the Sheet to activate." />
		<cfargument name="useXmlFormat" type="boolean" required="false" Hint="If true, creates an .xlsx workbook (ie XSSFWorkbook). Otherwise, creates a binary .xls object (ie HSSFWorkbook)" />
		<cfargument name="src" type="string" required="false" Hint="Path to an existing workbook on disk" />
		<cfargument name="sheet" type="numeric" required="false" Hint="Activate the sheet at this position. Applies only when using 'src'" />

		<cfif structKeyExists(arguments, "src") and structKeyExists(arguments, "useXmlFormat")>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Argument Combination"
						detail="Cannot specify both 'src' and 'useXmlFormat'. Argument 'useXmlFormat' only applies to new spreadsheets" />
		</cfif>


		<!--- Load an existing workbook from disk ---->
		<cfif structKeyExists(arguments, "src")>
			<cfset loadFromFile( argumentCollection=arguments ) />

		<!--- create a new workbook with a blank sheet ---->
		<cfelse>
			<!--- If a sheet name was not provided, use the default "Sheet1" --->
			<cfif not structKeyExists(arguments, "sheetName")>
				<cfset arguments.sheetName = "Sheet1" />
			</cfif>

			<!--- Initialize our workbook with a blank Sheet --->
			<cfset setWorkbook( createWorkBook(argumentCollection=arguments) ) />
			<cfset createSheet( sheetName=arguments.sheetName ) />
			<cfset setActiveSheet( sheetName=arguments.sheetName ) />

		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- BASIC READ/WRITE/UPDATE FUNCTIONS --->

	<!--- TODO: Add support for "destination" file --->
	<cffunction name="read" access="public" output="false" returntype="any"
			hint="Reads a spreadsheet from disk and returns a query, CSV, or HTML. **NOTE: To read a file into a spreadsheet object use init() instead.">
		<cfargument name="src" type="string" required="true" hint="The full file path to the spreadsheet" />
		<cfargument name="columns" type="string" required="false" />
		<cfargument name="columnnames" type="string" default="" />
		<cfargument name="format" type="string" required="false" />
		<cfargument name="headerrow" type="numeric" required="false" />
		<cfargument name="query" type="string" required="false" />
		<cfargument name="rows" type="string" required="false" />
		<cfargument name="sheet" type="numeric" required="false" />
		<cfargument name="sheetname" type="string" required="false" />
		<cfargument name="excludeHeaderRow" type="boolean" default="false" />
		<cfargument name="readAllSheets" type="boolean" default="false" />

		<cfset Local.returnVal 	= 0 />
		<cfset Local.exportUtil = 0 />
		<cfset Local.outFile 	= "" />

		<cfif not structKeyExists(arguments, "query") and not structKeyExists(arguments, "format")>
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Argument Combination"
						detail="Either 'query' or 'format' is required." />
		</cfif>

		<cfif structKeyExists(arguments, "format") and not listFindNoCase("csv,html,tab,pipe", arguments.format)>
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Format"
						detail="Supported formats are: HTML, CSV, TAB and PIPE" />
		</cfif>

		<cfif structKeyExists(arguments, "query")>
			<cfset arguments.format = "query" />
		</cfif>


		<!--- create an exporter for the selected format --->
		<cfswitch expression="#arguments.format#">

			<cfcase value="csv,tab,pipe">
				<!--- For CSV/HTML format, output results to a temp file --->
				<cfset Local.outFile = GetTempFile( ExpandPath("."), "cfpoi") />
				<cfset Local.exportUtil = loadPOI("org.cfsearching.poi.WorkbookExportFactory").createCSVExport( arguments.src, Local.outFile )/>
				<cfset Local.exportUtil.setSeparator( Local.exportUtil[ UCASE(arguments.format) ] ) />
			</cfcase>

			<cfcase value="html">
				<!--- For CSV/HTML format, output results to a temp file --->
				<cfset Local.outFile = GetTempFile( ExpandPath("."), "cfpoi") />
				<cfset Local.exportUtil = loadPOI("org.cfsearching.poi.WorkbookExportFactory").createSimpleHTMLExport( arguments.src, Local.outFile )/>
			</cfcase>

			<cfcase value="query">
				<cfset Local.exportUtil = loadPOI("org.cfsearching.poi.WorkbookExportFactory").createQueryExport( arguments.src, arguments.query )/>
				<cfset Local.exportUtil.setColumnNames( javacast("string", arguments.columnNames) ) />
			</cfcase>

		</cfswitch>

		<!--- read a specific sheet --->
		<cfif not arguments.readAllSheets>
			<cfif structKeyExists(arguments, "sheetname")>
				<cfset Local.exportUtil.setSheetToRead( javacast("string", arguments.sheetname) ) />

			<cfelseif structKeyExists(arguments, "sheet")>
				<cfset Local.exportUtil.setSheetToRead( javacast("int", arguments.sheet - 1 ) ) />

			<cfelse>
				<!--- default to the first sheet, like ACF --->
				<cfset Local.exportUtil.setSheetToRead( javacast("int", 0 ) ) />
			</cfif>
		</cfif>

		<!--- read a specific range of rows --->
		<cfif structKeyExists(arguments, "rows")>
			<cfset Local.exportUtil.setRowsToProcess( javacast("string", arguments.rows) ) />
		</cfif>

		<!--- read a specific range of columns --->
		<cfif structKeyExists(arguments, "columns")>
			<cfset Local.exportUtil.setColumnsToProcess( javacast("string", arguments.columns) ) />
		</cfif>

		<!--- identify header row --->
		<cfif structKeyExists(arguments, "headerRow")>
			<cfset Local.exportUtil.setHeaderRow( javacast("int", arguments.headerRow - 1) ) />
		</cfif>

		<!--- for ACF compatibility --->
		<cfif structKeyExists(arguments, "excludeHeaderRow")>
			<cfset Local.exportUtil.setExcludeHeaderRow( javacast("boolean", arguments.excludeHeaderRow) ) />
		</cfif>

		<cftry>
			<cfset Local.exportUtil.process() />

			<cfif arguments.format eq "query">
				<cfset Local.returnVal = Local.exportUtil.getQuery() />
			<cfelse>
				<cfset Local.returnVal = FileRead( Local.outFile, "utf-8" ) />
			</cfif>

			<cffinally>
				<!--- remove temp file --->
				<cfif FileExists( Local.outFile )>
					<cfset FileDelete( Local.outFile ) />
				</cfif>
			</cffinally>
		</cftry>

		<cfreturn Local.returnVal />

	</cffunction>

	<!--- Note: To better support ACF compatibility, Write() and update() functions are now separate.
		This is a departure from the base CFPOI project which uses a single function for both operations --->
	<cffunction name="write" access="public" output="false" returntype="void"
			hint="Writes a spreadsheet to disk">
		<cfargument name="filepath" type="string" required="true" />
		<cfargument name="format" type="string" required="false" />
		<cfargument name="name" type="string" required="false" />
		<cfargument name="overwrite" type="boolean" required="false" default="false" />
		<cfargument name="password" type="string" required="false" />
		<cfargument name="query" type="query" required="false" />
		<cfargument name="sheetname" type="string" required="false" />
		<cfargument name="columnFormats" type="struct" default="#structNew()#" />
		<cfargument name="autoSizeColumns" type="boolean" default="false" />

		<!--- Some of this is a duplication of the existing tag validation --->
		<cfif StructKeyExists(arguments, "query") and StructKeyExists(arguments, "format")>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Argument Combination"
						detail="Both 'query' and 'format' may not be provided." />
		</cfif>

		<cfif structKeyExists(arguments, "sheetName") and sheetExists(arguments.sheetName)>
		    <!--- Ignore the current sheet --->
			<cfif getActiveSheet().getSheetName() neq arguments.sheetName>
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
							message="Invalid Sheet Name"
							detail="The workbook already contains a sheet named [#arguments.sheetName#]." />
			</cfif>
		</cfif>

		<!--- fail fast if this format is not supported ... --->
		<cfif structKeyExists(arguments, "format") and arguments.format neq "CSV">
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
							message="Unsupported Format"
							detail="The format #arguments.format# is not supported for write/update operations." />
		</cfif>


		<cfset Local.newSheet			= 0 />
		<cfset Local.isAppend			= true />
		<cfset Local.sheetCount			= getWorkbook().getNumberOfSheets() />

		<!--- If neither name or format is supplied, we're just writing the workbook to disk --->
		<cfif not (structKeyExists(arguments, "query") or structKeyExists(arguments, "name"))>
			<cfset Local.isAppend	= false />
		</cfif>

		<!--- If we are appending data, make sure we have a blank sheet to populate.
				Create a new sheet when either
				a) active sheet already contains data  OR
				b) current workbook is empty (should not happen, but just in case ...)
			--->
		<cfif Local.isAppend and (Local.sheetCount eq 0 or getNextEmptyRow() gt 0)>
			<cfset Local.newSheet = createSheet() />
			<cfset setActiveSheet( sheetName=Local.newSheet.getSheetName() ) />
		</cfif>

		<!--- If requested, rename the active sheet --->
		<cfif structKeyExists(arguments, "sheetName")>
			<cfset renameSheet( arguments.sheetName, getWorkBook().getActiveSheetIndex() + 1 ) />
		</cfif>

		<!--- Handle query or CSV accordingly. --->
		<cfif StructKeyExists(arguments, "query")>
			<!--- Add the column names to the first row
				If arguments.columnames exist, use that value for the headers
				otherwise use the columnlist from the query variable itself
			--->
			<cfif structKeyExists(arguments, "columnnames")>
				<cfset addRow(arguments.columnnames, 1, 1, false) />
			<cfelse>
				<cfset addRow(arguments.query.columnlist, 1, 1, false) />
			</cfif>

			<!--- Add the data starting at the 2nd row, since the header
				was added to the first row
			---->
			<cfset addRows( arguments.query, 2, 1, false, arguments.columnFormats, arguments.autoSizeColumns ) />

		<cfelseif structKeyExists(arguments, "name")>

			<cfset addDelimitedRows( arguments.name ) />
		</cfif>

		<!--- save the workbook to disk --->
		<cfset writeToFile( argumentCollection=arguments ) />

	</cffunction>

	<!--- Note: To better support ACF compatibility, Write() and update() functions are now separate.
		This is a departure from the base CFPOI project which uses a single function for both operations --->
	<cffunction name="update" access="public" output="false" returntype="void"
			hint="Updates a workbook with a new sheet or overwrites an existing sheet with the same name">
		<cfargument name="filepath" type="string" required="true" />
		<cfargument name="format" type="string" required="false" />
		<cfargument name="name" type="string" required="false" />
		<cfargument name="password" type="string" required="false" />
		<cfargument name="query" type="query" required="false" />
		<cfargument name="sheetname" type="string" required="false" />
		<cfargument name="nameConflict" type="string" default="error" hint="Action to take if the sheetname already exists: overwrite or error (default)" />
		<cfargument name="columnFormats" type="struct" default="#structNew()#" />
		<cfargument name="autoSizeColumns" type="boolean" default="false" />

		<!--- remember the currently active sheet --->
		<cfset Local.activeSheetNum = getWorkBook().getActiveSheetIndex() + 1 />

		<!--- Create a new sheet to populate with data. Make it the active sheet so
			we can reuse existing functions	--->
		<cfset Local.sheetToUpdate = createSheet( argumentCollection=arguments ) />
		<cfset Local.sheetToActivate = getWorkbook().getSheetIndex( Local.sheetToUpdate ) + 1 />
		<cfset setActiveSheet( sheetIndex=Local.sheetToActivate ) />

		<cfif structKeyExists(arguments, "query")>
			<cfset addRows( arguments.query, 1, 1, false, arguments.columnFormats, arguments.autoSizeColumns ) />
		<cfelseif structKeyExists(arguments, "format")>
			<cfset addDelimitedRows( arguments.name ) />
		</cfif>

		<!--- restore the original active sheet index as in ACF --->
		<cfset setActiveSheet( sheetIndex=Local.activeSheetNum ) />

		<!--- save the workbook to disk --->
		<cfset writeToFile( argumentCollection=arguments ) />

	</cffunction>

	<!--- SPREADSHEET MANIPULATION FUNCTIONS --->
	<!--- sheet functions --->
	<cffunction name="addFreezePane" access="public" output="false" returntype="void"
			hint="Adds a split ('freeze pane') to the sheet">
		<cfargument name="splitColumn" type="numeric" required="true"
				hint="Horizontal position of split" />
		<cfargument name="splitRow" type="numeric" required="true"
				hint="Vertical position of split" />
		<cfargument name="leftmostColumn" type="numeric" required="false"
				hint="Left column visible in right pane" />
		<cfargument name="topRow" type="numeric" required="false"
				hint="Top row visible in bottom pane" />

		<cfif StructKeyExists(arguments, "leftmostColumn")
				and not StructKeyExists(arguments, "topRow")>
			<cfset arguments.topRow = arguments.splitRow />
		</cfif>

		<cfif StructKeyExists(arguments, "topRow")
				and not StructKeyExists(arguments, "leftmostColumn")>
			<cfset arguments.leftmostColumn = arguments.splitColumn />
		</cfif>

		<!--- createFreezePane() operates on the logical row/column numbers as opposed to physical,
				so no need for n-1 stuff here --->
		<cfif not StructKeyExists(arguments, "leftmostColumn")>
			<cfset getActiveSheet().createFreezePane(JavaCast("int", arguments.splitColumn),
													JavaCast("int", arguments.splitRow)) />
		<cfelse>
			<!--- POI lets you specify an active pane if you use createSplitPane() here --->
			<cfset getActiveSheet().createFreezePane(JavaCast("int", arguments.splitColumn),
													JavaCast("int", arguments.splitRow),
													JavaCast("int", arguments.leftmostColumn),
													JavaCast("int", arguments.topRow)) />
		</cfif>
	</cffunction>

	<!--- the CF 9 docs seem to be wrong on what the last argument means ... or
			they're combining split pane and freeze pane --->
	<cffunction name="createSplitPane" access="public" output="false" returntype="void"
			hint="Adds a split pane to a sheet, which differs from a freeze pane in that it has x and y positioning">
		<cfargument name="xSplitPos" type="numeric" required="true" />
		<cfargument name="ySplitPos" type="numeric" required="true" />
		<cfargument name="leftmostColumn" type="numeric" required="true" />
		<cfargument name="topRow" type="numeric" required="true" />
		<cfargument name="activePane" type="string" required="false" default="UPPER_LEFT"
				hint="Valid values are LOWER_LEFT, LOWER_RIGHT, UPPER_LEFT, and UPPER_RIGHT" />

		<cfset arguments.activePane = getActiveSheet()["PANE_#arguments.activePane#"] />

		<cfset getActiveSheet().createSplitPane(JavaCast("int", arguments.xSplitPos),
											JavaCast("int", arguments.ySplitPos),
											JavaCast("int", arguments.leftmostColumn),
											JavaCast("int", arguments.topRow),
											JavaCast("int", arguments.activePane)) />
	</cffunction>

	<!--- TODO: Should we allow for passing in of a boolean indicating whether or not an image resize
				should happen (only works on jpg and png)? Currently does not resize. If resize is
				performed, it does mess up passing in x/y coordinates for image positioning. --->
	<cffunction name="addImage" access="public" output="false" returntype="void"
			hint="Adds an image to the workbook. Valid argument combinations are filepath + anchor, or imageData + imageType + anchor">
		<cfargument name="filepath" type="string" required="false" />
		<cfargument name="imageData" type="any" required="false" />
		<cfargument name="imageType" type="string" required="false" />
		<cfargument name="anchor" type="string" required="true" />

		<cfset var toolkit = loadPOI("java.awt.Toolkit") />
		<!--- For some reason calling creationHelper.createClientAnchor() bombs with a 'could not instantiate object'
				error, so we'll create the anchor manually later. Just leaving this in here in case it's worth another
				look. --->
		<!--- <cfset var creationHelper = CreateObject("java", "org.apache.poi.hssf.usermodel.HSSFCreationHelper") /> --->
		<cfset var ioUtils = loadPoi("org.apache.poi.util.IOUtils") />
		<cfset var inputStream = 0 />
		<cfset var bytes = 0 />
		<cfset var picture = 0 />
		<cfset var imgType = "" />
		<cfset var imgTypeIndex = 0 />
		<cfset var imageIndex = 0 />
		<cfset var theAnchor = 0 />
		<!--- TODO: need to look into createDrawingPatriarch() vs. getDrawingPatriarch()
					since create will kill any existing images. getDrawingPatriarch() throws
					a null pointer exception when an attempt is made to add a second
					image to the spreadsheet --->
		<cfset var drawingPatriarch = getActiveSheet().createDrawingPatriarch() />

		<!--- we'll need the image type int in all cases --->
		<cfif StructKeyExists(arguments, "filepath")>
			<!--- TODO: better way to determine image type for physical files? using file extension for now --->
			<cfset imgType = UCase(ListLast(arguments.filePath, ".")) />
		<cfelseif StructKeyExists(arguments, "imageType")>
			<cfset imgType = UCase(arguments.imageType) />
		<cfelse>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Could Not Determine Image Type"
						detail="An image type could not be determined from the filepath or imagetype provided" />
		</cfif>

		<cfswitch expression="#imgType#">
			<cfcase value="DIB">
				<cfset imgTypeIndex = getWorkbook().PICTURE_TYPE_DIB />
			</cfcase>

			<cfcase value="EMF">
				<cfset imgTypeIndex = getWorkbook().PICTURE_TYPE_EMF />
			</cfcase>

			<cfcase value="JPG,JPEG" delimiters=",">
				<cfset imgTypeIndex = getWorkbook().PICTURE_TYPE_JPEG />
			</cfcase>

			<cfcase value="PICT">
				<cfset imgTypeIndex = getWorkbook().PICTURE_TYPE_PICT />
			</cfcase>

			<cfcase value="PNG">
				<cfset imgTypeIndex = getWorkbook().PICTURE_TYPE_PNG />
			</cfcase>

			<cfcase value="WMF">
				<cfset imgTypeIndex = getWorkbook().PICTURE_TYPE_WMF />
			</cfcase>

			<cfdefaultcase>
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
							message="Invalid Image Type"
							detail="Valid image types are DIB, EMF, JPG, JPEG, PICT, PNG, and WMF" />
			</cfdefaultcase>
		</cfswitch>

		<cfif StructKeyExists(arguments, "filepath") and StructKeyExists(arguments, "anchor")>
			<cfset inputStream = loadPOI("java.io.FileInputStream").init(JavaCast("string", arguments.filepath)) />
			<cfset bytes = ioUtils.toByteArray(inputStream) />
			<cfset inputStream.close() />
		<cfelse>
			<cfset bytes = arguments.imageData />
		</cfif>

		<cfset imageIndex = getWorkbook().addPicture(bytes, JavaCast("int", imgTypeIndex)) />

		<cfset theAnchor = loadPoi("org.apache.poi.hssf.usermodel.HSSFClientAnchor").init() />

		<cfif ListLen(arguments.anchor) eq 4>
			<!--- list is in format startRow, startCol, endRow, endCol --->
			<cfset theAnchor.setRow1(JavaCast("int", ListFirst(arguments.anchor) - 1)) />
			<cfset theAnchor.setCol1(JavaCast("int", ListGetAt(arguments.anchor, 2) - 1)) />
			<cfset theAnchor.setRow2(JavaCast("int", ListGetAt(arguments.anchor, 3) - 1)) />
			<cfset theAnchor.setCol2(JavaCast("int", ListLast(arguments.anchor) - 1)) />
		<cfelseif ListLen(arguments.anchor) eq 8>
			<!--- list is in format dx1, dy1, dx2, dy2, col1, row1, col2, row2 --->
			<cfset theAnchor.setDx1(JavaCast("int", ListFirst(arguments.anchor))) />
			<cfset theAnchor.setDy1(JavaCast("int", ListGetAt(arguments.anchor, 2))) />
			<cfset theAnchor.setDx2(JavaCast("int", ListGetAt(arguments.anchor, 3))) />
			<cfset theAnchor.setDy2(JavaCast("int", ListGetAt(arguments.anchor, 4))) />
			<cfset theAnchor.setRow1(JavaCast("int", ListGetAt(arguments.anchor, 5) - 1)) />
			<cfset theAnchor.setCol1(JavaCast("int", ListGetAt(arguments.anchor, 6) - 1)) />
			<cfset theAnchor.setRow2(JavaCast("int", ListGetAt(arguments.anchor, 7) - 1)) />
			<cfset theAnchor.setCol2(JavaCast("int", ListLast(arguments.anchor) - 1)) />
		<cfelse>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Anchor Argument"
						detail="The anchor argument must be a comma-delimited list of integers with either 4 or 8 elements" />
		</cfif>

		<cfset picture = drawingPatriarch.createPicture(theAnchor, imageIndex) />

		<!--- disabling this for now--maybe let people pass in a boolean indicating
				whether or not they want the image resized? --->
		<!--- if this is a png or jpg, resize the picture to its original size
				(this doesn't work for formats other than jpg and png) --->
		<!--- <cfif imgTypeIndex eq getWorkbook().PICTURE_TYPE_JPEG
				or imgTypeIndex eq getWorkbook().PICTURE_TYPE_PNG>
			<cfset picture.resize() />
		</cfif> --->
	</cffunction>

	<cffunction name="getInfo" access="public" output="false" returntype="struct"
			hint="Returns a struct containing the standard properties for the workbook">
		<!---
			workbook properties returned in the struct are:
			* AUTHOR
			* CATEGORY
			* COMMENTS
			* CREATIONDATE
			* LASTEDITED
			* LASTAUTHOR
			* LASTSAVED
			* KEYWORDS
			* MANAGER
			* COMPANY
			* SUBJECT
			* TITLE
			* SHEETS
			* SHEETNAMES
			* SPREADSHEETTYPE
		--->
		<!--- format specific metadata --->
		<cfif isBinaryFormat()>
			<cfset Local.info = getBinaryInfo() />
		<cfelse>
			<cfset Local.info = getOOXMLInfo() />
		</cfif>

		<!--- common properties --->
		<cfset Local.info.sheets = getWorkbook().getNumberOfSheets() />
		<cfset Local.info.sheetnames = "" />

		<cfif IsNumeric(Local.info.sheets) and Local.info.sheets gt 0>
			<cfloop index="Local.i" from="1" to="#Local.info.sheets#">
				<cfset Local.info.sheetnames = ListAppend(Local.info.sheetnames, getWorkbook().getSheetName(JavaCast("int", Local.i - 1))) />
			</cfloop>
		</cfif>

		<cfif getWorkbook().getClass().getName() eq "org.apache.poi.hssf.usermodel.HSSFWorkbook">
			<cfset Local.info.spreadsheettype = "Excel" />
		<cfelseif getWorkbook().getClass().getName() eq "org.apache.poi.xssf.usermodel.XSSFWorkbook">
			<cfset Local.info.spreadsheettype = "Excel (2007)" />
		<cfelse>
			<cfset Local.info.spreadsheettype = "" />
		</cfif>

		<cfreturn Local.info />
	</cffunction>

	<cffunction name="getOOXMLInfo" access="private" output="false" returntype="struct"
			hint="Returns a struct containing the standard properties for an OOXML workbook">

		<cfscript>
			local.info 				= {};
			local.docProps			= getWorkbook().getProperties().getExtendedProperties().getUnderlyingProperties();
			local.coreProps 		= getWorkbook().getProperties().getCoreProperties();

			// ACF compatibility, ensure keys always exist
			local.value				= local.coreProps.getCreator();
		    local.info.author 		= isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getCategory();
		    local.info.category 	= isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getDescription();
		    local.info.comments 	= isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getCreated();
		    local.info.creationdate = isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getModified();
		    local.info.lastedited   = isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getSubject();
			local.info.subject 		= isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getTitle();
			local.info.title 		= isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getUnderlyingProperties().getLastModifiedByProperty().getValue();
		    local.info.lastauthor   = isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getKeywords();
		    local.info.keywords 	= isNull(local.value) ?  "" : local.value;
		    // TODO: Determine if lastSaved applies to ooxml
			local.info.lastsaved    = "";

			local.value				= local.docProps.getManager();
		    local.info.manager   	= isNull(local.value) ?  "" : local.value;
			local.value				= local.docProps.getCompany();
		    local.info.company   	= isNull(local.value) ?  "" : local.value;

		    return local.info;
		</cfscript>
	</cffunction>

	<cffunction name="getBinaryInfo" access="private" output="false" returntype="struct"
			hint="Returns a struct containing the standard properties for a binary workbook">

		<cfscript>
			local.info 				= {};
			local.docProps			= getWorkbook().getDocumentSummaryInformation();
			local.coreProps 		= getWorkbook().getSummaryInformation();

			local.value				= local.coreProps.getAuthor();
		    local.info.author 		= isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getComments();
		    local.info.comments 	= isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getCreateDateTime();
		    local.info.creationdate = isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getEditTime();
			if (local.value neq 0) {
				local.value			= CreateObject("java", "java.util.Date").init( local.value );
			}
		    local.info.lastEdited   = local.value eq 0 ?  "" : local.value;
			local.value				= local.coreProps.getSubject();
			local.info.subject 		= isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getTitle();
			local.info.title 		= isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getLastAuthor();
		    local.info.lastauthor   = isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getLastSaveDateTime();
			local.info.lastsaved    = isNull(local.value) ?  "" : local.value;
			local.value				= local.coreProps.getKeywords();
		    local.info.keywords 	= isNull(local.value) ?  "" : local.value;

			local.value				= local.docProps.getManager();
		    local.info.manager   	= isNull(local.value) ?  "" : local.value;
			local.value				= local.docProps.getCompany();
		    local.info.company   	= isNull(local.value) ?  "" : local.value;
			local.value				= local.docProps.getCategory();
		    local.info.category 	= isNull(local.value) ?  "" : local.value;

		    return local.info;
		</cfscript>
	</cffunction>

	<cffunction name="addInfo" access="public" output="false" returntype="void"
			hint="Set standard properties on the workbook">
		<cfargument name="props" type="struct" required="true"
				hint="Valid struct keys are author, category, lastauthor, comments, keywords, manager, company, subject, title" />

		<cfif isBinaryFormat()>
			<cfset addInfoBinary( arguments.props ) />
		<cfelse>
			<cfset addInfoOOXML( arguments.props ) />
		</cfif>
	</cffunction>

	<cffunction name="addInfoBinary" access="private" output="false" returntype="void"
			hint="Set standard properties on the workbook">
		<cfargument name="props" type="struct" required="true"
				hint="Valid struct keys are author, category, lastauthor, comments, keywords, manager, company, subject, title" />

		<!--- Properties are automatically intialized in setWorkBook() and should always exist --->
		<cfset var documentSummaryInfo = getWorkbook().getDocumentSummaryInformation() />
		<cfset var summaryInfo = getWorkbook().getSummaryInformation() />
		<cfset var key = 0 />

		<cfscript>
			for (var key in arguments.props) {
				switch (key) {
					case "author":
						summaryInfo.setAuthor(JavaCast("string", arguments.props.author));
						break;
					case "category":
						documentSummaryInfo.setCategory(JavaCast("string", arguments.props.category));
						break;
					case "lastauthor":
						summaryInfo.setLastAuthor(JavaCast("string", arguments.props.lastauthor));
						break;
					case "comments":
						summaryInfo.setComments(JavaCast("string", arguments.props.comments));
						break;
					case "keywords":
						summaryInfo.setKeywords(JavaCast("string", arguments.props.keywords));
						break;
					case "manager":
						documentSummaryInfo.setManager(JavaCast("string", arguments.props.manager));
						break;
					case "company":
						documentSummaryInfo.setCompany(JavaCast("string", arguments.props.company));
						break;
					case "subject":
						summaryInfo.setSubject(JavaCast("string", arguments.props.subject));
						break;
					case "title":
						summaryInfo.setTitle(JavaCast("string", arguments.props.title));
						break;
				}
			}
		</cfscript>
	</cffunction>

	<cffunction name="addInfoOOXML" access="private" output="false" returntype="void"
			hint="Set standard properties on the workbook">
		<cfargument name="props" type="struct" required="true"
				hint="Valid struct keys are author, category, lastauthor, comments, keywords, manager, company, subject, title" />

		<!--- Properties are automatically intialized in setWorkBook() and should always exist --->
		<cfset var docProps  = getWorkbook().getProperties().getExtendedProperties().getUnderlyingProperties() />
		<cfset var coreProps = getWorkbook().getProperties().getCoreProperties() />
		<cfset var key  	 = 0 />

		<cfscript>
			for (var key in arguments.props) {
				switch (key) {
					case "author":
						coreProps.setCreator( JavaCast("string", arguments.props[key]) );
						break;
					case "category":
						coreProps.setCategory( JavaCast("string", arguments.props[key]));
						break;
					case "lastauthor":
						// TODO: This does not seem to be working. Not sure why
						coreProps.getUnderlyingProperties().setLastModifiedByProperty(JavaCast("string", arguments.props[key]));
						break;
					case "comments":
						coreProps.setDescription(JavaCast("string", arguments.props[key]));
						break;
					case "keywords":
						coreProps.setKeywords(JavaCast("string", arguments.props[key]));
						break;
					case "subject":
						coreProps.setSubjectProperty(JavaCast("string", arguments.props[key]));
						break;
					case "title":
						coreProps.setTitle(JavaCast("string", arguments.props[key]));
						break;
					case "manager":
						docProps.setManager(JavaCast("string", arguments.props[key]));
						break;
					case "company":
						docProps.setCompany(JavaCast("string", arguments.props[key]));
						break;
				}
			}
		</cfscript>
	</cffunction>

	<cffunction name="readBinary" access="public" output="false" returntype="binary"
			hint="Returns a binary representation of the file">

		<cfset var baos = loadPOI("org.apache.commons.io.output.ByteArrayOutputStream").init() />
		<cfset getWorkBook().write( baos ) />
		<cfset baos.flush()>

		<cfreturn baos.toByteArray() />
	</cffunction>

	<cffunction name="setFooter" access="public" output="false" returntype="void"
			hint="Sets the footer values on the sheet">
		<cfargument name="leftFooter" type="string" required="true" />
		<cfargument name="centerFooter" type="string" required="true" />
		<cfargument name="rightFooter" type="string" required="true" />

		<cfif arguments.centerFooter neq "">
			<cfset getActiveSheet().getFooter().setCenter(JavaCast("string", arguments.centerFooter)) />
		</cfif>

		<cfif arguments.leftFooter neq "">
			<cfset getActiveSheet().getFooter().setLeft(JavaCast("string", arguments.leftFooter)) />
		</cfif>

		<cfif arguments.rightFooter neq "">
			<cfset getActiveSheet().getFooter().setRight(JavaCast("string", arguments.rightFooter)) />
		</cfif>
	</cffunction>

	<cffunction name="setHeader" access="public" output="false" returntype="void"
			hint="Sets the header values on the sheet">
		<cfargument name="leftHeader" type="string" required="true" />
		<cfargument name="centerHeader" type="string" required="true" />
		<cfargument name="rightHeader" type="string" required="true" />

		<cfif arguments.centerHeader neq "">
			<cfset getActiveSheet().getHeader().setCenter(JavaCast("string", arguments.centerHeader)) />
		</cfif>

		<cfif arguments.leftHeader neq "">
			<cfset getActiveSheet().getHeader().setLeft(JavaCast("string", arguments.leftHeader)) />
		</cfif>

		<cfif arguments.rightHeader neq "">
			<cfset getActiveSheet().getHeader().setRight(JavaCast("string", arguments.rightHeader)) />
		</cfif>
	</cffunction>

	<!--- GENERAL INFORMATION FUNCTIONS --->
	<cffunction name="isBinaryFormat" access="public" output="false" returntype="boolean"
			hint="Returns true if this is a binary *.xls spreadsheet (ie instance of org.apache.poi.hssf.usermodel.HSSFWorkbook)">
		<!---  Since the workbook is created with a separate class loader, isInstanceOf may not
		       return the expected results. So we are using the class name as a simple/lazy alternative --->
		<cfreturn ( getWorkbook().getClass().getCanonicalName() eq "org.apache.poi.hssf.usermodel.HSSFWorkbook" ) />
	</cffunction>

	<!--- TODO: implement an addPageNumbers() function to allow for addition of page numbers
				in header or footer (tons more stuff like this that could easily be added) --->

	<!--- row functions --->
	<cffunction name="addRow" access="public" output="false" returntype="void"
			hint="Adds a new row and inserts the data provided in the new row.">
		<cfargument name="data" type="string" required="true" hint="Delimited list of data" />
		<cfargument name="startRow" type="numeric" required="false" hint="Target row number" />
		<cfargument name="startColumn" type="numeric" default="1" hint="Target column number" />
		<cfargument name="insert" type="boolean" default="true" hint="If true, data is inserted as a new row. Otherwise, any existing data is overwritten "/>
		<cfargument name="delimiter" type="string" default="," hint="Delimiter for the list of values" />
		<cfargument name="handleEmbeddedCommas" type="boolean" default="true" hint="When true, values enclosed in single quotes are treated as a single element like in ACF. Only applies when the delimiter is a comma."  />

		<cfif StructKeyExists(arguments, "startRow") and arguments.startRow lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Row Value"
						detail="The value for row must be greater than or equal to 1." />
		</cfif>

		<cfif StructKeyExists(arguments, "startColumn") and arguments.startColumn lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Column Value"
						detail="The value for column must be greater than or equal to 1." />
		</cfif>

		<!--- this equates to the last populated row in base-1. getNextEmptyRow() contains
			special handling required work around eccentricities with getLastRowNum(). --->
		<cfset Local.lastRow = getNextEmptyRow() />

		<!--- If the requested row already exists ... --->
		<cfif StructKeyExists(arguments, "startRow") and arguments.startRow lte Local.lastRow>

			<!--- shift the existing rows down (by one row) --->
			<cfif arguments.insert>
				<cfset shiftRows( arguments.startRow, Local.lastRow, 1 ) />
			<!--- otherwise, clear the entire row --->
			<cfelse>
				<cfset deleteRow( arguments.startRow ) />
			</cfif>

		</cfif>

		<cfif StructKeyExists(arguments, "startRow")>
			<cfset Local.theRow = createRow( arguments.startRow - 1 ) />
		<cfelse>
			<cfset Local.theRow	= createRow() />
		</cfif>


		<cfset Local.rowValues = parseRowData( arguments.data, arguments.delimiter, arguments.handleEmbeddedCommas ) />

		<!--- TODO: Move to setCellValue --->
		<cfset Local.cellNum = arguments.startColumn - 1 />
		<cfset Local.dateUtil = loadPOI("org.apache.poi.ss.usermodel.DateUtil") />

		<cfloop array="#Local.rowValues#" index="Local.cellValue">
			<cfset Local.oldWidth = getActiveSheet().getColumnWidth( Local.cellNum ) />
			<cfset Local.cell = createCell( Local.theRow, Local.cellNum ) />
			<cfset Local.isDateColumn  = false />
			<cfset Local.dateMask  = "" />
<!---
			<cftry>
			--->
				<!--- NUMERIC --->
				<!--- skip numeric strings with leading zeroes. treat those as text --->
				<cfif IsNumeric( Local.cellValue ) and NOT reFind("^0[\d]+", trim(Local.cellValue)) >
					<cfset Local.cell.setCellType( Local.cell.CELL_TYPE_NUMERIC ) />
					<cfset Local.cell.setCellValue( javacast("double", Local.cellValue ) ) />

				<!--- DATE --->
				<cfelseif IsDate( Local.cellValue)>
					<cfset Local.cellFormat = getDateTimeValueFormat( Local.cellValue ) />
					<cfset Local.cell.setCellStyle( buildCellStyle({dataFormat=Local.cellFormat }) ) />
					<cfset Local.cell.setCellType( Local.cell.CELL_TYPE_NUMERIC ) />

					<!--- Excel's uses a different epoch than CF (1900-01-01 versus 1899-12-30). "Time"
						only values will not display properly without special handling ---->
					<cfif Local.cellFormat eq variables.defaultFormats.TIME>
						 <cfset Local.cellValue = timeFormat(Local.cellValue, "HH:MM:SS")  />
						 <cfset Local.cell.setCellValue( Local.dateUtil.convertTime(Local.cellValue) ) />
					<cfelse>
						<cfset Local.cell.setCellValue( parseDateTime(Local.cellValue) ) />
					</cfif>

					<cfset Local.dateMask  = Local.cellFormat />
					<cfset Local.isDateColumn  = true />

				<!--- STRING --->
				<cfelseif len(trim(Local.cellValue))>
					<cfset Local.cell.setCellType( Local.cell.CELL_TYPE_STRING ) />
					<cfset Local.cell.setCellValue( JavaCast("string", Local.cellValue) ) />

				<!--- EMPTY  --->
				<cfelse>
					<cfset Local.cell.setCellType( Local.cell.CELL_TYPE_BLANK) />
					<cfset Local.cell.setCellValue("") />
				</cfif>
<!---
				<cfcatch>
					<!--- on error, default to string --->
					<cfset Local.cell.setCellType( Local.cell.CELL_TYPE_STRING ) />
					<cfset Local.cell.setCellValue( JavaCast("string", Local.cellValue) ) />
				</cfcatch>
			</cftry>
--->

			<!--- automatically resize column. It would be more efficient to invoke
				resize after all processing is finished, but obviously that is not possible with addRow.
			--->
			<cfset autoSizeColumnFix( Local.cellNum, Local.isDateColumn, Local.dateMask ) />

			<cfset Local.cellNum = Local.cellNum + 1 />
		</cfloop>

	</cffunction>


	<cffunction name="getDateTimeValueFormat" access="private" returntype="string"
				hint="Returns the default date mask for the given value: DATE (only), TIME (only) or TIMESTAMP ">
		<cfargument name="value" type="any" required="true" />

		<cfset Local.dateTime = parseDateTime(arguments.value) />
		<cfset Local.dateOnly = createDate(year(Local.dateTime), month(Local.dateTime), day(Local.dateTime)) />

		<cfif dateCompare(arguments.value, Local.dateOnly, "s") eq 0>
			<!--- DATE only --->
			<cfreturn variables.defaultFormats.DATE />

		<cfelseif dateCompare("1899-12-30", Local.dateOnly, "d") eq 0>
			<!--- TIME only --->
			<cfreturn variables.defaultFormats.TIME />
		<cfelse>
			<!--- DATE and TIME --->
			<cfreturn variables.defaultFormats.TIMESTAMP />
		</cfif>

	</cffunction>


	<!--- Workaround for an issue with autoSizeColumn(). It does not seem to handle
		date cells properly. It measures the length of the date "number", instead of
		the  visible date string ie mm//dd/yyyy. As a result columns are too narrow --->
	<cffunction name="autoSizeColumnFix" access="private" returnType="void">
	    <cfargument name="columnIndex" type="numeric" required="true" hint="Base-0 column index" />
	    <cfargument name="isDateColumn" type="boolean" default="false" />
		<cfargument name="dateMask" type="string" default="#variables.defaultFormats['TIMESTAMP']#" />

		<cfif arguments.isDateColumn>
			<!--- Add a few zeros for extra padding --->
			<cfset Local.newWidth = estimateColumnWidth( arguments.dateMask &"00000") />
			<cfset getActiveSheet().setColumnWidth( arguments.columnIndex, Local.newWidth ) />
		<cfelse>
			<cfset getActiveSheet().autoSizeColumn( javacast("int", arguments.columnIndex), true ) />
		</cfif>
	</cffunction>


	<cffunction name="addRows" access="public" output="false" returntype="void"
			hint="Adds rows to a sheet from a query object">
		<cfargument name="data" type="query" required="true" />
		<cfargument name="row" type="numeric" required="false" />
		<cfargument name="column" type="numeric" default="1" />
		<cfargument name="insert" type="boolean" default="true" />
		<cfargument name="formats" type="struct" default="#structNew()#" hint="Column format properties [key: columnName, value: format structure]" />
		<cfargument name="autoSizeColumns" type="boolean" default="false" />

		<cfif StructKeyExists(arguments, "row") and arguments.row lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Row Value"
						detail="The value for row must be greater than or equal to 1." />
		</cfif>

		<cfif StructKeyExists(arguments, "column") and arguments.column lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Column Value"
						detail="The value for column must be greater than or equal to 1." />
		</cfif>

		<!--- this equates to the last populated row in base-1. getNextEmptyRow() contains
			special handling required work around eccentricities with getLastRowNum(). --->
		<cfset Local.lastRow = getNextEmptyRow() />

		<!--- If the requested row already exists ... --->
		<cfif StructKeyExists(arguments, "row") and arguments.row lte Local.lastRow>

			<!--- shift the existing rows down  --->
			<cfif arguments.insert>
				<cfset shiftRows( arguments.row, Local.lastRow, arguments.data.recordCount ) />
			<!--- do not clear the entire row because would erase all existing styles too
			<cfelse>
				<cfset deleteRow( arguments.row ) />
			--->
			</cfif>

		</cfif>

		<!--- convert to base 0 for compatibility with existing functions. --->
		<cfif StructKeyExists(arguments, "row")>
			<cfset Local.rowNum = arguments.row - 1 />
		<cfelse>
			<!--- If a row number was not supplied, move to the next empty row --->
			<cfset Local.rowNum	= getNextEmptyRow() />
		</cfif>

		<!--- get the column names and formatting information --->
		<cfset Local.queryColumns = getQueryColumnFormats(arguments.data, arguments.formats) />
		<cfset Local.dateUtil	  = loadPOI("org.apache.poi.ss.usermodel.DateUtil") />
		<cfset Local.dateColumns  = {} />

		<cfloop query="arguments.data">
			<!--- can't just call addRow() here since that function expects a comma-delimited
					list of data (probably not the greatest limitation ...) and the query
					data may have commas in it, so this is a bit redundant with the addRow()
					function --->
			<cfset Local.theRow = createRow( Local.rowNum, false ) />
			<cfset Local.cellNum = arguments.column - 1 />

			<!---
				Note: To properly apply date/number formatting:
   				- cell type must be CELL_TYPE_NUMERIC
   				- cell value must be applied as a java.util.Date or java.lang.Double (NOT as a string)
   				- cell style must have a dataFormat (datetime values only)
			--->
			<!--- populate all columns in the row --->
			<cfloop array="#Local.queryColumns#" index="Local.column">
				<cfset Local.cell 	= createCell( Local.theRow, Local.cellNum, false ) />
				<cfset Local.value 	= arguments.data[Local.column.name][arguments.data.currentRow] />
				<cfset Local.forceDefaultStyle = false />
				<cfset Local.column.index = Local.cellNum />

				<!--- Cast the values to the correct type, so data formatting is properly applied --->
				<cfif Local.column.cellDataType EQ "DOUBLE" AND IsNumeric(Local.value)>
					<cfset Local.cell.setCellValue( JavaCast("double", val(Local.value) ) ) />

				<cfelseif Local.column.cellDataType EQ "TIME" AND IsDate(Local.value)>
					<cfset Local.value = timeFormat(parseDateTime(Local.value), "HH:MM:SS") />
					<cfset Local.cell.setCellValue( Local.dateUtil.convertTime(Local.value) ) />
					<cfset Local.forceDefaultStyle = true />
					<cfset Local.dateColumns[ Local.column.name ] = { index=Local.cellNum, type=Local.column.cellDataType }  />

				<cfelseif Local.column.cellDataType EQ "DATE" AND IsDate(Local.value)>
					<!--- If the cell is NOT already formatted for dates, apply the default format --->
					<!--- brand new cells have a styleIndex == 0 --->
					<cfset Local.styleIndex = Local.cell.getCellStyle().getDataFormat() />
					<cfset Local.styleFormat = Local.cell.getCellStyle().getDataFormatString() />
					<cfif Local.styleIndex EQ 0 OR NOT Local.dateUtil.isADateFormat(Local.styleIndex, Local.styleFormat)>
						<cfset Local.forceDefaultStyle = true />
					</cfif>
					<cfset Local.cell.setCellValue( parseDateTime(Local.value) ) />
					<cfset Local.dateColumns[ Local.column.name ] = { index=Local.cellNum, type=Local.column.cellDataType }  />

				<cfelseif Local.column.cellDataType EQ "BOOLEAN" AND IsBoolean(Local.value)>
					<cfset Local.cell.setCellValue( JavaCast("boolean", Local.value ) ) />

				<cfelseif IsSimpleValue(Local.value) AND NOT Len(Local.value)>
					<cfset Local.cell.setCellType( Local.cell.CELL_TYPE_BLANK ) />

				<cfelse>
					<cfset Local.cell.setCellValue( JavaCast("string", Local.value ) ) />
				</cfif>

				<!--- Replace the existing styles with custom formatting --->
				<cfif structKeyExists(Local.column, "customCellStyle")>
					<cfset Local.cell.setCellStyle( Local.column.customCellStyle ) />

				<!--- Replace the existing styles with default formatting (for readability). The reason we cannot
					just update the cell's style is because they are shared. So modifying it may impact more than
					just this one cell.
				--->
				<cfelseif structKeyExists(Local.column, "defaultCellStyle") AND Local.forceDefaultStyle>
					<cfset Local.cell.setCellStyle( Local.column.defaultCellStyle ) />
				</cfif>

				<cfset Local.cellNum = Local.cellNum + 1 />
			</cfloop>

			<cfset Local.rowNum = Local.rowNum + 1 />
		</cfloop>

		<!--- adjust column sizes to fit content. note: this method uses Java2D classes that throw
			exception if graphical environment is not available. If a graphical environment is not
			available, you must must run in headless mode ie java.awt.headless=true --->
		<cfif arguments.autoSizeColumns and arguments.data.recordCount>
			<!---
			<cfset Local.startColumn = arguments.column - 1 />
			<cfset Local.endColumn = Local.startColumn + arrayLen(Local.queryColumns) - 1 />
			<cfloop from="#Local.startColumn#" to="#Local.endColumn#" index="Local.index">
				<cfset getActiveSheet().autoSizeColumn( javacast("int", Local.index), true ) />
			</cfloop>
			--->
			<cfloop array="#Local.queryColumns#" index="Local.column">
				    <cflog file="POI" text="#Local.column.name# #local.column.index#:: #Local.column.cellDataType#">
				<!--- auto resize NON-date/time columns ---->
				<cfif NOT listFindNoCase("DATE,TIME", Local.column.cellDataType)>
					<cfset getActiveSheet().autoSizeColumn( javacast("int", Local.column.index), true ) />
				<cfelse>
					<!--- Workaround: autoSizeColumn does not handle date columns correctly. As a
					     result date columns are too narrow and cells display "######" ---->
					<cfset Local.sampleValue = variables.defaultFormats[Local.column.cellDataType] />
					<cfset Local.newWidth  = estimateColumnWidth( Local.sampleValue &"0000") />
					<cfset Local.oldWidth  = getActiveSheet().getColumnWidth( Local.column.index) />
				    <cflog file="POI" text="Date/time #Local.column.name# #local.column.index#:: #Local.oldWidth# #local.newWidth#">
					<cfif Local.oldWidth lt Local.newWidth>
						<cfset Local.oldWidth  = getActiveSheet().setColumnWidth( Local.column.index, Local.newWidth) />
					</cfif>
				</cfif>
			</cfloop>
		</cfif>

	</cffunction>

	<cffunction name="addDelimitedRows" access="public" output="false" returntype="void"
			hint="Appends rows to a sheet from a csv string">
		<cfargument name="data" type="string" required="true" />
		<cfargument name="delimiter" type="string" default="," />

		<!--- for now only csv format is supported. one row per line (duh) --->
		<cfset Local.dataLines = arguments.data.split("\r\n|\n") />
		<cfloop from="1" to="#ArrayLen(Local.dataLines)#" index="Local.row">
			<cfset addRow( data=Local.dataLines[ Local.row ], startRow=Local.row, delimiter=arguments.delimiter ) />
		</cfloop>
	</cffunction>

	<cffunction name="deleteRow" access="public" output="false" returntype="void"
			hint="Deletes the data from a row. Does not physically delete the row.">
		<cfargument name="rowNum" type="numeric" required="true" />

		<!--- If this is a valid row, remove it --->
		<cfset Local.rowToDelete = arguments.rowNum - 1 />
		<cfif Local.rowToDelete gte getFirstRowNum() and Local.rowToDelete lte getLastRowNum() >
			<cfset getActiveSheet().removeRow( getActiveSheet().getRow(JavaCast("int", Local.rowToDelete)) ) />
		</cfif>

	</cffunction>

	<cffunction name="deleteRows" access="public" output="false" returntype="void"
			hint="Deletes a range of rows">
		<cfargument name="range" type="string" required="true" />

		<!--- Validate and extract the ranges. Range is a comma-delimited list of ranges,
			and each value can be either a single number or a range of numbers with a hyphen. --->
		<cfset Local.allRanges 	= extractRanges( arguments.range ) />
		<cfset Local.theRange 	= 0 />
		<cfset Local.i 			= 0 />

		<cfloop array="#Local.allRanges#" index="Local.theRange">
			<!--- single row number --->
			<cfif Local.theRange.startAt eq Local.theRange.endAt>
				<cfset deleteRow( Local.theRange.startAt ) />
			<cfelse>
				<!--- range of rows --->
				<cfloop index="Local.i" from="#Local.theRange.startAt#" to="#Local.theRange.endAt#">
					<cfset deleteRow( Local.i ) />
				</cfloop>
			</cfif>
		</cfloop>

	</cffunction>


	<!--- Wrapper of POI's function. As mentioned in the POI API, when getLastRowNum()
		  returns 0 it could mean two things: either the sheet is emtpy =OR= the last
		  populated row index is 0. We must call  getPhysicalNumberOfRows() to differentiate.
		  Note: getFirstRowNum() seems behave the same way with respect to 0 --->
	<cffunction name="getLastRowNum" access="private" output="false" returntype="numeric"
				Hint="Returns the last row number in the current sheet (base-0). Returns -1 if the sheet is empty">

		<cfset Local.lastRow = getActiveSheet().getLastRowNum() />
		<!--- The sheet is empty. Return -1 instead of 0 --->
		<cfif Local.lastRow eq 0 AND getActiveSheet().getPhysicalNumberOfRows() eq 0>
			<cfset Local.lastRow = -1 />
		</cfif>

		<cfreturn Local.lastRow />
	</cffunction>

	<cffunction name="getFirstRowNum" access="private" output="false" returntype="numeric"
				Hint="Returns the index of the first row in the active sheet (0-based). Returns -1 if the sheet is empty">
		<cfset Local.firstRow = getActiveSheet().getFirstRowNum() />
		<!--- The sheet is empty. Return -1 instead of 0 --->
		<cfif Local.firstRow eq 0 AND getActiveSheet().getPhysicalNumberOfRows() eq 0>
			<cfreturn -1 />
		</cfif>

		<cfreturn Local.firstRow />
	</cffunction>

	<cffunction name="getNextEmptyRow" access="private" output="false" returntype="numeric"
				Hint="Returns the index of the next empty row in the active sheet (0-based)">

		<cfreturn getLastRowNum() + 1 />
	</cffunction>

	<cffunction name="shiftRows" access="public" output="false" returntype="void"
			hint="Shifts rows up (negative integer) or down (positive integer)">
		<cfargument name="startRow" type="numeric" required="true" />
		<cfargument name="endRow" type="numeric" required="false" />
		<cfargument name="offset" type="numeric" required="false" default="1" />

		<cfif not StructKeyExists(arguments, "endRow")>
			<cfset arguments.endRow = arguments.startRow />
		</cfif>

		<cfset getActiveSheet().shiftRows(JavaCast("int", arguments.startRow - 1),
											JavaCast("int", arguments.endRow - 1),
											JavaCast("int", arguments.offset)) />
	</cffunction>

	<!--- TODO: for some reason setRowStyle() formats the empty cells but leaves the populated cells
				alone, which is exactly opposite of what we want, so looping over each populated
				cell and setting the cell format individually instead. Better way to do this? --->
	<cffunction name="formatRow" access="public" output="false" returntype="void"
			hint="Sets various formatting values on a row">
		<cfargument name="format" type="struct" required="true" />
		<cfargument name="rowNum" type="numeric" required="true" />

		<cfset Local.theRow = getActiveSheet().getRow(arguments.rowNum - 1) />
		<!--- there is nothing to do if the row does not exist ... --->
		<cfif not IsNull( Local.theRow )>
			<cfset Local.cellIterator = Local.theRow.cellIterator() />
			<cfloop condition="#Local.cellIterator.hasNext()#">
				<cfset formatCell(arguments.format, arguments.rowNum, Local.cellIterator.next().getColumnIndex() + 1) />
			</cfloop>
		</cfif>

	</cffunction>

	<cffunction name="formatRows" access="public" output="false" returntype="void"
			hint="Sets various formatting values on multiple rows">
		<cfargument name="format" type="struct" required="true" />
		<cfargument name="range" type="string" required="true" />

		<!--- Validate and extract the ranges. Range is a comma-delimited list of ranges,
			and each value can be either a single number or a range of numbers with a hyphen. --->
		<cfset Local.allRanges 	= extractRanges( arguments.range ) />
		<cfset Local.theRange 	= 0 />
		<cfset Local.i 			= 0 />

		<cfloop array="#Local.allRanges#" index="Local.theRange">
			<!--- single row number --->
			<cfif Local.theRange.startAt eq Local.theRange.endAt>
				<cfset formatRow( arguments.format, Local.theRange.startAt ) />
			<cfelse>
				<!--- range of rows --->
				<cfloop index="Local.i" from="#Local.theRange.startAt#" to="#Local.theRange.endAt#">
					<cfset formatRow( arguments.format, Local.i ) />
				</cfloop>
			</cfif>
		</cfloop>

	</cffunction>

	<cffunction name="setRowHeight" access="public" output="false" returntype="void"
			hint="Sets the height of a row in points">
		<cfargument name="row" type="numeric" required="true" />
		<cfargument name="height" type="numeric" required="true" />

		<cfset getActiveSheet().getRow(JavaCast("int", arguments.row - 1)).setHeightInPoints(JavaCast("int", arguments.height)) />
	</cffunction>


	<!--- column functions --->
	<cffunction name="autoSizeColumn" access="public" output="false" returntype="void"
				hint="Adjusts the width of the specified column to fit the contents. For performance reasons, this should normally be called only once per column. ">
		<cfargument name="column" type="numeric" required="false" />
		<cfargument name="useMergedCells" type="boolean" default="false" hint="whether to use the contents of merged cells when calculating the width of the column" />

		<cfif StructKeyExists(arguments, "column") and arguments.column lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Column Value"
						detail="The value for column must be greater than or equal to 1." />
		</cfif>

		<cfset getActiveSheet().autoSizeColumn(arguments.column -1, arguments.useMergedCells ) />
	</cffunction>

	<cffunction name="addColumn" access="public" output="false" returntype="void"
			hint="Adds a column and inserts the data provided into the new column.">
		<cfargument name="data" type="string" required="true" />
		<cfargument name="startRow" type="numeric" required="false" />
		<cfargument name="column" type="numeric" required="false" />
		<cfargument name="insert" type="boolean" required="false" default="true"
			hint="If false, will overwrite data in an existing column if one exists" />
		<cfargument name="delimiter" type="string" required="true" />

		<!--- TODO: investigate possible VAR scope issue ? --->
		<cfset Local.row 			= 0 />
		<cfset Local.cell 			= 0 />
		<cfset Local.oldCell 		= 0 />
		<cfset Local.rowNum 		= 0 />
		<cfset Local.cellNum 		= 0 />
		<cfset Local.lastCellNum 	= 0 />
		<cfset Local.i 				= 0 />
		<cfset Local.cellValue 		= 0 />

		<cfif StructKeyExists(arguments, "startRow") and arguments.startRow lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Start Row Value"
						detail="The value for start row must be greater than or equal to 1." />
		</cfif>

		<cfif StructKeyExists(arguments, "column") and arguments.column lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Column Value"
						detail="The value for column must be greater than or equal to 1." />
		</cfif>

		<cfif StructKeyExists(arguments, "startRow")>
			<cfset Local.rowNum = arguments.startRow - 1 />
		</cfif>

		<cfif StructKeyExists(arguments, "column")>
			<cfset Local.cellNum = arguments.column - 1 />
		<cfelse>

			<cfset Local.row = getActiveSheet().getRow( Local.rowNum ) />
			<!--- if this row exists, find the next empty cell number. note: getLastCellNum()
				returns the cell index PLUS ONE or -1 if not found --->
			<cfif not IsNull( Local.row ) and Local.row.getLastCellNum() gt 0>
				<cfset Local.cellNum = Local.row.getLastCellNum() />
			<cfelse>
				<cfset Local.cellNum = 0 />
			</cfif>

		</cfif>

		<cfloop list="#arguments.data#" index="Local.cellValue" delimiters="#arguments.delimiter#">
       		<!--- if rowNum is greater than the last row of the sheet, need
                                      to create a new row --->
			<cfif Local.rowNum GT getActiveSheet().getLastRowNum() OR isNull(getActiveSheet().getRow( Local.rowNum ))>

				<cfset Local.row = createRow(Local.rowNum) />

			<cfelse>
				<cfset Local.row = getActiveSheet().getRow(Local.rowNum) />
			</cfif>

			<!--- POI doesn't have any 'shift column' functionality akin to shiftRows()
					so inserts get interesting ... --->
			<!--- ** Note: row.getLastCellNum() returns the cell index PLUS ONE or -1 if not found --->
			<cfif arguments.insert and Local.cellNum lt Local.row.getLastCellNum()>
				<!--- need to get the last populated column number in the row, figure out which
						cells are impacted, and shift the impacted cells to the right to make
						room for the new data --->
				<cfset Local.lastCellNum = Local.row.getLastCellNum() />

				<cfloop index="Local.i" from="#Local.lastCellNum#" to="#Local.cellNum + 1#" step="-1">
					<cfset Local.oldCell = Local.row.getCell(JavaCast("int", Local.i - 1)) />

					<cfif not IsNull( Local.oldCell )>
						<!--- TODO: Handle other cell types ? --->
						<cfset Local.cell = createCell(Local.row, Local.i) />
						<cfset Local.cell.setCellStyle( Local.oldCell.getCellStyle() ) />
						<cfset Local.cell.setCellValue( Local.oldCell.getStringCellValue() ) />
						<cfset Local.cell.setCellComment( Local.oldCell.getCellComment() ) />
					</cfif>

				</cfloop>
			</cfif>

			<cfset cell = createCell(Local.row, Local.cellNum) />

			<cfset cell.setCellValue(JavaCast("string", Local.cellValue)) />

			<cfset Local.rowNum = Local.rowNum + 1 />
		</cfloop>
	</cffunction>

	<cffunction name="deleteColumn" access="public" output="false" returntype="void"
			hint="Deletes the data from a column. Does not physically remove the column.">
		<cfargument name="columnNum" type="numeric" required="true" />

		<cfset var rowIterator = getActiveSheet().rowIterator() />
		<cfset var row  = 0 />
		<cfset var cell = 0 />

		<cfif arguments.columnNum lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Column Value"
						detail="The value for column must be greater than or equal to 1." />
		</cfif>

		<!--- POI doesn't have remove column functionality, so iterate over all the rows
				and remove the column indicated --->
		<cfloop condition="#rowIterator.hasNext()#">
			<cfset row = rowIterator.next() />
			<cfset cell = row.getCell(JavaCast("int", arguments.columnNum - 1)) />

			<cfif not IsNull(cell)>
				<cfset row.removeCell(cell) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="deleteColumns" access="public" output="false" returntype="void"
			hint="Deletes a range of columns">
		<cfargument name="range" type="string" required="true" />

		<!--- Validate and extract the ranges. Range is a comma-delimited list of ranges,
			and each value can be either a single number or a range of numbers with a hyphen. --->
		<cfset Local.allRanges 	= extractRanges( arguments.range ) />
		<cfset Local.theRange 	= 0 />
		<cfset Local.i 			= 0 />

		<cfloop array="#Local.allRanges#" index="Local.theRange">
			<!--- single column number --->
			<cfif Local.theRange.startAt eq Local.theRange.endAt>
				<cfset deleteColumn( Local.theRange.startAt ) />
			<cfelse>
				<!--- range of columns --->
				<cfloop index="Local.i" from="#Local.theRange.startAt#" to="#Local.theRange.endAt#">
					<cfset deleteColumn( Local.i ) />
				</cfloop>
			</cfif>
		</cfloop>

	</cffunction>

	<cffunction name="shiftColumns" access="public" output="false" returntype="void"
			hint="Shifts columns left (negative integer) or right (positive integer)">
		<cfargument name="startColumn" type="numeric" required="true" />
		<cfargument name="endColumn" type="numeric" required="false" />
		<cfargument name="offset" type="numeric" required="false" default="1" />

		<cfset var rowIterator = getActiveSheet().rowIterator() />
		<cfset var row = 0 />
		<cfset var tempCell = 0 />
		<cfset var cell = 0 />
		<cfset var i = 0 />
		<cfset var numColsShifted = 0 />
		<cfset var numColsToDelete = 0 />

		<cfif arguments.startColumn lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Start Column Value"
						detail="The value for start column must be greater than or equal to 1." />
		</cfif>

		<cfif StructKeyExists(arguments, "endColumn") and
				(arguments.endColumn lte 0 or arguments.endColumn lt arguments.startColumn)>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid End Column Value"
						detail="The value of end column must be greater than or equal to the value of start column." />
		</cfif>

		<cfset arguments.startColumn = arguments.startColumn - 1 />

		<cfif not StructKeyExists(arguments, "endColumn")>
			<cfset arguments.endColumn = arguments.startColumn />
		<cfelse>
			<cfset arguments.endColumn = arguments.endColumn - 1 />
		</cfif>

		<cfloop condition="#rowIterator.hasNext()#">
			<cfset row = rowIterator.next() />

			<cfif arguments.offset gt 0>
				<cfloop index="i" from="#arguments.endColumn#" to="#arguments.startColumn#" step="-1">
					<cfset tempCell = row.getCell(JavaCast("int", i)) />
					<cfset cell = createCell(row, i + arguments.offset) />

					<cfif not IsNull(tempCell)>
						<cfset cell.setCellValue(JavaCast("string", tempCell.getStringCellValue())) />
					</cfif>
				</cfloop>
			<cfelse>
				<cfloop index="i" from="#arguments.startColumn#" to="#arguments.endColumn#" step="1">
					<cfset tempCell = row.getCell(JavaCast("int", i)) />
					<cfset cell = createCell(row, i + arguments.offset) />

					<cfif not IsNull(tempCell)>
						<cfset cell.setCellValue(JavaCast("string", tempCell.getStringCellValue())) />
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>

		<!--- clean up any columns that need to be deleted after the shift --->
		<cfset numColsShifted = arguments.endColumn - arguments.startColumn + 1 />

		<cfset numColsToDelete = Abs(arguments.offset) />

		<cfif numColsToDelete gt numColsShifted>
			<cfset numColsToDelete = numColsShifted />
		</cfif>

		<cfif arguments.offset gt 0>
			<cfloop index="i" from="#arguments.startColumn#" to="#arguments.startColumn + numColsToDelete - 1#">
				<cfset deleteColumn(i + 1) />
			</cfloop>
		<cfelse>
			<cfloop index="i" from="#arguments.endColumn#" to="#arguments.endColumn - numColsToDelete + 1#" step="-1">
				<cfset deleteColumn(i + 1) />
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="formatCell" access="public" output="false" returntype="void"
			hint="Sets various formatting values on a single cell">
		<cfargument name="format" type="struct" required="true" />
		<cfargument name="row" type="numeric" required="true" />
		<cfargument name="column" type="numeric" required="true" />
		<cfargument name="cellStyle" type="any" required="false" Hint="Existing cellStyle to reusue" />

		<!--- Automatically create the cell if it does not exist, instead of throwing an error --->
		<cfset Local.cell = initializeCell( arguments.row, arguments.column ) />

		<cfif structKeyExists(arguments, "cellStyle")>
			<!--- reuse an existing style --->
			<cfset Local.cell.setCellStyle( arguments.cellStyle ) />
		<cfelse>
			<!--- create a new style --->
			<cfset Local.cell.setCellStyle( buildCellStyle(arguments.format) ) />
		</cfif>
 	</cffunction>

	<cffunction name="clearCellRange" access="public" output="false" returntype="void"
			hint="Clears the specified cell range of all styles and values">
		<cfargument name="startRow" type="numeric" required="true" />
		<cfargument name="startColumn" type="numeric" required="true" />
		<cfargument name="endRow" type="numeric" required="true" />
		<cfargument name="endColumn" type="numeric" required="true" />

		<cfset Local.rowNum = 0 />
		<cfset Local.colNum = 0 />

		<cfloop from="#arguments.startRow#" to="#arguments.endRow#" index="Local.rowNum">
			<cfloop from="#arguments.startColumn#" to="#arguments.endColumn#" index="Local.colNum">
				<cfset clearCell( Local.rowNum, Local.colNum ) />
			</cfloop>
		</cfloop>

	</cffunction>

	<cffunction name="clearCell" access="public" output="false" returntype="void"
			hint="Clears the specified cell of all styles and values">
		<cfargument name="row" type="numeric" required="true" />
		<cfargument name="column" type="numeric" required="true" />

		<cfset Local.defaultStyle  = getWorkBook().getCellStyleAt( javacast("short", 0) ) />
		<cfset Local.rowObj	 =  getWorkBook().getRow( javaCast("int", arguments.row - 1)) />

		<cfif not IsNull(Local.rowObj)>
			<cfset Local.cell =  Local.rowObj.getCell( javaCast("int", arguments.column - 1) ) />
			<cfif not IsNull(Local.cell)>
				<cfset Local.cell.setCellStyle( Local.defaultStyle ) />
				<cfset Local.cell.setCellType( Local.cell.CELL_TYPE_BLANK ) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="formatCellRange" access="public" output="false" returntype="void"
			hint="Applies formatting to a contigous range of cells">
		<cfargument name="format" type="struct" required="true" />
		<cfargument name="startRow" type="numeric" required="true" />
		<cfargument name="startColumn" type="numeric" required="true" />
		<cfargument name="endRow" type="numeric" required="true" />
		<cfargument name="endColumn" type="numeric" required="true" />

		<cfset Local.rowNum = 0 />
		<cfset Local.colNum = 0 />
		<cfset Local.style  = buildCellStyle(arguments.format) />

		<cfloop from="#arguments.startRow#" to="#arguments.endRow#" index="Local.rowNum">
			<cfloop from="#arguments.startColumn#" to="#arguments.endColumn#" index="Local.colNum">
				<cfset formatCell( arguments.format, Local.rowNum, Local.colNum, Local.style) />
			</cfloop>
		</cfloop>

	</cffunction>

	<cffunction name="formatColumn" access="public" output="false" returntype="void"
			hint="Sets various formatting values on a column">
		<cfargument name="format" type="struct" required="true" />
		<cfargument name="column" type="numeric" required="true" />

		<cfset var rowIterator = getActiveSheet().rowIterator() />

		<cfif arguments.column lte 0>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Column Value"
						detail="The column value must be greater than 0." />
		</cfif>

		<cfloop condition="#rowIterator.hasNext()#">
			<!--- Note: If the cells are not contigous, this will create the missing cells ie fill in the gaps --->
			<cfset formatCell(arguments.format, rowIterator.next().getRowNum() + 1, arguments.column) />
		</cfloop>
	</cffunction>

	<cffunction name="formatColumns" access="public" output="false" returntype="void"
			hint="Sets various formatting values on multiple columns">
		<cfargument name="format" type="struct" required="true" />
		<cfargument name="range" type="string" required="true" />

		<cfset var rangeValue = 0 />
		<cfset var rangeTest = "^[0-9]{1,}(-[0-9]{1,})?$">
		<cfset var i = 0 />

		<cfloop list="#arguments.range#" index="rangeValue">
			<cfif REFind(rangeTest, rangeValue) eq 0>
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
							message="Invalid Range Value"
							detail="The range value #rangeValue# is not valid." />
			<cfelse>
				<cfif ListLen(rangeValue, "-") eq 2>
					<cfloop index="i" from="#ListGetAt(rangeValue, 1, '-')#" to="#ListGetAt(rangeValue, 2, '-')#">
						<cfset formatColumn(arguments.format, i) />
					</cfloop>
				<cfelse>
					<cfset formatColumn(arguments.format, rangeValue) />
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="getCellComment" access="public" output="false" returntype="any"
			hint="Returns a struct containing comment info (author, column, row, and comment) for a specific cell, or an array of structs containing the comments for the entire sheet">
		<cfargument name="row" type="numeric" required="false" />
		<cfargument name="column" type="numeric" required="false" />

		<cfset var comment = 0 />
		<cfset var theComment = 0 />
		<cfset var comments = StructNew() />
		<cfset var rowIterator = 0 />
		<cfset var cellIterator = 0 />
		<cfset var cell = 0 />

		<cfif (StructKeyExists(arguments, "row") and not StructKeyExists(arguments, "column"))
				or (StructKeyExists(arguments, "column") and not StructKeyExists(arguments, "row"))>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Argument Combination"
						detail="If row or column is passed to getCellComment, both row and column must be provided." />
		</cfif>

		<cfif StructKeyExists(arguments, "row")>
			<!--- validate and retrieve the requested cell. note: row and column values are 1-based  --->
			<cfset cell = getCellAt( JavaCast("int", arguments.row), JavaCast("int", arguments.column) ) />

			<cfset comment = cell.getCellComment() />
			<!--- Comments may be null. So we must verify it exists before accessing it --->
			<cfif not IsNull( comment )>
				<cfset comments.author = comment.getAuthor() />
				<cfset comments.column = arguments.column />
				<cfset comments.comment = comment.getString().getString() />
				<cfset comments.row = arguments.row />
			</cfif>
		<cfelse>
			<!--- TODO: Look into checking all sheets in the workbook --->
			<!--- row and column weren't provided so loop over the whole shooting match and get all the comments --->
			<cfset comments = ArrayNew(1) />
			<cfset rowIterator = getActiveSheet().rowIterator() />

			<cfloop condition="#rowIterator.hasNext()#">
				<cfset cellIterator = rowIterator.next().cellIterator() />

				<cfloop condition="#cellIterator.hasNext()#">
					<cfset comment = cellIterator.next().getCellComment() />

					<!--- Comments may be null. So we must verify it exists before accessing it --->
					<cfif not IsNull( comment )>
						<cfset theComment = StructNew() />
						<cfset theComment.author = comment.getAuthor() />
						<cfset theComment.column = comment.getColumn() + 1 />
						<cfset theComment.comment = comment.getString().getString() />
						<cfset theComment.row = comment.getRow() + 1 />

						<cfset ArrayAppend(comments, theComment) />
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>

		<cfreturn comments />
	</cffunction>

	<cffunction name="setCellComment" access="public" output="false" returntype="void"
			hint="Sets a cell comment">
		<cfargument name="comment" type="struct" required="true" />
		<cfargument name="row" type="numeric" required="true" />
		<cfargument name="column" type="numeric" required="true" />

		<!---
			The comment struct may contain the following keys:
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

		<!--- <cfset var creationHelper = getWorkbook().getCreationHelper() /> --->
		<cfset var drawingPatriarch = getActiveSheet().createDrawingPatriarch() />
		<cfset var clientAnchor = 0 />
		<cfset var commentObj = 0 />
		<cfset var commentString = loadPoi("org.apache.poi.hssf.usermodel.HSSFRichTextString").init(JavaCast("string", arguments.comment.comment)) />
		<cfset var font = 0 />
		<cfset var javaColorRGB = 0 />
		<cfset var cell = 0 />

		<!--- make sure the cell exists before proceeding. note: row and column values are 1-based
		<cfset var cell = getCellAt( JavaCast("int", arguments.row ), JavaCast("int", arguments.column ) ) /> --->

		<cfif StructKeyExists(arguments.comment, "anchor")>
			<cfset clientAnchor = loadPoi("org.apache.poi.hssf.usermodel.HSSFClientAnchor").init(JavaCast("int", 0),
																												JavaCast("int", 0),
																													JavaCast("int", 0),
																													JavaCast("int", 0),
																													JavaCast("int", ListGetAt(arguments.comment.anchor, 1)),
																													JavaCast("int", ListGetAt(arguments.comment.anchor, 2)),
																													JavaCast("int", ListGetAt(arguments.comment.anchor, 3)),
																													JavaCast("int", ListGetAt(arguments.comment.anchor, 4))) />
		<cfelse>
			<!--- if no anchor is provided, just use + 2 --->
			<cfset clientAnchor = loadPoi("org.apache.poi.hssf.usermodel.HSSFClientAnchor").init(JavaCast("int", 0),
																													JavaCast("int", 0),
																													JavaCast("int", 0),
																													JavaCast("int", 0),
																													JavaCast("int", arguments.column),
																													JavaCast("int", arguments.row),
																													JavaCast("int", arguments.column + 2),
																													JavaCast("int", arguments.row + 2)) />
		</cfif>

		<cfset commentObj = drawingPatriarch.createComment(clientAnchor) />

		<cfif StructKeyExists(arguments.comment, "author")>
			<cfset commentObj.setAuthor(JavaCast("string", arguments.comment.author)) />
		</cfif>

		<!--- If we're going to do anything font related, need to create a font.
				Didn't really want to create it above since it might not be needed. --->
		<cfif StructKeyExists(arguments.comment, "bold")
					or StructKeyExists(arguments.comment, "color")
					or StructKeyExists(arguments.comment, "font")
					or StructKeyExists(arguments.comment, "italic")
					or StructKeyExists(arguments.comment, "size")
					or StructKeyExists(arguments.comment, "strikeout")
					or StructKeyExists(arguments.comment, "underline")>
			<cfset font = getWorkbook().createFont() />

			<cfif StructKeyExists(arguments.comment, "bold")>
				<cfif arguments.comment.bold>
					<cfset font.setBoldweight(font.BOLDWEIGHT_BOLD) />
				<cfelse>
					<cfset font.setBoldweight(font.BOLDWEIGHT_NORMAL) />
				</cfif>
			</cfif>

			<cfif StructKeyExists(arguments.comment, "color")>
				<cfset font.setColor(JavaCast("int", getColorIndex(arguments.comment.color))) />
			</cfif>

			<cfif StructKeyExists(arguments.comment, "font")>
				<cfset font.setFontName(JavaCast("string", arguments.comment.font)) />
			</cfif>

			<cfif StructKeyExists(arguments.comment, "italic")>
				<cfset font.setItalic(JavaCast("boolean", arguments.comment.italic)) />
			</cfif>

			<cfif StructKeyExists(arguments.comment, "size")>
				<cfset font.setFontHeightInPoints(JavaCast("int", arguments.comment.size)) />
			</cfif>

			<cfif StructKeyExists(arguments.comment, "strikeout")>
				<cfset font.setStrikeout(JavaCast("boolean", arguments.comment.strikeout)) />
			</cfif>

			<cfif StructKeyExists(arguments.comment, "underline")>
				<cfset font.setUnderline(JavaCast("boolean", arguments.comment.underline)) />
			</cfif>

			<cfset commentString.applyFont(font) />
		</cfif>

		<cfif StructKeyExists(arguments.comment, "fillcolor")>
			<cfset javaColorRGB = getJavaColorRGB(arguments.comment.fillcolor) />
			<cfset commentObj.setFillColor(JavaCast("int", javaColorRGB.red),
											JavaCast("int", javaColorRGB.green),
											JavaCast("int", javaColorRGB.blue)) />
		</cfif>

		<!---- Horizontal alignment can be left, center, right, justify, or distributed.
				Note that the constants on the Java class are slightly different in some cases:
				'center' = CENTERED
				'justify' = JUSTIFIED --->
		<cfif StructKeyExists(arguments.comment, "horizontalalignment")>
			<cfif UCase(arguments.comment.horizontalalignment) eq "CENTER">
				<cfset arguments.comment.horizontalalignment = "CENTERED" />
			</cfif>

			<cfif UCase(arguments.comment.horizontalalignment) eq "JUSTIFY">
				<cfset arguments.comment.horizontalalignment = "JUSTIFIED" />
			</cfif>

			<cfset commentObj.setHorizontalAlignment(JavaCast("int", Evaluate("commentObj.HORIZONTAL_ALIGNMENT_#UCase(arguments.comment.horizontalalignment)#"))) />
		</cfif>

		<!--- Valid values for linestyle are:
				* solid
				* dashsys
				* dashdotsys
				* dashdotdotsys
				* dotgel
				* dashgel
				* longdashgel
				* dashdotgel
				* longdashdotgel
				* longdashdotdotgel
		--->
		<cfif StructKeyExists(arguments.comment, "linestyle")>
			<cfset commentObj.setLineStyle(JavaCast("int", Evaluate("commentObj.LINESTYLE_#UCase(arguments.comment.linestyle)#"))) />
		</cfif>

		<!--- TODO: This doesn't seem to be working (no error, but doesn't do anything).
					Saw reference on the POI mailing list to this not working but it was
					from over a year ago; maybe it's just still broken.  --->
		<cfif StructKeyExists(arguments.comment, "linestylecolor")>
			<cfset javaColorRGB = getJavaColorRGB(arguments.comment.fillcolor) />
			<cfset commentObj.setLineStyleColor(JavaCast("int", javaColorRGB.red),
												JavaCast("int", javaColorRGB.green),
												JavaCast("int", javaColorRGB.blue)) />
		</cfif>

		<!--- Vertical alignment can be top, center, bottom, justify, and distributed.
				Note that center and justify are DIFFERENT than the constants for
				horizontal alignment, which are CENTERED and JUSTIFIED. --->
		<cfif StructKeyExists(arguments.comment, "verticalalignment")>
			<cfset commentObj.setVerticalAlignment(JavaCast("int", Evaluate("commentObj.VERTICAL_ALIGNMENT_#UCase(arguments.comment.verticalalignment)#"))) />
		</cfif>

		<cfif StructKeyExists(arguments.comment, "visible")>
			<cfset commentObj.setVisible(JavaCast("boolean", arguments.comment.visible)) />
		</cfif>

		<cfset commentObj.setString(commentString) />
		<!--- Automatically create the cell if it does not exist, instead of throwing an error --->
		<cfset cell = initializeCell( row=arguments.row, column=arguments.column ) />
		<cfset cell.setCellComment(commentObj) />
	</cffunction>

	<cffunction name="getCellFormula" access="public" output="false" returntype="any"
			hint="Returns the formula for a cell or for the entire spreadsheet">
		<cfargument name="row" type="numeric" required="false" />
		<cfargument name="column" type="numeric" required="false" />

		<cfset var formulaStruct = 0 />
		<cfset var formulas  = 0 />
		<cfset var rowIterator = 0 />
		<cfset var cellIterator = 0 />
		<cfset var cell = 0 />

		<!--- if row and column are passed in, return the formula for a single cell as a string --->
		<cfif StructKeyExists(arguments, "row") and StructKeyExists(arguments, "column")>
			<!--- if the cell/formula does not exist, just return an empty string --->
			<cfset formulas = "" />

			<!--- if we have got the right cell type, grab the formula  --->
			<cfif cellExists( argumentCollection=arguments )>
				<cfset cell = getCellAt( argumentCollection=arguments ) />
				<cfif cell.getCellType() eq cell.CELL_TYPE_FORMULA>
					<cfset formulas = cell.getCellFormula() />
				</cfif>
			</cfif>

		<cfelse>
			<!--- no row and column provided so return an array of structs containing formulas
					for the entire sheet --->
			<cfset rowIterator = getActiveSheet().rowIterator() />
			<cfset formulas = ArrayNew(1) />

			<cfloop condition="#rowIterator.hasNext()#">
				<cfset cellIterator = rowIterator.next().cellIterator() />

				<cfloop condition="#cellIterator.hasNext()#">
					<cfset cell = cellIterator.next() />

					<cfset formulaStruct = StructNew() />
					<cfset formulaStruct.row = cell.getRowIndex() + 1 />
					<cfset formulaStruct.column = cell.getColumnIndex() + 1 />

					<cftry>
						<cfset formulaStruct.formula = cell.getCellFormula() />
						<cfcatch type="any">
							<cfset formulaStruct.formula = "" />
						</cfcatch>
					</cftry>

					<cfif formulaStruct.formula neq "">
						<cfset ArrayAppend(formulas, formulaStruct) />
					</cfif>
				</cfloop>
			</cfloop>

		</cfif>

		<cfreturn formulas />
	</cffunction>

	<cffunction name="setCellFormula" access="public" output="false" returntype="void"
			hint="Sets the formula for a cell">
		<cfargument name="formula" type="string" required="true" />
		<cfargument name="row" type="numeric" required="true" />
		<cfargument name="column" type="numeric" required="true" />

		<!--- Automatically create the cell if it does not exist, instead of throwing an error --->
		<cfset Local.cell = initializeCell( row=arguments.row, column=arguments.column ) />

		<cfset Local.cell.setCellFormula( JavaCast("string", arguments.formula) ) />
	</cffunction>

	<cffunction name="getCellValue" access="public" output="false" returntype="string"
			hint="Returns the value of a single cell">
		<cfargument name="row" type="numeric" required="true" />
		<cfargument name="column" type="numeric" required="true" />


		<!--- If the row/cell does not exist just return an emtpy string --->
		<cfset Local.result = "" />

		<cfif cellExists( argumentCollection=arguments )>
			<cfset Local.row    = getActiveSheet().getRow( javaCast("int", arguments.row - 1)) />
			<cfset Local.cell   = Local.row.getCell( javaCast("int", arguments.column - 1) ) />

			<cfif Local.cell.getCellType() eq Local.cell.CELL_TYPE_FORMULA>
				<!--- evaluate the formula --->
				<cfset Local.result = getFormatter().formatCellValue(Local.Cell, getEvaluator()) />
			<cfelse>
				<!--- otherwise, return the formatted value as a string --->
				<cfset Local.result = getFormatter().formatCellValue(Local.Cell) />
			</cfif>
		</cfif>

		<cfreturn Local.result />
		<!---
		<!--- TODO: need to worry about additional cell types? --->
                        CellFormat cf = CellFormat.getInstance(
                                style.getDataFormatString());
                        CellFormatResult result = cf.apply(cell);
		<cfswitch expression="#getActiveSheet().getRow(JavaCast('int', arguments.row - 1)).getCell(JavaCast('int', arguments.column - 1)).getCellType()#">
			<!--- numeric or formula --->
			<cfcase value="0,2" delimiters=",">
				<cfset Local.returnVal = getActiveSheet().getRow(JavaCast("int", arguments.row - 1)).getCell(JavaCast("int", arguments.column - 1)).getNumericCellValue() />
			</cfcase>

			<!--- string --->
			<cfcase value="1">
				<cfset Local.returnVal = getActiveSheet().getRow(JavaCast("int", arguments.row - 1)).getCell(JavaCast("int", arguments.column - 1)).getStringCellValue() />
			</cfcase>
		</cfswitch>

		<cfreturn Local.returnVal />
		---->
	</cffunction>

	<cffunction name="setCellValue" access="public" output="false" returntype="void"
			hint="Sets the value of a single cell">
		<cfargument name="cellValue" type="string" required="true" />
		<cfargument name="row" type="numeric" required="true" />
		<cfargument name="column" type="numeric" required="true" />

		<!--- Automatically create the cell if it does not exist, instead of throwing an error --->
		<cfset Local.cell = initializeCell( row=arguments.row, column=arguments.column ) />

		<!--- TODO: need to worry about data types? doing everything as a string for now --->
		<cfset Local.cell.setCellValue( JavaCast("string", arguments.cellValue) ) />
	</cffunction>

	<cffunction name="setColumnWidth" access="public" output="false" returntype="void"
			hint="Sets the width of a column">
		<cfargument name="column" type="numeric" required="true" />
		<cfargument name="width" type="numeric" required="true" />

		<cfset getActiveSheet().setColumnWidth(JavaCast("int", arguments.column - 1), JavaCast("int", arguments.width * 256)) />
	</cffunction>

	<cffunction name="mergeCells" access="public" output="false" returntype="void"
			hint="Merges two or more cells">
		<cfargument name="startRow" type="numeric" required="true" />
		<cfargument name="endRow" type="numeric" required="true" />
		<cfargument name="startColumn" type="numeric" required="true" />
		<cfargument name="endColumn" type="numeric" required="true" />

		<cfif arguments.startRow lt 1 or arguments.startRow gt arguments.endRow>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
					message="Invalid StartRow or EndRow"
					detail="Row values must be greater than 0 and the StartRow cannot be greater than the EndRow." />
		</cfif>

		<cfif arguments.startColumn lt 1 or arguments.startColumn gt arguments.endColumn>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
					message="Invalid StartColumn or EndColumn"
					detail="Column values must be greater than 0 and the StartColumn cannot be greater than the EndColumn." />
		</cfif>

		<cfset var cellRangeAddress = loadPoi("org.apache.poi.ss.util.CellRangeAddress").init(JavaCast("int", arguments.startRow - 1),
																											JavaCast("int", arguments.endRow - 1),
																											JavaCast("int", arguments.startColumn - 1),
																											JavaCast("int", arguments.endColumn - 1)) />

		<cfset getActiveSheet().addMergedRegion(cellRangeAddress) />
	</cffunction>

	<!--- Retrieves the requested cell. Generates a user friendly error
		when an invalid cell position is specified --->
	<cffunction name="getCellAt" access="private" output="false" returntype="any"
				Hint="Returns the cell at the given position. Throws exception if the cell does not exist.">
		<cfargument name="row" type="numeric" required="true" Hint="Row index of cell to retrieve ( 1-based !)"/>
		<cfargument name="column" type="numeric" required="true" Hint="Column index of cell to retrieve ( 1-based !)"/>

		<!--- Do not continue if the cell does not exist --->
		<cfif not cellExists( argumentCollection=arguments )>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
					message="Invalid Cell"
					detail="The requested cell [#arguments.row#, #arguments.column#] does not exist in the active sheet" />
		</cfif>

		<!--- Otherwise, it is safe to return the requested cell --->
		<cfreturn getActiveSheet().getRow( JavaCast("int", arguments.row - 1) ).getCell( JavaCast("int", arguments.column - 1) ) />
	</cffunction>

	<cffunction name="initializeCell" access="private" output="false" returntype="any"
				Hint="Returns the cell at the given position. Creates the row and cell if either does not already exist.">
		<cfargument name="row" type="numeric" required="true" Hint="Row index of cell to retrieve ( 1-based !)"/>
		<cfargument name="column" type="numeric" required="true" Hint="Column index of cell to retrieve ( 1-based !)"/>

		<cfif (arguments.row lte 0) or (arguments.column lte 0)>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
					message="Invalid Row or Column Index"
					detail="Both the row [#arguments.row#] and column [#arguments.column#] values must be greater than zero." />
		</cfif>

		<!--- convert positions to (0-base) --->
		<cfset Local.jRow 	 =  JavaCast("int", arguments.row - 1) />
		<cfset Local.jColumn =  JavaCast("int", arguments.column - 1) />

		<!--- get the desired row/cell. initialize them if they do not already exist ... --->
		<cfset Local.rowObj  = getCellUtil().getRow( Local.jRow, getActiveSheet() ) />
		<cfset Local.cellObj = getCellUtil().getCell( Local.rowObj, Local.jColumn ) />

		<cfreturn Local.cellObj />
	</cffunction>

	<cffunction name="cellExists" access="private" output="false" returntype="boolean"
				Hint="Returns true if the requested cell exists">
		<cfargument name="row" type="numeric" required="true" Hint="Row index of cell to retrieve ( 1-based !)"/>
		<cfargument name="column" type="numeric" required="true" Hint="Col index of cell to retrieve ( 1-based !)"/>

		<cfset Local.checkRow = getActiveSheet().getRow( JavaCast("int", arguments.row - 1) ) />
		<cfif IsNull( Local.checkRow ) or IsNull( Local.checkRow.getCell( JavaCast("int", arguments.column - 1) ) )>
				<cfreturn false />
		</cfif>

		<cfreturn true />
	</cffunction>

	<!--- LOWER-LEVEL SPREADSHEET MANIPULATION FUNCTIONS --->
	<cffunction name="createRow" access="public" output="false" returntype="any"
			hint="Creates a new row in the sheet and returns the row">
		<cfargument name="rowNum" type="numeric" required="false" />
		<cfargument name="overwrite" type="boolean" default="true" />

		<!--- if rowNum is provided and is lte the last row number,
				need to shift existing rows down by 1 --->
		<cfif not StructKeyExists(arguments, "rowNum")>
			<!--- If a row number was not supplied, move to the next empty row --->
			<cfset arguments.rowNum = getNextEmptyRow() />

		<!--- TODO: need to revisit this; this isn't quite the behavior necessary, but
					leaving it out for now is fine
		 <cfelse>
			<cfif arguments.rowNum lte getActiveSheet().getLastRowNum()>
				<cfset shiftRows(arguments.rowNum, getActiveSheet().getLastRowNum()) />
			</cfif> --->
		</cfif>

		<!--- get existing row (if any) --->
		<cfset Local.row = getActiveSheet().getRow(JavaCast("int", arguments.rowNum)) />

		<cfif arguments.overwrite and not IsNull(Local.row)>
			<!--- forcibly remove existing row and all cells --->
			<cfset getActiveSheet().removeRow( Local.row) />
		</cfif>

		<cfif arguments.overwrite OR IsNull(getActiveSheet().getRow(JavaCast("int", arguments.rowNum)))>
			<cfset Local.row = getActiveSheet().createRow(JavaCast("int", arguments.rowNum)) />
		</cfif>

		<cfreturn Local.row />
	</cffunction>

	<!--- TODO: POI supports setting the cell type when the cell is created. Need to worry about this? --->
	<cffunction name="createCell" access="public" output="false" returntype="any"
		hint="Creates a new cell in a row and returns the cell">
		<cfargument name="row" type="any" required="true" />
		<cfargument name="cellNum" type="numeric" required="false" />
		<cfargument name="overwrite" type="boolean" default="true" />

		<cfif not StructKeyExists(arguments, "cellNum")>
			<cfset arguments.cellNum = arguments.row.getLastCellNum() />
		</cfif>

		<!--- get existing cell (if any) --->
		<cfset Local.cell = arguments.row.getCell(JavaCast("int", arguments.cellNum)) />

		<cfif arguments.overwrite AND NOT IsNull(Local.cell)>
			<!--- forcibly remove the existing cell --->
			<cfset arguments.row.removeCell( Local.cell ) />
		</cfif>

		<cfif arguments.overwrite OR IsNull( Local.cell )>
			<!--- create a brand new cell --->
			<cfset Local.cell = arguments.row.createCell(JavaCast("int", arguments.cellNum)) />
		</cfif>

		<cfreturn Local.cell />
	</cffunction>

	<!--- GET/SET FUNCTIONS FOR INTERNAL USE AND USING THIS CFC WITHOUT THE CORRESPONDING CUSTOM TAG --->
	<cffunction name="setWorkbook" access="public" output="false" returntype="void">
		<cfargument name="workbook" type="any" required="true" />
		<cfset variables.workbook = arguments.workbook />

		<!--- Makes sure summary properties are initialized. This will prevent
			  errors when addInfo() or getInfo() is called on brand new workbooks.
			  Since this method allows the workbook to be swapped, without going through init(),
			  we're doing the intialization here to ensure it's *always* called
		 --->
		<cfif isBinaryFormat()>
			<cfset getWorkBook().createInformationProperties() />
		</cfif>
	</cffunction>

	<cffunction name="getWorkbook" access="public" output="false" returntype="any">
		<cfreturn variables.workbook />
	</cffunction>

	<cffunction name="setActiveSheet" access="public" output="false" returntype="void"
			hint="Sets the active sheet within the workbook, either by name or by index">
		<cfargument name="sheetName" type="string" required="false" />
		<cfargument name="sheetIndex" type="numeric" required="false" />

		<!--- verify we have sufficient arguments --->
		<cfset validateSheetNameOrIndexWasProvided( argumentCollection=arguments ) />

		<cfif StructKeyExists(arguments, "sheetName")>
			<cfset validateSheetName( arguments.sheetName ) />
			<cfset arguments.sheetIndex = getWorkbook().getSheetIndex(JavaCast("string", arguments.sheetName)) + 1 / >
		</cfif>

		<!--- verify the sheet exists --->
		<cfset validateSheetIndex( arguments.sheetIndex ) />
		<cfset getWorkbook().setActiveSheet(JavaCast("int", arguments.sheetIndex - 1)) />

	</cffunction>

	<cffunction name="getActiveSheet" access="public" output="false" returntype="any">
		<cfreturn getWorkbook().getSheetAt(JavaCast("int", getWorkbook().getActiveSheetIndex())) />
	</cffunction>

	<cffunction name="sheetExists" access="private" output="false" returntype="boolean"
			hint="Returns true if the requested SheetName or Sheet (position) exists">
		<cfargument name="sheetName" type="string" required="false" />
		<cfargument name="sheetIndex" type="numeric" required="false" Hint="Sheet position (1-based)"/>

		<cfset validateSheetNameOrIndexWasProvided( argumentCollection=arguments ) />

		<!--- convert the name to a 1-based sheet index --->
		<cfif StructKeyExists(arguments, "sheetName")>
			<cfset arguments.sheetIndex = getWorkBook().getSheetIndex( javaCast("string", arguments.sheetName) ) + 1 />
		</cfif>

		<!--- the position is valid if it an integer between 1 and the total number of sheets in the workbook --->
		<cfif arguments.sheetIndex gt 0
					and arguments.sheetIndex eq round(arguments.sheetIndex)
					and arguments.sheetIndex lte getWorkBook().getNumberOfSheets() >

			<cfreturn true />
		</cfif>

		<cfreturn false />
	</cffunction>

	<!--- PRIVATE FUNCTIONS --->

	<!--- Note: XML format is not fully supported yet  --->
	<cffunction name="createWorkBook" access="private" output="false" returntype="any"
				Hint="This function creates and returns a new POI Workbook with one blank Sheet">
		<cfargument name="sheetName" type="string" default="Sheet1" Hint="Name of the initial Sheet. Default name is 'Sheet1'" />
		<cfargument name="useXMLFormat" type="boolean" default="false" Hint="If true, returns type XSSFWorkbook (xml). Otherwise, returns an HSSFWorkbook (binary)"/>

		<cfset var newWorkbook = "" />

		<!--- Create an xml workbook ie *.xlsx --->
		<cfif arguments.useXMLFormat>
			<cfset newWorkBook = loadPOI("org.apache.poi.xssf.usermodel.XSSFWorkbook").init() />
		<!--- Otherwise, create a binary ie *.xls workbook --->
		<cfelse>
			<cfset newWorkBook = loadPOI("org.apache.poi.hssf.usermodel.HSSFWorkbook").init() />
		</cfif>

		<cfreturn newWorkBook />
	</cffunction>

	<!--- TODO: Validate sheet names for bad characters --->
	<cffunction name="createSheet" access="public" output="false" returntype="any"
				Hint="Adds a new Sheet to the current workbook and returns it. Throws an error if the Sheet name is invalid or already exists">
		<cfargument name="sheetName" type="string" required="false" Hint="Name of the new sheet" />
		<cfargument name="nameConflict" type="string" default="error" Hint="Action to take if the sheet name already exists: overwrite or error (default)" />

		<cfif len(arguments.sheetName) gt 31>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
					message="Invalid Sheet Name"
					detail="The supplied sheet name is too long [#len(arguments.sheetName)#]. The maximum length is 31 characters." />
		</cfif>


		<cfif structKeyExists(arguments, "sheetName")>
			<cfset Local.newSheetName = arguments.sheetName />
		<cfelse>
			<cfset Local.newSheetName = generateUniqueSheetName() />
		</cfif>

		<!--- If this sheet name is already in use ... --->
		<cfset Local.sheetNum = getWorkBook().getSheetIndex( javacast("string", Local.newSheetName) ) + 1 />
		<!--- Workaround for POI bug that returns wrong index for "Sheet1" with empty workbooks --->
		<cfif Local.sheetNum gt 0 and getWorkBook().getNumberOfSheets() eq 0>
			<cfset Local.sheetNum = 0 />
		</cfif>

		<!--- If this sheet name is already in use ... --->
		<cfif Local.sheetNum gt 0>

			<!--- Replace the existing sheet --->
			<cfif arguments.nameConflict eq "overwrite">
				<cfset deleteSheetAt( Local.sheetNum ) />

			<cfelse>
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Sheet Name"
						detail="The Workbook already contains a sheet named [#arguments.sheetName#]" />
			</cfif>

		</cfif>

		<cfset Local.newSheet = getWorkBook().createSheet( javaCast("String", Local.newSheetName) ) />

		<!--- if overwriting, restore the sheet to its previous position --->
		<cfif Local.sheetNum gt 0 and arguments.nameConflict eq "overwrite">
			<cfset moveSheet( Local.newSheetName, Local.sheetNum ) />
		</cfif>

		<cfreturn Local.newSheet />

	</cffunction>

	<!--- The reason we need this function is because POI does not verify sheet
		names are unique when you call createSheet() without a sheet name. Also POI's
		sheet names	are 0-based. For ACF compatibility they should be 1-based (ie Sheet1 versus Sheet0 ) --->
	<cffunction name="generateUniqueSheetName" access="private" output="false" returntype="string"
				hint="Generates a unique sheet name (Sheet1, Sheet2, etecetera).">

		<cfset Local.startNum  		= getWorkBook().getNumberOfSheets() + 1 />
		<cfset Local.maxRetry  		= Local.startNum + 250 />

		<!--- Try and generate a unique sheet name using the convetion: Sheet1, Sheet2, SheetX ... --->
		<cfloop from="#Local.startNum#" to="#Local.maxRetry#" index="Local.sheetNum">

			<cfset Local.proposedName = "Sheet"& Local.sheetNum />
			<!--- we found an available sheet name --->
			<cfif getWorkBook().getSheetIndex( Local.proposedName ) lt 0>
				<cfreturn Local.proposedName />
			</cfif>

		</cfloop>

		<!--- this should never happen. but if for some reason it did,
			warn the action failed and abort ... --->
		<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
				message="Unable to generate name"
				detail="Unable to generate a unique sheet name" />
	</cffunction>

	<cffunction name="moveSheet" access="public" output="false" returntype="void"
				Hint="Moves a Sheet Name to the given position">
		<cfargument name="sheetName" type="string" required="true" Hint="Name of the sheet to move" />
		<cfargument name="sheet" type="numeric" required="true" Hint="Move the sheet to this position" />


		<!--- First make sure the sheet exists and the target position is within range --->
		<cfset validateSheetName( arguments.sheetName ) />
		<cfset validateSheetIndex( arguments.sheet ) />

		<cfset Local.moveToIndex = arguments.sheet - 1 />
		<cfset getWorkBook().setSheetOrder( javaCast("String", arguments.sheetName),
											javaCast("int", Local.moveToIndex) ) />
	</cffunction>

	<cffunction name="deleteSheet" access="public" output="false" returntype="void"
				Hint="Removes the requested sheet. Throws an error if the sheet name or index is invalid -OR- if it is the last sheet in the workbook.">
		<cfargument name="sheetName" type="string" required="false" Hint="Name of the sheet to remove" />
		<cfargument name="sheetIndex" type="numeric" required="false" Hint="Position of the sheet to remove" />

		<cfset Local.removeSheetNum 	 = 0 />

		<cfset validateSheetNameOrIndexWasProvided( argumentCollection=arguments ) />

		<!--- Convert the sheet name into an index (1-based) --->
		<cfif structKeyExists(arguments, "sheetName")>
			<cfset validateSheetName( arguments.sheetName ) />
			<cfset Local.removeSheetNum = getWorkBook().getSheetIndex( sheetName ) + 1 />
		</cfif>

		<cfif structKeyExists(arguments, "sheetIndex")>
			<cfset validateSheetIndex( arguments.sheetIndex ) />
			<cfset Local.removeSheetNum = arguments.sheetIndex />
		</cfif>

		<!--- Do not allow all of the sheets to be deleted, or the component will not function properly --->
		<cfif getWorkBook().getNumberOfSheets() lte 1>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
					message="Invalid Action"
					detail="Workbooks must always contain at least one sheet." />
		</cfif>

		<!--- NOTE: If this sheet is currently active/selected POI automatically activates/selects
			another sheet. Either the next sheet OR the last sheet in the workbook.
			--->
		<cfset deleteSheetAt( Local.removeSheetNum ) />

	</cffunction>

	<cffunction name="deleteSheetAt" access="private" output="false" returntype="void"
				Hint="(Internal use only) Removes the sheet at the specified index without any validation">
		<cfargument name="sheetIndex" type="numeric" required="false" Hint="Index of the sheet to remove (1-based)" />

		<cfreturn getWorkBook().removeSheetAt( javaCast("int", arguments.sheetIndex - 1) ) />
	</cffunction>

	<cffunction name="renameSheet" access="public" output="false" returntype="void"
			hint="Renames the work sheet at the given position. Throws an error if the SheetName or Position is not valid">
		<cfargument name="sheetName" type="string" required="true" Hint="New Sheet Name"/>
		<cfargument name="sheetIndex" type="numeric" required="true" Hint="Position of the Sheet to rename (1-based)"/>

		<!--- verify the sheet position exists --->
		<cfset validateSheetIndex( arguments.sheetIndex )>

		<!--- sheet already has this name --->
		<cfset Local.foundAt = getWorkBook().getSheetIndex( javacast("string", arguments.sheetName) ) + 1 />
		<cfif Local.foundAt gt 0 and Local.foundAt neq arguments.sheetIndex>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Sheet Name [#arguments.SheetName#]"
						detail="The workbook already contains a sheet named [#arguments.sheetName#]. Sheet names must be unique" />
		</cfif>

		<!--- TODO: Validate new sheet names --->
		<cfset getWorkBook().setSheetName( javacast("int", arguments.sheetIndex - 1)
										  , javacast("string", arguments.sheetName) ) />

	</cffunction>

	<cffunction name="loadFromFile" access="private" output="false" returntype="void"
			hint="Initializes this component from a workbook file from disk.">

		<!--- TODO: need to make sure this handles XSSF format; works with HSSF for now --->
		<cfargument name="src" type="string" required="true" hint="The full file path to the spreadsheet" />
		<cfargument name="sheet" type="numeric" required="false" hint="Used to set the active sheet" />
		<cfargument name="sheetName" type="string" required="false" hint="Used to set the active sheet" />

		<!--- Fail fast --->
		<cfif StructKeyExists(arguments, "sheet") and StructKeyExists(arguments, "sheetname")>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
					message="Cannot Provide Both Sheet and SheetName Attributes"
					detail="Only one of either 'sheet' or 'sheetname' attributes may be provided.">
		</cfif>

		<cfscript>
			// load the workbook from disk
			Local.input 	= loadPoi("java.io.FileInputStream").init( arguments.src );
			Local.buffered 	= loadPoi("java.io.BufferedInputStream").init( Local.input );
			Local.workbookFactory = loadPoi("org.apache.poi.ss.usermodel.WorkbookFactory");
			Local.workbook 	= Local.workbookFactory.create( Local.buffered );
			Local.input.close();
			Local.buffered.close();

			// initalize this component
			setWorkBook( workbook );

			// activate the requested sheet	number
			if (structKeyExists(arguments, "sheet")) {
				validateSheetIndex( arguments.sheet );
				setActiveSheet( sheetIndex=arguments.sheet );
			}
			// activate sheet by name
			else if ( structKeyExists(arguments, "sheetname")) {
				validateSheetName( arguments.sheetName );
				setActiveSheet( sheetName=arguments.sheetname );
			}
			// otherwise, activate the 1st sheet
			else {
				setActiveSheet( sheetIndex=1 );
			}
		</cfscript>

	</cffunction>

	<cffunction name="writeToFile" access="public" output="false" returntype="void"
			hint="Writes the current spreadsheet file to disk">
		<cfargument name="filepath" type="string" required="true" />
		<!---  <cfargument name="workbook" type="any" required="true" /> --->
		<cfargument name="overwrite" type="boolean" required="false" default="false" />
		<cfargument name="password" type="string" required="false" />

		<cfif not arguments.overwrite and FileExists(arguments.filepath)>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="File Exists"
						detail="The file attempting to be written to already exists. Either use the update action or pass an overwrite argument of true to this function." />
		</cfif>

		<cfscript>
			// writeProtectWorkbook takes both a user name and a password, but
			//		since CF 9 tag only takes a password, just making up a user name
			// TODO: workbook.isWriteProtected() returns true but the workbook opens
			//			without prompting for a password --->
			if ( StructKeyExists(arguments, "password") and arguments.password neq "") {
				getWorkbook().writeProtectWorkbook(JavaCast("string", arguments.password), JavaCast("string", "user"));
			}

			Local.fos = CreateObject("java", "java.io.FileOutputStream").init( arguments.filepath );

			try {
				getWorkbook().write( Local.fos );
				Local.fos.flush();
			}
			finally {
				// always close the stream. otherwise file may be left in a locked state
				// if an unexpected error occurs
				Local.fos.close();
			}
		</cfscript>
	</cffunction>

	<cffunction name="cloneFont" access="private" output="false" returntype="any"
			hint="Returns a new Font object with the same settings as the Font object passed in">
		<cfargument name="fontToClone" type="any" required="true" />

		<cfset var newFont = getWorkbook().createFont() />

		<!--- copy the existing cell's font settings to the new font --->
		<cfset newFont.setBoldweight(arguments.fontToClone.getBoldweight()) />
		<cfset newFont.setCharSet(arguments.fontToClone.getCharSet()) />
		<cfset newFont.setColor(arguments.fontToClone.getColor()) />
		<cfset newFont.setFontHeight(arguments.fontToClone.getFontHeight()) />
		<cfset newFont.setFontName(arguments.fontToClone.getFontName()) />
		<cfset newFont.setItalic(arguments.fontToClone.getItalic()) />
		<cfset newFont.setStrikeout(arguments.fontToClone.getStrikeout()) />
		<cfset newFont.setTypeOffset(arguments.fontToClone.getTypeOffset()) />
		<cfset newFont.setUnderline(arguments.fontToClone.getUnderline()) />

		<cfreturn newFont />
	</cffunction>

	<cffunction name="buildCellStyle" access="public" output="false" returntype="any"
			hint="Builds an HSSFCellStyle with settings provided in a struct">
		<cfargument name="format" type="struct" required="true" />

		<!--- TODO: Reuse styles --->
		<cfset var cellStyle = getWorkbook().createCellStyle() />
		<cfset var formatter = getWorkbook().getCreationHelper().createDataFormat() />
		<cfset var font = 0 />
		<cfset var setting = 0 />
		<cfset var settingValue = 0 />
		<cfset var formatIndex = 0 />

		<!---
			Valid values of the format struct are:
			* alignment
			* bold
			* bottomborder
			* bottombordercolor
			* color
			* dataformat
			* fgcolor
			* fillpattern
			* font
			* fontsize
			* hidden
			* indent
			* italic
			* leftborder
			* leftbordercolor
			* locked
			* rightborder
			* rightbordercolor
			* rotation
			* strikeout
			* textwrap
			* topborder
			* topbordercolor
			* underline
			* verticalalignment  (added in CF9.0.1)
		--->

		<!--- Compatibility warning. ACF 9.0.1, uses a separate property for vertical alignment --->
		<cfif structKeyExists(arguments.format, "alignment")
				and findNoCase("vertical", trim(arguments.format.alignment)) eq 1>
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
							message="Invalid alignment [#arguments.format.alignment#]"
							detail="Use the verticalAlignment property instead." />
		</cfif>


		<cfloop collection="#arguments.format#" item="setting">
			<cfset settingValue = UCASE( arguments.format[ setting ] ) />

			<cfswitch expression="#setting#">

				<cfcase value="alignment">
					<cfset cellStyle.setAlignment( cellStyle["ALIGN_" & settingValue] ) />
				</cfcase>

				<cfcase value="bold">
					<cfset font = cloneFont(getWorkbook().getFontAt(cellStyle.getFontIndex())) />

					<cfif StructFind(arguments.format, setting)>
						<cfset font.setBoldweight(font.BOLDWEIGHT_BOLD) />
					<cfelse>
						<cfset font.setBoldweight(font.BOLDWEIGHT_NORMAL)>
					</cfif>

					<cfset cellStyle.setFont(font) />
				</cfcase>

				<cfcase value="bottomborder">
					<cfset cellStyle.setBorderBottom(Evaluate("cellStyle." & "BORDER_" & UCase(StructFind(arguments.format, setting)))) />
				</cfcase>

				<cfcase value="bottombordercolor">
					<cfset cellStyle.setBottomBorderColor(JavaCast("int", getColorIndex(StructFind(arguments.format, setting)))) />
				</cfcase>

				<cfcase value="color">
					<cfset font = cloneFont(getWorkbook().getFontAt(cellStyle.getFontIndex())) />
					<cfset font.setColor(getColorIndex(StructFind(arguments.format, setting))) />
					<cfset cellStyle.setFont(font) />
				</cfcase>

				<!--- TODO: this is returning the correct data format index from HSSFDataFormat but
							doesn't seem to have any effect on the cell. Could be that I'm testing
							with OpenOffice so I'll have to check things in MS Excel --->
				<cfcase value="dataformat">
					<cfset cellStyle.setDataFormat(formatter.getFormat(JavaCast("string", arguments.format[setting]))) />
				</cfcase>

				<cfcase value="fgcolor">
					<cfset cellStyle.setFillForegroundColor(getColorIndex(StructFind(arguments.format, setting))) />
					<!--- make sure we always apply a fill pattern or the color will not be visible --->
					<cfif not structKeyExists(arguments, "fillpattern")>
						<cfset cellStyle.setFillPattern(cellStyle.SOLID_FOREGROUND) />
					</cfif>
				</cfcase>

				<!--- TODO: CF 9 docs list "nofill" as opposed to "no_fill"; docs wrong? The rest match POI
							settings exactly.If it really is nofill instead of no_fill, just change to no_fill
							before calling setFillPattern --->
				<cfcase value="fillpattern">
					<cfset cellStyle.setFillPattern(Evaluate("cellStyle." & UCase(StructFind(arguments.format, setting)))) />
				</cfcase>

				<cfcase value="font">
					<cfset font = cloneFont(getWorkbook().getFontAt(cellStyle.getFontIndex())) />
					<cfset font.setFontName(JavaCast("string", StructFind(arguments.format, setting))) />
					<cfset cellStyle.setFont(font) />
				</cfcase>

				<cfcase value="fontsize">
					<cfset font = cloneFont(getWorkbook().getFontAt(cellStyle.getFontIndex())) />
					<cfset font.setFontHeightInPoints(JavaCast("int", StructFind(arguments.format, setting))) />
					<cfset cellStyle.setFont(font) />
				</cfcase>

				<!--- TODO: I may just not understand what's supposed to be happening here,
							but this doesn't seem to do anything--->
				<cfcase value="hidden">
					<cfset cellStyle.setHidden(JavaCast("boolean", StructFind(arguments.format, setting))) />
				</cfcase>

				<!--- TODO: I may just not understand what's supposed to be happening here,
							but this doesn't seem to do anything--->
				<cfcase value="indent">
					<cfset cellStyle.setIndention(JavaCast("int", StructFind(arguments.format, setting))) />
				</cfcase>

				<cfcase value="italic">
					<cfset font = cloneFont(getWorkbook().getFontAt(cellStyle.getFontIndex())) />

					<cfif StructFind(arguments.format, setting)>
						<cfset font.setItalic(JavaCast("boolean", true)) />
					<cfelse>
						<cfset font.setItalic(JavaCast("boolean", false)) />
					</cfif>

					<cfset cellStyle.setFont(font) />
				</cfcase>

				<cfcase value="leftborder">
					<cfset cellStyle.setBorderLeft(Evaluate("cellStyle." & "BORDER_" & UCase(StructFind(arguments.format, setting)))) />
				</cfcase>

				<cfcase value="leftbordercolor">
					<cfset cellStyle.setLeftBorderColor(getColorIndex(StructFind(arguments.format, setting))) />
				</cfcase>

				<!--- TODO: I may just not understand what's supposed to be happening here,
							but this doesn't seem to do anything--->
				<cfcase value="locked">
					<cfset cellStyle.setLocked(JavaCast("boolean", StructFind(arguments.format, setting))) />
				</cfcase>

				<cfcase value="rightborder">
					<cfset cellStyle.setBorderRight(Evaluate("cellStyle." & "BORDER_" & UCase(StructFind(arguments.format, setting)))) />
				</cfcase>

				<cfcase value="rightbordercolor">
					<cfset cellStyle.setRightBorderColor(getColorIndex(StructFind(arguments.format, setting))) />
				</cfcase>

				<cfcase value="rotation">
					<cfset cellStyle.setRotation(JavaCast("int", StructFind(arguments.format, setting))) />
				</cfcase>

				<cfcase value="strikeout">
					<cfset font = cloneFont(getWorkbook().getFontAt(cellStyle.getFontIndex())) />

					<cfif StructFind(arguments.format, setting)>
						<cfset font.setStrikeout(JavaCast("boolean", true)) />
					<cfelse>
						<cfset font.setStrikeout(JavaCast("boolean", false)) />
					</cfif>

					<cfset cellStyle.setFont(font) />
				</cfcase>

				<cfcase value="textwrap">
					<cfset cellStyle.setWrapText(JavaCast("boolean", StructFind(arguments.format, setting))) />
				</cfcase>

				<cfcase value="topborder">
					<cfset cellStyle.setBorderTop(Evaluate("cellStyle." & "BORDER_" & UCase(StructFind(arguments.format, setting)))) />
				</cfcase>

				<cfcase value="topbordercolor">
					<cfset cellStyle.setTopBorderColor(getColorIndex(StructFind(arguments.format, setting))) />
				</cfcase>

				<cfcase value="underline">
					<cfset font = cloneFont(getWorkbook().getFontAt(cellStyle.getFontIndex())) />

					<cfif StructFind(arguments.format, setting)>
						<cfset font.setUnderline(JavaCast("boolean", true)) />
					<cfelse>
						<cfset font.setUnderline(JavaCast("boolean", false)) />
					</cfif>

					<cfset cellStyle.setFont(font) />
				</cfcase>

				<!--- ACF 9.0.1 moved veritical alignments to a separate property --->
				<cfcase value="verticalalignment">
					<cfset cellStyle.setVerticalAlignment( cellStyle[ settingValue ] ) />
				</cfcase>
			</cfswitch>
		</cfloop>

		<cfreturn cellStyle />
	</cffunction>

	<cffunction name="getColorIndex" access="private" output="false" returntype="numeric"
			hint="Returns the color index of a color string">
		<cfargument name="colorName" type="string" required="true" />

		<cftry>
			<!--- Note: Names must be in upper case and must match EXACTLY. No extra spaces ! --->
			<cfset Local.findColor = trim( ucase(arguments.colorName) ) />
			<cfset Local.IndexedColors = loadPOI("org.apache.poi.ss.usermodel.IndexedColors") />
			<cfset Local.color	= Local.IndexedColors.valueOf( javacast("string", Local.findColor) ) />
			<cfreturn Local.color.getIndex() />

			<cfcatch type="java.lang.IllegalArgumentException">
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
							message="Invalid Color"
							detail="The color provided (#arguments.colorName#) is not valid." />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getJavaColorRGB" access="private" output="false" returntype="struct"
			hint="Returns a struct containing RGB values from java.awt.Color for the color name passed in">
		<cfargument name="colorName" type="string" required="true" />

		<cfset Local.findColor 	= ucase( trim(arguments.colorName) ) />
		<cfset Local.color		= CreateObject("java", "java.awt.Color") />
		<cfset Local.colorRGB 	= StructNew() />

		<cfif not structKeyExists(Local.color, findColor) or
				not	isInstanceOf(Local.color[findColor], "java.awt.Color")>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
							message="Invalid Color"
							detail="The color provided (#arguments.colorName#) is not valid." />
		</cfif>

		<cfset Local.color 			= Local.color[ findColor ] />
		<cfset Local.colorRGB.red   = Local.color.getRed() />
		<cfset Local.colorRGB.green = Local.color.getGreen() />
		<cfset Local.colorRGB.blue  = Local.color.getBlue() />

		<cfreturn colorRGB />
	</cffunction>

	<cffunction name="getCellUtil" access="private" output="false" returntype="any"
				Hint="Returns stored cell utility object ie org.apache.poi.ss.util.CellUtil">
		<!--- initialize object if needed --->
		<cfif not structKeyExists(variables, "cellUtil")>
			<cfset variables.cellUtil = loadPOI("org.apache.poi.ss.util.CellUtil") />
		</cfif>

		<cfreturn variables.cellUtil />
	</cffunction>

	<cffunction name="getFormatter" access="private" output="false" returntype="any"
				Hint="Returns cell formatting utility object ie org.apache.poi.ss.usermodel.DataFormatter">

		<cfif not structKeyExists(variables, "dataFormatter")>
			<cfset variables.dataFormatter = loadPOI("org.apache.poi.ss.usermodel.DataFormatter").init() />
		</cfif>

		<cfreturn variables.dataFormatter />
	</cffunction>

	<cffunction name="getEvaluator" access="private" output="false" returntype="any"
				Hint="Returns evaluator object ie org.apache.poi.ss.usermodel.FormulaEvaluator">

		<cfif not structKeyExists(variables, "formulaEvaluator")>
			<cfset variables.formulaEvaluator = getWorkbook().getCreationHelper().createFormulaEvaluator() />
		</cfif>

		<cfreturn variables.formulaEvaluator />
	</cffunction>

	<cffunction name="getQueryColumnFormats" access="private" output="false" returntype="array">
		<cfargument name="query" type="query" required="true">
		<cfargument name="formats" type="struct" default="#structNew()#">

		<!--- extract the query columns and data types --->
		<cfset Local.cell	  	= loadPOI("org.apache.poi.ss.usermodel.Cell") />
		<cfset Local.formatter	= getWorkbook().getCreationHelper().createDataFormat() />
		<cfset Local.metadata 	= getMetaData(arguments.query) />

		<!--- assign default formats based on the data type of each column --->
		<cfloop array="#Local.metadata#" index="Local.col">

			<cfswitch expression="#Local.col.typeName#">
				<!--- apply basic formatting to dates and times for increased readability --->
				<cfcase value="DATE,TIMESTAMP">
					<cfset Local.col.cellDataType 		= "DATE" />
					<cfset Local.col.defaultCellStyle 	= buildCellStyle( {dataFormat = variables.defaultFormats[ Local.col.typeName ]} ) />
				</cfcase>
				<cfcase value="TIME">
					<cfset Local.col.cellDataType 		= "TIME" />
					<cfset Local.col.defaultCellStyle 	= buildCellStyle( {dataFormat = variables.defaultFormats[ Local.col.typeName ]} ) />
				</cfcase>
				<!--- Note: Excel only supports "double" for numbers. Casting very large DECIMIAL/NUMERIC
				    or BIGINT values to double may result in a loss of precision or conversion to
					NEGATIVE_INFINITY / POSITIVE_INFINITY. --->
				<cfcase value="DECIMAL,BIGINT,NUMERIC,DOUBLE,FLOAT,INTEGER,REAL,SMALLINT,TINYINT">
					<cfset Local.col.cellDataType = "DOUBLE" />
				</cfcase>
				<cfcase value="BOOLEAN,BIT">
					<cfset Local.col.cellDataType = "BOOLEAN" />
				</cfcase>
				<cfdefaultcase>
					<cfset Local.col.cellDataType = "STRING" />
				</cfdefaultcase>
			</cfswitch>

			<!--- if custom formatting was supplied, load a new style object --->
			<cfif structKeyExists(arguments.formats, Local.col.name)>
				<cfset Local.formatProp = duplicate(arguments.formats[ Local.col.name ]) />

				<!--- apply the default format (if none was provided) --->
				<cfif not structKeyExists(Local.formatProp, "dataFormat") and structKeyExists(Local.col, cellFormat)>
					<cfset Local.formatProp.dataFormat = variables.defaultFormats[ Local.col.typeName ] />
				</cfif>

				<!--- generate the cell style --->
				<cfset Local.col.customCellStyle = buildCellStyle(format=Local.formatProp) />
			</cfif>

		</cfloop>

		<cfreturn Local.metadata />
	</cffunction>

	<!--- COMMON VALIDATION FUNCTIONS --->
	<!--- TODO: Incorporate into other existing functions --->
	<cffunction name="validateSheetIndex" access="private" output="false" returntype="void"
				Hint="Validates the given SheetIndex is valid for this workbook: a) an integer greater than 0 and b) does not exceed the number sheets in this workbook">
		<cfargument name="sheetIndex" type="numeric" required="true" Hint="Sheet position (base-1)" />

		<cfif not sheetExists( sheetIndex=arguments.sheetIndex )>
			<cfset Local.sheetCount = getWorkBook().getNumberOfSheets() />
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Sheet Index [#arguments.sheetIndex#]"
						detail="The SheetIndex must a whole number between 1 and the total number of sheets in the workbook [#Local.sheetCount#]" />

		</cfif>
	</cffunction>

	<cffunction name="validateSheetName" access="private" output="false" returntype="void"
				Hint="Validates the given SheetName exists within this workbook.">
		<cfargument name="sheetName" type="string" required="true" Hint="Name of the sheet to validate" />

		<cfif not sheetExists( sheetName=arguments.sheetName )>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Invalid Sheet Name [#arguments.SheetName#]"
						detail="The requested sheet was not found in the current workbook." />

		</cfif>
	</cffunction>

	<cffunction name="validateSheetNameOrIndexWasProvided" access="private" output="false" returntype="void"
				Hint="Validates either a SheetName OR SheetIndex was supplied (not both).">
		<cfargument name="sheetName" type="string" required="false" />
		<cfargument name="sheetIndex" type="numeric" required="false" />


		<cfif not StructKeyExists(arguments, "sheetName") and not StructKeyExists(arguments, "sheetIndex")>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Missing Required Argument"
						detail="Either sheetName or sheetIndex must be provided" />
		</cfif>

		<cfif StructKeyExists(arguments, "sheetName") and StructKeyExists(arguments, "sheetIndex")>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
						message="Too Many Arguments"
						detail="Only one argument is allowed. Specify either a SheetName or SheetIndex, not both" />
		</cfif>
	</cffunction>

	<!--- Range is a comma-delimited list of ranges, and each value can be either
			a single number or a range of numbers with a hyphen. Ignores any white space --->
	<cffunction name="extractRanges" access="private" output="false" returntype="array"
				Hint="Parses and validates a list of row/column numbers. Returns an array of structures with the keys: startAt, endAt ">
		<cfargument name="rangeList" type="string" required="true" />

		<cfset Local.range 	 	= 0 />
		<cfset Local.elem		= 0 />
		<cfset Local.parts		= 0 />
		<cfset Local.rangeTest 	= "^[0-9]{1,}(-[0-9]{1,})?$" />
		<cfset Local.allRanges 	= [] />

		<cfloop list="#arguments.rangeList#" index="Local.elem">
			<!--- remove all white space first --->
			<cfset Local.elem = reReplace(Local.elem, "[[:space:]]+", "", "all") />

			<cfif REFind(Local.rangeTest, Local.elem) gt 0>
				<cfset Local.parts 	= listToArray(Local.elem, "-") />

				<!--- if this is a single number, the start/endAt values are the same --->
				<cfset Local.range 	= {} />
				<cfset Local.range.startAt = Local.parts[ 1 ] />
				<cfset Local.range.endAt   = Local.parts[ arrayLen(Local.parts) ] />
				<cfset arrayAppend( Local.allRanges, Local.range ) />

			<cfelse>
				<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet"
							message="Invalid Range Value"
							detail="The range value #Local.elem# is not valid." />
			</cfif>
		</cfloop>

		<cfreturn Local.allRanges />
	</cffunction>

	<cffunction name="parseRowData" returntype="array" output="false"
			hint="Converts a list of values to an array">
		<cfargument name="line" type="string" required="true" hint="List of values to parse" />
		<cfargument name="delimiter" type="string" required="true" hint="List delimiter" />
		<cfargument name="handleEmbeddedCommas" type="boolean" default="true" />

		<cfscript>
			var elements = listToArray( arguments.line, arguments.delimiter, true );
			var potentialQuotes = 0;
			arguments.line = toString(arguments.line);

			if (arguments.delimiter eq "," && arguments.handleEmbeddedCommas) {
				potentialQuotes = arguments.line.replaceAll("[^']", "").length();
			}

			if (potentialQuotes <= 1) {
			  	return elements;
			}

			/*
				For ACF compatibility, find any values enclosed in single
				quotes and treat them as a single element.
			*/
		  	var currValue = 0;
		  	var nextValue = "";
			var isEmbeddedValue = false;
			var values = [];
			var buffer = loadPOI("java.lang.StringBuilder").init();
			var maxElem = arrayLen(elements);

			for (var i = 1; i <= maxElem; i++) {
				  currValue = trim( elements[ i ] );
				  nextValue = i < maxElem ? elements[ i + 1 ] : "";

				  var isComplete = false;
				  var hasLeadingQuote = currValue.startsWith("'");
				  var hasTrailingQuote = currValue.endsWith("'");
				  var isFinalElem = (i == maxElem);

				  if (hasLeadingQuote) {
					  isEmbeddedValue = true;
				  }
				  if (isEmbeddedValue && hasTrailingQuote) {
					  isComplete = true;
				  }

				  // We are finished with this value if:
				  // * no quotes were found OR
				  // * it is the final value OR
				  // * the next value is embedded in quotes
				  if (!isEmbeddedValue || isFinalElem || nextValue.startsWith("'")) {
					  isComplete = true;
				  }

				  if (isEmbeddedValue || isComplete) {
					  // if this a partial value, append the delimiter
					  if (isEmbeddedValue && buffer.length() > 0) {
						  buffer.append(",");
					  }
					  buffer.append( elements[i] );
				  }

				  //WriteOutput("[#i#] value=#currValue# isEmbedded=#isEmbeddedValue# isComplete=#isComplete#"
				  //	  &" (start/end #hasLeadingQuote#/#hasTrailingQuote#) <br>");

				  if (isComplete) {
					  var finalValue = buffer.toString();
					  var startAt = finalValue.indexOf("'");
					  var endAt = finalValue.lastIndexOf("'");

					  if (isEmbeddedValue && startAt >= 0 && endAt > startAt) {
						  finalValue = finalValue.substring(startAt+1, endAt);
					  }

					  values.add( finalValue );
					  buffer.setLength(0);
					  isEmbeddedValue = false;
				  }

			  }

			  return values;
		</cfscript>

	</cffunction>


	<!---
		COLUMN WIDTH UTILITY FUNCTIONS
	--->
	<cffunction name="estimateColumnWidth" returntype="number" access="private"
			hint="Estimates approximate column width based on cell value and default character width.">
		<cfargument name="value" type="any" required="true" />

		<!---
			"Excel bases its measurement of column widths on the number of digits (specifically,
			the number of zeros) in the column, using the Normal style font."

			This function approximates the column width using the number of characters and
			the default character width in the normal font. POI expresses the width in 1/256
			of Excel's character unit.  The maximum size in POI is: (255 * 256)
		--->
		<cfscript>
			Local.defaultWidth = getDefaultCharWidth();
			Local.numOfChars = len(arguments.value);
			Local.width = ( Local.numOfChars * Local.defaultWidth +5) / Local.defaultWidth * 256;
		    // Do not allow the size to exceed POI's maximum
			return Min( Local.width, (255*256) );
		</cfscript>
	</cffunction>

	<cffunction name="getDefaultCharWidth" returntype="number" access="private"
			hint="Estimates the default character width using Excel's 'Normal' font">
		<cfscript>
			// this is a compromise between hard coding a default value and the
			// more complex method of using an AttributedString and TextLayout
			Local.defaultFont = getWorkBook().getFontAt(0);
			Local.style = getAWTFontStyle( Local.defaultFont );
			Local.Font = loadPOI("java.awt.Font");
			Local.javaFont = Local.Font.init( Local.defaultFont.getFontName()
													, Local.style
													, Local.defaultFont.getFontHeightInPoints()
												);

			Local.transform = createObject("java", "java.awt.geom.AffineTransform");
			Local.fontContext = createObject("java", "java.awt.font.FontRenderContext").init(Local.transform, true, true);
			Local.bounds = Local.javaFont.getStringBounds("0", Local.fontContext);

			return Local.bounds.getWidth();
		</cfscript>
	</cffunction>

	<cffunction name="getAWTFontStyle" returntype="number" access="private"
		hint="Transforms a POI Font ">
		<cfargument name="poiFont" type="any" required="true" />
		<cfscript>
			Local.Font = loadPOI("java.awt.Font");
			Local.isBold = arguments.poiFont.getBoldweight() == arguments.poiFont.BOLDWEIGHT_BOLD;

			if (Local.isBold && arguments.poiFont.getItalic()) {
	           Local.style = BitOr( Local.Font.BOLD, Local.Font.ITALIC);
			}
			else if (Local.isBold) {
	           Local.style = Local.Font.BOLD;
			}
			else if (arguments.poiFont.getItalic()) {
	           Local.style  = Local.Font.ITALIC;
			}
			else {
				Local.style = Local.Font.PLAIN;
			}

			return Local.style;
		</cfscript>
	</cffunction>

	<cfscript>
	function getCFMLEngine() {
		if ( structKeyExists( server, "lucee" ) and structkeyExists( server.lucee, "version") ) {
			return "lucee";
		} else {
			return "acf";
		}
	}

	function isLinux() {

		var isLinux = false;

		if ( getCFMLEngine() is "lucee" ) {

			if ( server.os.name is "Linux" ) {
				isLinux = true;
			}

		} elseif ( getCFMLEngine() is "acf" ) {

			if ( server.os.name is "UNIX" and server.os.additionalinformation is "Linux" ) {
				isLinux = true;
			}
		}

		return isLinux;
	}
	</cfscript>

</cfcomponent>
