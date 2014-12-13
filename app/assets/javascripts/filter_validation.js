/**
 * Created by svetakrasikova on 13/12/2014.
 */

$("#entry_date_from").change(function(event){
    if ($("#entry_date_to").val() === "" || $("#entry_date_to").val() < $("#entry_date_from").val()) {
        $("#entry_date_to").val($("#entry_date_from").val())
    }
});
$("#entry_date_to").change(function(event){
    if ($("#entry_date_from").val() === "" || $("#entry_date_to").val() < $("#entry_date_from").val()) {
        $("#entry_date_from").val($("#entry_date_to").val())
    }
});