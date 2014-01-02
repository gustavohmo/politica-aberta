<!--<div class="tab-content" id="{$dom_id}"><!-- inicio tab-->

    <h2 class="table-head">{$doacoes_titulo}</h2>
    <table id="{$tabela_id}" class="datatable lobbyist-actions">
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
        {if $doacoes_vazio != ''}
            <tr>
                <td></td>
                <td class="nb">{$doacoes_vazio}</td>
                <td></td>
                <td class="bar"></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
        {else}
            {foreach $doacao_array as $d}
                <tr>
                    <td><img src="/imagens/details_open.png" style="cursor: pointer;"></td>
                    {if $tabela_id == "tabela-doacoes-juridicas"}
                    <td><a href="/entidade/{$d.cod_doador}/{$d.nome_link}">{$d.nome_doador}</a></td>
                    {else}
                    <td>{$d.nome_doador}</td>
                    {/if}
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
    {foreach $paginacao_doacoes as $p}
        {if $p.selecionada == 1}<b>{/if}
        <a class="LinkPag" href="#" title="/ccp_tab/{$tipo_ccp}/{$tipo_receita}/{$codigo_ccp}/{$p.pg}" onclick="return false;">{$p.range}</a>
        {if $p.selecionada == 1}</b>{/if}
    {/foreach}
<!--</div><!-- fim tab-->