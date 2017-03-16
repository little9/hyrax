export default class Default {
    constructor(element, url) {
	var authorities = new Bloodhound({
	    datumTokenizer: Bloodhound.tokenizers.whitespace,
	    queryTokenizer: Bloodhound.tokenizers.whitespace,
	    remote: {
		url: url + '?q=%QUERY',
		wildcard: '%QUERY',
		filter: (authorities) => {
		    return $.map(authorities, (data) => {
			return {
			    label: data.label,
			    uri: data.id
			};
		    });
		}
	    }
	});
	element.typeahead('destroy');
	element.typeahead({
	    hint: true,
	    highlight: true,
	    minLength: 2
	},{
	    name: 'label',
	    displayKey: (authority) => {
		return authority.label;
	    },
	    source: authorities
	});
    }
}

