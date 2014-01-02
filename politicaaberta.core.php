<?php
############################################################
# politicaaberta.core.php
# A aplicacao é estruturada da seguinte forma:
# 1- Arquivos de template das páginas a serem exibidas, em formato Smarty;
# 2- Um arquivo de controle (este arquivo) que contém toda a lógica de busca com o banco de dados;
# 3- Arquivos chamados pelo usuário, que montam o template a partir de chamadas ao controle.
#
# Atencao: você não precisa mudar nada neste arquivo. Toda a configuração da aplicação está em politcaaberta.config.php.
#
############################################################

require_once("politicaaberta.config.php");

error_reporting(E_ALL);
date_default_timezone_set(PA_TIMEZONE);

# Controlando a chamada ao Smarty. A opcao abaixo entre Linux e outros deve-se ao fato de que
# utilizei ambientes diferentes para desenvolvimento e producao.
if (PHP_OS == "Linux") {
    require_once(PA_SMARTY_LINUX);
}
else {
    require_once(PA_SMARTY_OUTROS);
}


class CCP {

    # apoio
    private $anosConsulta;
    private $PA_MYSQL_GASTOSDIRETOS = PA_MYSQL_GASTOSDIRETOS;
    private $tabela_ccp;
    private $tabela_index_ccp;
    private $documento_ccp;

    # geral
    public $cod;
    public $nome_ccp;
    public $tipo_ccp;
    public $sigla_partido;
    public $uf;
    public $cargo;
    public $doacoes_total;
    public $doacoes_total_tipo = array();
    public $doacoes_count_tipo = array();
    public $APOIO_TIPO_RECEITA = array(
        0 => "Recursos de partido político",
        1 => "Recursos de pessoas físicas",
        2 => "Recursos de pessoas jurídicas",
        3 => "Recursos de outros candidatos/comitês",
        4 => "Recursos próprios",
        5 => "Recursos de doações pela Internet",
        6 => "Comercialização de bens e/ou realização de eventos",
        7 => "Recursos de origens não identificadas",
        8 => "Rendimentos de aplicações financeiras"
    );

    function __construct($con,$tipo_ccp,$cod_arg) {
        $this->conexao = $con;
        $this->cod = $cod_arg;
        $this->tipo_ccp = $tipo_ccp;
        if ($this->tipo_ccp == "candidato") {
            $this->tabela_ccp = "prestacaocandidato";
            $this->tabela_index_ccp = "cpf_candidato";
            $this->documento_ccp = "numero_recibo_eleitoral";
        }
        else if ($this->tipo_ccp == "comite") {
            $this->tabela_ccp = "prestacaocomite";
            $this->tabela_index_ccp = "sequencial_comite";
            $this->documento_ccp = "tipo_de_documento";
        }
        else {
            $this->tabela_ccp = "prestacaopartido";
            $this->tabela_index_ccp = "sequencial_diretorio";
            $this->documento_ccp = "tipo_documento";
        }

        # Construindo a array dos resultados
        foreach ($this->APOIO_TIPO_RECEITA as $value) {
            $this->doacoes_total_tipo[$value] = 0;
            $this->doacoes_count_tipo[$value] = 0;
        }
    }

    public function ccpNaCCP (array $anosArray) {
        $this->anosConsulta = implode(',',$anosArray);

        $query = "SELECT sigla_partido,uf,municipio,cargo,nome_ccp,tipo_receita,valor_total,doacoes_count FROM ccp WHERE cod_ccp = ? AND tipo_ccp = ? AND ano IN (?)";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->cod);
        $consulta->bindParam(2,$this->tipo_ccp);
        $consulta->bindParam(3,$this->anosConsulta);
        $consulta->execute();
        $result = $consulta->fetchAll(\PDO::FETCH_OBJ);

        # Setando os valores do objeto:
        if(isset($result)) {
            $count = 0;
            foreach ($result as $row) {
                if ($count == 0) {
                    $this->nome_ccp = $row->nome_ccp . " ($row->sigla_partido - $row->uf)";
                    $this->sigla_partido = $row->sigla_partido;
                    $this->uf = $row->uf;
                    $this->municipio = $row->municipio;
                    $this->cargo = $row->cargo;
                    $this->doacoes_total_tipo[$row->tipo_receita] = $row->valor_total;
                    $this->doacoes_count_tipo[$row->tipo_receita] = $row->doacoes_count;
                    $count++;
                }
                else {
                    $this->doacoes_total_tipo[$row->tipo_receita] = $row->valor_total;
                    $this->doacoes_count_tipo[$row->tipo_receita] = $row->doacoes_count;
                }
            }

            # Calculando o total
            $d = 0;
            foreach ($this->doacoes_total_tipo as $doacao) {
                $d += $doacao;
            }
            $this->doacoes_total = $d;
        }

