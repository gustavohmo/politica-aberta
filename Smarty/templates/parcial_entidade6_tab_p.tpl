<!--<div class="tab-content" id="tab-pagamentos"><!-- inicio tab-pagamentos-->

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
            </tr>
        {else}
            {foreach $pagamentos_recebidos as $p}
                <tr>
                    <td><img src="/imagens/details_open.png"></td>
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
<!--</div><!-- fim tab-pagamentos-->