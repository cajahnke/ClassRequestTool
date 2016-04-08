$(function(){

  // Sorting on date cell data rather than cell contents
  // Borrowing from two digit year parser included in tablesorter package
  var $ts = $.tablesorter;  
	
  $ts.addParser({
    id: 'data_date',
    is: function(s) {
      return false;
    },
    format: function(s, table, cell, cellIndex) {
      var $cell = $(cell);
      
      var dateVal = $cell.data('date');
      return $ts.formatDate(dateVal, $ts.dates.regxxxxyy, "$1/$2/19$3", table);
    },
    type: 'numeric'
  });
      
  var $tables = $('table.sortable');
 
  var tablesorterOptions = {
    theme: 'bootstrap',
    headerTemplate: "{content} {icon}",
    widgets: ['uitheme', 'filter', 'zebra'],
    cssIcons: 'glyphicon glyphicon-{name}',
    widthFixed: true,
    widgetOptions: {
      zebra: ['even', 'odd' ],
      filter_reset: '.filter-reset',
      filter_hideFilters: false,
      filter_cssFilter: 'form-control',
      filter_external : '.table-search',
      filter_startsWith: false,
      filter_placeholder: { search : 'Filter...' }
    }
  };
  
  var pagerOptions = {
    cssGoto: '.pagenum',
    removeRows: false, 
    output: "page {page} of {filteredPages}", 
    size: 20
  };
  
  $.each($tables, function(i) {
    var tableId = $(this).attr('id');
    
    // Use date_data parser for date columns
   var mySorters = {};
    $(this).find('tr.active-headers th').each( function(i) {
      if ($(this).hasClass('date')) {
        mySorters[i] = { sorter: 'data_date' };
      }
    });
    
    tablesorterOptions = $.extend(true, tablesorterOptions,
      {
        headers: mySorters
      }
    );
    
    // Add text extraction for status columns
    var textExtractions = {};
    var startsWith = {};
    $(this).find('th').each( function(i) {
      if ($(this).hasClass('status-column')) {
        textExtractions[i] = function(node) {
          return $(node).find('span').text();
        };
        if ($(this).hasClass('starts_with')) {
          startsWith[i] = true;
        }
      }
    });
    tablesorterOptions = $.extend(true, tablesorterOptions, 
      { 
        widgetOptions: {
          textExtraction: textExtractions,
        }
      }
    );
    
    //Add range filter for all date columns
    var filterFormatters = {};
    $(this).find('tr.active-headers th').each(function(i) {
      if ($(this).hasClass('date')) {
        filterFormatters[i] = function($cell, indx) {
          return $ts.filterFormatter.uiDatepicker( $cell, indx, {
            textFrom: 'From:',
            textTo: 'To:',
            changeMonth: true,
            changeYear: true
          });
        }
      }
    });
    
    tablesorterOptions = $.extend(true, tablesorterOptions, 
      {
        widgetOptions: {
          filter_formatter: filterFormatters
        }
    });
                
    pagerOptions = $.extend(true, pagerOptions, { container: $('.pager-' + tableId) });

    if ($(this).hasClass('2-up')) {
      pagerOptions = $.extend(true, pagerOptions, { positionFixed: false });
    }
    
    $(this).tablesorter(tablesorterOptions).tablesorterPager(pagerOptions);
  });
  
  // Bring to page one on resort
  $('table.sortable').bind("sortEnd", function(e, table) {
    $(this).trigger('pageSet', 0);
  });
  
  // Remove border and stripe classes
  //$('table').removeClass('table-bordered').removeClass('table-striped'); 
});
