var isLoggedIn = false;
var token = null;
var loggedPlayer = null;
var clickedElement = null;
var matches = {};
var playerImg = '<img class="center-block" width="80px" height="80" src="images/tic-tac-toe-X.png"/>';
var opponentImg = '<img class="center-block" width="80px" height="80" src="images/tic-tac-toe-O.png"/>';
var blank = '<img class="center-block" width="80px" height="80" src="images/tic-tac-toe-blank.png"/>';
var moveToSubmit = null;


function doLogin() {
    var user = $("#username").val();
    var passw = $("#password").val();
    $.post("/auth", {username: user, password:passw}, function(data) {
        if (data.success) {
            token = data.token;
            isLoggedIn = true;
            loggedPlayer = user;
            $('#loggedInMessage').html('Welcome ' + token);
            $('#loginForm').addClass("hidden");
            $('#loggedInNavBar').removeClass("hidden");
            $('#matchesButton').prop('disabled', false);
            //setInterval("getMatches()", 5000);
        }
    }).fail(function() {
        alert("error");
    });
    return false;
}

function getJSONWithToken(url) {
    return $.getJSON(url, {token: token});
}

function postWithToken(url, data) {
    return $.ajax({
        type: "POST",
        url: url+ "?token=" + token,
        data: JSON.stringify(data),
        contentType: "application/json"
    });
}

function getMatches() {
    getJSONWithToken('/matches').done(function(data) {
        var table = $('<table/>');
        table.addClass("table");
        var thead_row = table.append('<thead/>').children('thead').append('<tr/>').children('tr');
        thead_row.append('<th>ID</th><th>Players</th><th>Open</th>');
        var tbody = table.append('<tbody/>').children('tbody');

        $.each(data, function(i, match) {
            matches[match.data.id] = match;
            var tr = tbody.append('<tr />').children('tr:last')            
            if (match.data.match_finished) {
                tr.addClass("info");
            } else if (match.data.active_player === loggedPlayer) {
                tr.addClass("danger");
            }
            tr.append('<td>' + match.data.id + '</td>');
            var players = $.map(match.data.players, function(player) {
                return player == loggedPlayer ? "<strong>" + player + "</strong>" : player;
            }).join(",");
            tr.append('<td>' + players + '</td>');
            var btn = tr.append('<td/>').children('td:last').append("<button>Open</button>").children('button');
            btn.attr("id", "matchButton" + i);            
            btn.addClass("btn btn-primary matchButton");
            btn.data("matchId", match.data.id);
        });
        $('#content div').empty().append(table);
        $('.matchButton').click(openMatch);
    });
}

function resetBoard() {
    $('.tictactoecell').empty();
    $('td.tictactoecell:empty').unbind("click");
}

function move(event) {
    console.log(event);
    var cell = event.delegateTarget;
    var moveData = {id: "move", x: cell.getAttribute("data-x"), y: cell.getAttribute("data-y")};
    $(event.delegateTarget).empty().append(playerImg);
    var url = matches[event.data].links.event;
    moveToSubmit = {url: url, data: moveData};
    $('#submitMoveButton').unbind("click").click(submitMove).prop('disabled', false);

}

function submitMove() {
    console.log("submitting move");
    postWithToken(moveToSubmit.url, moveToSubmit.data).done(function(data) {
        moveToSubmit = null;
        console.log(data);
        alert("Move submitted");
    });
}

function openMatch(event) {
    console.log(event.target);
    var id = $(event.target).data("matchId");
    var match = matches[id]; // more correct: go to server and load the match data here
    resetBoard();
    $.each(match.data.state.map, function(player, cells) {
        var img = (player === loggedPlayer) ? playerImg : opponentImg;
        $.each(cells, function(i, cell) {
            $('#tictactoecell-' + cell[0] + '-' + cell[1]).empty().append($(img));
        });
    });
    $('td.tictactoecell:empty').click(id, move);
    $('td.tictactoecell:empty').append($(blank));
    $('#matchModal').on("hide.bs.modal", function() {
        console.log()
        getMatches();
    });
    $('#matchModal').modal();
}

$(document).ready(function() {
    $("#loginButton").click(doLogin);
    $("#matchesButton").click(getMatches);
});