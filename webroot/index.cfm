<cfspreadsheet action="read" src="#expandPath( 'test.xlsx' )#" query="qTestXslx">
<cfscript>
	qAllArtists = queryExecute(
		"
			SELECT artistid, firstname, lastname, address, city, state, postalcode, email, phone, fax
			FROM artists
		",
		{},
		{ datasource = "cfartgallery" }
	);

	dump( qAllArtists );
	dump( qTestXslx );
	dump( cgi );
	dump( client );
	dump( server );
</cfscript>
