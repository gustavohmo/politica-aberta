jQuery.fn.dataTableExt.afnSortData['dom-text'] = function  ( oSettings, iColumn ) {
	var aData = [];
	$( 'td:eq('+iColumn+') span strong', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
		aData.push( this.innerHTML );
	} );
	return aData;
}

// Currency
jQuery.fn.dataTableExt.oSort['currency-asc'] = function(a,b) {
	/* Remove any commas (assumes that if present all strings will have a fixed number of d.p) */
	var x = a == "-" ? 0 : a.replace( /,/g, "" );
	var y = b == "-" ? 0 : b.replace( /,/g, "" );

	/* Remove the currency sign */
	x = x.substring( 1 );
	y = y.substring( 1 );

	/* Parse and return */
	x = parseFloat( x );
	y = parseFloat( y );

	return x - y;
};

jQuery.fn.dataTableExt.oSort['currency-desc'] = function(a,b) {
	/* Remove any commas (assumes that if present all strings will have a fixed number of d.p) */
	var x = a == "-" ? 0 : a.replace( /,/g, "" );
	var y = b == "-" ? 0 : b.replace( /,/g, "" );

	/* Remove the currency sign */
	x = x.substring( 1 );
	y = y.substring( 1 );

	/* Parse and return */
	x = parseFloat( x );
	y = parseFloat( y );
	return y - x;
};

jQuery.fn.dataTableExt.oSort['num-html-asc']  = function(a,b) {
      var x = parseFloat( a.replace( /<.*?>/g, "" ).replace("$","").replace(",","") ),
          y = parseFloat( b.replace( /<.*?>/g, "" ).replace("$","").replace(",","") );
      return ((x < y) ? -1 : ((x > y) ?  1 : 0));
    };

jQuery.fn.dataTableExt.oSort['num-html-desc'] = function(a,b) {
      var x = parseFloat( a.replace( /<.*?>/g, "" ).replace("$","").replace(",","") ),
          y = parseFloat( b.replace( /<.*?>/g, "" ).replace("$","").replace(",","") );
      return ((x < y) ?  1 : ((x > y) ? -1 : 0));
    };


jQuery.fn.dataTableExt.oSort['realmoeda-asc'] = function(a,b) {
    var x = (a == "-") ? 0 : a.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
    var y = (b == "-") ? 0 : b.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
};

jQuery.fn.dataTableExt.oSort['realmoeda-desc'] = function(a,b) {
    var x = (a == "-") ? 0 : a.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
    var y = (b == "-") ? 0 : b.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ? 1 : ((x > y) ? -1 : 0));
};

jQuery.fn.dataTableExt.oSort['title-numeric-asc']  = function(a,b) {
    var x = a.match(/title="*(-?[0-9\.]+)/)[1];
    var y = b.match(/title="*(-?[0-9\.]+)/)[1];
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['title-numeric-desc'] = function(a,b) {
    var x = a.match(/title="*(-?[0-9\.]+)/)[1];
    var y = b.match(/title="*(-?[0-9\.]+)/)[1];
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

/*jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "title-numeric-pre": function ( a ) {
        var x = a.match(/title="*(-?[0-9\.]+)/)[1];
        return parseFloat( x );
    },

    "title-numeric-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "title-numeric-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
} );*/
