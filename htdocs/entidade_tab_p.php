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

#####################################################################################################
# Carregando dados da entidade
#####################################################################################################
# Lembrar depois de limitar os anos!!!!!!!!!!!!!

# Pegando o codigo (i.e. cnpj) da entidade
if (isset($_GET['id']) && preg_match('/^[A-Za-z0-9_]+$/',$_GET['id'])) {
    $codigo_entidade = $_GET['id'];
}
else {
    die;
}

# Setando a pagina requisitada da aba de doacoes
if (isset($_GET['dpg']) && is_numeric($_GET['dpg'])) {
    $pagina_doacoes = $_GET['dpg'];
}
else {
    $pagina_doacoes = 1;
}

# Setando a pagina requisitada da aba de gastosdiretos (ou pagamentos)
if (isset($_GET['ppg']) && is_numeric($_GET['ppg'])) {
    $pagina_pagamentos = $_GET['ppg'];
}
else {
    $pagina_pagamentos = 1;
}

$entidade = new Entidade($con,$codigo_entidade);
$smarty->assign('codigo_entidade',$entidade->cod);

# Necessario para setarmos o $entidade->gastosdiretos_num
$entidade->entidadeNosGastosTotais($PA_CONTRATADAS_ANOS);

###################
# Tab de pagamentos
###################
$pagamentosArray = $entidade->entidadeNosGastosDiretosListaTodosArraySmarty($PA_CONTRATADAS_ANOS,$pagina_pagamentos,$itensPagina);

$smarty->assign('pagamentos_itens_num',$entidade->gastosdiretos_num);

if ($entidade->gastosdiretos_num != 0) {
    $smarty->assign('pagamentos_vazio','');
    $smarty->assign('pagamentos_recebidos',$pagamentosArray);
} else {
    $smarty->assign('pagamentos_vazio','Nenhum pagamento para o(s) ano(s) especificado(s).');
    $smarty->assign('pagamentos_recebidos','');
}

# Criando a estrutura de paginacao dos pagamentos:
$paginacaoPag = new Paginador();
$paginacaoPag->pagina = $pagina_pagamentos;
$paginacaoPag->range_fim = $entidade->gastosdiretos_num; # Criar definicao
$paginacaoPag->itens_por_pg = $itensPagina;
$paginacaoPag->ranges_paginacao = 11;

$smarty->assign('paginacaoPag',$paginacaoPag->paginacaoCriaRanges());
$smarty->assign('pagina_doacoes',$pagina_doacoes);

#####################################################################################################
# Disparando o Smarty
#####################################################################################################
$smarty->display('entidade6_tab_p.tpl')
?>