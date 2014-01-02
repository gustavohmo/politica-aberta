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
# Preparando a lista de contratadas
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

$result = $gastosTotais->contratadasUnicasListaTodas($pagina,$itensPag);

$count = 0;
$posicao = $pagina*$itensPag - ($itensPag-1);
foreach($result as $row) {
    if ($count==0) {
        $total_percent = $row->valor_total;
    }
    $contratadasArray[$count] = array(
        "posicao" => $posicao,
        "cod_contratada" => $row->cod_favorecido,
        "contratada" => preg_replace('/\[.*?\]/', '', $row->nome_favorecido),
        "valor_total" => number_format($row->valor_total,2,',','.'),
        "pagamentos_count" => number_format($row->pagamentos_count,0,',','.'),
        "contratada_percent" => round(($row->valor_total/$total_percent)*100,3)
    );

    $contratadasArray[$count]["nome_link"] = Entidade::entidadeNomeParaLink($contratadasArray[$count]["contratada"]);

    $count++;
    $posicao++;
}

$smarty->assign('contratadas',$contratadasArray);

# Criando a estrutura de paginacao:
$paginacao_contratadas = new Paginador();
$paginacao_contratadas->pagina = $pagina;
$paginacao_contratadas->range_fim = $num_contratadas[0];
$paginacao_contratadas->itens_por_pg = $itensPag;
$paginacao_contratadas->ranges_paginacao = 11;

$smarty->assign('paginacao',$paginacao_contratadas->paginacaoCriaRanges());

$smarty->display('contratadas.tpl');

?>