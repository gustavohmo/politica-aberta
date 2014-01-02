<!--<div class="tab-content" id="tab-pessoas-juridicas"><!-- inicio tab-pessoas-juridicas-->
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
<!--</div>-->