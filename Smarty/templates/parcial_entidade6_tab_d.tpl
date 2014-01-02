<!--<div class="tab-content" id="tab-doacoes"><!-- inicio tab-doacoes-->

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
                <td class="bar"></td>
            </tr>
        {else}
            {foreach $doacao_recebedores as $d}
                <tr>
                    <td class="nb"><a href="/{$d.tipo_prestacao}/{$d.cod_recebedor}">{$d.nome}</a></td>
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
<!--</div><!-- fim tab-doacoes-->