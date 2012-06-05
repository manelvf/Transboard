
var App = {
  rowStatus : []
}


$(document).ready( function() {

  $("td.line").click(function() {
    s = "<tr><td>test</td><td>test</td></tr>";
    $(this).parent().after(s);
    var id = $(this).attr("id");
    App.rowStatus[id] = true; 
  });

});

