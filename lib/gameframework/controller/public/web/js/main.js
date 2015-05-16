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
        var table = document.createElement('table');
        table.classList.add("table");
        var tbody = document.createElement('tbody');
        table.appendChild(tbody);
        var tr = document.createElement('tr');
        var td1 = document.createElement('td');
        var text1 = document.createTextNode('ID');
        td1.appendChild(text1);
        var td2 = document.createElement('td');
        var text2 = document.createTextNode('Active player');
        td2.appendChild(text2);
        var td3 = document.createElement('td');
        var text3 = document.createTextNode('Open');
        td3.appendChild(text3);

        tr.appendChild(td1);
        tr.appendChild(td2);
        tr.appendChild(td3);

        tbody.appendChild(tr);

        $.each(data, function(i, match) {
            matches[match.data.id] = match;
            var tr = document.createElement('tr');
            if (match.data.match_finished) {
                tr.classList.add("info");
            } else if (match.data.active_player === loggedPlayer) {
                tr.classList.add("danger");
            }
            var td1 = document.createElement('td');
            var text1 = document.createTextNode(match.data.id);
            td1.appendChild(text1);
            var td2 = document.createElement('td');
            var text2 = document.createTextNode(match.data.active_player);
            td2.appendChild(text2);
            var td3 = document.createElement('td');
            if (!match.data.match_finished) {
                var btn = document.createElement('button');
                var text3 = document.createTextNode("Open");
                btn.appendChild(text3);
                btn.setAttribute("id", "matchButton" + i);            
                btn.classList.add("btn");
                btn.classList.add("btn-primary");
                btn.classList.add("matchButton");
                btn.setAttribute("data-matchId", match.data.id);
                td3.appendChild(btn);
            }
            tr.appendChild(td1);
            tr.appendChild(td2);
            tr.appendChild(td3);
            tbody.appendChild(tr);
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
    var id = event.target.getAttribute("data-matchid");
    var match = matches[id];
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