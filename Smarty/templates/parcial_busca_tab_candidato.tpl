<!--<div class="tab-content" id="tab-candidatos"><!-- inicio tab-candidatos-->
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
<!--</div>-->