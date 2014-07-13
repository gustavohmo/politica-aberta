# GASTOSDIRETOS
# Inserindo dados nas tabelas auxiliares
## aux_org_superior
INSERT INTO `politicaaberta`.`aux_org_superior` SELECT DISTINCT(cod_org_superior) as a,nome_org_superior FROM `politicaaberta`.`gastosdiretos` GROUP BY a ORDER BY a;

## aux_org
INSERT INTO `politicaaberta`.`aux_org` SELECT DISTINCT(cod_org) as a,nome_org FROM `politicaaberta`.`gastosdiretos` GROUP BY a ORDER BY a;

## aux_unid_gestora
INSERT INTO `politicaaberta`.`aux_unid_gestora` SELECT DISTINCT(cod_unid_gestora) as a,nome_unid_gestora FROM `politicaaberta`.`gastosdiretos` GROUP BY a ORDER BY a;

## aux_grupo_despesa
INSERT INTO `politicaaberta`.`aux_grupo_despesa` SELECT DISTINCT(cod_grupo_despesa) as a,nome_grupo_despesa FROM `politicaaberta`.`gastosdiretos` GROUP BY a ORDER BY a;

## aux_elemento_despesa
INSERT INTO `politicaaberta`.`aux_elemento_despesa` SELECT DISTINCT(cod_elemento_despesa) as a,nome_elemento_despesa FROM `politicaaberta`.`gastosdiretos` GROUP BY a ORDER BY a;

## aux_funcao
INSERT INTO `politicaaberta`.`aux_funcao` SELECT DISTINCT(cod_funcao) as a,nome_funcao FROM `politicaaberta`.`gastosdiretos` GROUP BY a ORDER BY a;

## aux_subfuncao
INSERT INTO `politicaaberta`.`aux_subfuncao` SELECT DISTINCT(cod_subfuncao) as a,nome_subfuncao FROM `politicaaberta`.`gastosdiretos` GROUP BY a ORDER BY a;

## aux_programa
INSERT INTO `politicaaberta`.`aux_programa` SELECT DISTINCT(cod_programa) as a,nome_programa FROM `politicaaberta`.`gastosdiretos` GROUP BY a ORDER BY a;

## aux_acao
INSERT INTO `politicaaberta`.`aux_acao` SELECT DISTINCT(cod_acao) as a,nome_acao FROM `politicaaberta`.`gastosdiretos` GROUP BY a ORDER BY a;

# Query para criacao do gastosdiretos_rel a partir da gastosdiretos nao-normalizada:
TRUNCATE gastosdiretos_rel;
INSERT INTO gastosdiretos_rel (idGastosDiretos_orig,cod_org_superior,cod_org,cod_unid_gestora,cod_grupo_despesa,cod_elemento_despesa,cod_funcao,cod_subfuncao,cod_programa,cod_acao,linguagem_cidada,cod_favorecido,numero_documento,gestao_pagamento,data_pagamento,valor,new_ano_arquivo_orig,new_mes_arquivo_orig,new_pessoa_juridica) (SELECT idGastosDiretos,cod_org_superior,cod_org,cod_unid_gestora,cod_grupo_despesa,cod_elemento_despesa,cod_funcao,cod_subfuncao,cod_programa,cod_acao,linguagem_cidada,SUBSTRING(cod_favorecido,1,14),SUBSTRING(numero_documento,1,12),SUBSTRING(gestao_pagamento,1,10),new_data_pagamento,new_valor,SUBSTRING(new_arquivo_orig,1,4),SUBSTRING(new_arquivo_orig,5,2),new_pessoa_juridica FROM gastosdiretos);


# PRESTACOES
# Inserindo dados na tabela auxiliar
INSERT INTO aux_tipo_receita (nome_tipo_receita) (SELECT DISTINCT(tipo_receita) as t FROM `politicaaberta`.`prestacaocandidato` GROUP BY t ORDER BY t)
UNION (SELECT DISTINCT(tipo_receita) as t FROM `politicaaberta`.`prestacaocomite` GROUP BY t ORDER BY t)
UNION (SELECT DISTINCT(tipo_receita) as t FROM `politicaaberta`.`prestacaopartido` GROUP BY t ORDER BY t);


