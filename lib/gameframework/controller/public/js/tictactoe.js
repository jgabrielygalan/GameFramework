var img_o = 'images/o.png';
var img_x = 'images/x.png';
var img_empty = 'images/empty.png';
var symbol_o = "@";
var symbol_x = "X";
var symbol_empty = null;
var idArray = [];
var boardArray = [];
var finalBoardArray = [];
var loadState = null;
var finalState = [[null,null,null],[null,null,null],[null,null,null]];

loadState = [["@","X",null],[null,"@","X"],["@",null,"X"]];


function initBoardArray(){
    for(var i = 0; i < 3; i++){
        for(var j = 0; j < 3; j++){
            idArray.push('r' + i + 'c' + j);
        }
    }
}

function firstBoard(){
    var img;
    for(var i = 0; i < idArray.length; i++){
        img = document.getElementById(idArray[i]);
        img.src = img_empty;
    }
}

function putBoard(){
    for(var i = 0; i < idArray.length; i++){
        var img = document.getElementById(idArray[i]);
        img.src = boardArray[i];
    }
}

function createBoardArray(element){
    switch(element){
        case symbol_x:
            boardArray.push(img_x);
            break;
        case symbol_o:
            boardArray.push(img_o);
            break;
        default :
            boardArray.push(img_empty);
    }
}

function loadBoard(){
    for(var i = 0; i < 3; i++){
        var row = loadState[i];
        for(var j = 0; j < 3; j++){
            var element = row[j];
            createBoardArray(element);
            putBoard();
        }
    }
}

function initBoard(){
    initBoardArray();
    if (loadState === null){
        firstBoard();
    }
    else {
        loadBoard();
    }
}

window.onload = function(){
    initBoard();
}

function swapImg(idElement){
    var setImg = document.getElementById(idElement);
    if (setImg.src.includes(img_empty)) {
        setImg.src = img_o;
    }
    else {
        setImg.src = img_empty;
    }
}

function addfinalBoardArray(img){
    if (img.src.includes(img_o)){
        finalBoardArray.push(symbol_o);
    }
    else if (img.src.includes(img_x)){
        finalBoardArray.push(symbol_x);
    }
    else {
        finalBoardArray.push(symbol_empty);
    }
}

function getBoard(){
    var img = 0;
    for(i = 0; i < idArray.length; i++){
        img = document.getElementById(idArray[i]);
        addfinalBoardArray(img);
    }
}

function sendBoard(){
    getBoard();
    console.log(loadState);
    console.log(finalBoardArray);
    prepareFinalState();
    console.log(finalState);
}

function prepareFinalState(){
    for (var i = 0; i < 3; i++){
        var row = [];
        row.push(finalBoardArray.pop());
        console.log(row);
        finalState[i].push(row);
    }
}
