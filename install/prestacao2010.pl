#!/usr/bin/perl
#
# Política Aberta - prestacao.pl
# Este script automatiza a inclusão de dados do TSE num banco do MySQL. A automatização
# não é completa, por diversos motivos (mencionados na documentação.
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

# Definições dependentes do sistema
# Este script espera uma configuracao especifica do diretorio. No primeiro nivel após o diretorio definido abaixo,
# este script buscará todos os diretórios com a estrutura: 'PrestacaoFinalXXXX', sendo XXXX o ano da prestação.
# Depois, dentro desse diretorio, a estrutura é a do arquivo do TSE (com os 3 tipos de prestacao - candidato,
# comite e partido) e os diretorios dos estados. Se você quiser, defina apenas para o sistema operacional que você
# utiliza (Linux ou todos os outros). (Aqui há duas opções porque eu utilizei este script em ambientes distintos):
# (Repare que isso funciona apenas para as prestacoes de 2010 e 2012, porque a de 2008 tem estrutura distinta de
# diretorios e arquivos csv).
my $DIR_CSV_LINUX = "/home/openmodo/PoliticaAberta/DadosBrutosTSE/OriginaisUnzip/";
#my $DIR_CSV_OUTRO = "C:\\Users\\GustavoA\\Documents\\Projeto open data\\Dados Brutos TSE\\Originais unzip\\";
my $DIR_CSV_OUTRO = "C:/Users/GustavoA/Documents/Projeto open data/Dados Brutos TSE/Originais unzip/";

# Defina o caminho do binário do MySQL:
my $MYSQL_BIN_LINUX = "/usr/bin/mysql";
my $MYSQL_BIN_OUTRO = "\"C:\\Program Files\\MySQL\\MySQL Server 5.5\\bin\\mysql.exe\"";

# Defina o ano da prestacao
my $ANO = 2010;

#################################################################################################################
# Fim das configurações
#################################################################################################################

my $DIR_CSV = "";
my $MYSQL_BIN = "";

if ($^O eq "linux") {
    $DIR_CSV = $DIR_CSV_LINUX;
    $MYSQL_BIN = $MYSQL_BIN_LINUX;
}
else {
    $DIR_CSV = $DIR_CSV_OUTRO;
    $MYSQL_BIN = $MYSQL_BIN_OUTRO;
}


# A prestacao fornecida pelo TSE para os anos de 2012 e 2010 contém 3 diretorios principais: candidato, comite e
# partido. # Em cada diretorio desses há 28 diretórios: um para cada estado da federacao mais um para 'br'.
# Assim, vamos ter de iterar por todas essas combinações.
my @tipo_prestacao = ("candidato","comite","partido");
my %nome_txt = (
    "candidato" => "ReceitasCandidatos.txt",
    "comite"    => "ReceitasComites.txt",
    "partido"   => "ReceitasPartidos.txt"
);

my @estados = ("AC","AL","AM","AP","BA","BR","CE","DF","ES","GO","MA","MG","MS","MT","PA","PB","PE","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO");

print "*** Iniciando importacao...\n";

