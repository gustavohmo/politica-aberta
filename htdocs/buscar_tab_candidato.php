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
    $smarty->assign('candidatos_vazio','Ocorreu um problema com sua busca. Por favor nos envie um email sobre o problema. Obrigado');
}

else {
    $smarty->assign('candidatos_vazio','');
    $smarty->assign('parametro',$parametro_busca);


    # Criando objeto da busca
    $busca = new Busca($con);
    $busca->anosDoadores = $PA_DOADORES_ANOS;
    $busca->anosContratadas = $PA_CONTRATADAS_ANOS;

    # Calculando os totais
    $totalEncontradosCandidatos = $busca->buscaNomeCandidatoCount($parametro_busca);
    $smarty->assign('candidatos_num',$totalEncontradosCandidatos);

    # Resultados para candidatos
    ########################################################################################################
    $resultados_busca2 = $busca->buscaNomeCandidato($parametro_busca,$pagina,$itensPagina);

    if (count($resultados_busca2) > 0) {
        $smarty->assign('candidatos_vazio','');
        $smarty->assign('candidatos_array',$resultados_busca2);
    } else {
        $smarty->assign('candidatos_vazio','Nenhum resultado para candidatos. Tente outra busca.');
        $smarty->assign('candidatos_array','');
    }

    # Criando a estrutura de paginacao dos candidatos:
    $paginacaoCandidato = new Paginador();
    $paginacaoCandidato->pagina = $pagina;
    $paginacaoCandidato->range_fim = $totalEncontradosCandidatos;
    $paginacaoCandidato->itens_por_pg = $itensPagina;
    $paginacaoCandidato->ranges_paginacao = 11;

    $smarty->assign('paginacaoCandidato',$paginacaoCandidato->paginacaoCriaRanges());

} # Fechando o if sobre busca invalida

#####################################################################################################
# Disparando o Smarty
#####################################################################################################
$smarty->display('parcial_busca_tab_candidato.tpl');

?>