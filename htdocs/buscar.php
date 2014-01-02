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

# A rotina abaixo está comentada pois desabilitei o autocomplete
# Pegando o cod_hidden e verificando se eh valido:
#if (isset($_POST['cod_hidden']) && preg_match("/^[a-z0-9 .\-]+$/i",$_POST['cod_hidden'])) {
#    $codigo = $_POST['cod_hidden'];
#
#    header("Location: /entidade/$codigo");
#}

# Verificando parametro de busca:
$invalido_razao = 'Parâmetro de busca inválido: <br>';
$invalido_razao_fim = '<p>Se você acha que isso é um erro, por favor nos envie um email sobre o problema. Obrigado';
$parametro_invalido = '';
if (isset($_POST['buscar'])) {
    $parametro_busca = Busca::limpaParametro($_POST['buscar']);
    $parametro_invalido = Busca::checaParametro($parametro_busca);
}

$pagina = 1; # A pagina é um pois este script é chamado apenas para a 1a página (a implementação é, portanto,
             # um pouco distinta da das demais paginações. Quem chamará as outras páginas é o ajax, em outro script.
$itensPagina = 10;


$smarty->assign('parametro',$parametro_busca);

if ($parametro_invalido != '') {
    $smarty->assign('parametro_invalido',$invalido_razao . $parametro_invalido . $invalido_razao_fim);
}

else {
    $smarty->assign('parametro_invalido','');


    # Criando objeto da busca
    $busca = new Busca($con);
    $busca->anosDoadores = $PA_DOADORES_ANOS;
    $busca->anosContratadas = $PA_CONTRATADAS_ANOS;

    # Calculando os totais
    $totalEncontradosPJ = $busca->buscaNomePJCount($parametro_busca);
    $smarty->assign('pessoas_juridicas_num',$totalEncontradosPJ);
    $totalEncontradosCandidatos = $busca->buscaNomeCandidatoCount($parametro_busca);
    $smarty->assign('candidatos_num',$totalEncontradosCandidatos);


    # Resultados para PJs
    ########################################################################################################
    # Buscamos apenas se os encontrados forem maior que zero:
    if ($totalEncontradosPJ > 0) {
        $resultados_busca = $busca->buscaNomePJ($parametro_busca,$pagina,$itensPagina);
        if (count($resultados_busca) > 0) {
            $smarty->assign('pessoas_juridicas_vazio','');
            $smarty->assign('pessoas_juridicas_array',$resultados_busca);
        }
    }
    else {
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

    # Resultados para candidatos
    ########################################################################################################
    if ($totalEncontradosCandidatos > 0) {
        $resultados_busca2 = $busca->buscaNomeCandidato($parametro_busca,1,10);
        if (count($resultados_busca2) > 0) {
            $smarty->assign('candidatos_vazio','');
            $smarty->assign('candidatos_array',$resultados_busca2);
        }
    }
     else {
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



} # Fechando o if sobre o parametro_valido

#####################################################################################################
# Disparando o Smarty
#####################################################################################################
$smarty->display('busca_resultados_ajax.tpl');

?>