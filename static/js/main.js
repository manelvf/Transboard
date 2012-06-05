
var App = {
  rowStatus : []
}


$(document).ready( function() {

  $("td.line").click(function() {
    var id = $(this).attr("id");
    s = "<tr><td>test</td><td>test</td></tr>";

    if ()
    $(this).parent().after(s);

    App.rowStatus[id] = true; 
  });

});

