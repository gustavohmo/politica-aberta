<?php
require_once('../politicaaberta.core.php');

# Inicializando o template engine
#####################################################################################################
$smarty = new NovoSmarty();

# Inicializando a conexao.
#####################################################################################################
$con = new Conexao();

# Inicializando o objeto que usaremos para a tabela de prestacaototal, que contém os dados totalizados
# das doações por cod_doador. Repare que temos de passar os anos a serem utilizados. Neste caso,
# utilizaremos apenas o ano de 2012.
# É importante prestar atenção sobre a consequência da escolha do ano. Por exemplo, se estamos calculando
# o total de doadoresunicos (doadoresUnicos()), o ano não fará tanta diferença (pois estamos selecionando
# os únicos e, portanto, haverá repetição). No entanto, fará bastante diferença ao somarmos todas as prestações.
#####################################################################################################
$prestacaoTotal = new PrestacaoTotal($con,$PA_DOADORES_ANOS);

# Inicializando o objeto que usaremos para a tabela de gastostotais, que contém todas as transferências
# diretas (gastos diretos) do governo federal. Também temos de passar os anos aqui.
#####################################################################################################
$gastosTotais = new GastosTotais($con,$PA_CONTRATADAS_ANOS);

#####################################################################################################
# Fim da inicializacao
#####################################################################################################

#####################################################################################################
# Preparando os numeros da barra de cima
#####################################################################################################
# Numero de doadores unicos para campanhas
$num_doadores = $prestacaoTotal->doadoresUnicosNum();
$smarty->assign('num_doadores',number_format($num_doadores[0],0,',','.'));

# Total de doacao em R$
$total_doacao = $prestacaoTotal->doacoesTotal();
$smarty->assign('total_doacao',number_format($total_doacao[0],2,',','.'));

# Numero de contratadas com dinheiro publico
$num_contratadas = $gastosTotais->contratadasUnicasNum();
$smarty->assign('num_contratadas',number_format($num_contratadas[0],0,',','.'));

#####################################################################################################
# Fim da barra superior
#####################################################################################################

# Setando a pagina requisitada, que tb deve ser < 20 (pois estamos limitando o ranking em 600)
if (isset($_GET['pg']) && is_numeric($_GET['pg']) && $_GET['pg'] < 21) {
    $pagina = $_GET['pg'];
}
else {
    $pagina = 1;
}

#####################################################################################################
# Preparando as listas
#####################################################################################################
$itensPagina = 30;

# Setando os anos:
$ano_doadores = implode(', ',$PA_DOADORES_ANOS);
$smarty->assign('doadores_ano',$ano_doadores);

$ano_contratadas = implode(', ',$PA_CONTRATADAS_ANOS);
$smarty->assign('contratadas_ano',$ano_contratadas);

# Preparando a lista de doadores e atribuindo ao objeto smarty do template.
$result = $prestacaoTotal->doadoresUnicosLista($pagina,$itensPagina);

$count=1;
$posicao = ($pagina*$itensPagina) - ($itensPagina-1);
foreach($result as $row){
    if ($count==1) {
        $total_percent = $row->valor_total_ccp;
    }
    $doadoresArray[$count] = array(
        "posicao" => $posicao,
        "cod_doador" => $row->cod_doador,
        "valor_total" => number_format($row->valor_total_ccp,2,',','.'),
        "doador_percent" => round(($row->valor_total_ccp/$total_percent)*100,3)
    );

    if ($row->nome_receita_doador != '') {
        $doadoresArray[$count]["doador"] = $row->nome_receita_doador;
    }
    else {
        $doadoresArray[$count]["doador"] = $row->nome_doador;
    }

    $doadoresArray[$count]["nome_link"] = Entidade::entidadeNomeParaLink($doadoresArray[$count]["doador"]);

    $doadoresArray[$count]["doador"] = (strlen($doadoresArray[$count]["doador"]) > 43) ? substr($doadoresArray[$count]["doador"],0,43).'...' : $doadoresArray[$count]["doador"];
    $count++;
    $posicao++;
}

$smarty->assign('doadores',$doadoresArray);



# Preparando a lista de contratadas e atribuindo ao objeto smarty do template.
$result2 = $gastosTotais->contratadasUnicasLista($pagina,$itensPagina);

$contratadasArray;
$count=1;
$posicao = ($pagina*$itensPagina) - ($itensPagina-1);
foreach($result2 as $row2){
    if ($count==1) {
            $total_percent = $row2->valor_total;
    }
    $contratadasArray[$count] = array(
        "posicao" => $posicao,
        "cod_contratada" => $row2->cod_favorecido,
        "valor_total" => number_format($row2->valor_total,2,',','.'),
        "contratada_percent" => round(($row2->valor_total/$total_percent)*100,3)
    );

    # Limpando os colchetes dos nomes:
    $nomeSemColchete = preg_replace('/\[.*?\]/', '', $row2->nome_favorecido);
    $nomeSemColchete = (strlen($nomeSemColchete) > 43) ? substr($nomeSemColchete,0,43).'...' : $nomeSemColchete;
    $contratadasArray[$count]["contratada"] = $nomeSemColchete;

    $contratadasArray[$count]["nome_link"] = Entidade::entidadeNomeParaLink($contratadasArray[$count]["contratada"]);

    $count++;
    $posicao++;
}
$smarty->assign('contratadas',$contratadasArray);


# Criando a estrutura de paginacao. Limitamos o ranking em 600 entidades:
$paginacao = new Paginador();
$paginacao->pagina = $pagina;
$paginacao->range_fim = 600;
$paginacao->itens_por_pg = $itensPagina;
$paginacao->ranges_paginacao = 11;

$smarty->assign('paginacao',$paginacao->paginacaoCriaRanges());

#####################################################################################################
# Fim das listas
#####################################################################################################

#####################################################################################################
# Disparando o Smarty
#####################################################################################################
$smarty->display('ranking.tpl')
?>