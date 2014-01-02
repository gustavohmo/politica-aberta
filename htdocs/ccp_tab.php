<?php
require_once('../politicaaberta.core.php');

# Inicializando o template engine
#####################################################################################################
$smarty = new NovoSmarty();

# Inicializando a conexao.
#####################################################################################################
$con = new Conexao();

# Esta variável define quantos itens teremos por página. Ela é usada tanto para passar o número de itens
# para a busca no banco. Para definir a paginacao (os ranges que aparecem embaixo da tabela), utilizaremos
# o Paginador mais abaixo.
#####################################################################################################
$itensPagina = 10;

#####################################################################################################
# Fim da inicializacao
#####################################################################################################

# Verificando os parametros passados. Temos 4 parâmetros: o tipo de ccp; o sequencial da entidade ccp; o número do
# tipo receita; e o número da página.
# Tipo ccp
if (isset($_GET['tipo_ccp']) && preg_match('/^[A-Za-z0-9_]+$/',$_GET['tipo_ccp'])) {
    $tipo_ccp = $_GET['tipo_ccp'];
}
else {
    print "Erro 211";
    die;
}

# Pegando o codigo ccp
if (isset($_GET['id']) && preg_match('/^[A-Za-z0-9_]+$/',$_GET['id'])) {
    $codigo_ccp = $_GET['id'];
}
else {
    print "Erro 212";
    die;
}

# Setando a pagina requisitada
if (isset($_GET['pg']) && is_numeric($_GET['pg'])) {
    $pagina = $_GET['pg'];
}
else {
    $pagina = 1;
}

# Verificando o tipo_receita passado
$ccp = new CCP($con,$tipo_ccp,$codigo_ccp);
if (isset($_GET['tipo_receita']) && is_numeric($_GET['tipo_receita']) && $_GET['tipo_receita'] < (count($ccp->APOIO_TIPO_RECEITA) - 1)) {
    $tipo_receita = $_GET['tipo_receita'];
}
else {
    print "Erro 213";
    die;
}

####################################################################################################################
# Montando a tab
####################################################################################################################
# Para cada tipo_receita, temos um titulo para a tab e um nome da tabela (para o dataTables/jquery) diferentes:
$titulo_tab = '';
$tabela_id = '';
if ($tipo_receita == 0) {
    $titulo_tab = "Doações recebidas de partido político";
    $tabela_id = "tabela-doacoes-partido";
    $dom_id = "tab-partido";
}
elseif ($tipo_receita == 1) {
    $titulo_tab = "Doações recebidas de pessoas físicas";
    $tabela_id = "tabela-doacoes-fisicas";
    $dom_id = "tab-fisicas";
}
elseif ($tipo_receita == 2) {
    $titulo_tab = "Doações recebidas de pessoas jurídicas";
    $tabela_id = "tabela-doacoes-juridicas";
    $dom_id = "tab-juridicas";
}
elseif ($tipo_receita == 3) {
    $titulo_tab = "Doações recebidas de outros candidatos/comitês";
    $tabela_id = "tabela-doacoes-outros";
    $dom_id = "tab-outros";
}
elseif ($tipo_receita == 4) {
    $titulo_tab = "Recursos próprios utilizados na campanha";
    $tabela_id = "tabela-doacoes-proprios";
    $dom_id = "tab-proprios";
}
elseif ($tipo_receita == 5) {
    $titulo_tab = "Doações recebidas pela Internet";
    $tabela_id = "tabela-doacoes-internet";
    $dom_id = "tab-internet";
}
else {
    print "Erro 214";
    die;
}

$smarty->assign('doacoes_titulo',$titulo_tab);
$smarty->assign('tabela_id',$tabela_id);
$smarty->assign('dom_id',$dom_id);
$smarty->assign('tipo_ccp',$tipo_ccp);
$smarty->assign('tipo_receita',$tipo_receita);
$smarty->assign('codigo_ccp',$codigo_ccp);

# Construindo a tab
################
$ccp->ccpNaCCP($PA_DOADORES_ANOS);

$tipo_receita_extenso = $ccp->APOIO_TIPO_RECEITA[$tipo_receita];
$ccpArray = $ccp->ccpDoacoesListaPorTipoReceitaArraySmarty($PA_DOADORES_ANOS,$tipo_receita,$pagina,$itensPagina);

if ($ccp->doacoes_count_tipo["$tipo_receita_extenso"] != 0) {
    $smarty->assign('doacoes_vazio','');
    $smarty->assign('doacao_array',$ccpArray);
} else {
    $smarty->assign('doacoes_vazio','Nenhuma doação para o(s) ano(s) especificado(s).');
    $smarty->assign('doacao_array','');
}

# Criando a estrutura de paginacao das doacoes:
$paginacao = new Paginador();
$paginacao->pagina = $pagina;
$paginacao->range_fim = $ccp->doacoes_count_tipo[$tipo_receita_extenso];
$paginacao->itens_por_pg = $itensPagina;
$paginacao->ranges_paginacao = 11;

$smarty->assign('paginacao_doacoes',$paginacao->paginacaoCriaRanges());


#####################################################################################################
# Disparando o Smarty
#####################################################################################################
$smarty->display('parcial_ccp_tab.tpl');

?>
