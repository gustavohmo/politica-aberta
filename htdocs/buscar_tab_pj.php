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

# Verificando os parametros passados
## Verificando o parametro de busca passado
$parametro_invalido = '';
if (isset($_GET['parametro'])) {
    $parametro_busca = Busca::limpaParametro($_GET['parametro']);
    $parametro_invalido = Busca::checaParametro($parametro_busca);
}

## Setando a pagina requisitada
$pagina_valida = 0;
if (isset($_GET['pg']) && is_numeric($_GET['pg'])) {
    $pagina = $_GET['pg'];
    $pagina_valida = 1;
}

if ($parametro_invalido != '' or $pagina_valida == 0) {
    $smarty->assign('pessoas_juridicas_vazio','Ocorreu um problema com sua busca. Por favor nos envie um email sobre o problema. Obrigado');
}

else {
    $smarty->assign('pessoas_juridicas_vazio','');
    $smarty->assign('parametro',$parametro_busca);


    # Criando objeto da busca
    $busca = new Busca($con);
    $busca->anosDoadores = $PA_DOADORES_ANOS;
    $busca->anosContratadas = $PA_CONTRATADAS_ANOS;

    # Calculando os totais
    $totalEncontradosPJ = $busca->buscaNomePJCount($parametro_busca);
    $smarty->assign('pessoas_juridicas_num',$totalEncontradosPJ);

    $smarty->assign('candidatos_num','');


    # Resultados para PJs
    ########################################################################################################
    $resultados_busca = $busca->buscaNomePJ($parametro_busca,$pagina,$itensPagina);

    if (count($resultados_busca) > 0) {
        $smarty->assign('pessoas_juridicas_vazio','');
        $smarty->assign('pessoas_juridicas_array',$resultados_busca);
    } else {
        $smarty->assign('pessoas_juridicas_vazio','Nenhum resultado para pessoas jurídicas. Tente outra busca.');
        $smarty->assign('pessoas_juridicas_array','');
    }

    # Criando a estrutura de paginacao das doacoes:
    $paginacaoPJ = new Paginador();
    $paginacaoPJ->pagina = $pagina;
    $paginacaoPJ->range_fim = $totalEncontradosPJ;
    $paginacaoPJ->itens_por_pg = $itensPagina;
    $paginacaoPJ->ranges_paginacao = 11;

    $smarty->assign('paginacaoPJ',$paginacaoPJ->paginacaoCriaRanges());

} # Fechando o if sobre busca invalida

#####################################################################################################
# Disparando o Smarty
#####################################################################################################
$smarty->display('parcial_busca_tab_pj.tpl');

?>