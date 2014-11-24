// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
//= require uikit
//= require geocomplete
// script for calendar date pick
$(function (){
    var dateInput = $(".datepicker");
    $.UIkit.datepicker(dateInput,{format:'YYYY-MM-DD'})
    $(".entry_location_input").geocomplete({
        details: '.geo_details',
        detailsAttribute: 'data-geo'
    });
    $(".entry_location_input").focusout(function(){
        $(".entry_location_input").trigger("geocode");
    });
});