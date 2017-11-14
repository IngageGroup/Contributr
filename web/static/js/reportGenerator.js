const HEADER_FS = 10;
const CONTENT_FS = 16;
const STEP = 10;
const FIRST_LINE = 20;
const LAST_LINE = 270;
const LEFT_MARGIN = 10;
const RIGHT_MARGIN = 180;

let DOC = null;
let line = 0;

let eventName = "";
let userName = "";

function addPageHeader(){
    if(userName && line === FIRST_LINE){
        DOC.setFontSize(HEADER_FS);
        let headerText = "Comments for "+ userName;
        DOC.text("Comments for "+ userName, RIGHT_MARGIN-headerText.length, 5 );
        DOC.setFontSize(CONTENT_FS);
    }
}

function setupPage(){
    line = FIRST_LINE;
    addPageHeader();
}

function addPage(){
    DOC.addPage();
    setupPage()
}

function writeLine(text){
    //don't print any blanks or fail with undefineds
    if(text) {
        if (line <= LAST_LINE) {
            line = line + STEP;
            DOC.text(text , LEFT_MARGIN, line);
        } else {
            addPage();
            writeLine(text);
        }
    }
}

function wrapLine(text){
    let splitText = DOC.splitTextToSize(text, RIGHT_MARGIN);
    let needsLines = splitText.length * STEP;
    let totalLines = line + needsLines;
    if(totalLines > LAST_LINE){
        addPage();
    }
    splitText.forEach(writeLine)
}

function commentsForUser(user, index){
    eventName = user.event_name;
    userName = user.user_name;

    if(index === 0){
        setupPage()
    }else{
        addPage()
    }
    writeLine("Name : " + user.user_name+index);
    writeLine("Event: " +user.event_name);
    writeLine("Comments :");

    let comments = user.comments;
    if (comments) {
        comments.forEach(wrapLine)
    }
}


function contributionsByUser(user){
    let uName = user.user_name +"_"+ index;
    if(index === 0){
        setupPage()
    }else{
        addPage()
    }
    let msg = "User: " + user.user_name + " received " + user.total_received;
    writeLine(msg);
}

function initReport(){
    DOC = new jsPDF();
    line = 0;
    userName = "";
    eventName = "";
}



function commentReport(){
    let reportButton = $("#commentReport");
    let data = JSON.parse(reportButton.attr("data-report"));
    initReport();
    DOC = new jsPDF();
    data.forEach(commentsForUser);
    DOC.save(eventName+"comment-report.pdf")
}

function contributionReport(){
    let reportButton = $("#contribReport");
    let data = JSON.parse(reportButton.attr("data-report"));
    initReport();
    writeLine("Event: " +data[0].event_name);
    writeLine("Contributions to user: ");
    data.forEach(contributionsByUser);
    DOC.save(eventName+"contribution-report.pdf");
}

module.exports = commentReport;