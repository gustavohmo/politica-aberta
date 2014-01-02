#!/usr/bin/perl
#
# # Política Aberta - gastosdiretos.pl
# Este script automatiza a inclusão de dados do Portal da Transparência num banco do MySQL. A automatização
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
# O diretorio abaixo será lido para inclusão dos arquivos no db. Defina o diretório onde estarão os arquivos
# deszipados do Portal da Transparência. Se você quiser, defina apenas para o sistema operacional que você
# utiliza (Linux ou todos os outros). (Aqui há duas opções porque eu utilizei este script em ambientes distintos):
my $DIR_CSV_LINUX = "/root/PoliticaAberta/DadosBrutosPortalTransparencia/OriginaisUnzip/";
my $DIR_CSV_OUTRO = "C:\\Users\\GustavoA\\Documents\\Projeto open data\\Dados Brutos Portal Transparencia\\Originais unzip\\";

# Defina o caminho do binário do MySQL:
my $MYSQL_BIN_LINUX = "/usr/bin/mysql";
my $MYSQL_BIN_OUTRO = "\"C:\\Program Files\\MySQL\\MySQL Server 5.5\\bin\\mysql.exe\"";

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
    $MYSQL_BIN = $MYSQL_BIN_OUTRO
}

# Lendo o diretorio com os arquivos CSV
print "*** Lendo o diretorio $DIR_CSV\n";
opendir(DIR_H,$DIR_CSV) || die ("Não foi possível abrir o diretório $DIR_CSV");
my @arquivos = grep !/^\.\.?$/,readdir(DIR_H); # ignorando o . e o ..
@arquivos = sort @arquivos; #Ordem alfabética
closedir(DIR_H);

print "*** Iniciando importacao...\n";

my $continua = 0;
foreach my $csv (@arquivos) {
    print "\n\n+----------------------------------------------------------------------------------------------------+\n";
    print "$csv:\n\t *** Checando imports anteriores...\n";
    # Passo 1) Checamos se este arquivo já não foi importado antes.
    &mysql_exec("-e \"SELECT COUNT(*) FROM gastosdiretos WHERE new_arquivo_orig = '$csv'\"");
    print "Deseja continuar? [y/N]";
    chomp($continua = <STDIN>);
    unless ($continua eq "y") {
        next;
    }

    # Passo 2) Zerando a tabela de apoio
    print "\t*** Zerando a tabela de apoio...\n";
    &mysql_exec("-e \"TRUNCATE gastosdiretos_import\"");
    &espera_usuario();

    # Passo 3) Importando o arquivo para a tabela de _import
    my $csv_path = $DIR_CSV . $csv;
    $csv_path =~ s/\\/\\\\/g;
    print "\t*** Importando o arquivo $csv_path para o import...";
    my $query = "-e \"LOAD DATA LOCAL INFILE '$csv_path' INTO TABLE politicaaberta.gastosdiretos_import CHARACTER SET latin1 COLUMNS ENCLOSED BY '\\\"' IGNORE 1 LINES (cod_org_superior,nome_org_superior,cod_org,nome_org,cod_unid_gestora,nome_unid_gestora,cod_grupo_despesa,nome_grupo_despesa,cod_elemento_despesa,nome_elemento_despesa,cod_funcao,nome_funcao,cod_subfuncao,nome_subfuncao,cod_programa,nome_programa,cod_acao,nome_acao,linguagem_cidada,cod_favorecido,nome_favorecido,numero_documento,gestao_pagamento,data_pagamento,valor)\"";

    &mysql_exec($query);
    &espera_usuario();

    # Passo 4) Incluindo o nome do arquivo csv para documentacao:
    print "\t*** Incluindo o nome do arquivo para documentacao...\n";
    &mysql_exec("-e \"UPDATE gastosdiretos_import SET new_arquivo_orig = '$csv'\"");
    &espera_usuario();

    # Passo 5) Setando as novas variáveis
    print "\t*** Setando as novas variaveis...";
    &mysql_exec("-e \"UPDATE gastosdiretos_import SET new_valor = REPLACE(valor,',','.')\"");
    &mysql_exec("-e \"UPDATE gastosdiretos_import SET new_data_pagamento = IF (data_pagamento != 'Detalhamento das informações bloqueado.',STR_TO_DATE(data_pagamento,'%d/%m/%Y'),NULL)\"");
    &espera_usuario();
    # Passo 6) Movendo para a tabela final
    print "\t*** Prontos para mover para a tabela final. ";
    print "Deseja continuar? [y/N]";
    chomp($continua = <STDIN>);
    unless ($continua eq "y") {
        next;
    }
    &mysql_exec("-e \"INSERT INTO gastosdiretos (cod_org_superior,nome_org_superior,cod_org,nome_org,cod_unid_gestora,nome_unid_gestora,cod_grupo_despesa,nome_grupo_despesa,cod_elemento_despesa,nome_elemento_despesa,cod_funcao,nome_funcao,cod_subfuncao,nome_subfuncao,cod_programa,nome_programa,cod_acao,nome_acao,linguagem_cidada,cod_favorecido,nome_favorecido,numero_documento,gestao_pagamento,data_pagamento,valor,new_arquivo_orig,new_pessoa_juridica,new_valor,new_data_pagamento) SELECT cod_org_superior,nome_org_superior,cod_org,nome_org,cod_unid_gestora,nome_unid_gestora,cod_grupo_despesa,nome_grupo_despesa,cod_elemento_despesa,nome_elemento_despesa,cod_funcao,nome_funcao,cod_subfuncao,nome_subfuncao,cod_programa,nome_programa,cod_acao,nome_acao,linguagem_cidada,cod_favorecido,nome_favorecido,numero_documento,gestao_pagamento,data_pagamento,valor,new_arquivo_orig,new_pessoa_juridica,new_valor,new_data_pagamento FROM gastosdiretos_import\"");
}


sub mysql_exec() {
    my $arg_query = $_[0];
    my $cmd = sprintf("%s --local-infile --user=%s --password=%s --database=%s %s --show-warnings --verbose --verbose --verbose",$MYSQL_BIN,$DB_USER,$DB_PASS,$DB_NAME,$arg_query);
    #system($MYSQL_BIN,"--local-infile","--user=$DB_USER","--password=$DB_PASS",$arg_query);
    print "$cmd\n\n";
    system($cmd);
}


sub espera_usuario() {
    print "Pressione ENTER para continuar: ";
    <STDIN>;
}

sub atualiza_mes_string() {
    if ($_[0] < 10) {
        return ("0".$_[0]);
    }
    else {
        return $_[0];
    }
}