        # Caso o objeto nao exista, retornando zerado:
        else {
            $this->nome_ccp = '';
            $this->sigla_partido = '';
            $this->uf = '';
            $this->cargo = '';
            $this->doacoes_total = 0.00;
            $this->doacoes_count = 0;
        }
    }

    public function ccpNasCCPTotais (array $anosArray) {
        $this->anosConsulta = implode(',',$anosArray);

        $query = "SELECT sigla_partido,uf,cargo,nome_ccp,valor_total,doacoes_count FROM ccptotais WHERE cod_ccp = ? AND tipo_ccp = ? AND ano IN (?)";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->cod);
        $consulta->bindParam(2,$this->tipo_ccp);
        $consulta->bindParam(3,$this->anosConsulta);
        $consulta->execute();
        $result = $consulta->fetch(\PDO::FETCH_OBJ);
        if(is_object($result)) {
            $this->nome_ccp = $result->nome_ccp;
            $this->sigla_partido = $result->sigla_partido;
            $this->uf = $result->uf;
            $this->cargo = $result->cargo;
            $this->doacoes_total = $result->valor_total;
            $this->doacoes_count = $result->doacoes_count;
        }
        else {
            $this->nome_ccp = '';
            $this->sigla_partido = '';
            $this->uf = '';
            $this->cargo = '';
            $this->doacoes_total = 0.00;
            $this->doacoes_count = 0;
        }
    }

    public function ccpDoacoesListaTodosArraySmarty(array $anosArray,$pagina,$itensPagina) {
        $result = $this->ccpDoacoesListaTodosArray($anosArray,$pagina,$itensPagina);

        # Montando uma array com os resultados, separada por tipo_receita, para uso pelo template Smarty.
        $countArray = array();
        $ccpArray = array();
        $total_percentArray = array();

        foreach($result as $row) {
            $tipo_receita = $row->tipo_receita;
            if (!isset($countArray[$tipo_receita])) {
                $countArray[$tipo_receita] = 0;
                $total_percentArray[$tipo_receita] = $row->new_valor;
            }

            $nome_doador = $row->nome_receita_doador != '' ? $row->nome_receita_doador : $row->nome_doador;
            $descricao_receita = $row->descricao_receita != ''? $row->descricao_receita : "[não informada]";

            $ccpArray[$tipo_receita][$countArray[$tipo_receita]] = array(
                "cod_doador" => $row->cpf_cnpj_doador,
                "nome_doador" => $nome_doador,
                "nome_link" => Entidade::entidadeNomeParaLink($nome_doador),
                "sigla_ue_doador" => $row->sigla_ue_doador,
                "valor_sem_formato" => $row->new_valor,
                "percent" => round(($row->new_valor/$total_percentArray[$tipo_receita])*100,3),
                "valor" => number_format($row->new_valor,2,',','.'),
                "data_receita" => date("d/m/y",strtotime($row->new_data_receita)),
                "data_receita_sort" => $row->new_data_receita,
                "fonte_recurso" => $row->fonte_recurso,
                "especie_recurso" => $row->especie_recurso,
                "descricao_receita" => $descricao_receita,
                "numero_documento" => $row->numero_documento
            );
            $countArray[$tipo_receita]++;
        }
        return $ccpArray;
    }

    public function ccpDoacoesListaTodosArray(array $anosArray,$pagina,$itensPagina) {
        $this->anosConsulta = implode(',',$anosArray);
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);

        $query_campos = "cpf_cnpj_doador,tipo_receita,nome_doador,nome_receita_doador,sigla_ue_doador,new_valor,new_data_receita,fonte_recurso,especie_recurso,descricao_receita,$this->documento_ccp as numero_documento";

        $query = "(SELECT $query_campos FROM $this->tabela_ccp WHERE tipo_receita = \"" . $this->APOIO_TIPO_RECEITA[2] . "\" AND new_prestacao_tse_ano IN (?) AND $this->tabela_index_ccp = ? ORDER BY new_valor DESC LIMIT 0,10)
        UNION ALL
        (SELECT $query_campos FROM $this->tabela_ccp WHERE tipo_receita = \"" . $this->APOIO_TIPO_RECEITA[0] . "\" AND new_prestacao_tse_ano IN (?) AND $this->tabela_index_ccp = ? ORDER BY new_valor DESC LIMIT 0,10)
        UNION ALL
        (SELECT $query_campos FROM $this->tabela_ccp WHERE tipo_receita = \"" . $this->APOIO_TIPO_RECEITA[1] . "\" AND new_prestacao_tse_ano IN (?) AND $this->tabela_index_ccp = ? ORDER BY new_valor DESC LIMIT 0,10)
        UNION ALL
        (SELECT $query_campos FROM $this->tabela_ccp WHERE tipo_receita = \"" . $this->APOIO_TIPO_RECEITA[3] . "\" AND new_prestacao_tse_ano IN (?) AND $this->tabela_index_ccp = ? ORDER BY new_valor DESC LIMIT 0,10)
        UNION ALL
        (SELECT $query_campos FROM $this->tabela_ccp WHERE tipo_receita = \"" . $this->APOIO_TIPO_RECEITA[4] . "\" AND new_prestacao_tse_ano IN (?) AND $this->tabela_index_ccp = ? ORDER BY new_valor DESC LIMIT 0,10)
        UNION ALL
        (SELECT $query_campos FROM $this->tabela_ccp WHERE tipo_receita = \"" . $this->APOIO_TIPO_RECEITA[5] . "\" AND new_prestacao_tse_ano IN (?) AND $this->tabela_index_ccp = ? ORDER BY new_valor DESC LIMIT 0,10)";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$this->cod);
        #$consulta->bindParam(3,$offset,PDO::PARAM_INT);
        #$consulta->bindParam(4,$itensPagina,PDO::PARAM_INT);
        $consulta->bindParam(3,$this->anosConsulta);
        $consulta->bindParam(4,$this->cod);
        #$consulta->bindParam(7,$offset,PDO::PARAM_INT);
        #$consulta->bindParam(8,$itensPagina,PDO::PARAM_INT);
        $consulta->bindParam(5,$this->anosConsulta);
        $consulta->bindParam(6,$this->cod);
        #$consulta->bindParam(11,$offset,PDO::PARAM_INT);
        #$consulta->bindParam(12,$itensPagina,PDO::PARAM_INT);
        $consulta->bindParam(7,$this->anosConsulta);
        $consulta->bindParam(8,$this->cod);
        #$consulta->bindParam(15,$offset,PDO::PARAM_INT);
        #$consulta->bindParam(16,$itensPagina,PDO::PARAM_INT);
        $consulta->bindParam(9,$this->anosConsulta);
        $consulta->bindParam(10,$this->cod);
        #$consulta->bindParam(19,$offset,PDO::PARAM_INT);
        #$consulta->bindParam(20,$itensPagina,PDO::PARAM_INT);
        $consulta->bindParam(11,$this->anosConsulta);
        $consulta->bindParam(12,$this->cod);
        #$consulta->bindParam(23,$offset,PDO::PARAM_INT);
        #$consulta->bindParam(24,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        return($consulta->fetchAll(\PDO::FETCH_OBJ));
    }

    public function ccpDoacoesListaPorTipoReceitaArraySmarty(array $anosArray,$tipo_receita,$pagina,$itensPagina) {
        $result = $this->ccpDoacoesListaPorTipoReceitaArray($anosArray,$tipo_receita,$pagina,$itensPagina);

        $count = 0;
        $ccpArray = array();

        foreach($result as $row) {
            $tipo_receita = $row->tipo_receita;
            if ($count==0) {
                $total_percent = $row->new_valor;
            }

            $nome_doador = $row->nome_receita_doador != '' ? $row->nome_receita_doador : $row->nome_doador;
            $descricao_receita = $row->descricao_receita != ''? $row->descricao_receita : "[não informada]";

            $ccpArray[$count] = array(
                "cod_doador" => $row->cpf_cnpj_doador,
                "nome_doador" => $nome_doador,
                "nome_link" => Entidade::entidadeNomeParaLink($nome_doador),
                "sigla_ue_doador" => $row->sigla_ue_doador,
                "valor_sem_formato" => $row->new_valor,
                "percent" => round(($row->new_valor/$total_percent)*100,3),
                "valor" => number_format($row->new_valor,2,',','.'),
                "data_receita" => date("d/m/y",strtotime($row->new_data_receita)),
                "data_receita_sort" => $row->new_data_receita,
                "fonte_recurso" => $row->fonte_recurso,
                "especie_recurso" => $row->especie_recurso,
                "descricao_receita" => $descricao_receita,
                "numero_documento" => $row->numero_documento
            );
            $count++;
        }
        return $ccpArray;
    }

    public function ccpDoacoesListaPorTipoReceitaArray(array $anosArray,$tipo_receita,$pagina,$itensPagina) {
        $this->anosConsulta = implode(',',$anosArray);
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);

        $query_campos = "cpf_cnpj_doador,tipo_receita,nome_doador,nome_receita_doador,sigla_ue_doador,new_valor,new_data_receita,fonte_recurso,especie_recurso,descricao_receita,$this->documento_ccp as numero_documento";

        $query = "SELECT $query_campos FROM $this->tabela_ccp WHERE tipo_receita = ? AND new_prestacao_tse_ano IN (?) AND $this->tabela_index_ccp = ? ORDER BY new_valor DESC LIMIT ?,?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->APOIO_TIPO_RECEITA[$tipo_receita]);
        $consulta->bindParam(2,$this->anosConsulta);
        $consulta->bindParam(3,$this->cod);
        $consulta->bindParam(4,$offset,PDO::PARAM_INT);
        $consulta->bindParam(5,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        return($consulta->fetchAll(\PDO::FETCH_OBJ));
    }


}


Class Entidade {
# Por uma questão de simplicidade, resolvi implementar a classe da entidade separada da classe de cálculos de
# totais (abaixo).

    # apoio
    private $anosConsulta;
    private $PA_MYSQL_GASTOSDIRETOS = PA_MYSQL_GASTOSDIRETOS;

    # geral
    public $cod;
    public $nome_entidade;

    # gastostotais / pagamentos
    public $gastosdiretos_num;
    public $contratos_total;

    # prestacaoCCP / doacoes
    ## Valores
    public $doacoes_candidato;
    public $doacoes_partido;
    public $doacoes_comite;
    public $doacoes_total;

    ## Counts
    public $prestacao_candidato__num;
    public $prestacao_comite_num;
    public $prestacao_partido_num;
    public $prestacao_total_num;

    ## doacoes
    public $doacoes_candidatos_lista;
    public $doacoes_comites_lista;
    public $doacoes_partidos_lista;

    function __construct($con,$cod_arg) {
        $this->conexao = $con;
        $this->cod = $cod_arg;
    }

    public static function entidadeNomeParaLink($nome) {
        $nome = iconv('UTF-8', 'us-ascii//TRANSLIT',$nome);
        $nome_search = array(" ","'",'~','^');
        $nome_replace = array('_','','','');
        return (str_replace($nome_search,$nome_replace,$nome));
    }

    public function entidadeNasPrestacoesTotais(array $anosArray) {
        $this->anosConsulta = implode(',',$anosArray);

        # Calculando total de doacoes
        $query = "SELECT nome_receita_doador,nome_doador,valor_total_candidatos,prestacao_candidato_count,valor_total_comites,prestacao_comite_count,valor_total_partidos,prestacao_partido_count,valor_total_ccp,prestacao_total_ccp_count FROM prestacaototais WHERE excluir_view = 0 AND ano IN (?) AND cod_doador = ?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$this->cod);
        $consulta->execute();
        $result = $consulta->fetch(\PDO::FETCH_OBJ);
        if(is_object($result)) {
            $this->nome_entidade = $result->nome_receita_doador != '' ? $result->nome_receita_doador : $result->nome_doador;
            $this->doacoes_candidato = $result->valor_total_candidatos;
            $this->prestacao_candidato__num = $result->prestacao_candidato_count;
            $this->doacoes_comite = $result->valor_total_comites;
            $this->prestacao_comite_num = $result->prestacao_comite_count;
            $this->doacoes_partido = $result->valor_total_partidos;
            $this->prestacao_partido_num = $result->prestacao_partido_count;
            $this->doacoes_total = $result->valor_total_ccp;
            $this->prestacao_total_num = $result->prestacao_total_ccp_count;
        }
        else {
            $this->doacoes_candidato = 0.00;
            $this->prestacao_candidato__num = 0;
            $this->doacoes_comite = 0.00;
            $this->prestacao_comite_num = 0;
            $this->doacoes_partido = 0.00;
            $this->prestacao_partido_num = 0;
            $this->doacoes_total = 0.00;
            $this->prestacao_total_num = 0;
        }
    }

    public function entidadeNosGastosTotais(array $anosArray) {
        $this->anosConsulta = implode(',',$anosArray);

        # Calculando total de contratos
        $query = "SELECT nome_favorecido,valor_total,pagamentos_count FROM gastostotais WHERE excluir_view = 0 AND ano IN (?) AND cod_favorecido = ?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$this->cod);
        #$consulta->bindParam(2,$this->conexao->quote($this->cod));
        $consulta->execute();
        $result = $consulta->fetch(\PDO::FETCH_OBJ); # Falta tratar para o caso de não existir!!
        if(is_object($result)) {
            $this->contratos_total = $result->valor_total;
            $this->gastosdiretos_num = $result->pagamentos_count;
        }
        else {
            $this->contratos_total = 0.00;
            $this->gastosdiretos_num = 0;
        }
        # Setando o nome em caso de a entidade existir apenas nesta tabela
        if ($this->nome_entidade == '') {
            if ($result->nome_favorecido == '') {
                $this->nome_entidade = 'Entidade não encontrada';
            } else {
                $this->nome_entidade = $result->nome_favorecido;
            }
        }
        # Retirando os colchetes:
        $this->nome_entidade = preg_replace('/\[.*?\]/', '', $this->nome_entidade);
    }

    public function entidadeNosGastosDiretosListaTodos(array $anosArray,$pagina,$itensPagina) {
        $this->anosConsulta = implode(',',$anosArray);
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);

        #$query = "SELECT cod_org_superior,nome_org_superior,nome_unid_gestora,nome_elemento_despesa,linguagem_cidada,new_valor FROM gastosdiretos WHERE new_pessoa_juridica = 1 AND YEAR(new_data_pagamento) IN (?) AND cod_favorecido = ? ORDER BY new_valor DESC";
        $query = "SELECT $this->PA_MYSQL_GASTOSDIRETOS.cod_org_superior,aux_org_superior.nome_org_superior,
                         $this->PA_MYSQL_GASTOSDIRETOS.cod_unid_gestora,aux_unid_gestora.nome_unid_gestora,
                         $this->PA_MYSQL_GASTOSDIRETOS.cod_elemento_despesa,aux_elemento_despesa.nome_elemento_despesa,
                         $this->PA_MYSQL_GASTOSDIRETOS.cod_programa,aux_programa.nome_programa,
                         $this->PA_MYSQL_GASTOSDIRETOS.cod_acao,aux_acao.nome_acao,
                         $this->PA_MYSQL_GASTOSDIRETOS.numero_documento,
                         $this->PA_MYSQL_GASTOSDIRETOS.data_pagamento,
                         $this->PA_MYSQL_GASTOSDIRETOS.valor
                  FROM $this->PA_MYSQL_GASTOSDIRETOS
                    INNER JOIN aux_org_superior
                      ON $this->PA_MYSQL_GASTOSDIRETOS.cod_org_superior = aux_org_superior.cod_org_superior
                    INNER JOIN aux_unid_gestora
                      ON $this->PA_MYSQL_GASTOSDIRETOS.cod_unid_gestora = aux_unid_gestora.cod_unid_gestora
                    INNER JOIN aux_elemento_despesa
                      ON $this->PA_MYSQL_GASTOSDIRETOS.cod_elemento_despesa = aux_elemento_despesa.cod_elemento_despesa
                    INNER JOIN aux_programa
                      ON $this->PA_MYSQL_GASTOSDIRETOS.cod_programa = aux_programa.cod_programa
                    INNER JOIN aux_acao
                      ON $this->PA_MYSQL_GASTOSDIRETOS.cod_acao = aux_acao.cod_acao
                  WHERE new_pessoa_juridica = 1 AND new_ano_arquivo_orig IN (?) and cod_favorecido = ?
                  ORDER BY valor DESC LIMIT ?,?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        #$consulta->bindParam(2,$this->cod);
        $consulta->bindValue(2,$this->cod,PDO::PARAM_STR);
        $consulta->bindParam(3,$offset,PDO::PARAM_INT);
        $consulta->bindParam(4,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        #$consulta = $this->conexao->query($query);
        return($consulta->fetchAll(\PDO::FETCH_OBJ));
    }

    public function entidadeNosGastosDiretosListaTodosArraySmarty(array $anosArray,$pagina,$itensPagina) {
        $result = $this->entidadeNosGastosDiretosListaTodos($anosArray,$pagina,$itensPagina);

        # Montando uma array com os resultados, para uso pelo template Smarty.
        $count = 0;
        $pagamentosArray = array();
        foreach($result as $row) {
            if ($count==0) {
                $total_percent = $row->valor;
            }
            $pagamentosArray[$count] = array(
                "nome_orgao" => $row->nome_org_superior,
                "nome_unidade_gestora" => $row->nome_unid_gestora,
                "nome_elemento_despesa" => $row->nome_elemento_despesa,
                "numero_documento" => $row->numero_documento,
                "nome_programa" => $row->nome_programa,
                "nome_acao" => $row->nome_acao,
                "data_pagamento" => date("d/m/y",strtotime($row->data_pagamento)),
                "data_pagamento_sort" => $row->data_pagamento,
                "valor_sem_formato" => $row->valor,
                "valor" => number_format($row->valor,2,',','.'),
                "percent" => round(($row->valor/$total_percent)*100,3)
            );
            $count++;
        }
        return $pagamentosArray;
    }

    public function entidadeNumGastosDiretosDEPRECIADA(array $anosArray) {
        $this->anosConsulta = implode(',',$anosArray);
        $query = "SELECT COUNT(*) FROM $this->PA_MYSQL_GASTOSDIRETOS WHERE new_pessoa_juridica = 1 AND new_ano_arquivo_orig IN (?) AND cod_favorecido = ?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$this->cod,PDO::PARAM_STR);
        $consulta->execute();
        $numGastosDiretos = $consulta->fetch();
        $this->gastosdiretos_num = $numGastosDiretos[0];
    }

    public function entidadeNasPrestacoesListaTodos(array $anosArray,$pagina,$itensPagina) {
        # Atencao: Prestacao de 2010 nao tem sequencial comite ou diretorio
        $this->anosConsulta = implode(',',$anosArray);
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);

        $query = "(SELECT nome_candidato AS nome,sigla_partido,uf,cpf_candidato AS cod_recebedor,new_data_receita,new_valor,'candidato' as tipo_prestacao FROM prestacaocandidato WHERE tipo_receita='Recursos de pessoas jurídicas' AND new_prestacao_tse_ano IN (?) AND cpf_cnpj_doador = ?)
UNION ALL
(SELECT tipo_comite AS nome,sigla_partido,uf,sequencial_comite AS cod_recebedor,new_data_receita,new_valor,'comite' as tipo_prestacao FROM prestacaocomite WHERE tipo_receita='Recursos de pessoas jurídicas' AND new_prestacao_tse_ano IN (?) AND cpf_cnpj_doador = ?)
UNION ALL
(SELECT CONCAT(tipo_diretorio,' - ',uf) AS nome,sigla_partido,uf,sequencial_diretorio AS cod_recebedor,new_data_receita,new_valor,'partido' as tipo_prestacao FROM prestacaopartido WHERE tipo_receita='Recursos de pessoas jurídicas' AND new_prestacao_tse_ano IN (?) AND cpf_cnpj_doador = ?) ORDER BY new_valor DESC LIMIT ?,?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$this->cod);
        $consulta->bindParam(3,$this->anosConsulta);
        $consulta->bindParam(4,$this->cod);
        $consulta->bindParam(5,$this->anosConsulta);
        $consulta->bindParam(6,$this->cod);
        $consulta->bindParam(7,$offset,PDO::PARAM_INT);
        $consulta->bindParam(8,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        return($consulta->fetchAll(\PDO::FETCH_OBJ));
    }

    public function entidadeNasPrestacoesListaTodosArraySmarty(array $anosArray,$pagina,$itensPagina) {
        $result = $this->entidadeNasPrestacoesListaTodos($anosArray,$pagina,$itensPagina);

        # Montando uma array com os resultados
        $count = 0;
        $doacoesArray = array();
        foreach($result as $row) {
            if ($count==0) {
                $total_percent = $row->new_valor;
            }
            $nome = $row->nome . " (".$row->sigla_partido." - ". $row->uf.")";
            $nome_link = $row->nome . " " . $row->sigla_partido . " " . $row->uf;
            $doacoesArray[$count] = array(
                "cod_recebedor" => $row->cod_recebedor,
                "nome" => $nome,
                "nome_link" => Entidade::entidadeNomeParaLink($nome_link),
                "tipo_prestacao" => $row->tipo_prestacao,
                "data" => date("d/m/y",strtotime($row->new_data_receita)),
                "data_sort" => $row->new_data_receita,
                "valor_sem_formato" => $row->new_valor,
                "valor" => number_format($row->new_valor,2,',','.'),
                "percent" => round(($row->new_valor/$total_percent)*100,3)
            );
            $count++;
        }
        return $doacoesArray;
    }
}


Class PrestacaoTotal {
    private $conexao;
    private $anosConsulta;

    function __construct($con,array $anosArray) {
        $this->conexao = $con;
        $this->anosConsulta = implode(',',$anosArray);
    }

    public function doadoresUnicosLista($pagina,$itensPagina) {
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);

        $query = "SELECT cod_doador,nome_receita_doador,nome_doador,valor_total_ccp FROM prestacaototais WHERE ano IN (?) AND excluir_view = 0 ORDER BY valor_total_ccp DESC LIMIT ?,?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$offset,PDO::PARAM_INT);
        $consulta->bindParam(3,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        return ($consulta->fetchAll(\PDO::FETCH_OBJ));
    }

    public function doadoresUnicosListaTodos($pagina,$itensPagina) {
        # Calculando o offset para o select:
        #$offset = $pagina == 1 ? 0 : ((($pagina - 1)*$itensPagina) - 1);
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);
        $query = "SELECT cod_doador,nome_receita_doador,nome_doador,valor_total_ccp,prestacao_total_ccp_count FROM prestacaototais WHERE ano IN (?) AND excluir_view = 0 ORDER BY valor_total_ccp DESC LIMIT ?,?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$offset,PDO::PARAM_INT);
        $consulta->bindParam(3,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        return ($consulta->fetchAll(\PDO::FETCH_OBJ));
    }

    public function doadoresUnicosNum() {
        $query = "SELECT COUNT(DISTINCT cod_doador) FROM prestacaototais WHERE ano IN (?) AND excluir_view = 0";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->execute();
        return ($consulta->fetch());
    }

    public function doacoesTotal() {
        $query = "SELECT SUM(valor_total_ccp) FROM prestacaototais WHERE ano IN (?) AND excluir_view = 0";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->execute();
        return ($consulta->fetch());
    }

    public function buscaDoador($consulta) {
        $termo_consulta = "%"."$consulta"."%";
        $query = "SELECT cod_doador,nome_doador from prestacaototais WHERE ANO IN (?) AND excluir_view = 0 AND nome_doador LIKE ? ORDER BY valor_total_ccp DESC LIMIT 8";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$termo_consulta);
        $consulta->execute();
        return json_encode($consulta->fetchAll(\PDO::FETCH_ASSOC));
    }
}

