# Política Aberta 2013

Este repositório contém toda a aplicação do Política Aberta - http://www.politicaaberta.org

## Instalação

### Inicialmente, para criar o banco:
1. Usar o script `Politicaaberta2 - script 1.sql` para criar a estrutura inicial do banco;
2. Rodar o `gastosdiretos.pl` para importar os dados do Portal da Transparência;
3. Rodar o `prestacoes2012.pl` para importar os dados de 2012 do TSE;
4. Rodar o `totais.pl` para criar os totais;
5. Rodar o `Politicaaberta2 - script 2.sql` para criar as tabelas auxiliares e para popular o gastosdiretos_rel a partir do gastosdiretos nao-relacional.

## Preparar o resto do ambiente

1. Instalar `apache`, `mod_rewrite`, `mysql`, `php`, `Smarty`;
2. Configurar o `htaccess` do apache;
3. Renomenar o `politicaaberta.config.php.example` para `politicaaberta.config.php`.

Qualquer dúvida, é só entrar em contato.

Abs
