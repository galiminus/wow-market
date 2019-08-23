// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require ./materialize
//= require_tree .


function region_change()
{
    realm_select = document.getElementById("realm-select");
    while (realm_select.options.length > 1) {
	realm_select.options.remove(1);
    }
    region_select = document.getElementById("region-select");
    options = region_select.options;
    selectedRegion = options[options.selectedIndex].text;
    realm_select = document.getElementById("realm-select");
    for (i in realms[selectedRegion]) {
	realm_select.options.add(new Option(realms[selectedRegion][i], realms[selectedRegion][i]), realm_select.options[realm_select.options.length]);
    }
    $('select').formSelect();
}

// document.addEventListener('DOMContentLoaded', function() {
//     $('select').formSelect();

//     $('#region-select').change(region_change);
//     // $('#region-select').val(0);
//     $('#region-select').trigger('change', true);
// });