Class PrestacaoCandidato {
    private $conexao;
    private $anosConsulta;

    function __construct($con,array $anos) {
        $this->conexao = $con;
        foreach($anos as $i=>$value) {
            $anosArray[$i] = $value;
        }
        $this->anosConsulta = implode(',',$anosArray);
    }

    public function candidatosUnicosNum() {
        $query = 'SELECT COUNT(DISTINCT cpf_candidato) FROM prestacaocandidato WHERE ano IN (?)';
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->execute();
        return ($consulta->fetch());
    }
}

Class GastosTotais {
    private $conexao;
    private $anosConsulta;

    function __construct($con,array $anos) {
        $this->conexao = $con;
        foreach($anos as $i=>$value) {
            $anosArray[$i] = $value;
        }
        $this->anosConsulta = implode(',',$anosArray);
    }

    public function contratadasUnicasLista($pagina,$itensPagina) {
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);

        $query = "SELECT cod_favorecido,nome_favorecido,valor_total FROM gastostotais WHERE ano IN (?) AND excluir_view = 0 ORDER BY valor_total DESC LIMIT ?,?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$offset,PDO::PARAM_INT);
        $consulta->bindParam(3,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        return ($consulta->fetchAll(\PDO::FETCH_OBJ));
    }

    public function contratadasUnicasListaTodas($pagina,$itensPagina) {
        # Calculando o offset para o select:
        #$offset = $pagina == 1 ? 0 : ((($pagina - 1)*$itensPagina) - 1);
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);
        $query = "SELECT cod_favorecido,nome_favorecido,valor_total,pagamentos_count FROM gastostotais WHERE ano IN (?) AND excluir_view = 0 ORDER BY valor_total DESC LIMIT ?,?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->bindParam(2,$offset,PDO::PARAM_INT);
        $consulta->bindParam(3,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        return ($consulta->fetchAll(\PDO::FETCH_OBJ));
    }

    public function contratadasUnicasNum() {
        $query = "SELECT COUNT(DISTINCT cod_favorecido) FROM gastostotais WHERE ano IN (?) AND excluir_view = 0";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsulta);
        $consulta->execute();
        return ($consulta->fetch());
    }
}

