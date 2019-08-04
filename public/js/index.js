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
	realm_select.options.add(new Option(realms[selectedRegion][i], parseInt(i) + 1), realm_select.options[realm_select.options.length]);
    }
    $('select').formSelect();
}

$(document).ready(function(){
    $('select').formSelect();

    $('#region-select').change(region_change);
    // $('#region-select').val(0);
    $('#region-select').trigger('change', true);
});
