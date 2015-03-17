$().ready(function() {
	$.ajax({
		url: "games", 
		success: function(data) {
			$("#content").append("<ul>");
			$.each(data.games, function(i,value) {
				$("#content").append("<li><a href='" + value.uri + "'>" + value.name + "</a></li>");
			})
		}, 
		headers: {
    		"Authorization": "Basic " + btoa("jesus:test")
  		}
	});
});