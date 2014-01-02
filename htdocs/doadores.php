<?php
require_once('../politicaaberta.core.php');

# Inicializando o template engine
#####################################################################################################
$smarty = new NovoSmarty();

# Inicializando a conexao.
#####################################################################################################
$con = new Conexao();

# Inicializando o objeto para consulta.
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

#####################################################################################################
# Preparando a lista de doadores
#####################################################################################################
# Esta variável define quantos itens teremos por página. Ela é usada tanto para passar o número de itens
# para a busca no banco. Para definir a paginacao (os ranges que aparecem embaixo da tabela), utilizaremos
# o Paginador mais abaixo.
$itensPag = 30;


if (isset($_GET['pg']) && is_numeric($_GET['pg'])) {
    $pagina = $_GET['pg'];
}
else {
    $pagina = 1;
}

$result = $prestacaoTotal->doadoresUnicosListaTodos($pagina,$itensPag);

$count = 0;
$posicao = $pagina*$itensPag - ($itensPag-1);
foreach($result as $row) {
    if ($count==0) {
        $total_percent = $row->valor_total_ccp;
    }
    $doadoresArray[$count] = array(
        "posicao" => $posicao,
        "cod_doador" => $row->cod_doador,
        "valor_total_ccp" => number_format($row->valor_total_ccp,2,',','.'),
        "prestacao_total_ccp_count" => number_format($row->prestacao_total_ccp_count,0,',','.'),
        "doador_percent" => round(($row->valor_total_ccp/$total_percent)*100,3)
    );

    if ($row->nome_receita_doador != '') {
        $doadoresArray[$count]["doador"] = $row->nome_receita_doador;
    }
    else {
        $doadoresArray[$count]["doador"] = $row->nome_doador;
    }

    $doadoresArray[$count]["nome_link"] = Entidade::entidadeNomeParaLink($doadoresArray[$count]["doador"]);

    $count++;
    $posicao++;
}

$smarty->assign('doadores',$doadoresArray);

# Criando a estrutura de paginacao:
$paginacao_doadores = new Paginador();
$paginacao_doadores->pagina = $pagina;
$paginacao_doadores->range_fim = $num_doadores[0];
$paginacao_doadores->itens_por_pg = $itensPag;
$paginacao_doadores->ranges_paginacao = 11;

$smarty->assign('paginacao',$paginacao_doadores->paginacaoCriaRanges());

$smarty->display('doadores.tpl');

?>