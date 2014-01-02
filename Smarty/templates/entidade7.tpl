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
{include file='parcial_scripts.tpl'}

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
            /*            setBarWidthByCurrency();*/

            /* Inicializanto os tabs */
            $('.tabs').tabs();

            $('ul.tab-nav li').click(function(){
                $('ul.tab-nav li').removeClass('ui-tabs-selected');
                $(this).addClass('ui-tabs-selected');
            });


            /*
             * Insert a 'details' column to the table
             *
            var nCloneTh = document.createElement( 'th' );
            var nCloneTd = document.createElement( 'td' );
            nCloneTd.innerHTML = '<img src="/imagens/details_open.png">';
            /* nCloneTd.className = "center"; *

            $('#tabela-pagamentos thead tr').each( function () {
                this.insertBefore( nCloneTh, this.childNodes[0] );
            } );

            $('#tabela-pagamentos tbody tr').each( function () {
                this.insertBefore(  nCloneTd.cloneNode( true ), this.childNodes[0] );
            } );*/


            /* Inicializanto os datatables */
            initDataTablePagamentos();
            initDataTableDoacoes();

            /* Evento click - Chamada ajax do Tab de Pagamentos */
            $(document).on("click","a.LinkPag",function() {
                $("#tab-pagamentos").spin({
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
                var request;
                var link = this.title;
                var link_array = link.split("/");
                request = $.ajax({
                    url: link,
                    cache: false,
                    type: "get"
                })
                        .done(function(resultado) {
                            /*alert( "success" );*/
                            $("#tab-pagamentos").html(resultado);
                            initDataTablePagamentos();
                        })
                        .fail(function() {
                            alert( "Ocorreu um erro ao buscar os dados. Por favor tente mais tarde." );
                            $("tab-pagamentos").spin(false);
                        })
                        .always(function() {
                            /*alert( "complete" );*/
                            $("tab-pagamentos").spin(false);
                        });
            });

            /* Evento click - Chamada ajax do Tab de Doações */
            $(document).on("click","a.LinkDoa",function() {
                $("#tab-doacoes").spin({
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
                var request;
                var link = this.title;
                var link_array = link.split("/");
                request = $.ajax({
                    url: link,
                    cache: false,
                    type: "get"
                })
                        .done(function(resultado) {
                            /*alert( "success" );*/
                            $("#tab-doacoes").html(resultado);
                            initDataTableDoacoes();
                        })
                        .fail(function() {
                            alert( "Ocorreu um erro ao buscar os dados. Por favor tente mais tarde." );
                            $("tab-doacoes").spin(false);
                        })
                        .always(function() {
                            /*alert( "complete" );*/
                            $("tab-doacoes").spin(false);
                        });
            });

            /* Evento click - Mostra detalhes de pagamentos */
            $(document).on("click","#tabela-pagamentos tbody td img",function() {
                var nTr = $(this).parents('tr')[0];
                if ($(this).attr("isOpen") == "true") {
                    /* This row is already open - close it */
                    this.src = "/imagens/details_open.png";
                    tabelaPagamentos.fnClose( nTr );
                    $(this).attr("isOpen","false");
                }
                else {
                    /* Open this row */
                    this.src = "/imagens/details_close.png";
                    tabelaPagamentos.fnOpen( nTr, detalhesPagamentos(tabelaPagamentos, nTr), 'details' );
                    $(this).attr("isOpen","true");
                }
            });

            function initDataTablePagamentos(){
                window.tabelaPagamentos = $("#tabela-pagamentos").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* Detalhes */        { "bSearchable": false,
                                                "sWidth": "3%" },
                        /* Orgao superior */  { "sWidth": "32%" },
                        /* Tipo de despesa */ { "sWidth": "30%" },
                        /* Data pagamento */  { "sWidth": "15%",
                                                "iDataSort": 5},
                        /* Valor */           { "sType": "title-numeric",
                                                "sWidth": "20%" },
                        /* Data pag. sort */  { "bSearchable": false,
                                                "bVisible":    false },
                        /* Numero docum.  */  { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false },
                        /* Unidade gestora */ { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false },
                        /* Nome programa   */ { "bSortable": false,
                                                "bSearchable": false,
                                                "bVisible":    false },
                        /* Nome acao       */ { "bSortable": false,
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
            function detalhesPagamentos ( oTable, nTr ) {
                var aData = oTable.fnGetData( nTr );
                var sOut = '<table style="width: 102.3%">';
                sOut += '<tr><td>Número do documento:</td><td>' + aData[6] + '</td></tr>';
                sOut += '<tr><td>Unidade gestora:</td><td>' + aData[7] + '</td></tr>';
                sOut += '<tr><td>Programa:</td><td>' + aData[8] + '</td></tr>';
                sOut += '<tr><td>Ação:</td><td>' + aData[9] + '</td></tr>';
                sOut += '</table>';
                return sOut;
            }

            function initDataTableDoacoes(){
                $("#tabela-doacoes").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* CCP */    { "sWidth": "60%" },
                        /* Data */   { "sWidth": "20%",
                                       "iDataSort": 3},
                        /* Valor */  { "sType": "title-numeric",
                                       "sWidth": "20%" },
                      /* Data sort*/ { "bSortable": false,
                                       "bSearchable": false,
                                       "bVisible":    false }
                    ],
                    "aaSorting": [[2, "desc"]],
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
                        if (aaData.length > 0) {
                            for ( var i = 0; i < aaData.length; i++) {
                                var x = (aaData[i][2].match(/title="*(-?[0-9\.]+)/) || 0)[1];
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

                        var nCells = nRow.getElementsByTagName('th');
                        nCells[1].innerHTML = iTotalValor;
                    }
                });
            }

        });
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
      <h1>{$nome_entidade} <span>(pessoa jurídica)</span></h1>
      <div class="c2l">
	      <ul class="stats">
	      	<li><strong>{$doacoes_total}</strong> pagos em doações p/ campanhas ({$doacoes_anos})</li>
              <p>
                  {$doacoes_candidatos} para candidatos
                  <br>{$doacoes_partidos} para partidos
                  <br>{$doacoes_comites} para comitês
              </p>
              <!--<li><strong>123</strong>  partidos diferentes receberam doação (ano) </li>-->
	      </ul>
      </div>
      <div class="c2r">
      	<ul class="stats">
	        <li><strong>{$contratos_total}</strong> recebidos em contratos ({$contratos_anos})</li>
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
        	<li class="ui-tabs-selected" onclick="return false;"><a href="#tab-doacoes">Doações feitas <span class="mute">({$doacoes_itens_num})</span></a></li>
        	
        	<li><a href="#tab-pagamentos" onclick="return false;">Pagamentos recebidos <span class="mute">({$pagamentos_itens_num})</span></a></li>

        	<!--<li><a href="#tab-comments" onclick="return false;">Comments</a></li>-->
        </ul>



          <div class="tab-content" id="tab-pagamentos"><!-- inicio tab-pagamentos-->

          <h2 class="table-head">Pagamentos recebidos</h2>
		  <table id="tabela-pagamentos" class="datatable lobbyist-actions">
	        <thead>
	          <tr>
                <th></th><!-- Coluna detalhes -->
	            <th class="purpose"><span>Órgão pagador (Unidade interna)</span></th>
	            <th class="client"><span>Tipo despesa</span></th>
                <th class="actions"><span>Data pagamento</span></th>
                <th class="actions"><span>Valor</span></th>
	          </tr>
	        </thead>
	        <tbody>
            {if $pagamentos_vazio != ''}
                <tr>
                    <td></td>
                    <td class="nb">{$pagamentos_vazio}</td>
                    <td></td>
                    <td class="bar"></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
            {else}
            {foreach $pagamentos_recebidos as $p}
	          <tr>
                <td><img src="/imagens/details_open.png" style="cursor: pointer;"></td>
	          	<td>{$p.nome_orgao}</td>
	          	<td>{$p.nome_elemento_despesa}</td>
                <td>{$p.data_pagamento}</td>
                <td class="bar"><span style="width:{$p.percent}%;" title="{$p.valor_sem_formato}"><strong style="white-space: nowrap;">R$ {$p.valor}</strong></span></td>
                <td>{$p.data_pagamento_sort}</td>
                <td>{$p.numero_documento}</td>
                <td>{$p.nome_unidade_gestora}</td>
                <td>{$p.nome_programa}</td>
                <td>{$p.nome_acao}</td>
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
            {foreach $paginacaoPag as $p}
                {if $p.selecionada == 1}<b>{/if}
                <a class="LinkPag" href="#" title="/entidade_tab_p/{$codigo_entidade}/{$pagina_doacoes}/{$p.pg}" onclick="return false;">{$p.range}</a>
                {if $p.selecionada == 1}</b>{/if}
            {/foreach}
      	</div><!-- fim tab-pagamentos-->
      	
      
      	<div class="tab-content" id="tab-doacoes"><!-- inicio tab-doacoes-->

	      <h2 class="table-head">Doações feitas</h2>
	      <table id="tabela-doacoes" class="datatable">
	        <thead>
	          <tr>
	            <th><span>Candidato, Comitê ou Partido</span></th>
                <th><span>Data doação</span></th>
                <th><span>Valor</span></th>
	          </tr>
	        </thead>
	        <tbody>
            {if $doacoes_vazio != ''}
            <tr>
                <td class="nb">{$doacoes_vazio}</td>
                <td></td>
                <td class="bar"></td>
                <td></td>
            </tr>
            {else}
            {foreach $doacao_recebedores as $d}
                <tr>
	          	  <td class="nb"><a href="/{$d.tipo_prestacao}/{$d.cod_recebedor}/{$d.nome_link}">{$d.nome}</a></td>
                  <td>{$d.data}</td>
	          	  <td class="bar"><span title="{$d.valor_sem_formato}" style="width:{$d.percent}%;"><strong style="white-space: nowrap;">R$ {$d.valor}</strong></span></td>
                  <td>{$d.data_sort}</td>
                </tr>
            {/foreach}
            {/if}

	        </tbody>
              <tfoot>
              <tr>
                  <th style="text-align:right" colspan="2">Total:</th>
                  <th></th>
              </tr>
              </tfoot>
	      </table>
            {foreach $paginacaoDoa as $p}
                {if $p.selecionada == 1}<b>{/if}
                <a class="LinkDoa" href="#" title="/entidade_tab_d/{$codigo_entidade}/{$p.pg}/{$pagina_pagamentos}" onclick="return false;">{$p.range}</a>
                {if $p.selecionada == 1}</b>{/if}
            {/foreach}
	    </div><!-- fim tab-doacoes-->

        <!--
        <div class="tab-content" id="tab-comments">
        <div id="disqus_thread"></div>
		  <script type="text/javascript">
		    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
		    var disqus_shortname = 'chicagolobbyists'; // required: replace example with your forum shortname
		
		    /* * * DON'T EDIT BELOW THIS LINE * * */
		    (function() {
		        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
		        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
		        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
		    })();
		  </script>
		  <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
		  <a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>
        </div><!-- end tab-comment-->

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