Class Busca {
    private $conexao;
    private $anosConsultaDoadores;
    private $anosConsultaContratadas;

    public $anosDoadores = array();
    public $anosContratadas = array();

    private $queryPJ = "SELECT codigo_entidade,COALESCE(nome_favorecido,nome_receita_doador,nome_doador) as nome FROM entidade_nomes WHERE ano IN (?) AND nome_favorecido LIKE ? OR nome_receita_doador LIKE ? OR nome_doador LIKE ? ORDER BY nome";

    public $queryCandidato = "SELECT DISTINCT(cod_ccp),nome_ccp,cargo,sigla_partido,uf,municipio FROM ccp WHERE ano IN (?) AND excluir_view = 0 AND tipo_ccp = 'candidato' AND nome_ccp LIKE ? ORDER BY nome_ccp";

    function __construct($con) {
        $this->conexao = $con;
    }

    function buscaNomeCandidatoCount($parametro) {
        $param = $this->preparaParametro($parametro);

        # Primeiramente, definindo as vars dos anos que usaremos:
        $this->defineAnosConsulta();

        $query = "SELECT COUNT(*) FROM (" . $this->queryCandidato .") as queryTable";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsultaDoadores);
        $consulta->bindParam(2,$param,PDO::PARAM_STR);
        $consulta->execute();
        $queryCandidatoCount = $consulta->fetch();
        return($queryCandidatoCount[0]);
    }

    function buscaNomeCandidato($parametro,$pagina,$itensPagina) {
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);
        $param = $this->preparaParametro($parametro);

        # Primeiramente, definindo as vars dos anos que usaremos:
        $this->defineAnosConsulta();

        $query = $this->queryCandidato . " LIMIT ?,?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsultaDoadores);
        $consulta->bindParam(2,$param,PDO::PARAM_STR);
        $consulta->bindParam(3,$offset,PDO::PARAM_INT);
        $consulta->bindParam(4,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        $resultados = $consulta->fetchAll(\PDO::FETCH_OBJ);

        # Montando uma array com os resultados
        $count = 0;
        $resultadosArray = array();
        foreach($resultados as $row) {
            $resultadosArray[$count] = array(
                "cod_ccp" => $row->cod_ccp,
                "nome_ccp" => $row->nome_ccp,
                "nome_link" => Entidade::entidadeNomeParaLink($row->nome_ccp),
                "cargo" => $row->cargo,
                "sigla_partido" => $row->sigla_partido,
                "uf" => $row->uf,
                "municipio" => $row->municipio
            );
            $count++;
        }
        return $resultadosArray;
    }

    function buscaNomePJCount($parametro) {
        $param = "%".$parametro."%";

        # Primeiramente, definindo as vars dos anos que usaremos:
        $this->defineAnosConsulta();

        $query = "SELECT COUNT(*) FROM (" . $this->queryPJ .") as queryTable";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsultaContratadas);
        $consulta->bindParam(2,$param);
        $consulta->bindParam(3,$param);
        $consulta->bindParam(4,$param);
        $consulta->execute();
        $queryPJCount = $consulta->fetch();
        return($queryPJCount[0]);
    }

    function buscaNomePJ($parametro,$pagina,$itensPagina) {
        $offset = $pagina == 1 ? 0 : (($pagina - 1)*$itensPagina);
        $param = "%".$parametro."%";

        # Primeiramente, definindo as vars dos anos que usaremos:
        $this->defineAnosConsulta();

        # Montando a query para buscar nas duas tabelas:
        $query = $this->queryPJ . " LIMIT ?,?";
        $consulta = $this->conexao->prepare($query);
        $consulta->bindParam(1,$this->anosConsultaContratadas);
        $consulta->bindParam(2,$param);
        $consulta->bindParam(3,$param);
        $consulta->bindParam(4,$param);
        $consulta->bindParam(5,$offset,PDO::PARAM_INT);
        $consulta->bindParam(6,$itensPagina,PDO::PARAM_INT);
        $consulta->execute();
        $resultados = $consulta->fetchAll(\PDO::FETCH_OBJ);

        $query2 = "
        SELECT codigo,nome1,nome2,SUM(pagamentos_total) AS pagamentos_total,SUM(doacoes_total) AS doacoes_total FROM (
          SELECT cod_favorecido AS codigo,nome_favorecido AS nome1,'' AS nome2,valor_total AS pagamentos_total,0 AS doacoes_total FROM gastostotais WHERE ano IN (?) AND cod_favorecido = ?
          UNION ALL
          SELECT cod_doador AS codigo,nome_receita_doador AS nome1,nome_doador AS nome2,0 AS pagamentos_total,valor_total_ccp AS doacoes_total FROM prestacaototais WHERE ano IN (?) AND cod_doador = ?
        ) as t GROUP BY codigo";
        $consulta2 = $this->conexao->prepare($query2);
        $consulta2->bindParam(1,$this->anosConsultaContratadas);
        $consulta2->bindParam(3,$this->anosConsultaDoadores);

        # Montando uma array com os resultados
        $count = 0;
        $resultadosArray = array();
        foreach($resultados as $row) {
            $consulta2->bindParam(2,$row->codigo_entidade);
            $consulta2->bindParam(4,$row->codigo_entidade);
            $consulta2->execute();
            $result = $consulta2->fetch(\PDO::FETCH_OBJ);
            if(is_object($result)) {
                $nome = $result->nome1 != '' ? $result->nome1 : $result->nome2;
                $resultadosArray[$count] = array(
                    "cod" => $result->codigo,
                    "nome" => $nome,
                    "nome_link" => Entidade::entidadeNomeParaLink($nome),
                    "valor_total_ccp" => number_format($result->doacoes_total,2,',','.'),
                    "valor_total_ccp_sem_formato" => $result->doacoes_total,
                    "valor_total_pagamentos" =>  number_format($result->pagamentos_total,2,',','.'),
                    "valor_total_pagamentos_sem_formato" => $result->pagamentos_total
                );
            }
            $count++;
        }
        return $resultadosArray;
    }


    public static function limpaParametro($parametro) {
        $parametro_busca = iconv('UTF-8', 'us-ascii//TRANSLIT',$parametro);
        $parametro_busca = trim($parametro_busca);
        $parametro_search = array("'",'~','^');
        $parametro_replace = array('','','');
        return(str_replace($parametro_search,$parametro_replace,$parametro_busca));
    }

    public static function checaParametro($parametro) {
        $mensagem = '';
        if (!preg_match("/^[A-Za-z0-9 ]+$/",$parametro)) {
            $mensagem .= '- apenas letras e números são aceitos.<br>';
        }

        if (strlen($parametro) < 3) {
            $mensagem .= '- o parâmetro de busca deve ter ao menos 3 caracteres.<br>';
        }
        return $mensagem;
    }

    private function preparaParametro($parametro) {
        $parametro = trim($parametro);
        $parametro = str_replace(' ','%',$parametro);
        return($param = "%".$parametro."%");
    }

    private function defineAnosConsulta() {
        foreach($this->anosDoadores as $i=>$value) {
            $anosDoadoresArray[$i] = $value;
        }
        $this->anosConsultaDoadores = implode(',',$anosDoadoresArray);

        foreach($this->anosContratadas as $i=>$value) {
            $anosContratadasArray[$i] = $value;
        }
        $this->anosConsultaContratadas = implode(',',$anosContratadasArray);
    }
}

