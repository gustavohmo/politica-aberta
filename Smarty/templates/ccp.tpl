<!DOCTYPE html>
<html>
<head>
	<!-- Title -->
	<title>Política Aberta</title>
    <link rel="Shortcut Icon" href="/favicon.ico" type="image/x-icon" />

	<!-- Info -->
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script src="/js4/ga.js" type="text/javascript"></script>


    <!-- Styles -->
	<link rel="stylesheet" type="text/css" media="all" href="/stylesheets/master2.css" />

	<!-- JavaScript -->
{include file="parcial_scripts.tpl"}


    <script type="text/javascript">
       /* if (typeof jQuery.ui !== 'undefined'){
            alert('jQuery UI loaded');
        } */
    </script>
    <script type="text/javascript">
        {literal}
        function formataReal(nStr) {
            nStr += '';
            var x = nStr.split('.');
            var x1 = x[0];
            var x2 = x.length > 1 ? ',' + x[1] : '';
            var rgx = /(\d+)(\d{3})/;
            while (rgx.test(x1)) {
                x1 = x1.replace(rgx, '$1' + '.' + '$2');
            }
            return x1 + x2;
        }
        {/literal}
    </script>
    <script type="text/javascript">
        {literal}
        $(function(){

            /* Plotando o grafico */
            var doacoes_pessoa_juridica = $("#doacoes_pessoa_juridica").prop("title");
            var doacoes_partido = $("#doacoes_partido").prop("title");
            var doacoes_pessoa_fisica = $("#doacoes_pessoa_fisica").prop("title");
            var doacoes_outros = $("#doacoes_outros").prop("title");
            var doacoes_proprios = $("#doacoes_proprios").prop("title");
            var doacoes_internet = $("#doacoes_internet").prop("title");
            var doacoesTotal = (1*doacoes_pessoa_juridica) + (1*doacoes_partido) + (1*doacoes_pessoa_fisica) + (1*doacoes_outros) + (1*doacoes_proprios) + (1*doacoes_internet);

            var doacoes_pessoa_juridica_percent = ((doacoes_pessoa_juridica/doacoesTotal)*100).toFixed(2);
            var doacoes_partido_percent = ((doacoes_partido/doacoesTotal)*100).toFixed(2);
            var doacoes_pessoa_fisica_percent = ((doacoes_pessoa_fisica/doacoesTotal)*100).toFixed(2);
            var doacoes_outros_percent = ((doacoes_outros/doacoesTotal)*100).toFixed(2);
            var doacoes_proprios_percent = ((doacoes_proprios/doacoesTotal)*100).toFixed(2);
            var doacoes_internet_percent = ((doacoes_internet/doacoesTotal)*100).toFixed(2);

            CanvasJS.addCultureInfo("br",
                    {
                        decimalSeparator: ",",
                        digitGroupSeparator: ".",
                    });



            var chart = new CanvasJS.Chart("chartContainer",
                    {
                        culture: "br",
                        axisY:{
                            valueFormatString: ""
                        },
                        data: [
                            {
                                type: "doughnut",
                                dataPoints: [
                                    {  y: doacoes_pessoa_juridica_percent, indexLabel: "P. Jurídicas" },
                                    {  y: doacoes_pessoa_fisica_percent, indexLabel: "P. Físicas" },
                                    {  y: doacoes_partido_percent, indexLabel: "Partido" },
                                    {  y: doacoes_outros_percent, indexLabel: "Candidatos/comitês" },
                                    {  y: doacoes_proprios_percent, indexLabel: "Recursos próprios" },
                                    {  y: doacoes_internet_percent, indexLabel: "Via Internet" }
                                ]
                            }
                        ]
                    });

            chart.render();

            /* Inicializanto os tabs */
            $('.tabs').tabs({
/*                beforeLoad: function(event,ui) {
                    // if the target panel is empty, return true
                    return ui.panel.html() == "";
                },
                load: function(event,ui) {
                    id_tab = ui.tab.attr('id');
                    switch(id_tab) {
                        case "partido":
                            initDataTableDoacoesPartido();
                            break;
                        case "fisicas":
                            initDataTableDoacoesFisicas();
                            break;
                        case "outros":
                            initDataTableDoacoesOutros();
                            break;
                        case "proprios":
                            initDataTableDoacoesProprios();
                            break;
                        case "internet":
                            initDataTableDoacoesInternet();
                            break;
                    }
                }*/
            });
            $(".tabs").css("min-height", "500px")

            /* Evento click - Chamada ajax das tabs */
            var tabsDoacao = new Array();
            tabsDoacao[0] = 'partido';
            tabsDoacao[1] = 'fisicas';
            tabsDoacao[2] = 'juridicas';
            tabsDoacao[3] = 'outros';
            tabsDoacao[4] = 'proprios';
            tabsDoacao[5] = 'internet';
            $('body').delegate(".LinkPag","click",function() {
                carregaTab(this);
            });


            $('ul.tab-nav li').click(function(){
                $('ul.tab-nav li').removeClass('ui-tabs-selected');
                $(this).addClass('ui-tabs-selected');
                /* Se a div estiver vazia, carrega a tab */
                var link = this.title;
                var link_array = link.split("/");
                var link_array_tipo_receita = link_array[3] * 1;

                var tab_doacao = tabsDoacao[link_array_tipo_receita];
                tab_doacao = "#tab-" + tab_doacao;
                if ($(tab_doacao).html() == '') {
                    carregaTab(this);
                }
            });


            /* Inicializanto os datatables */
            initDataTableDoacoesJuridicas();

            function carregaTab(carr) {
                var request;
                var link = carr.title;
                var link_array = link.split("/");
                var link_array_tipo_receita = link_array[3] * 1;

                var tab_doacao = tabsDoacao[link_array_tipo_receita];
                tab_doacao = "#tab-" + tab_doacao;

                $(tab_doacao).spin({
                    lines: 13, // The number of lines to draw
                    length: 16, // The length of each line
                    width: 4, // The line thickness
                    radius: 30, // The radius of the inner circle
                    corners: 1, // Corner roundness (0..1)
                    rotate: 0, // The rotation offset
                    direction: 1, // 1: clockwise, -1: counterclockwise
                    color: '#000', // #rgb or #rrggbb or array of colors
                    speed: 1, // Rounds per second
                    trail: 60, // Afterglow percentage
                    shadow: false, // Whether to render a shadow
                    hwaccel: false, // Whether to use hardware acceleration
                    className: 'spinner', // The CSS class to assign to the spinner
                    zIndex: 2e9, // The z-index (defaults to 2000000000)
                    top: 'auto', // Top position relative to parent in px
                    left: 'auto' // Left position relative to parent in px
                });

                request = $.ajax({
                    url: link,
                    cache: false,
                    type: "get"
                })
                        .done(function(resultado) {
                            /*alert( "success" );*/
                            $(tab_doacao).html(resultado);
                            switch(link_array_tipo_receita) {
                                case 0:
                                    initDataTableDoacoesPartido();
                                    break;
                                case 1:
                                    initDataTableDoacoesFisicas();
                                    break;
                                case 2:
                                    initDataTableDoacoesJuridicas();
                                    break;
                                case 3:
                                    initDataTableDoacoesOutros();
                                    break;
                                case 4:
                                    initDataTableDoacoesProprios();
                                    break;
                                case 5:
                                    initDataTableDoacoesInternet();
                                    break;
                            }
                        })
                        .fail(function() {
                            alert( "Ocorreu um erro ao buscar os dados. Por favor tente mais tarde." );
                            $(tab_doacao).spin(false);
                        })
                        .always(function() {
                            $(tab_doacao).spin(false);
                        });
            }

            /* Evento click - Mostra detalhes de DoacoesJuridicas */
            $(document).on("click","#tabela-doacoes-juridicas tbody td img",function() {
                var nTr = $(this).parents('tr')[0];
                if ($(this).attr("isOpen") == "true") {
                    /* This row is already open - close it */
                    this.src = "/imagens/details_open.png";
                    tabelaDoacoesJuridicas.fnClose( nTr );
                    $(this).attr("isOpen","false");
                }
                else {
                    /* Open this row */
                    this.src = "/imagens/details_close.png";
                    tabelaDoacoesJuridicas.fnOpen( nTr, detalhesDoacoes(tabelaDoacoesJuridicas, nTr), 'details' );
                    $(this).attr("isOpen","true");
                }
            });

            /* Evento click - Mostra detalhes de DoacoesPartido */
            $(document).on("click","#tabela-doacoes-partido tbody td img",function() {
                var nTr = $(this).parents('tr')[0];
                if ($(this).attr("isOpen") == "true") {
                    /* This row is already open - close it */
                    this.src = "/imagens/details_open.png";
                    tabelaDoacoesPartido.fnClose( nTr );
                    $(this).attr("isOpen","false");
                }
                else {
                    /* Open this row */
                    this.src = "/imagens/details_close.png";
                    tabelaDoacoesPartido.fnOpen( nTr, detalhesDoacoes(tabelaDoacoesPartido, nTr), 'details' );
                    $(this).attr("isOpen","true");
                }
            });

            /* Evento click - Mostra detalhes de DoacoesFisicas */
            $(document).on("click","#tabela-doacoes-fisicas tbody td img",function() {
                var nTr = $(this).parents('tr')[0];
                if ($(this).attr("isOpen") == "true") {
                    /* This row is already open - close it */
                    this.src = "/imagens/details_open.png";
                    tabelaDoacoesFisicas.fnClose( nTr );
                    $(this).attr("isOpen","false");
                }
                else {
                    /* Open this row */
                    this.src = "/imagens/details_close.png";
                    tabelaDoacoesFisicas.fnOpen( nTr, detalhesDoacoes(tabelaDoacoesFisicas, nTr), 'details' );
                    $(this).attr("isOpen","true");
                }
            });

            /* Evento click - Mostra detalhes de DoacoesOutros */
            $(document).on("click","#tabela-doacoes-outros tbody td img",function() {
                var nTr = $(this).parents('tr')[0];
                if ($(this).attr("isOpen") == "true") {
                    /* This row is already open - close it */
                    this.src = "/imagens/details_open.png";
                    tabelaDoacoesOutros.fnClose( nTr );
                    $(this).attr("isOpen","false");
                }
                else {
                    /* Open this row */
                    this.src = "/imagens/details_close.png";
                    tabelaDoacoesOutros.fnOpen( nTr, detalhesDoacoes(tabelaDoacoesOutros, nTr), 'details' );
                    $(this).attr("isOpen","true");
                }
            });

            /* Evento click - Mostra detalhes de DoacoesProprios */
            $(document).on("click","#tabela-doacoes-proprios tbody td img",function() {
                var nTr = $(this).parents('tr')[0];
                if ($(this).attr("isOpen") == "true") {
                    /* This row is already open - close it */
                    this.src = "/imagens/details_open.png";
                    tabelaDoacoesProprios.fnClose( nTr );
                    $(this).attr("isOpen","false");
                }
                else {
                    /* Open this row */
                    this.src = "/imagens/details_close.png";
                    tabelaDoacoesProprios.fnOpen( nTr, detalhesDoacoes(tabelaDoacoesProprios, nTr), 'details' );
                    $(this).attr("isOpen","true");
                }
            });

            /* Evento click - Mostra detalhes de DoacoesInternet */
            $(document).on("click","#tabela-doacoes-internet tbody td img",function() {
                var nTr = $(this).parents('tr')[0];
                if ($(this).attr("isOpen") == "true") {
                    /* This row is already open - close it */
                    this.src = "/imagens/details_open.png";
                    tabelaDoacoesInternet.fnClose( nTr );
                    $(this).attr("isOpen","false");
                }
                else {
                    /* Open this row */
                    this.src = "/imagens/details_close.png";
                    tabelaDoacoesInternet.fnOpen( nTr, detalhesDoacoes(tabelaDoacoesInternet, nTr), 'details' );
                    $(this).attr("isOpen","true");
                }
            });

            function initDataTableDoacoesJuridicas(){
                window.tabelaDoacoesJuridicas = $("#tabela-doacoes-juridicas").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* Detalhes */        { "bSearchable": false,
                                                "sWidth": "3%" },
                        /* Nome Doador */     { "sWidth": "52%" },
                        /* Especie recurso */ { "sWidth": "30%" },
                        /* Data doacao */     { "sWidth": "15%",
                                                "iDataSort": 5},
                        /* Valor */           { "sType": "title-numeric",
                                                "sWidth": "20%" },
                        /* Data pag. sort */  { "bSearchable": false,
                                                "bVisible":    false },
                        /* Numero rec. el.*/  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false },
                        /* Descricao rec. */  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false }
                    ],
                    "aaSorting": [[4, "desc"]],
                    "bFilter": true,
                    "bInfo": false,
                    "bPaginate": false,
                    "oLanguage": {
                        "sSearch": "Buscar:",
                        "sZeroRecords": "Nenhum registro encontrado"
                    },
                    "fnFooterCallback" : function(nRow, aaData, iStart, iEnd,
                                                  aiDisplay) {
                        var iTotalValor = 0;
                        /*var xItem = 0;
                         /*var xItem2 = 0;
                         /*var iTotalNumb = 0;*/
                        if (aaData.length > 0) {
                            for ( var i = 0; i < aaData.length; i++) {
                                /* O indice 2 refere-se a coluna do valor */
                                /* xItem = aaData[i][2];/*.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );*/
                                /* xItem = xItem.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
                                 /*xItem2 = parseFloat(xItem);*/
                                /* iTotalValor += (xItem);
                                 /*iTotalNumb += aaData[i].numb;*/
                                /* Adicionei o OR (||) abaixo porque caso o aaData estivesse vazio, dava TypeError */
                                var x = (aaData[i][4].match(/title="*(-?[0-9\.]+)/) || 0)[1];
                                iTotalValor += parseFloat(x);
                            }
                        }
                        /*
                         * render the total row in table footer
                         */
                        if (isNaN(iTotalValor)) {
                            iTotalValor = 0;
                        }
                        iTotalValor = iTotalValor.toFixed(2);
                        iTotalValor = "R$ " + formataReal(iTotalValor);
                        /*iTotalValor = formataReal(iTotalValor,".",2);*/

                        /*alert(iTotalValor);*/
                        var nCells = nRow.getElementsByTagName('th');
                        nCells[1].innerHTML = iTotalValor;
                        /*nCells[2].innerHTML = iTotalNumb;*/

                    }
                });
            }

            function initDataTableDoacoesPartido(){
                window.tabelaDoacoesPartido = $("#tabela-doacoes-partido").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* Detalhes */        { "bSearchable": false,
                                                "sWidth": "3%" },
                        /* Nome Doador */     { "sWidth": "52%" },
                        /* Especie recurso */ { "sWidth": "30%" },
                        /* Data doacao */     { "sWidth": "15%",
                                                "iDataSort": 5},
                        /* Valor */           { "sType": "title-numeric",
                                                "sWidth": "20%" },
                        /* Data pag. sort */  { "bSearchable": false,
                                                "bVisible":    false },
                        /* Numero rec. el.*/  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false },
                        /* Descricao rec. */  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false }
                    ],
                    "aaSorting": [[4, "desc"]],
                    "bFilter": true,
                    "bInfo": false,
                    "bPaginate": false,
                    "oLanguage": {
                        "sSearch": "Buscar:",
                        "sZeroRecords": "Nenhum registro encontrado"
                    },
                    "fnFooterCallback" : function(nRow, aaData, iStart, iEnd,
                                                  aiDisplay) {
                        var iTotalValor = 0;
                        /*var xItem = 0;
                         /*var xItem2 = 0;
                         /*var iTotalNumb = 0;*/
                        if (aaData.length > 0) {
                            for ( var i = 0; i < aaData.length; i++) {
                                /* O indice 2 refere-se a coluna do valor */
                                /* xItem = aaData[i][2];/*.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );*/
                                /* xItem = xItem.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
                                 /*xItem2 = parseFloat(xItem);*/
                                /* iTotalValor += (xItem);
                                 /*iTotalNumb += aaData[i].numb;*/
                                /* Adicionei o OR (||) abaixo porque caso o aaData estivesse vazio, dava TypeError */
                                var x = (aaData[i][4].match(/title="*(-?[0-9\.]+)/) || 0)[1];
                                iTotalValor += parseFloat(x);
                            }
                        }
                        /*
                         * render the total row in table footer
                         */
                        if (isNaN(iTotalValor)) {
                            iTotalValor = 0;
                        }
                        iTotalValor = iTotalValor.toFixed(2);
                        iTotalValor = "R$ " + formataReal(iTotalValor);
                        /*iTotalValor = formataReal(iTotalValor,".",2);*/

                        /*alert(iTotalValor);*/
                        var nCells = nRow.getElementsByTagName('th');
                        nCells[1].innerHTML = iTotalValor;
                        /*nCells[2].innerHTML = iTotalNumb;*/

                    }
                });
            }

            function initDataTableDoacoesFisicas(){
                window.tabelaDoacoesFisicas = $("#tabela-doacoes-fisicas").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* Detalhes */        { "bSearchable": false,
                                                "sWidth": "3%" },
                        /* Nome Doador */     { "sWidth": "52%" },
                        /* Especie recurso */ { "sWidth": "30%" },
                        /* Data doacao */     { "sWidth": "15%",
                                                "iDataSort": 5},
                        /* Valor */           { "sType": "title-numeric",
                                                "sWidth": "20%" },
                        /* Data pag. sort */  { "bSearchable": false,
                                                "bVisible":    false },
                        /* Numero rec. el.*/  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false },
                        /* Descricao rec. */  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false }
                    ],
                    "aaSorting": [[4, "desc"]],
                    "bFilter": true,
                    "bInfo": false,
                    "bPaginate": false,
                    "oLanguage": {
                        "sSearch": "Buscar:",
                        "sZeroRecords": "Nenhum registro encontrado"
                    },
                    "fnFooterCallback" : function(nRow, aaData, iStart, iEnd,
                                                  aiDisplay) {
                        var iTotalValor = 0;
                        /*var xItem = 0;
                         /*var xItem2 = 0;
                         /*var iTotalNumb = 0;*/
                        if (aaData.length > 0) {
                            for ( var i = 0; i < aaData.length; i++) {
                                /* O indice 2 refere-se a coluna do valor */
                                /* xItem = aaData[i][2];/*.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );*/
                                /* xItem = xItem.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
                                 /*xItem2 = parseFloat(xItem);*/
                                /* iTotalValor += (xItem);
                                 /*iTotalNumb += aaData[i].numb;*/
                                /* Adicionei o OR (||) abaixo porque caso o aaData estivesse vazio, dava TypeError */
                                var x = (aaData[i][4].match(/title="*(-?[0-9\.]+)/) || 0)[1];
                                iTotalValor += parseFloat(x);
                            }
                        }
                        /*
                         * render the total row in table footer
                         */
                        if (isNaN(iTotalValor)) {
                            iTotalValor = 0;
                        }
                        iTotalValor = iTotalValor.toFixed(2);
                        iTotalValor = "R$ " + formataReal(iTotalValor);
                        /*iTotalValor = formataReal(iTotalValor,".",2);*/

                        /*alert(iTotalValor);*/
                        var nCells = nRow.getElementsByTagName('th');
                        nCells[1].innerHTML = iTotalValor;
                        /*nCells[2].innerHTML = iTotalNumb;*/

                    }
                });
            }

            function initDataTableDoacoesOutros(){
                window.tabelaDoacoesOutros = $("#tabela-doacoes-outros").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* Detalhes */        { "bSearchable": false,
                                                "sWidth": "3%" },
                        /* Nome Doador */     { "sWidth": "52%" },
                        /* Especie recurso */ { "sWidth": "30%" },
                        /* Data doacao */     { "sWidth": "15%",
                                                "iDataSort": 5},
                        /* Valor */           { "sType": "title-numeric",
                                                "sWidth": "20%" },
                        /* Data pag. sort */  { "bSearchable": false,
                                                "bVisible":    false },
                        /* Numero rec. el.*/  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false },
                        /* Descricao rec. */  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false }
                    ],
                    "aaSorting": [[4, "desc"]],
                    "bFilter": true,
                    "bInfo": false,
                    "bPaginate": false,
                    "oLanguage": {
                        "sSearch": "Buscar:",
                        "sZeroRecords": "Nenhum registro encontrado"
                    },
                    "fnFooterCallback" : function(nRow, aaData, iStart, iEnd,
                                                  aiDisplay) {
                        var iTotalValor = 0;
                        /*var xItem = 0;
                         /*var xItem2 = 0;
                         /*var iTotalNumb = 0;*/
                        if (aaData.length > 0) {
                            for ( var i = 0; i < aaData.length; i++) {
                                /* O indice 2 refere-se a coluna do valor */
                                /* xItem = aaData[i][2];/*.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );*/
                                /* xItem = xItem.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
                                 /*xItem2 = parseFloat(xItem);*/
                                /* iTotalValor += (xItem);
                                 /*iTotalNumb += aaData[i].numb;*/
                                /* Adicionei o OR (||) abaixo porque caso o aaData estivesse vazio, dava TypeError */
                                var x = (aaData[i][4].match(/title="*(-?[0-9\.]+)/) || 0)[1];
                                iTotalValor += parseFloat(x);
                            }
                        }
                        /*
                         * render the total row in table footer
                         */
                        if (isNaN(iTotalValor)) {
                            iTotalValor = 0;
                        }
                        iTotalValor = iTotalValor.toFixed(2);
                        iTotalValor = "R$ " + formataReal(iTotalValor);
                        /*iTotalValor = formataReal(iTotalValor,".",2);*/

                        /*alert(iTotalValor);*/
                        var nCells = nRow.getElementsByTagName('th');
                        nCells[1].innerHTML = iTotalValor;
                        /*nCells[2].innerHTML = iTotalNumb;*/

                    }
                });
            }

            function initDataTableDoacoesProprios(){
                window.tabelaDoacoesProprios = $("#tabela-doacoes-proprios").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* Detalhes */        { "bSearchable": false,
                                                "sWidth": "3%" },
                        /* Nome Doador */     { "sWidth": "52%" },
                        /* Especie recurso */ { "sWidth": "30%" },
                        /* Data doacao */     { "sWidth": "15%",
                                                "iDataSort": 5},
                        /* Valor */           { "sType": "title-numeric",
                                                "sWidth": "20%" },
                        /* Data pag. sort */  { "bSearchable": false,
                                                "bVisible":    false },
                        /* Numero rec. el.*/  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false },
                        /* Descricao rec. */  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false }
                    ],
                    "aaSorting": [[4, "desc"]],
                    "bFilter": true,
                    "bInfo": false,
                    "bPaginate": false,
                    "oLanguage": {
                        "sSearch": "Buscar:",
                        "sZeroRecords": "Nenhum registro encontrado"
                    },
                    "fnFooterCallback" : function(nRow, aaData, iStart, iEnd,
                                                  aiDisplay) {
                        var iTotalValor = 0;
                        /*var xItem = 0;
                         /*var xItem2 = 0;
                         /*var iTotalNumb = 0;*/
                        if (aaData.length > 0) {
                            for ( var i = 0; i < aaData.length; i++) {
                                /* O indice 2 refere-se a coluna do valor */
                                /* xItem = aaData[i][2];/*.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );*/
                                /* xItem = xItem.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
                                 /*xItem2 = parseFloat(xItem);*/
                                /* iTotalValor += (xItem);
                                 /*iTotalNumb += aaData[i].numb;*/
                                /* Adicionei o OR (||) abaixo porque caso o aaData estivesse vazio, dava TypeError */
                                var x = (aaData[i][4].match(/title="*(-?[0-9\.]+)/) || 0)[1];
                                iTotalValor += parseFloat(x);
                            }
                        }
                        /*
                         * render the total row in table footer
                         */
                        if (isNaN(iTotalValor)) {
                            iTotalValor = 0;
                        }
                        iTotalValor = iTotalValor.toFixed(2);
                        iTotalValor = "R$ " + formataReal(iTotalValor);
                        /*iTotalValor = formataReal(iTotalValor,".",2);*/

                        /*alert(iTotalValor);*/
                        var nCells = nRow.getElementsByTagName('th');
                        nCells[1].innerHTML = iTotalValor;
                        /*nCells[2].innerHTML = iTotalNumb;*/

                    }
                });
            }

            function initDataTableDoacoesInternet(){
                window.tabelaDoacoesInternet = $("#tabela-doacoes-internet").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* Detalhes */        { "bSearchable": false,
                                                "sWidth": "3%" },
                        /* Nome Doador */     { "sWidth": "52%" },
                        /* Especie recurso */ { "sWidth": "30%" },
                        /* Data doacao */     { "sWidth": "15%",
                                                "iDataSort": 5},
                        /* Valor */           { "sType": "title-numeric",
                                                "sWidth": "20%" },
                        /* Data pag. sort */  { "bSearchable": false,
                                                "bVisible":    false },
                        /* Numero rec. el.*/  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false },
                        /* Descricao rec. */  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false }
                    ],
                    "aaSorting": [[4, "desc"]],
                    "bFilter": true,
                    "bInfo": false,
                    "bPaginate": false,
                    "oLanguage": {
                        "sSearch": "Buscar:",
                        "sZeroRecords": "Nenhum registro encontrado"
                    },
                    "fnFooterCallback" : function(nRow, aaData, iStart, iEnd,
                                                  aiDisplay) {
                        var iTotalValor = 0;
                        /*var xItem = 0;
                         /*var xItem2 = 0;
                         /*var iTotalNumb = 0;*/
                        if (aaData.length > 0) {
                            for ( var i = 0; i < aaData.length; i++) {
                                /* O indice 2 refere-se a coluna do valor */
                                /* xItem = aaData[i][2];/*.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );*/
                                /* xItem = xItem.replace("R$ ","").replace( /\./g, "" ).replace( /,/, "." );
                                 /*xItem2 = parseFloat(xItem);*/
                                /* iTotalValor += (xItem);
                                 /*iTotalNumb += aaData[i].numb;*/
                                /* Adicionei o OR (||) abaixo porque caso o aaData estivesse vazio, dava TypeError */
                                var x = (aaData[i][4].match(/title="*(-?[0-9\.]+)/) || 0)[1];
                                iTotalValor += parseFloat(x);
                            }
                        }
                        /*
                         * render the total row in table footer
                         */
                        if (isNaN(iTotalValor)) {
                            iTotalValor = 0;
                        }
                        iTotalValor = iTotalValor.toFixed(2);
                        iTotalValor = "R$ " + formataReal(iTotalValor);
                        /*iTotalValor = formataReal(iTotalValor,".",2);*/

                        /*alert(iTotalValor);*/
                        var nCells = nRow.getElementsByTagName('th');
                        nCells[1].innerHTML = iTotalValor;
                        /*nCells[2].innerHTML = iTotalNumb;*/

                    }
                });
            }


            /* Funcao para mostrar detalhes Pagamentos */
            function detalhesDoacoes ( oTable, nTr ) {
                var aData = oTable.fnGetData( nTr );
                var sOut = '<table style="width: 102.3%">';
                sOut += '<tr><td>Número do documento:</td><td>' + aData[6] + '</td></tr>';
                sOut += '<tr><td>Descricao da doação:</td><td>' + aData[7] + '</td></tr>';
                sOut += '</table>';
                return sOut;
            }
        });
        {/literal}
    </script>
    <script type="text/javascript">
    {literal}

     {/literal}
    </script>
