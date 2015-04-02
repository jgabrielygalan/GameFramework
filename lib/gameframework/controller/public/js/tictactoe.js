var domImgs = [[]];
var img_o = 'images/o.png';
var img_x = 'images/x.png';
var img_empty = 'images/empty.png';
var idArray = [];
var loadState = null;

//loadState = [["@","X",null],[null,"@","X"],["@",null,"X"]];



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

function loadBoard(){
    console.log(loadState);
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


