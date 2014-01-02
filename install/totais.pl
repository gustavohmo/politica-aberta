#!/usr/bin/perl
#
# Política Aberta - totais.pl
# Este script automatiza a criação de tabelas de totais. Ele deve ser utilizado depois que os dados do Portal da
# Transparência e do TSE (quer dizer, depois que já utilizamos o gastosdiretos.pl e o prestacao.pl) forem incluídos
# no banco. A automatização não é completa, por diversos motivos (mencionados na documentação.
#
# Este script pode ser rodado no command-line tanto no Windows como no Linux. É necessário ter o Perl instalado.
#################################################################################################################
use strict;
use warnings;

#################################################################################################################
# Início das configurações
#################################################################################################################
# Defina o nome, usuário e senha do banco:
my $DB_NAME = "politicaaberta";
my $DB_USER = "NOME_DO_USUARIO";
my $DB_PASS = "SENHA";

# Defina o caminho do binário do MySQL:
my $MYSQL_BIN_LINUX = "/usr/bin/mysql";
my $MYSQL_BIN_OUTRO = "\"C:\\Program Files\\MySQL\\MySQL Server 5.5\\bin\\mysql.exe\"";

#################################################################################################################
# Fim das configurações
#################################################################################################################
my $MYSQL_BIN = "";

if ($^O eq "linux") {
    $MYSQL_BIN = $MYSQL_BIN_LINUX;
}
else {
    $MYSQL_BIN = $MYSQL_BIN_OUTRO;
}


# Total dos gastosdiretos (dados do Portal da Transparência)
#################################################################################################################
# Há duas coisas que temos de tratar antes de criar os gastostotais:
# 1) Há linhas no gastosdiretos sem informação (por exemplo, gastos da ABIN). Elas são marcadas com a string
# 'Detalhamento das informações bloqueado.'.
# 2) Há muitas pessoas físicas, cujo CPF é omitido (com asteriscos).
#
# Vamos, assim, utilizar o campo de "new_pessoa_juridica" na tabela de gastosdiretos para marcar isso:
print "*** Iniciando criacao dos gastostotais...\n";
print "*** Setando new_pessoa_juridica...";
my $seta_query = "-e \"UPDATE gastosdiretos SET new_pessoa_juridica = IF (cod_favorecido NOT LIKE '*%' AND cod_favorecido != 'Detalhamento das informações bloqueado.',1,0)\"";
&mysql_exec($seta_query);
&espera_usuario();

print "*** Truncando tabela de gastostotais...";
my $trunca_gastostotais = "-e \"TRUNCATE gastostotais\"";
&mysql_exec($trunca_gastostotais);
&espera_usuario();

print "*** Criando tabela de gastostotais (isso vai demorar)...";
my $cria_gastostotais = "-e \"INSERT INTO gastostotais (cod_favorecido,nome_favorecido,ano, valor_total,pagamentos_count) (SELECT cod_favorecido,nome_favorecido,YEAR(new_data_pagamento),sum(new_valor),COUNT(*) FROM gastosdiretos WHERE new_pessoa_juridica = 1 GROUP BY cod_favorecido,YEAR(new_data_pagamento))\"";
&mysql_exec($cria_gastostotais);
&espera_usuario();



# Total das prestacoes (dados do TSE)
#################################################################################################################
# Primeiramente, criaremos a tabela prestacaoCCP (CCP significa candidato, comite e partido), que contem os
# tres tipos de prestacao na mesma tabela. Estes totais são apenas os totais de recursos provenientes de
# pessoas juridicas, agrupados por doador.
print "*** Iniciando criacao da prestacaoCCP...\n";
print "*** Truncando tabela de prestacaoCCP...\n";
my $trunca_prestacaoCCP = "-e \"TRUNCATE prestacaoCCP\"";
&mysql_exec($trunca_prestacaoCCP);
&espera_usuario();

print "*** Adicionando conteudo de prestacaocandidato...";
my $prestacaocandidato = "-e \"INSERT INTO prestacaoCCP (cod_doador,nome_doador,nome_receita_doador,tipo_receita,cod_setor_econ_doador,setor_econ_doador,valor_total,ano,tipo_prestacao,prestacao_count) (SELECT cpf_cnpj_doador,nome_doador,nome_receita_doador,tipo_receita,cod_setor_econ_doador,setor_econ_doador,SUM(new_valor),new_prestacao_tse_ano,'candidato',COUNT(*) FROM prestacaocandidato WHERE tipo_receita='Recursos de pessoas jurídicas' GROUP BY cpf_cnpj_doador,new_prestacao_tse_ano)\"";
&mysql_exec($prestacaocandidato);
&espera_usuario();

print "*** Adicionando conteudo de prestacaocomite...";
my $prestacaocomite = "-e \"INSERT INTO prestacaoCCP (cod_doador,nome_doador,nome_receita_doador,tipo_receita,cod_setor_econ_doador,setor_econ_doador,valor_total,ano,tipo_prestacao,prestacao_count) (SELECT cpf_cnpj_doador,nome_doador,nome_receita_doador,tipo_receita,cod_setor_econ_doador,setor_econ_doador,SUM(new_valor),new_prestacao_tse_ano,'comite',COUNT(*) FROM prestacaocomite WHERE tipo_receita='Recursos de pessoas jurídicas' GROUP BY cpf_cnpj_doador,new_prestacao_tse_ano)\"";
&mysql_exec($prestacaocomite);
&espera_usuario();