# Queries para criacao do ccp:
## candidatos
INSERT INTO ccp (cod_ccp,tipo_ccp,sigla_partido,uf,municipio,cargo,nome_ccp,ano,tipo_receita,valor_total,doacoes_count) (SELECT cpf_candidato,"candidato",sigla_partido,uf,municipio,cargo,nome_candidato,new_prestacao_tse_ano,tipo_receita,SUM(new_valor),COUNT(*) FROM prestacaocandidato GROUP BY cpf_candidato,tipo_receita,new_prestacao_tse_ano);

## comite
INSERT INTO ccp (cod_ccp,tipo_ccp,sigla_partido,uf,municipio,nome_ccp,ano,tipo_receita,valor_total,doacoes_count) (SELECT sequencial_comite,"comite",sigla_partido,uf,municipio,tipo_comite,new_prestacao_tse_ano,tipo_receita,SUM(new_valor),COUNT(*) FROM prestacaocomite GROUP BY sequencial_comite,tipo_receita,new_prestacao_tse_ano);

## partido
INSERT INTO ccp (cod_ccp,tipo_ccp,sigla_partido,uf,municipio,nome_ccp,ano,tipo_receita,valor_total,doacoes_count) (SELECT sequencial_diretorio,"partido",sigla_partido,uf,municipio,tipo_diretorio,new_prestacao_tse_ano,tipo_receita,SUM(new_valor),COUNT(*) FROM prestacaopartido GROUP BY sequencial_diretorio,tipo_receita,new_prestacao_tse_ano);



# Apagando a tabela de gastosdiretos_rel para livrarmos espaco de memoria e
# otimizarmos o banco:
ALTER TABLE gastosdiretos_rel DROP FOREIGN KEY `gastosdiretos_rel_ibfk_1`;
DROP TABLE gastosdiretos;
DROP TABLE gastosdiretos_import;
DROP TABLE prestacaocandidato_import;
DROP TABLE prestacaocomite_import;
DROP TABLE prestacaopartido_import;

# Optimizing tables:
OPTIMIZE TABLE gastosdiretos_rel;
OPTIMIZE TABLE aux_acao;
OPTIMIZE TABLE aux_elemento_despesa;
OPTIMIZE TABLE aux_funcao;
OPTIMIZE TABLE aux_grupo_despesa;
OPTIMIZE TABLE aux_org;
OPTIMIZE TABLE aux_org_superior;
OPTIMIZE TABLE aux_programa;
OPTIMIZE TABLE aux_subfuncao;
OPTIMIZE TABLE aux_tipo_receita;
OPTIMIZE TABLE aux_unid_gestora;
OPTIMIZE TABLE ccp;
OPTIMIZE TABLE gastostotais;
OPTIMIZE TABLE prestacaoCCP;
OPTIMIZE TABLE prestacaocandidato;
OPTIMIZE TABLE prestacaocomite;
OPTIMIZE TABLE prestacaopartido;
OPTIMIZE TABLE prestacaototais;

OPTIMIZE TABLE stats_empresa_partidos;

# Populando a tabela para busca:
INSERT INTO entidade_nomes (codigo_entidade,nome_favorecido,ano) SELECT cod_favorecido,nome_favorecido,ano FROM gastostotais;

INSERT INTO entidade_nomes (codigo_entidade,nome_receita_doador,nome_doador,ano) SELECT cod_doador,nome_receita_doador,nome_doador,ano FROM prestacaototais ON DUPLICATE KEY UPDATE entidade_nomes.nome_receita_doador = (SELECT nome_receita_doador FROM prestacaototais WHERE entidade_nomes.codigo_entidade = prestacaototais.cod_doador), entidade_nomes.nome_doador = (SELECT nome_doador FROM prestacaototais WHERE entidade_nomes.codigo_entidade = prestacaototais.cod_doador);