Class Paginador {
# Esta classe cria a array com a sequencia de paginação (os ranges que aparecerao embaixo da pagina0 de acordo
# com o número total de elementos e o range que estamos vendo no momento.
    private $count = 1;
    public $pagina; # a pagina que estamos vendo no momento
    public $range_fim; # tem de ser setado com o número total de doadores/contratadas (itens a serem listados/paginados)
    public $itens_por_pg; # setado com o numero de itens por pagina;
    public $ranges_paginacao; # o numero de ranges que queremos ver ao final.

    function __construct() {
    }

    function paginacaoCriaRanges() {
        # Calculando o escopo a ser paginado
        $paginasCheias = intval($this->range_fim/$this->itens_por_pg);
        $paginaUltimaItens = $this->range_fim % $this->itens_por_pg;

        # Se houver remainder na divisao, é porque temos uma página além das cheias:
        if ($paginaUltimaItens != 0) {
            $paginasTotal = $paginasCheias + 1;
        }
        else {
            $paginasTotal = $paginasCheias;
            # Caso o remainder seja zero, isso significa que a ultima pagina tem um numero de paginas multiplo de itens_por_pg,
            # quer dizer, eh uma pagina cheia.
            $paginaUltimaItens = $this->itens_por_pg;
        }

        # Se o numero total de itens a serem paginados for menor que o numero de itens por pg, nao precisamos de paginacao.
        if ($this->range_fim < $this->itens_por_pg) {
            $this->paginacao[0]['pg'] = '';
            $this->paginacao[0]['range'] = '';
            $this->paginacao[0]['selecionada'] = '';
            return $this->paginacao;
        }

        # Iniciando a iteração
        # Ao verificar o final da iteracao, checamos se estamos a menos da metade do final. Para isso, dividimos
        # o total de ranges a mostrar por dois:
        $rangesMetade = intval($this->ranges_paginacao/2); # Debug (ignorar): 11/2 = 5
        if ($this->pagina > ($rangesMetade + 1)) { # Se não estivermos no iniciozinho da lista
            if ($this->pagina >= ($paginasTotal - $rangesMetade)) { # Se estivermos no finalzinho da lista
                $inicioIteracao = $paginasTotal - (2*$rangesMetade) + 1; # Setando o ponteiro de onde a contagem comeca
                if ($inicioIteracao < 2) { # Prevenindo-se para o fato de que uma lista curta pode gerar um no. negativo aqui
                    $inicioIteracao = 2;
                    $marca_distancia_inicio = "";
                }
                else {
                    $marca_distancia_inicio = " ...";
                }
                if ($paginasTotal <= $this->ranges_paginacao) { # Se nao tivermos uma lista comprida (q cabe numa tela)
                    $marca_distancia_inicio = "";
                }

                $fimIteracao = $paginasTotal - 1;
                $marca_distancia_fim = ""; # para visualização
            }
            else {
                $inicioIteracao = $this->pagina - ($rangesMetade - 1); # Debug: 2
                $fimIteracao = $this->pagina + ($rangesMetade - 1); # Debug 10
                $marca_distancia_fim = "... ";
                $marca_distancia_inicio = " ...";
            }
        }
        else {
            $inicioIteracao = 2;

            # Verificando se temos paginas suficientes (se precisamos mostrar o range todo ou nao)
            if ($paginasTotal > $this->ranges_paginacao) {
                $fimIteracao = $this->ranges_paginacao - 1;
                $marca_distancia_fim = "... ";
            }
            else {
                $fimIteracao = $paginasTotal - 1;
                $marca_distancia_fim = "";
            }

            $marca_distancia_inicio = "";
        }

        # Criando a array da paginacao:
        ## A sequência de ranges sempre comeca com o primeiro range:
        $this->paginacao[0]['pg'] = 1;
        $this->paginacao[0]['range'] = "<< Início [1-" . $this->itens_por_pg . "] " . $marca_distancia_inicio;
        $this->paginacao[0]['selecionada'] = $this->pagina == 1 ? 1 : 0;

        ## Calculando o meio
        for($i=$inicioIteracao;$i<=$fimIteracao;$i++) {
            $this->paginacao[$this->count]['pg'] = $i;
            $range_inicio = ($i - 1)*$this->itens_por_pg + 1;
            $range = "[" . $range_inicio . "-" . ($range_inicio + $this->itens_por_pg - 1) . "]";
            $this->paginacao[$this->count]['range'] = $range;
            $this->paginacao[$this->count]['selecionada'] = $this->pagina == $i ? 1 : 0;
            $this->count++;
        }

        ## Setando o fim da paginacao
        $this->paginacao[$this->count]['pg'] = $paginasTotal;
        $this->paginacao[$this->count]['range'] = $marca_distancia_fim . " [" . ($this->range_fim - ($paginaUltimaItens-1)) . "-" . $this->range_fim . "] >>";
        $this->paginacao[$this->count]['selecionada'] = $this->pagina == $this->paginacao[$this->count]['pg'] ? 1: 0;

        return $this->paginacao;
    }
}

