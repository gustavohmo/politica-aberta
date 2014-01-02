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


# Esta variável define quantos itens teremos por página. Ela é usada tanto para passar o número de itens
# para a busca no banco. Para definir a paginacao (os ranges que aparecem embaixo da tabela), utilizaremos
# o Paginador mais abaixo.
#####################################################################################################
$itensPagina = 10;


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

#####################################################################################################
# Criando o objeto que utilizaremos para as consultas sobre essa entidade
#####################################################################################################
$entidade = new Entidade($con,$codigo_entidade);
$smarty->assign('codigo_entidade',$entidade->cod);


# Dados de doacoes/prestacoes
$entidade->entidadeNasPrestacoesTotais($PA_DOADORES_ANOS);

$smarty->assign('doacoes_anos',implode(', ',$PA_DOADORES_ANOS));

$smarty->assign('doacoes_total',number_format($entidade->doacoes_total,2,',','.'));
$smarty->assign('doacoes_candidatos',number_format($entidade->doacoes_candidato,2,',','.'));
$smarty->assign('doacoes_comites',number_format($entidade->doacoes_comite,2,',','.'));
$smarty->assign('doacoes_partidos',number_format($entidade->doacoes_partido,2,',','.'));

# Dados de contratos
$entidade->entidadeNosGastosTotais($PA_CONTRATADAS_ANOS);

$smarty->assign('contratos_anos',implode(', ',$PA_CONTRATADAS_ANOS));

$smarty->assign('contratos_total',number_format($entidade->contratos_total,2,',','.'));

# Setando o nome da entidade:
$smarty->assign('nome_entidade',$entidade->nome_entidade);

#####################################################################################################
# Fim do resumo da entidade
#####################################################################################################

#####################################################################################################
# Construindo as tabs
#####################################################################################################
# Tab de doacoes
################
$doacoesArray = $entidade->entidadeNasPrestacoesListaTodosArraySmarty($PA_DOADORES_ANOS,$pagina_doacoes,$itensPagina);

$smarty->assign('doacoes_itens_num',$entidade->prestacao_total_num);

if ($entidade->prestacao_total_num != 0) {
    $smarty->assign('doacoes_vazio','');
    $smarty->assign('doacao_recebedores',$doacoesArray);
} else {
    $smarty->assign('doacoes_vazio','Nenhuma doação para o(s) ano(s) especificado(s).');
    $smarty->assign('doacao_recebedores','');
}

# Criando a estrutura de paginacao das doacoes:
$paginacaoDoa = new Paginador();
$paginacaoDoa->pagina = $pagina_doacoes;
$paginacaoDoa->range_fim = $entidade->prestacao_total_num; # Criar definicao
$paginacaoDoa->itens_por_pg = $itensPagina;
$paginacaoDoa->ranges_paginacao = 11;

$smarty->assign('paginacaoDoa',$paginacaoDoa->paginacaoCriaRanges());
$smarty->assign('pagina_pagamentos',$pagina_pagamentos);


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
$smarty->display('entidade7.tpl')
?>