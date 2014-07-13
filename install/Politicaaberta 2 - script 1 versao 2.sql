################################################################################################
# Política Aberta 2013 - Script de criacao do banco
#
# As tabelas criadas respeitam fielmente os campos dos arquivos CSV originais. Os campos
# que nós adicionamos para usar no Política Aberta foram incluídos ao final, com um "new_" à
# frente.
################################################################################################
# Para criar o DB do ZERO:
# Depois de instalar e criar um usuario no banco:
# 1) Usar o script "Politicaaberta2 - script 1.sql" para criar a estrutura inicial do banco
# 2) Rodar o gastosdiretos.pl para importar tudo
# 3) Rodar o prestacoes.pl para importar tudo
# 3.1) Limpar o cabecalho de varios arquivos de 2010
# 3.2) Rodar o prestacoes2010.pl para importar os dados de 2010
# 4) Rodar o totais.pl para criar os totais
# 5) Rodar o "Politicaaberta2 - script 2.sql" para criar as tabelas auxiliares e
# para popular o gastosdiretos_rel a partir do gastosdiretos nao-relacional
#
# Depois: instalar mysql, php, mod_rewrite, Smarty

################################################################################################
# Criando o schema
CREATE SCHEMA `politicaaberta` ;

# Criando a tabela de gastosdiretos
CREATE TABLE `politicaaberta`.`gastosdiretos` (
  `idGastosDiretos` int(11) NOT NULL AUTO_INCREMENT,
  `cod_org_superior` varchar(255) DEFAULT NULL,
  `nome_org_superior` varchar(255) DEFAULT NULL,
  `cod_org` varchar(255) DEFAULT NULL,
  `nome_org` varchar(255) DEFAULT NULL,
  `cod_unid_gestora` varchar(255) DEFAULT NULL,
  `nome_unid_gestora` varchar(255) DEFAULT NULL,
  `cod_grupo_despesa` varchar(255) DEFAULT NULL,
  `nome_grupo_despesa` varchar(255) DEFAULT NULL,
  `cod_elemento_despesa` varchar(255) DEFAULT NULL,
  `nome_elemento_despesa` varchar(255) DEFAULT NULL,
  `cod_funcao` varchar(255) DEFAULT NULL,
  `nome_funcao` varchar(255) DEFAULT NULL,
  `cod_subfuncao` varchar(255) DEFAULT NULL,
  `nome_subfuncao` varchar(255) DEFAULT NULL,
  `cod_programa` varchar(255) DEFAULT NULL,
  `nome_programa` varchar(255) DEFAULT NULL,
  `cod_acao` varchar(255) DEFAULT NULL,
  `nome_acao` varchar(255) DEFAULT NULL,
  `linguagem_cidada` varchar(255) DEFAULT NULL,
  `cod_favorecido` varchar(255) DEFAULT NULL,
  `nome_favorecido` varchar(255) DEFAULT NULL,
  `numero_documento` varchar(255) DEFAULT NULL,
  `gestao_pagamento` varchar(255) DEFAULT NULL,
  `data_pagamento` varchar(255) DEFAULT NULL,
  `valor` varchar(255) DEFAULT NULL,
  `new_data_pagamento` date DEFAULT NULL,
  `new_valor` decimal(13,2) DEFAULT NULL,
  `new_pessoa_juridica` tinyint(1) DEFAULT NULL,
  `new_arquivo_orig` varchar(255)  NOT NULL,
  PRIMARY KEY (`idGastosDiretos`),
  UNIQUE KEY `idGastosDiretos_UNIQUE` (`idGastosDiretos`),
  KEY `cod_favorecido_index` (`cod_favorecido`),
  KEY `new_pessoa_juridica_index` (`new_pessoa_juridica`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX new_arquivo_orig_index ON gastosdiretos (`new_arquivo_orig`);

## Criando a tabela de apoio gastosdiretos_import
CREATE TABLE `politicaaberta`.`gastosdiretos_import` LIKE `politicaaberta`.`gastosdiretos`;

# Criando tabelas auxiliares
CREATE TABLE `politicaaberta`.`aux_org_superior` (
  `cod_org_superior` int(5) DEFAULT NULL,
  `nome_org_superior` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cod_org_superior`),
  KEY `org_superior_covering_index` (`cod_org_superior`,`nome_org_superior`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`aux_org` (
  `cod_org` int(5) DEFAULT NULL,
  `nome_org` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cod_org`),
  KEY `org_covering_index` (`cod_org`,`nome_org`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`aux_unid_gestora` (
  `cod_unid_gestora` int(6) DEFAULT NULL,
  `nome_unid_gestora` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cod_unid_gestora`),
  KEY `unid_gestora_covering_index` (`cod_unid_gestora`,`nome_unid_gestora`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`aux_grupo_despesa` (
  `cod_grupo_despesa` int(1) DEFAULT NULL,
  `nome_grupo_despesa` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cod_grupo_despesa`),
  KEY `grupo_despesa_covering_index` (`cod_grupo_despesa`,`nome_grupo_despesa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`aux_elemento_despesa` (
  `cod_elemento_despesa` int(2) DEFAULT NULL,
  `nome_elemento_despesa` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cod_elemento_despesa`),
  KEY `elemento_despesa_covering_index` (`cod_elemento_despesa`,`nome_elemento_despesa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`aux_funcao` (
  `cod_funcao` int(2) DEFAULT NULL,
  `nome_funcao` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cod_funcao`),
  KEY `funcao_covering_index` (`cod_funcao`,`nome_funcao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`aux_subfuncao` (
  `cod_subfuncao` int(3) DEFAULT NULL,
  `nome_subfuncao` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cod_subfuncao`),
  KEY `subfuncao_covering_index` (`cod_subfuncao`,`nome_subfuncao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`aux_programa` (
  `cod_programa` int(4) DEFAULT NULL,
  `nome_programa` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cod_programa`),
  KEY `programa_covering_index` (`cod_programa`,`nome_programa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`aux_acao` (
  `cod_acao` varchar(4) DEFAULT NULL,
  `nome_acao` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cod_acao`),
  KEY `acao_covering_index` (`cod_acao`,`nome_acao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


# A tabela abaixo eh relacional, mas ainda contem dados de pessoa fisica
# e dados com as informacoes bloqueadas. Nesta tabela, ainda foi importado o "Detalhamento etc.."
# para o cod_favorecido (com apenas 14 caracteres: "Detalhamento d"). Mas a variavel
# new_pessoa_juridica funciona para retirar este grupo da query, assim como tb o grupo
# de pessoas fisicas (com asteriscos).
CREATE TABLE `politicaaberta`.`gastosdiretos_rel` (
  `idGastosDiretos_rel` int(11) NOT NULL AUTO_INCREMENT,
  `idGastosDiretos_orig` int (11) NOT NULL,
  `cod_org_superior` int(5) DEFAULT NULL,
  `cod_org` int(5) DEFAULT NULL,
  `cod_unid_gestora` int(6) DEFAULT NULL,
  `cod_grupo_despesa` int(1) DEFAULT NULL,
  `cod_elemento_despesa` int(2) DEFAULT NULL,
  `cod_funcao` int(2) DEFAULT NULL,
  `cod_subfuncao` int(3) DEFAULT NULL,
  `cod_programa` int(4) DEFAULT NULL,
  `cod_acao` varchar(4) DEFAULT NULL,
  `linguagem_cidada` varchar(255) DEFAULT NULL,
  `cod_favorecido` varchar(14) DEFAULT NULL,
  `numero_documento` varchar(12) DEFAULT NULL,
  `gestao_pagamento` varchar(10) DEFAULT NULL,
  `data_pagamento` date DEFAULT NULL,
  `valor` decimal(13,2) DEFAULT NULL,
  `new_ano_arquivo_orig` year DEFAULT NULL,
  `new_mes_arquivo_orig` int(2) DEFAULT NULL,
  `new_pessoa_juridica` tinyint(1) DEFAULT NULL,
  `new_excluir_view` tinyint(1) DEFAULT '0',
  `new_excluir_view_justificativa` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`idGastosDiretos_rel`),

  KEY `idGastosDiretos_orig_index` (`idGastosDiretos_orig`),
  FOREIGN KEY (`idGastosDiretos_orig`) REFERENCES gastosdiretos(idGastosDiretos),

  KEY `cod_org_superior_index` (`cod_org_superior`),
  FOREIGN KEY (`cod_org_superior`) REFERENCES aux_org_superior(cod_org_superior),

  KEY `cod_org_index` (`cod_org`),
  FOREIGN KEY (`cod_org`) REFERENCES aux_org(cod_org),

  KEY `cod_unid_gestora_index` (`cod_unid_gestora`),
  FOREIGN KEY (`cod_unid_gestora`) REFERENCES aux_unid_gestora(cod_unid_gestora),

  KEY `cod_grupo_despesa_index` (`cod_grupo_despesa`),
  FOREIGN KEY (`cod_grupo_despesa`) REFERENCES aux_grupo_despesa(cod_grupo_despesa),

  KEY `cod_elemento_despesa_index` (`cod_elemento_despesa`),
  FOREIGN KEY (`cod_elemento_despesa`) REFERENCES aux_elemento_despesa(cod_elemento_despesa),

  KEY `cod_funcao_index` (`cod_funcao`),
  FOREIGN KEY (`cod_funcao`) REFERENCES aux_funcao(cod_funcao),

  KEY `cod_subfuncao_index` (`cod_subfuncao`),
  FOREIGN KEY (`cod_subfuncao`) REFERENCES aux_subfuncao(cod_subfuncao),

  KEY `cod_programa_index` (`cod_programa`),
  FOREIGN KEY (`cod_programa`) REFERENCES aux_programa(cod_programa),

  KEY `cod_acao_index` (`cod_acao`),
  FOREIGN KEY (`cod_acao`) REFERENCES aux_acao(cod_acao),

  KEY `cod_favorecido_index` (`cod_favorecido`),
  KEY `data_pagamento_index` (`data_pagamento`),
  KEY `new_pessoa_juridica_index` (`new_pessoa_juridica`),
  KEY `new_ano_arquivo_orig_index` (`new_ano_arquivo_orig`),
  KEY `new_mes_arquivo_orig_index` (`new_mes_arquivo_orig`),
  KEY `new_excluir_view_index` (`new_excluir_view`),
  KEY `gastosdiretos_rel_covering_index` (`cod_favorecido`,`cod_org_superior`,`cod_org`,`cod_unid_gestora`,`cod_grupo_despesa`,`cod_elemento_despesa`,`cod_funcao`,`cod_subfuncao`,`cod_programa`,`cod_acao`,`data_pagamento`,`valor`,`new_ano_arquivo_orig`,`new_mes_arquivo_orig`,`new_pessoa_juridica`,`new_excluir_view`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


#
# Criando a parte de prestacao de contas - Dados TSE
# Criando a tabela de prestacao de candidatos
CREATE TABLE `politicaaberta`.`prestacaocandidato` (
  `idPrestacaoCandidato` int(11) NOT NULL AUTO_INCREMENT,
  `data_e_hora` varchar(20) DEFAULT NULL,
  `sequencial_candidato` bigint DEFAULT NULL,
  `uf` char(2) DEFAULT NULL,
  `numero_ue` int(5) DEFAULT NULL,
  `municipio` varchar(255) DEFAULT NULL,
  `sigla_partido` varchar(7) DEFAULT NULL,
  `numero_candidato` int(5) DEFAULT NULL,
  `cargo` varchar(255) DEFAULT NULL,
  `nome_candidato` varchar(255) DEFAULT NULL,
  `cpf_candidato` bigint NOT NULL,
  `entrega_conjunto` varchar(3) DEFAULT NULL,
  `numero_recibo_eleitoral` varchar(18) DEFAULT NULL,
  `numero_documento` varchar(255) DEFAULT NULL,
  `cpf_cnpj_doador` varchar(14) DEFAULT NULL,
  `nome_doador` varchar(255) DEFAULT NULL,
  `nome_receita_doador` varchar(255) DEFAULT NULL,
  `sigla_ue_doador` varchar(6) DEFAULT NULL,
  `numero_partido_doador` varchar(6) DEFAULT NULL,
  `numero_candidato_doador` varchar(6) DEFAULT NULL,
  `cod_setor_econ_doador` varchar(7) DEFAULT NULL,
  `setor_econ_doador` varchar(255) DEFAULT NULL,
  `data_receita` varchar(20) DEFAULT NULL,
  `valor_receita` varchar(255) DEFAULT NULL,
  `tipo_receita` varchar(50) DEFAULT NULL,
  `fonte_recurso` varchar(50) DEFAULT NULL,
  `especie_recurso` varchar(50) DEFAULT NULL,
  `descricao_receita` varchar(255) DEFAULT NULL,
  `new_pessoa_juridica` tinyint(1) DEFAULT NULL,
  `new_valor` decimal(13,2) DEFAULT NULL,
  `new_data_receita` date DEFAULT NULL,
  `new_prestacao_tse_ano` year(4) DEFAULT NULL,
  `new_prestacao_tse_tipo` varchar(10) DEFAULT NULL,
  `new_prestacao_tse_sigla` varchar(2) DEFAULT NULL,
  `new_excluir_view` tinyint(1) DEFAULT '0',
  `new_excluir_view_descricao` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`idPrestacaoCandidato`),
  UNIQUE KEY `idPrestacaoCandidato_UNIQUE` (`idPrestacaoCandidato`),

  KEY `cpf_candidato_index` (`cpf_candidato`),
  KEY `uf_index` (`uf`),
  KEY `data_e_hora_index` (`data_e_hora`),
  KEY `sigla_partido_index` (`sigla_partido`),
  KEY `nome_candidato_index` (`nome_candidato`),
  KEY `cpf_cnpj_doador_index` (`cpf_cnpj_doador`),
  KEY `new_data_receita_index` (`data_receita`),
  KEY `new_pessoa_juridica_index` (`new_pessoa_juridica`),
  KEY `new_prestacao_tse_ano_index` (`new_prestacao_tse_ano`),
  KEY `new_prestacao_tse_tipo_index` (`new_prestacao_tse_tipo`),
  KEY `new_prestacao_tse_sigla_index` (`new_prestacao_tse_sigla`),
  KEY `new_excluir_view_index` (`new_excluir_view`),

  KEY prestacaocandidato_covering_index (`cpf_cnpj_doador`,`uf`,`new_prestacao_tse_ano`,`new_excluir_view`,`cpf_candidato`,`nome_candidato`,`sigla_partido`,`new_data_receita`,`new_valor`,`tipo_receita`,`new_pessoa_juridica`,`new_prestacao_tse_tipo`,`new_prestacao_tse_sigla`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

## Criando para o import
CREATE TABLE `politicaaberta`.`prestacaocandidato_import` LIKE `politicaaberta`.`prestacaocandidato`;


# Criando tabela para prestacao comite
CREATE TABLE `politicaaberta`.`prestacaocomite` (
  `idPrestacaoComite` int(11) NOT NULL AUTO_INCREMENT,
  `data_e_hora` varchar(20) DEFAULT NULL,
  `sequencial_comite` int(6) NOT NULL,
  `uf` char(2) DEFAULT NULL,
  `numero_ue` int(5) DEFAULT NULL,
  `municipio` varchar(255) DEFAULT NULL,
  `tipo_comite` varchar(80) DEFAULT NULL,
  `sigla_partido` varchar(7) DEFAULT NULL,
  `tipo_de_documento` varchar(20) DEFAULT NULL,
  `numero_do_documento` varchar(255) DEFAULT NULL,
  `cpf_cnpj_doador` varchar(14) DEFAULT NULL,
  `nome_doador` varchar(255) DEFAULT NULL,
  `nome_receita_doador` varchar(255) DEFAULT NULL,
  `sigla_ue_doador` varchar(6) DEFAULT NULL,
  `numero_partido_doador` varchar(6) DEFAULT NULL,
  `numero_candidato_doador` varchar(6) DEFAULT NULL,
  `cod_setor_econ_doador` varchar(7) DEFAULT NULL,
  `setor_econ_doador` varchar(255) DEFAULT NULL,
  `data_receita` varchar(20) DEFAULT NULL,
  `valor_receita` varchar(255) DEFAULT NULL,
  `tipo_receita` varchar(50) DEFAULT NULL,
  `fonte_recurso` varchar(50) DEFAULT NULL,
  `especie_recurso` varchar(50) DEFAULT NULL,
  `descricao_receita` varchar(255) DEFAULT NULL,
  `new_pessoa_juridica` tinyint(1) DEFAULT NULL,
  `new_valor` decimal(13,2) DEFAULT NULL,
  `new_data_receita` date DEFAULT NULL,
  `new_prestacao_tse_ano` year(4) DEFAULT NULL,
  `new_prestacao_tse_tipo` varchar(9) DEFAULT NULL,
  `new_prestacao_tse_sigla` varchar(2) DEFAULT NULL,
  `new_excluir_view` tinyint(1) DEFAULT '0',
  `new_excluir_view_descricao` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`idPrestacaoComite`),
  UNIQUE KEY `idPrestacaoComite_UNIQUE` (`idPrestacaoComite`),

  KEY `sequencial_comite_index` (`sequencial_comite`),
  KEY `uf_index` (`uf`),
  KEY `tipo_comite_index` (`tipo_comite`),
  KEY `data_e_hora_index` (`data_e_hora`),
  KEY `sigla_partido_index` (`sigla_partido`),
  KEY `cpf_cnpj_doador_index` (`cpf_cnpj_doador`),
  KEY `new_data_receita_index` (`data_receita`),
  KEY `new_pessoa_juridica_index` (`new_pessoa_juridica`),
  KEY `new_prestacao_tse_ano_index` (`new_prestacao_tse_ano`),
  KEY `new_prestacao_tse_tipo_index` (`new_prestacao_tse_tipo`),
  KEY `new_prestacao_tse_sigla_index` (`new_prestacao_tse_sigla`),
  KEY `new_excluir_view_index` (`new_excluir_view`),

  KEY prestacaocomite_covering_index (`cpf_cnpj_doador`,`sequencial_comite`,`uf`,`tipo_comite`,`new_prestacao_tse_ano`,`new_excluir_view`,`sigla_partido`,`new_data_receita`,`new_valor`,`tipo_receita`,`new_pessoa_juridica`,`new_prestacao_tse_tipo`,`new_prestacao_tse_sigla`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

## Criando para o import
CREATE TABLE `politicaaberta`.`prestacaocomite_import` LIKE `politicaaberta`.`prestacaocomite`;

# Criando tabela para prestacao partido
CREATE TABLE `politicaaberta`.`prestacaopartido` (
  `idPrestacaoPartido` int(11) NOT NULL AUTO_INCREMENT,
  `data_e_hora` varchar(20) DEFAULT NULL,
  `sequencial_diretorio` varchar(6) NOT NULL,
  `uf` char(2) DEFAULT NULL,
  `numero_ue` varchar(5) DEFAULT NULL,
  `municipio` varchar(255) DEFAULT NULL,
  `tipo_diretorio` varchar(80) DEFAULT NULL,
  `sigla_partido` varchar(7) DEFAULT NULL,
  `tipo_documento` varchar(50) DEFAULT NULL,
  `numero_documento` varchar(255) DEFAULT NULL,
  `cpf_cnpj_doador` varchar(14) DEFAULT NULL,
  `nome_doador` varchar(255) DEFAULT NULL,
  `nome_receita_doador` varchar(255) DEFAULT NULL,
  `sigla_ue_doador` varchar(6) DEFAULT NULL,
  `numero_partido_doador` varchar(6) DEFAULT NULL,
  `numero_candidato_doador` varchar(6) DEFAULT NULL,
  `cod_setor_econ_doador` varchar(7) DEFAULT NULL,
  `setor_econ_doador` varchar(255) DEFAULT NULL,
  `data_receita` varchar(20) DEFAULT NULL,
  `valor_receita` varchar(255) DEFAULT NULL,
  `tipo_receita` varchar(50) DEFAULT NULL,
  `fonte_recurso` varchar(50) DEFAULT NULL,
  `especie_recurso` varchar(50) DEFAULT NULL,
  `descricao_receita` varchar(255) DEFAULT NULL,
  `new_pessoa_juridica` tinyint(1) DEFAULT NULL,
  `new_valor` decimal(13,2) DEFAULT NULL,
  `new_data_receita` date DEFAULT NULL,
  `new_prestacao_tse_ano` year(4) DEFAULT NULL,
  `new_prestacao_tse_tipo` varchar(9) DEFAULT NULL,
  `new_prestacao_tse_sigla` varchar(2) DEFAULT NULL,
  `new_excluir_view` tinyint(1) DEFAULT '0',
  `new_excluir_view_descricao` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`idPrestacaoPartido`),
  UNIQUE KEY `idPrestacaoPartido_UNIQUE` (`idPrestacaoPartido`),

  KEY `sequencial_diretorio_index` (`sequencial_diretorio`),
  KEY `uf_index` (`uf`),
  KEY `tipo_diretorio_index` (`tipo_diretorio`),
  KEY `data_e_hora_index` (`data_e_hora`),
  KEY `sigla_partido_index` (`sigla_partido`),
  KEY `cpf_cnpj_doador_index` (`cpf_cnpj_doador`),
  KEY `new_data_receita_index` (`data_receita`),
  KEY `new_pessoa_juridica_index` (`new_pessoa_juridica`),
  KEY `new_prestacao_tse_ano_index` (`new_prestacao_tse_ano`),
  KEY `new_prestacao_tse_tipo_index` (`new_prestacao_tse_tipo`),
  KEY `new_prestacao_tse_sigla_index` (`new_prestacao_tse_sigla`),
  KEY `new_excluir_view_index` (`new_excluir_view`),

  KEY prestacaopartido_covering_index (`cpf_cnpj_doador`,`sequencial_diretorio`,`uf`,`tipo_diretorio`,`new_prestacao_tse_ano`,`new_excluir_view`,`sigla_partido`,`new_data_receita`,`new_valor`,`tipo_receita`,`new_pessoa_juridica`,`new_prestacao_tse_tipo`,`new_prestacao_tse_sigla`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`prestacaopartido_import` LIKE `politicaaberta`.`prestacaopartido`;


#
# Criando as tabelas de totais
## gastostotais
CREATE TABLE `politicaaberta`.`gastostotais` (
  `idGastosTotais` int(11) NOT NULL AUTO_INCREMENT,
  `cod_favorecido` varchar(14) DEFAULT NULL,
  `nome_favorecido` varchar(255) DEFAULT NULL,
  `ano` year(4) DEFAULT NULL,
  `valor_total` decimal(13,2) DEFAULT NULL,
  `pagamentos_count` bigint DEFAULT NULL,
  `excluir_view` tinyint(1) DEFAULT '0',
  `excluir_view_descricao` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`idGastosTotais`),
  UNIQUE KEY `idGastosTotais_UNIQUE` (`idGastosTotais`),
  UNIQUE KEY (`cod_favorecido`,`ano`),
  KEY `cod_favorecido_index` (`cod_favorecido`),
  KEY `ano_index` (`ano`),
  KEY `excluir_view_index` (`excluir_view`),

  KEY `gastostotais_covering_index` (`cod_favorecido`,`ano`,`nome_favorecido`,`valor_total`,`pagamentos_count`,`excluir_view`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;


## prestacaoCCP
## CCP = candidato, comite e partido
CREATE TABLE `politicaaberta`.`prestacaoCCP` (
  `idPrestacaoCCP` int(11) NOT NULL AUTO_INCREMENT,
  `cod_doador` varchar(14) NOT NULL,
  `nome_doador` varchar(255) NOT NULL,
  `nome_receita_doador` varchar(255) DEFAULT NULL,
  `tipo_receita` varchar(255) NOT NULL,
  `cod_setor_econ_doador` varchar(255) DEFAULT NULL,
  `setor_econ_doador` varchar(255) DEFAULT NULL,
  `tipo_prestacao` varchar(255) NOT NULL,
  `prestacao_count` bigint NOT NULL,
  `ano` year(4) NOT NULL,
  `valor_total` decimal(13,2) NOT NULL,
  PRIMARY KEY (`idPrestacaoCCP`),
  UNIQUE KEY `cod_doador` (`cod_doador`,`ano`,`tipo_prestacao`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


## Prestacao Total
CREATE TABLE `politicaaberta`.`prestacaototais` (
  `idPrestacaoTotais` int(11) NOT NULL AUTO_INCREMENT,
  `cod_doador` varchar(14) NOT NULL,
  `nome_doador` varchar(255) NOT NULL,
  `nome_receita_doador` varchar(255) DEFAULT NULL,
  `cod_setor_econ_doador` varchar(7) DEFAULT NULL,
  `setor_econ_doador` varchar(255) DEFAULT NULL,
  `ano` year(4) NOT NULL,
  `valor_total_candidatos` decimal(13,2) DEFAULT '0',
  `prestacao_candidato_count` bigint DEFAULT '0',
  `valor_total_comites` decimal(13,2) DEFAULT '0',
  `prestacao_comite_count` bigint DEFAULT '0',
  `valor_total_partidos` decimal(13,2) DEFAULT '0',
  `prestacao_partido_count` bigint DEFAULT '0',
  `valor_total_ccp` decimal(13,2) DEFAULT '0',
  `prestacao_total_ccp_count` bigint DEFAULT '0',
  `excluir_view` tinyint(1) DEFAULT '0',
  `excluir_view_descricao` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`idPrestacaoTotais`),

  KEY `cod_doador_index` (`cod_doador`),
  KEY `ano_index` (`ano`),
  KEY `excluir_view_index` (`excluir_view`),

  UNIQUE KEY `cod_doador_ano_unique` (`cod_doador`,`ano`),

  KEY `prestacaototais_covering_index` (`cod_doador`,`ano`,`nome_doador`,`nome_receita_doador`,`cod_setor_econ_doador`,`setor_econ_doador`,`valor_total_candidatos`,`valor_total_comites`,`valor_total_partidos`,`valor_total_ccp`,`excluir_view`)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;


# ccpTotais
# Criando tabela de totais para candidatos, comites e partidos. A ideia desta tabela
# eh semelhante a prestacaoCCP, porem em vez de ser agrupado por doador, aqui agrupamos
# por recebedor (candidato, comite ou partido) e por tipo de receita. Alem disso, aqui 
# incluimos tudo, e nao
# apenas as doacoes de pessoas juridicas (na prestacaoCCP ha apenas pessoa juridica porque,
# obviamente, a tabela eh keyed por pessoa juridica)
CREATE TABLE `politicaaberta`.`aux_tipo_receita` (
   `idTipoReceita` int(2) NOT NULL AUTO_INCREMENT,
   `nome_tipo_receita` varchar(255) DEFAULT NULL,
   PRIMARY KEY (`idTipoReceita`),
   UNIQUE(`nome_tipo_receita`),
   KEY `tipo_receita_covering_index` (`idTipoReceita`,`nome_tipo_receita`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `politicaaberta`.`ccp` (
  `idCcp` int(11) NOT NULL AUTO_INCREMENT,
  `cod_ccp` varchar(14) NOT NULL,
  `tipo_ccp` varchar(9) DEFAULT NULL,
  `sigla_partido` varchar(7) DEFAULT NULL,
  `uf` varchar(2) DEFAULT NULL,
  `municipio` varchar(255) DEFAULT NULL,
  `cargo` varchar(255) DEFAULT NULL,
  `nome_ccp` varchar(255) DEFAULT NULL,
  `ano` year(4) DEFAULT NULL,
  `tipo_receita` varchar(50) NOT NULL,
  `valor_total` decimal(13,2) DEFAULT NULL,
  `doacoes_count` bigint DEFAULT NULL,
  `excluir_view` tinyint(1) DEFAULT '0',
  `excluir_view_descricao` varchar(1000) DEFAULT NULL,

  PRIMARY KEY (`idCcp`),
  UNIQUE KEY (`cod_ccp`,`tipo_ccp`,`tipo_receita`,`ano`),
  KEY `cod_ccp_index` (`cod_ccp`),
  KEY `ano_index` (`ano`),
  KEY `excluir_view_index` (`excluir_view`),
  KEY `ccp_covering_index` (`cod_ccp`,`tipo_ccp`,`ano`,`tipo_receita`,`nome_ccp`,`sigla_partido`,`uf`,`valor_total`,`doacoes_count`,`cargo`,`excluir_view`,`municipio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


# Criando tabela para busca
CREATE TABLE `politicaaberta`.`entidade_nomes` (
   `idEntidade` int(11) NOT NULL AUTO_INCREMENT,
   `codigo_entidade` varchar(14) NOT NULL,
   `nome_favorecido` varchar(255) DEFAULT NULL,
   `nome_doador`     varchar(255) DEFAULT NULL,
   `nome_receita_doador` varchar(255) DEFAULT NULL,
   `ano` year(4) NOT NULL,
   PRIMARY KEY (`idEntidade`),
   UNIQUE(`codigo_entidade`,`ano`),
   KEY `nome_favorecido_index` (`nome_favorecido`),
   KEY `nome_doador` (`nome_doador`),
   KEY `nome_receita_doador` (`nome_receita_doador`),

   FULLTEXT(`nome_favorecido`),
   FULLTEXT(`nome_receita_doador`),
   FULLTEXT(`nome_doador`)

 ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
