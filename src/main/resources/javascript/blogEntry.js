$(document).ready(function() {
    $.each(['addContent'], function(index, element) {
        if ($('#' + element).length > 0) {
            $('label[for="' + element + '"]').hide();
        }
    });

    $('#formPost').bind("keyup keypress", function(e) {
        var code = e.keyCode || e.which;
        if (code  == 13) {
            e.preventDefault();
            return false;
        }
    });
});

function deleteTag(tag) {
    $(tag).parent("li").remove();
    if($(".post-tags li").length == 0){
        $("#formPost").append("<input id='clearTag' style='display: none' type='text' name='j:tagList' value='jcrClearAllValues'/>")
    }
}

function addTag(){
    var $newTag = $(".addTag");
    var values = $newTag.val().trim().split(",");
    if(values.length > 0){
        var $ul = $('.post-tags');
        for (var i = 0; i < values.length; i++) {
            if(values[i] && values[i].trim().length > 0 && $('[data-tag="' + values[i].trim() + '"]').length == 0){
                if($("#clearTag").length > 0){
                    $("#clearTag").remove();
                }
                var $li = $("<li></li>").text(values[i]);
                var $a = $("<a href='#' class='delete' onclick='deleteTag(this); return false;'></a>").attr('data-tag', values[i].trim());
                var $input = $("<input style='display: none' type='text' name='j:tagList'/>").attr('value', values[i].trim());
                $li.append($a).append($input);
                $ul.append($li);
            }
        }
        $newTag.val("")
    }
}