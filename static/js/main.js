if (typeof console == "undefined") console = { log: function() {} } 


/************
 * App Singleton
 ***************/
var App = {
  rowStatus : [],
  rowTemplate : "<tr><td>{proposal}</td><td></td><tr>",
  noActionButtons: ["download", "projectoptions", "editproject"]
}


$(document).ready( function() {

  // Login Form
  $("form.signup").submit( function(e) {
    e.preventDefault(); 

    el = $(this);

    var hasSpaces = [];
    el.find("input").each( function() {
      var t = $(this);

      if (t.attr("type") != "submit" && /\s/g.test(t.val())) {
        hasSpaces.push(t.attr("id"));
      }
    });

    if (hasSpaces.length > 0) {
      //console.log(hasSpaces);
      alert("Forms fields "+String(hasSpaces)+" should not include spaces");
    } else {
      this.submit();
    }
  });


  $("td.line").click(function() {
    var id = $(this).attr("id");
    s = "";

    $(this).parent().after(s);

    App.rowStatus[id] = true; 
  });

  $("tr.list").mouseover(function() {
    $(this).find("img").not('.donothide').css({"visibility":"visible"});
  });

  $("tr.list").mouseout(function() {
    $(this).find("img").not('.donothide').css({"visibility":"hidden"});
  });


  // links
  $(".list > td.links a").click( function(e) {
    var t = $(this);


    if ($.inArray(t.attr("name"), App.noActionButtons) < 0) {
      callAjax(e, t);
    }
  });

  
  // add a new translation line
  $("td > input.line").keypress( function(e) {
    var el = $(this);

    if (e.which == 13) {

      $.post("/addline", {
          docId : documentId,
          id: el.attr("id"),
          text: el.val()
        }, function(d) {
          var s = t(App.rowTemplate, {
            proposal: el.val()
          });
        el.parent().parent().after(s); // add a new line
      });

    }

  });


  // votes

  $("a.voteLink").click( function() {
    var el = $(this);

    var id = el.attr("id").match(/^id(.*)/);
    var lineId = id[1];

    var prop = el.attr("name").match(/^prop(.*)/);
    var propId = prop[1];

    $.post('/vote', {
        docId: documentId,
        lineId: lineId,
        propId: propId 
      }, function(d) {
        if (d == "OK") { // Profit

          el.hide();
          var prev = el.prev();
          var n = prev.html();
          n = Number(n) + 1;
          prev.html(n);

        } else if (d == "VOTED") {
          alert(d);
        }
      }
    );

  });


  // status
  $("select.status").change( function() {
    var el = $(this);

    var authorId = el.attr("id").match(/^status(.*)$/)

    if (!authorId[1])
      return;

    $.post("/changestatus", {
      'docId' : documentId,
      'authorId' : authorId[1],
      'status' : el.val()
    }, function(d) {
      //console.log(d);
    });

  });

});



// generic ajax call
function callAjax(e, el) {
  e.preventDefault();

  var id = el.attr("href").match(/[^\/]*$/)
  if (id && id[0] && id[0].length > 0) {
    $.get( '/'+el.attr("name") + '/' + id[0], SUCCESS[el.attr("name")](el) ); 
  }

}


SUCCESS = {
  'delete' : function(el) {
      el.parent().parent().remove();
  },
  'askcollaborate': function(el) {
      el.parent().parent().remove();
  }
}



function t(s,d){
 for(var p in d)
   s=s.replace(new RegExp('{'+p+'}','g'), d[p]);
 return s;
}