Class NovoSmarty extends Smarty {
    function __construct() {
        parent::__construct();
        if (PHP_OS == "Linux") {
            $this->setTemplateDir(PA_SMARTY_TEMPLATES);
            $this->setCompileDir(PA_SMARTY_COMPILE);
            $this->setConfigDir(PA_SMARTY_CONFIG);
            $this->setCacheDir(PA_SMARTY_CACHE);
        }
        else{
            $this->setTemplateDir(PA_SMARTY_TEMPLATES_OUTROS);
            $this->setCompileDir(PA_SMARTY_COMPILE_OUTROS);
            $this->setConfigDir(PA_SMARTY_CONFIG_OUTROS);
            $this->setCacheDir(PA_SMARTY_CACHE_OUTROS);
        }
    }
}

Class SafePDO extends PDO {
    public static function exception_handler($exception) {
        //Output the exception details
        die('Uncaught exception: '. $exception->getMessage());
    }
    public function __construct($dsn, $username='', $password='', $driver_options=array()) {
        // Temporarily change the PHP exception handler while we . . .
        set_exception_handler(array(__CLASS__, 'exception_handler'));

        // . . . create a PDO object
        parent::__construct($dsn, $username, $password, $driver_options);

        // Change the exception handler back to whatever it was before
        restore_exception_handler();
    }
}

Class Conexao extends \SafePDO {
    public function __construct() {
        parent::__construct('mysql:host='.PA_MYSQL_HOST.';dbname='.PA_MYSQL_DBNAME,
            PA_MYSQL_USER,
            PA_MYSQL_PASSWORD,
            array(
                \PDO::ATTR_ERRMODE => \PDO::ERRMODE_EXCEPTION,
                \PDO::ATTR_PERSISTENT => true,
                \PDO::MYSQL_ATTR_INIT_COMMAND => 'set names utf8mb4'
            )
        );
    }
}
?>