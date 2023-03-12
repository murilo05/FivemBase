window.addEventListener("load", function() {
    errdiv = document.createElement("div");
    if (true) {
        errdiv.classList.add("console");
        document.body.appendChild(errdiv);
        window.onerror = function(errorMsg, url, lineNumber, column, errorObj) {
            errdiv.innerHTML += '<br />Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber + ' Column: ' + column + ' StackTrace: ' + errorObj;
        }
    }

    var wprompt = new WPrompt();
    var requestmgr = new RequestManager();

    requestmgr.onResponse = function(id, ok) { $.post("http://vrp/request", JSON.stringify({ act: "response", id: id, ok: ok })); }
    wprompt.onClose = function() { $.post("http://vrp/prompt", JSON.stringify({ act: "close", result: wprompt.result })); }

    window.addEventListener("message", function(evt) {
        var data = evt["data"];

        if (data["act"] == "prompt") {
            wprompt.open(data["title"], data["text"]);
        }

        if (data["act"] == "request") {
            requestmgr.addRequest(data["id"], data["text"], data["accept"], data["reject"]);
        }

        if (data["act"] == "event") {
            if (data["event"] == "Y") {
                requestmgr.respond(true);
            } else if (data["event"] == "U") {
                requestmgr.respond(false);
            }
        }

        if (data["death"] == true) {
            $("#deathDiv").css("display", "flex");
        }

        if (data["death"] == false) {
            $("#deathDiv").css("display", "none");
        }

        if (data["deathtext"] !== undefined) {
            $("#deathText").html(data["deathtext"]);
        }

        if (data["identity"] !== undefined) {
            if (data["identity"] == false) {
                if ($("#identityDiv").css("display") === "flex") {
                    $("#identityDiv").css("display", "none");
                }
            } else {
                if ($("#identityDiv").css("display") === "none") {
                    $("#identityDiv").css("display", "flex");
                }

                if (data["mode"] == "identity") {
                    $("#identityDiv").html(`
                    <div class="identity"> 
                        <div class="doppler">
                            <div></div>
                        </div>
                        <div class="card">
                            <div class="name">${data["nome"]}</span></div>
                            <div class="identityInfo">Nacionalidade<br><span>${data["nacionalidade"]}</span></div>

                            <div class="identityInfo">Tipo Sanguíneo<br><span>${data["sangue"]}</span></div>
                            <div class="identityInfo">Máximo de Veículos<br><span>${format(data["veiculos"])}</span></div>

                            <div class="identityInfo">Total de Gemas<br><span>${format(data["gemas"])}</span></div>
                            <div class="identityInfo">Porte de Armas<br><span>${data["porte"] == 0 ? "Não":"Sim"}</span></div>

                            <div class="identityInfo">Premium<br><span>${data["premium"]}</span></div>
					    </div>
                    </div>`);
                } else {
                    $("#identityDiv").html(`
                    <div class="identity">
                        <div class="doppler">
                            <div></div>
                        </div>
                        <div class="card">
                            <div class="name">${data["nome"]}</span></div>
                            <div class="identityInfo">Nacionalidade<br><span>${data["nacionalidade"]}</span></div>

                            <div class="identityInfo">Porte de Armas<br><span>${data["porte"] == 0 ? "Não":"Sim"}</span></div>
                            <div class="identityInfo">Tipo Sanguíneo<br><span>${data["sangue"]}</span></div>
                            <div class="identityInfo">Profissão<br><span>${data["job"]}</span></div>
                        </div>
                    </div>`);
                }
            }
        }
    });
});
/* ----------FORMAT---------- */
const format = (n) => {
    var n = n.toString();
    var r = '';
    var x = 0;

    for (var i = n.length; i > 0; i--) {
        r += n.substr(i - 1, 1) + (x == 2 && i != 1 ? '.' : '');
        x = x == 2 ? 0 : x + 1;
    }

    return r.split('').reverse().join('');
}