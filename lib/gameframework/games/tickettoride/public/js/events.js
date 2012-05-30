draw_open_card = function() {
	color = $(this).attr('color');
	var data = {"id":"draw_card"}
	data["params"] = {"color": color}
	send_event(data);
}

draw_from_deck = function() {
	var data = {"id":"draw_card"}
	data["params"] = {"deck": "true"}
	send_event(data);
}

draw_tickets = function() {
	var data = {"id":"draw_tickets"}
	send_event(data);
}

build = function() {
	var data = {"id" : "build"};
	route = $('#routes').val();
	data["params"] = JSON.parse(route);
	send_event(data);
}

return_tickets = function() {
	var data = {"id": "return_tickets"};
	var params = {"tickets": []};
	$('#drawn_tickets :input:checked').each(function(index,element) {
		params["tickets"].push($(element).val());
	});
	if (params["tickets"].length == 0) {
		alert("You need to keep at least one ticket");
		return;
	}
	data["params"] = params;
	alert(JSON.stringify(data));
	send_event(data);
}


send_event = function(event_data) {
	event = {"json_class":"GameFramework::Event"};
	event["data"] = event_data;
	$('<form action="/game/event" method="post"><input type="text" name="event" value="' +
	escape(JSON.stringify(event)) + '"/></form>').appendTo("body").submit();
}

$(function() {
	$('.available_card').click(draw_open_card);
	$('#deck').click(draw_from_deck);
	$('#tickets').click(draw_tickets);
 	$('#build').click(build);
 	$('#return_tickets').click(return_tickets);
});