</head>
<body>
{include file='parcial_facebook.tpl'}

{include file='parcial_pag_topo_nav.tpl' capa_class='' sobre_class='' blog_class=''}
{include file='parcial_pag_topo.tpl'}
{include file='parcial_pag_topo_stats.tpl'}
<hr>

  <div class="clear"></div>

  <div id="bio">
    <div id="bio-primary">
      <h1>{$nome_ccp} <span>({$tipo_ccp}{$cargo}{$municipio})</span></h1>
      <div class="c2l">
	      <ul class="stats">
	      	<li><strong>{$doacoes_total}</strong> recebidos em doações p/ campanhas ({$doacoes_anos})</li>
              <p>
                  <span id="doacoes_pessoa_juridica" title="{$doacoes_pessoa_juridica_noformat}">{$doacoes_pessoa_juridica}</span> de pessoas jurídicas<br>
                  <span id="doacoes_pessoa_fisica" title="{$doacoes_pessoa_fisica_noformat}">{$doacoes_pessoa_fisica}</span> de pessoas físicas<br>
                  <span id="doacoes_partido" title="{$doacoes_partido_noformat}">{$doacoes_partido}</span> de partido político<br>
                  <span id="doacoes_outros" title="{$doacoes_outros_noformat}">{$doacoes_outros}</span> de outros candidatos/comitês<br>
                  <span id="doacoes_proprios" title="{$doacoes_proprios_noformat}">{$doacoes_proprios}</span> de recursos próprios<br>
                  <span id="doacoes_internet" title="{$doacoes_internet_noformat}">{$doacoes_internet}</span> de doações via Internet<br>
                  <span id="doacoes_comercializacao" title="{$doacoes_comercializacao_noformat}">{$doacoes_comercializacao}</span> de comercialização de bens e/ou realização de eventos<br>
                  <span id="doacoes_naoident" title="{$doacoes_naoident_noformat}">{$doacoes_naoident}</span> de origens não identificadas<br>
                  <span id="doacoes_financeiras" title="{$doacoes_financeiras_noformat}">{$doacoes_naoident}</span> de aplicações financeiras<br>


              </p>
	      </ul>
      </div>
      <div class="c2r">
      	<ul class="stats">
            <div id="chartContainer" style="height: 250px; width: 70%; margin-left: 30px;"></div>
	        <!--<li><strong>00</strong> recebidos em contratos (00)</li>-->
	        <!--<li><strong>166</strong>  actions sought
	      	<p>
	      	  166 administrative
	          <br />156 legislative
	        </p>
	     	</li>-->
	     </ul>
      </div>

      <div class="clear"></div>

      <div class="tabs">
        <ul class="tab-nav">
        	<li id="juridicas" title="/ccp_tab/{$tipo_ccp}/2/{$codigo_ccp}/1" class="ui-tabs-selected" onclick="return false;"><a href="#tab-juridicas">Pessoas jurídicas <span class="mute">({$doacoes_pessoas_juridicas_num})</span></a></li>
        	<li id="partido" title="/ccp_tab/{$tipo_ccp}/0/{$codigo_ccp}/1"><a href="#tab-partido" onclick="return false;">Partido <span class="mute">({$doacoes_partido_num})</span></a></li>
            <li id="fisicas" title="/ccp_tab/{$tipo_ccp}/1/{$codigo_ccp}/1"><a href="#tab-fisicas">Pessoas físicas <span class="mute">({$doacoes_pessoas_fisicas_num})</span></a></li>
            <li id="outros" title="/ccp_tab/{$tipo_ccp}/3/{$codigo_ccp}/1"><a href="#tab-outros" onclick="javascript:void(0);">Outros c/c <span class="mute">({$doacoes_outros_num})</span></a></li>
            <li id="proprios" title="/ccp_tab/{$tipo_ccp}/4/{$codigo_ccp}/1"><a href="#tab-proprios" onclick="return false;">Próprios <span class="mute">({$doacoes_proprios_num})</span></a></li>
            <li id="internet" title="/ccp_tab/{$tipo_ccp}/5/{$codigo_ccp}/1"><a href="#tab-internet" onclick="return false;">Internet <span class="mute">({$doacoes_internet_num})</span></a></li>

        	<!--<li><a href="#tab-comments" onclick="return false;">Comments</a></li>-->
        </ul>



          <div class="tab-content" id="tab-juridicas"><!-- inicio tab-doacoes-juridicas-->

          <h2 class="table-head">Doações recebidas de pessoas jurídicas</h2>
		  <table id="tabela-doacoes-juridicas" class="datatable lobbyist-actions">
	        <thead>
	          <tr>
                <th></th><!-- Coluna detalhes -->
	            <th class="purpose"><span>Nome doador</span></th>
	            <th class="client"><span>Espécie recurso</span></th>
                <th class="actions"><span>Data doação</span></th>
                <th class="actions"><span>Valor</span></th>
	          </tr>
	        </thead>
	        <tbody>
            {if $doacoes_juridicas_vazio != ''}
                <tr>
                    <td></td>
                    <td class="nb">{$doacoes_juridicas_vazio}</td>
                    <td></td>
                    <td class="bar"></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
            {else}
            {foreach $doacao_juridicas_array as $d}
	          <tr>
                <td><img src="/imagens/details_open.png" style="cursor: pointer;"></td>
	          	<td><a href="/entidade/{$d.cod_doador}/{$d.nome_link}">{$d.nome_doador}</a></td>
	          	<td>{$d.especie_recurso}</td>
                <td>{$d.data_receita}</td>
                <td class="bar"><span style="width:{$d.percent}%;" title="{$d.valor_sem_formato}"><strong style="white-space: nowrap;">R$ {$d.valor}</strong></span></td>
                <td>{$d.data_receita_sort}</td>
                <td>{$d.numero_documento}</td>
                <td>{$d.descricao_receita}</td>
	          </tr>
	        {/foreach}
            {/if}

            </tbody>
              <tfoot>
              <tr>
                  <th style="text-align:right" colspan="4">Total:</th>
                  <th></th>
              </tr>
              </tfoot>
	      </table>
          {foreach $paginacao_doacoes_juridicas as $p}
             {if $p.selecionada == 1}<b>{/if}
             <a class="LinkPag" href="#" title="/ccp_tab/{$tipo_ccp}/2/{$codigo_ccp}/{$p.pg}" onclick="return false;">{$p.range}</a>
             {if $p.selecionada == 1}</b>{/if}
          {/foreach}
      	</div><!-- fim tab-doacoes-juridicas-->

          <div class="tab-content" id="tab-partido"></div>
          <div class="tab-content" id="tab-fisicas"></div>
          <div class="tab-content" id="tab-outros"></div>
          <div class="tab-content" id="tab-proprios"></div>
          <div class="tab-content" id="tab-internet"></div>


          </div><!-- end tabs-->
    </div><!-- end bio-primary-->


  </div><!-- /.bio -->

  <div class="clear"></div>

<!-- Footer -->
{include file='parcial_pag_foot_nav.tpl'}
<!-- /Footer -->

</div>
<!-- /Content -->

</body>
</html>