print "*** Adicionando conteudo de prestacaopartido...";
my $prestacaopartido = "-e \"INSERT INTO prestacaoCCP (cod_doador,nome_doador,nome_receita_doador,tipo_receita,cod_setor_econ_doador,setor_econ_doador,valor_total,ano,tipo_prestacao,prestacao_count) (SELECT cpf_cnpj_doador,nome_doador,nome_receita_doador,tipo_receita,cod_setor_econ_doador,setor_econ_doador,SUM(new_valor),new_prestacao_tse_ano,'partido',COUNT(*) FROM prestacaopartido WHERE tipo_receita='Recursos de pessoas jurídicas' GROUP BY cpf_cnpj_doador,new_prestacao_tse_ano)\"";
&mysql_exec($prestacaopartido);
&espera_usuario();

print "*** Truncando tabela de prestacaototais...";
my $trunca_prestacaototal = "-e \"TRUNCATE prestacaototais\"";
&mysql_exec($trunca_prestacaototal);
&espera_usuario();

print "*** Criando tabela de prestacaototais...";
# Iniciando com totais de candidato
my $cria_prestacaototal = "-e \"INSERT INTO prestacaototais (cod_doador,nome_doador,nome_receita_doador,cod_setor_econ_doador,setor_econ_doador,ano,prestacao_candidato_count,valor_total_candidatos) (SELECT cod_doador,nome_doador,nome_receita_doador,cod_setor_econ_doador,setor_econ_doador,ano,prestacao_count,SUM(valor_total) FROM prestacaoCCP WHERE tipo_prestacao='candidato' GROUP BY cod_doador,ano)\"";
&mysql_exec($cria_prestacaototal);

# Totais de comite
my $cria_prestacaototal2 = "-e \"INSERT INTO prestacaototais (cod_doador,nome_doador,nome_receita_doador,cod_setor_econ_doador,setor_econ_doador,ano,prestacao_comite_count,valor_total_comites) (SELECT cod_doador,nome_doador,nome_receita_doador,cod_setor_econ_doador,setor_econ_doador,ano,prestacao_count,SUM(valor_total) FROM prestacaoCCP WHERE tipo_prestacao='comite' GROUP BY cod_doador,ano) ON DUPLICATE KEY UPDATE prestacaototais.valor_total_comites = (SELECT SUM(valor_total) FROM prestacaoCCP WHERE tipo_prestacao='comite' AND prestacaototais.cod_doador=prestacaoCCP.cod_doador AND prestacaototais.ano=prestacaoCCP.ano GROUP BY cod_doador,ano), prestacaototais.prestacao_comite_count = (SELECT prestacao_count FROM prestacaoCCP WHERE tipo_prestacao='comite' AND prestacaototais.cod_doador=prestacaoCCP.cod_doador AND prestacaototais.ano=prestacaoCCP.ano GROUP BY cod_doador,ano)\"";
&mysql_exec($cria_prestacaototal2);
&espera_usuario();

# Totais de partidos
my $cria_prestacaototal3 = "-e \"INSERT INTO prestacaototais (cod_doador,nome_doador,nome_receita_doador,cod_setor_econ_doador,setor_econ_doador,ano,prestacao_partido_count,valor_total_partidos) (SELECT cod_doador,nome_doador,nome_receita_doador,cod_setor_econ_doador,setor_econ_doador,ano,prestacao_count,SUM(valor_total) FROM prestacaoCCP WHERE tipo_prestacao='partido' GROUP BY cod_doador,ano) ON DUPLICATE KEY UPDATE prestacaototais.valor_total_partidos = (SELECT SUM(valor_total) FROM prestacaoCCP WHERE tipo_prestacao='partido' AND prestacaototais.cod_doador=prestacaoCCP.cod_doador AND prestacaototais.ano=prestacaoCCP.ano GROUP BY cod_doador,ano), prestacaototais.prestacao_partido_count = (SELECT prestacao_count from prestacaoCCP WHERE tipo_prestacao='partido' AND prestacaototais.cod_doador=prestacaoCCP.cod_doador AND prestacaototais.ano=prestacaoCCP.ano GROUP BY cod_doador,ano)\"";
&mysql_exec($cria_prestacaototal3);
&espera_usuario();

# Criando o total geral dos 3 tipos
my $cria_prestacaototal_ccp = "-e \"UPDATE prestacaototais SET valor_total_ccp = valor_total_candidatos + valor_total_comites + valor_total_partidos\"";
&mysql_exec($cria_prestacaototal_ccp);
&espera_usuario();

# Criando o total geral dos counts
my $cria_prestacaototal_ccp_count = "-e \"UPDATE prestacaototais SET prestacao_total_ccp_count = prestacao_candidato_count + prestacao_comite_count + prestacao_partido_count\"";
&mysql_exec($cria_prestacaototal_ccp_count);
&espera_usuario();

sub mysql_exec() {
    my $arg_query = $_[0];
    my $cmd = sprintf("%s --local-infile --user=%s --password=%s --database=%s %s --show-warnings --verbose --verbose --verbose",$MYSQL_BIN,$DB_USER,$DB_PASS,$DB_NAME,$arg_query);
    #system($MYSQL_BIN,"--local-infile","--user=$DB_USER","--password=$DB_PASS",$arg_query);
    print "\n$cmd\n\n";
    system($cmd);
}

sub espera_usuario() {
    print "Pressione ENTER para continuar: ";
    <STDIN>;
}