my $continua = 0;
my $query = '';
my $tabela = '';
my $tabela_import = '';
foreach my $tipo (@tipo_prestacao) {
    $tabela = $DB_NAME . "." . "prestacao" . $tipo;
    $tabela_import = $tabela . "_import";

    foreach my $sigla (@estados) {

        print "#######################################################\n";
        print "*** $ANO-$tipo-$sigla\n\t*** Checando imports anteriores...\n";
        # Passo 1) Checamos se este ano de prestação já não foi importado antes. Os campos new_prestacao_tse guardam
         # a informação única a respeito do arquivo (ano, tipo e sigla).
        &mysql_exec("-e \"SELECT COUNT(*) FROM $tabela WHERE new_prestacao_tse_ano = $ANO AND new_prestacao_tse_tipo = '$tipo' and new_prestacao_tse_sigla = '$sigla'\"");
        print "Deseja continuar? [y/N]";
        chomp($continua = <STDIN>);
        unless ($continua eq "y") {
            next;
        }

        # Passo 2) Zerando a tabela de apoio
        print "\t*** Zerando a tabela de apoio...\n";
        &mysql_exec("-e \"TRUNCATE $tabela_import\"");
        &espera_usuario();

        # Passo 3) Importanto o arquivo para a tabela de import
        my $csv_path = $DIR_CSV . "PrestacaoFinal" . $ANO . "/" . $tipo . "/" . $sigla . "/" . $nome_txt{$tipo};
        $csv_path =~ s/\\/\\\\/g;

        print "\t*** Importando o arquivo $csv_path para o import...";
        $query = &file_load_query($tipo,$csv_path);

        #print "\n *** Query: " . $query; # para DEBUG
        #&espera_usuario();

        &mysql_exec($query);
        &espera_usuario();

        # Passo 4) Incluindo o ano da prestacao para documentacao
        print "\t*** Incluindo informacao sobre o arquivo do TSE para documentacao...\n";
        &mysql_exec("-e \"UPDATE $tabela_import SET new_prestacao_tse_ano = $ANO, new_prestacao_tse_tipo = '$tipo', new_prestacao_tse_sigla = '$sigla'\"");
        &espera_usuario();

        # Passo 5) Setando as novas variáveis
        print "\t*** Setando as novas variaveis...";
        &mysql_exec("-e \"UPDATE $tabela_import SET new_valor = REPLACE(valor_receita,',','.')\"");
        &mysql_exec("-e \"UPDATE $tabela_import SET new_data_receita = STR_TO_DATE(data_receita,'%d/%m/%Y')\"");
        &espera_usuario();

        # Passo 6) Movendo para a tabela final
        print "\t*** Prontos para mover para a tabela final. ";
        print "Deseja continuar? [y/N]";
        chomp($continua = <STDIN>);
        unless ($continua eq "y") {
            next;
        }
        $query = &final_insert_query($tipo);
        &mysql_exec($query);
    }
}


sub file_load_query() {
    my $query_tipo = $_[0];
    my $query_tabela_import = "prestacao" . $query_tipo . "_import";

    if ($query_tipo eq "candidato") {
        return  "-e \"LOAD DATA LOCAL INFILE '$_[1]' INTO TABLE $query_tabela_import CHARACTER SET utf8 COLUMNS TERMINATED BY ';' ENCLOSED BY '\\\"' IGNORE 1 LINES (data_e_hora,uf,sigla_partido,numero_candidato,cargo,nome_candidato,cpf_candidato,entrega_conjunto,numero_recibo_eleitoral,numero_documento,cpf_cnpj_doador,nome_doador,data_receita,valor_receita,tipo_receita,fonte_recurso,especie_recurso,descricao_receita)\"";
    }
    elsif ($query_tipo eq "comite") { # Atencao: 2010 nao tem sequencial comite
        return "-e \"LOAD DATA LOCAL INFILE '$_[1]' INTO TABLE $query_tabela_import CHARACTER SET utf8 COLUMNS TERMINATED BY ';' ENCLOSED BY '\\\"' IGNORE 1 LINES (data_e_hora,uf,tipo_comite,sigla_partido,tipo_de_documento,numero_do_documento,cpf_cnpj_doador,nome_doador,data_receita,valor_receita,tipo_receita,fonte_recurso,especie_recurso,descricao_receita)\"";
    }
    elsif ($query_tipo eq "partido") { # Atencao: 2010 nao tem sequencial diretorio
        return "-e \"LOAD DATA LOCAL INFILE '$_[1]' INTO TABLE $query_tabela_import CHARACTER SET utf8 COLUMNS TERMINATED BY ';' ENCLOSED BY '\\\"' IGNORE 1 LINES (data_e_hora,uf,tipo_diretorio,sigla_partido,tipo_documento,numero_documento,cpf_cnpj_doador,nome_doador,data_receita,valor_receita,tipo_receita,fonte_recurso,especie_recurso,descricao_receita)\"";
    }
    else { die; }
}

