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

# Setando o tipo da ccp (candidato, comite ou partido)
if (isset($_GET['tipo_ccp']) && preg_match('/^[A-Za-z0-9_]+$/',$_GET['tipo_ccp'])) {
    $tipo_ccp = $_GET['tipo_ccp'];
}
else {
    print "Erro 111";
    die;
}

# Pegando o codigo da ccp
if (isset($_GET['id']) && preg_match('/^[A-Za-z0-9_]+$/',$_GET['id'])) {
    $codigo_ccp = $_GET['id'];
}
else {
    print "Erro 112";
    die;
}

# Setando a pagina requisitada
if (isset($_GET['pg']) && is_numeric($_GET['pg'])) {
    $pagina = $_GET['pg'];
}
else {
    $pagina = 1;
}

#####################################################################################################
# Criando o objeto que utilizaremos para as consultas sobre essa entidade
#####################################################################################################
$ccp = new CCP($con,$tipo_ccp,$codigo_ccp);
$smarty->assign('codigo_ccp',$ccp->cod);

$ccp->ccpNaCCP($PA_DOADORES_ANOS);

$smarty->assign('nome_ccp',$ccp->nome_ccp);
$smarty->assign('tipo_ccp',$ccp->tipo_ccp);
$smarty->assign('doacoes_anos',implode(', ',$PA_DOADORES_ANOS));

if ($ccp->cargo != '') {
    $smarty->assign('cargo'," - " . $ccp->cargo);
}
else {
    $smarty->assign('cargo','');
}

if ($ccp->municipio != '') {
    $smarty->assign('municipio'," - " . $ccp->municipio);
}
else {
    $smarty->assign('municipio','');
}

# Calculando os totais para o resumo da entidade
$smarty->assign('doacoes_total',number_format($ccp->doacoes_total,2,',','.'));
$smarty->assign('doacoes_pessoa_juridica',number_format($ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[2]],2,',','.'));
$smarty->assign('doacoes_partido',number_format($ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[0]],2,',','.'));
$smarty->assign('doacoes_pessoa_fisica',number_format($ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[1]],2,',','.'));
$smarty->assign('doacoes_outros',number_format($ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[3]],2,',','.'));
$smarty->assign('doacoes_proprios',number_format($ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[4]],2,',','.'));
$smarty->assign('doacoes_internet',number_format($ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[5]],2,',','.'));
$smarty->assign('doacoes_comercializacao',number_format($ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[6]],2,',','.'));
$smarty->assign('doacoes_naoident',number_format($ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[7]],2,',','.'));
$smarty->assign('doacoes_financeiras',number_format($ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[8]],2,',','.'));

# Passando os valores sem formatacao
$smarty->assign('doacoes_pessoa_juridica_noformat',$ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[2]]);
$smarty->assign('doacoes_partido_noformat',$ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[0]]);
$smarty->assign('doacoes_pessoa_fisica_noformat',$ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[1]]);
$smarty->assign('doacoes_outros_noformat',$ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[3]]);
$smarty->assign('doacoes_proprios_noformat',$ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[4]]);
$smarty->assign('doacoes_internet_noformat',$ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[5]]);
$smarty->assign('doacoes_comercializacao_noformat',$ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[6]]);
$smarty->assign('doacoes_naoident_noformat',$ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[7]]);
$smarty->assign('doacoes_financeiras_noformat',$ccp->doacoes_total_tipo[$ccp->APOIO_TIPO_RECEITA[8]]);

#####################################################################################################
# Fim do resumo da entidade
#####################################################################################################

#####################################################################################################
# Construindo as tabs
#####################################################################################################
# Setando o número de entradas em cada tipo_receita:
$smarty->assign('doacoes_pessoas_juridicas_num',$ccp->doacoes_count_tipo[$ccp->APOIO_TIPO_RECEITA[2]]);
$smarty->assign('doacoes_partido_num',$ccp->doacoes_count_tipo[$ccp->APOIO_TIPO_RECEITA[0]]);
$smarty->assign('doacoes_pessoas_fisicas_num',$ccp->doacoes_count_tipo[$ccp->APOIO_TIPO_RECEITA[1]]);
$smarty->assign('doacoes_outros_num',$ccp->doacoes_count_tipo[$ccp->APOIO_TIPO_RECEITA[3]]);
$smarty->assign('doacoes_proprios_num',$ccp->doacoes_count_tipo[$ccp->APOIO_TIPO_RECEITA[4]]);
$smarty->assign('doacoes_internet_num',$ccp->doacoes_count_tipo[$ccp->APOIO_TIPO_RECEITA[5]]);


# 1. Tab de pessoas juridicas
################
# Este tipo_receita é APOIO_TIPO_RECEITA[2], então passamos o número 2 abaixo:
$tipo_receita = "Recursos de pessoas jurídicas";
$ccpArray = $ccp->ccpDoacoesListaPorTipoReceitaArraySmarty($PA_DOADORES_ANOS,2,1,$itensPagina);

if ($ccp->doacoes_count_tipo["$tipo_receita"] != 0) {
    $smarty->assign('doacoes_juridicas_vazio','');
    $smarty->assign('doacao_juridicas_array',$ccpArray);
} else {
    $smarty->assign('doacoes_juridicas_vazio','Nenhuma doação para o(s) ano(s) especificado(s).');
    $smarty->assign('doacao_juridicas_array','');
}

# Criando a estrutura de paginacao das doacoes:
$paginacao_juridicas = new Paginador();
$paginacao_juridicas->pagina = 1;
$paginacao_juridicas->range_fim = $ccp->doacoes_count_tipo[$tipo_receita];
$paginacao_juridicas->itens_por_pg = $itensPagina;
$paginacao_juridicas->ranges_paginacao = 11;

$smarty->assign('paginacao_doacoes_juridicas',$paginacao_juridicas->paginacaoCriaRanges());


#####################################################################################################
# Disparando o Smarty
#####################################################################################################
$smarty->display('ccp.tpl')
?>