
    <script>
        $(function() {
            $('.tabs').tabs();

            $('ul.tab-nav li').click(function(){
                $('ul.tab-nav li').removeClass('ui-tabs-selected');
                $(this).addClass('ui-tabs-selected');
            });

            initDataTablePessoasJuridicas();
            initDataTableCandidatos();

            /* Evento click - Chamada ajax do Tab de buscaPJ */
            $(document).on("click","a.buscaPJ",function() {
                $("#tab-pessoas-juridicas").spin({
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
                            $("#tab-pessoas-juridicas").html(resultado);
                            initDataTablePessoasJuridicas();
                        })
                        .fail(function() {
                            alert( "Ocorreu um erro ao buscar os dados. Por favor tente mais tarde." );
                            $("tab-pessoas-juridicas").spin(false);
                        })
                        .always(function() {
                            /*alert( "complete" );*/
                            $("tab-pessoas-juridicas").spin(false);
                        });
            });

            /* Evento click - Chamada ajax do Tab de buscaCandidato */
            $(document).on("click","a.buscaCandidato",function() {
                $("#tab-candidatos").spin({
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
                            $("#tab-candidatos").html(resultado);
                            initDataTableCandidatos();
                        })
                        .fail(function() {
                            alert( "Ocorreu um erro ao buscar os dados. Por favor tente mais tarde." );
                            $("tab-candidatos").spin(false);
                        })
                        .always(function() {
                            /*alert( "complete" );*/
                            $("tab-candidatos").spin(false);
                        });
            });

            function initDataTablePessoasJuridicas(){
                window.tabelaDoacoesJuridicas = $("#tabela-pessoas-juridicas").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* Nome  */             { "sWidth": "60%" },
                        /* ccp valor */         { "sWidth": "20%",
                                                  "sType": "title-numeric" },
                        /* pagamentos valor */  { "sWidth": "20%",
                                                  "sType": "title-numeric" }
                    ],
                    "aaSorting": [[0, "asc"]],
                    "bFilter": false,
                    "bInfo": false,
                    "bPaginate": false,
                    "oLanguage": {
                        "sSearch": "Buscar:",
                        "sZeroRecords": "Nenhum registro encontrado"
                    }
                });
            }

            function initDataTableCandidatos(){
                window.tabelaDoacoesJuridicas = $("#tabela-candidatos").dataTable({
                    "bAutoWidth": false,
                    "aoColumns": [
                        /* Nome  */             { "sWidth": "60%" },
                        /* cargo */         { "sWidth": "10%" },
                        /* partido */         { "sWidth": "10%" },
                        /* regiao */         { "sWidth": "20%" }
                    ],
                    "aaSorting": [[0, "asc"]],
                    "bFilter": false,
                    "bInfo": false,
                    "bPaginate": false,
                    "oLanguage": {
                        "sSearch": "Buscar:",
                        "sZeroRecords": "Nenhum registro encontrado"
                    }
                });
            }
        })
    </script>

    {include file='parcial_facebook.tpl'}

    {include file='parcial_pag_topo_nav.tpl' capa_class='' sobre_class='' blog_class=''}
    {include file='parcial_pag_topo.tpl'}
<hr>
  
<div class="clear"></div>
  
  <h1><u>Resultados - buscando por</u>: {$parametro}</h1>

  {if $parametro_invalido != ''}
      <p>{$parametro_invalido}</p>
  {else}

<div class="tabs">
    <ul class="tab-nav">
        <li class="ui-tabs-selected" onclick="return false;"><a href="#tab-pessoas-juridicas">Pessoas jurídicas ({$pessoas_juridicas_num})</a></li>
        <li><a href="#tab-candidatos" onclick="return false;">Candidatos ({$candidatos_num})</a></li>
    </ul>

<div class="tab-content" id="tab-pessoas-juridicas"><!-- inicio tab-pessoas-juridicas-->
    <h2 class="table-head">Pessoas jurídicas encontradas</h2>
    <table id="tabela-pessoas-juridicas" class="datatable lobbyist-actions">
        <thead>
        <tr>
            <th><span>Nome</span></th>
            <th><span>Total de doações feitas</span></th>
            <th><span>Total de pagamentos recebidos</span></th>
        </tr>
        </thead>
        <tbody>
        {if $pessoas_juridicas_vazio != ''}
            <tr>
                <td>{$pessoas_juridicas_vazio}</td>
                <td></td>
                <td></td>

            </tr>
        {else}
            {foreach $pessoas_juridicas_array as $p}
                <tr>
                    <td><a href="/entidade/{$p.cod}/{$p.nome_link}">{$p.nome}</a></td>
                    <td><span title="{$p.valor_total_ccp_sem_formato}">R$ {$p.valor_total_ccp}</span></td>
                    <td><span title="{$p.valor_total_pagamentos_sem_formato}">R$ {$p.valor_total_pagamentos}</span></td>
                </tr>
            {/foreach}
        {/if}
        </tbody>
    </table>
    {foreach $paginacaoPJ as $p}
        {if $p.selecionada == 1}<b>{/if}
        <a class="buscaPJ" href="#" title="/buscar_tab_pj/{$parametro}/{$p.pg}" onclick="return false;">{$p.range}</a>
        {if $p.selecionada == 1}</b>{/if}
    {/foreach}
</div>



<div class="tab-content" id="tab-candidatos"><!-- inicio tab-candidatos-->
    <h2 class="table-head">Candidatos encontrados</h2>
    <table id="tabela-candidatos" class="datatable lobbyist-actions">
        <thead>
        <tr>
            <th><span>Nome</span></th>
            <th><span>Cargo</span></th>
            <th><span>Partido</span></th>
            <th><span>Região</span></th>
        </tr>
        </thead>
        <tbody>
        {if $candidatos_vazio != ''}
            <tr>
                <td>{$candidatos_vazio}</td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
        {else}
            {foreach $candidatos_array as $c}
                <tr>
                    <td><a href="/candidato/{$c.cod_ccp}/{$c.nome_link}">{$c.nome_ccp}</a></td>
                    <td>{$c.cargo}</td>
                    <td>{$c.sigla_partido}</td>
                    <td>{$c.uf} ({$c.municipio})</td>
                </tr>
            {/foreach}
        {/if}

        </tbody>
    </table>
    {foreach $paginacaoCandidato as $p}
        {if $p.selecionada == 1}<b>{/if}
        <a class="buscaCandidato" href="#" title="/buscar_tab_candidato/{$parametro}/{$p.pg}" onclick="return false;">{$p.range}</a>
        {if $p.selecionada == 1}</b>{/if}
    {/foreach}
</div>

</div><!--end tabs-->

{/if} {* fechando if parametro invalido *}
  <!-- Footer -->
{include file='pag_foot_nav.tpl'}
<!-- /Footer -->

</div>
<!-- /Content -->