sub final_insert_query() {
    my $query_tipo = $_[0];
    my $query_tabela = "prestacao".$query_tipo;
    my $query_tabela_import = $query_tabela . "_import";

    if ($query_tipo eq "candidato") {
        return "-e \"INSERT INTO $query_tabela (data_e_hora,sequencial_candidato,uf,numero_ue,municipio,sigla_partido,numero_candidato,cargo,nome_candidato,cpf_candidato,entrega_conjunto,numero_recibo_eleitoral,numero_documento,cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_ue_doador,numero_partido_doador,numero_candidato_doador,cod_setor_econ_doador,setor_econ_doador,data_receita,valor_receita,tipo_receita,fonte_recurso,especie_recurso,descricao_receita,new_pessoa_juridica,new_valor,new_data_receita,new_prestacao_tse_ano,new_prestacao_tse_tipo,new_prestacao_tse_sigla,new_excluir_view,new_excluir_view_descricao) SELECT data_e_hora,sequencial_candidato,uf,numero_ue,municipio,sigla_partido,numero_candidato,cargo,nome_candidato,cpf_candidato,entrega_conjunto,numero_recibo_eleitoral,numero_documento,cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_ue_doador,numero_partido_doador,numero_candidato_doador,cod_setor_econ_doador,setor_econ_doador,data_receita,valor_receita,tipo_receita,fonte_recurso,especie_recurso,descricao_receita,new_pessoa_juridica,new_valor,new_data_receita,new_prestacao_tse_ano,new_prestacao_tse_tipo,new_prestacao_tse_sigla,new_excluir_view,new_excluir_view_descricao FROM $query_tabela_import\"";
    }
    elsif ($query_tipo eq "comite") {
        return "-e \"INSERT INTO $query_tabela (data_e_hora,sequencial_comite,uf,numero_ue,municipio,tipo_comite,sigla_partido,tipo_de_documento,numero_do_documento,cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_ue_doador,numero_partido_doador,numero_candidato_doador,cod_setor_econ_doador,setor_econ_doador,data_receita,valor_receita,tipo_receita,fonte_recurso,especie_recurso,descricao_receita,new_pessoa_juridica,new_valor,new_data_receita,new_prestacao_tse_ano,new_prestacao_tse_tipo,new_prestacao_tse_sigla,new_excluir_view,new_excluir_view_descricao) SELECT data_e_hora,sequencial_comite,uf,numero_ue,municipio,tipo_comite,sigla_partido,tipo_de_documento,numero_do_documento,cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_ue_doador,numero_partido_doador,numero_candidato_doador,cod_setor_econ_doador,setor_econ_doador,data_receita,valor_receita,tipo_receita,fonte_recurso,especie_recurso,descricao_receita,new_pessoa_juridica,new_valor,new_data_receita,new_prestacao_tse_ano,new_prestacao_tse_tipo,new_prestacao_tse_sigla,new_excluir_view,new_excluir_view_descricao FROM $query_tabela_import\"";
    }
    elsif ($query_tipo eq "partido") {
        return "-e \"INSERT INTO $query_tabela (data_e_hora,sequencial_diretorio,uf,numero_ue,municipio,tipo_diretorio,sigla_partido,tipo_documento,numero_documento,cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_ue_doador,numero_partido_doador,numero_candidato_doador,cod_setor_econ_doador,setor_econ_doador,data_receita,valor_receita,tipo_receita,fonte_recurso,especie_recurso,descricao_receita,new_pessoa_juridica,new_valor,new_data_receita,new_prestacao_tse_ano,new_prestacao_tse_tipo,new_prestacao_tse_sigla,new_excluir_view,new_excluir_view_descricao) SELECT data_e_hora,sequencial_diretorio,uf,numero_ue,municipio,tipo_diretorio,sigla_partido,tipo_documento,numero_documento,cpf_cnpj_doador,nome_doador,nome_receita_doador,sigla_ue_doador,numero_partido_doador,numero_candidato_doador,cod_setor_econ_doador,setor_econ_doador,data_receita,valor_receita,tipo_receita,fonte_recurso,especie_recurso,descricao_receita,new_pessoa_juridica,new_valor,new_data_receita,new_prestacao_tse_ano,new_prestacao_tse_tipo,new_prestacao_tse_sigla,new_excluir_view,new_excluir_view_descricao FROM $query_tabela_import\"";
    }
    else { die; }
}

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