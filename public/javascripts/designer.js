$(document).ready(function(){
  $(".designer").parent(".content-area").css("overflow", "visible");

  var thumbs = ["avatar", "work1", "work2", "work3"];
  $.each(thumbs, function(index, value){
    if($("#" + value).length > 0)
      $("#" + value).next("li").hide();
  });

  $("span.remove_attr").click(function(){
    //TODO: add confirmation dialog with translation
    var li = $(this).parents("li");
    var attr = li.attr("id");
    li.next("li").show();
    li.remove();
    $("input:hidden[id='delete_" + attr + "']").val('true');
  });

  $("#tab_holder" ).tabs();
});
