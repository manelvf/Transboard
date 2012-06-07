
var App = {
  rowStatus : []
}


$(document).ready( function() {

  $("td.line").click(function() {
    var id = $(this).attr("id");
    s = "<tr><td>test</td><td>test</td></tr>";

    $(this).parent().after(s);

    App.rowStatus[id] = true; 
  });

  $("tr.list").mouseover(function() {
    $(this).find("img").css({"visibility":"visible"});
  });

  $("tr.list").mouseout(function() {
    $(this).find("img").css({"visibility":"hidden"});
  });


  // links
  $(".list > td.links a").click( function(e) {
    var t = $(this);

    if (t.attr("name") != "download") {
      callAjax(e, t);
    }
  });

});

// generic ajax call
function callAjax(e, el) {
  e.preventDefault();

  var id = el.attr("href").match(/[^\/]*$/)
  if (id && id[0] && id[0].length > 0) {

    $.get( '/'+el.attr("name") + '/' + id[0], function(d){
      console.log(d);
      el.parent().parent().remove();
    });
  } 

}



