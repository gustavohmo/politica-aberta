<!DOCTYPE html>
<html>
<head>
	<!-- Title -->
	<title>Sobre o Política Aberta</title>
    <link rel="Shortcut Icon" href="/favicon.ico" type="image/x-icon" />
	
	<!-- Info -->
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script src="/js4/ga.js" type="text/javascript"></script>
	
	<!-- Styles -->
	<link rel="stylesheet" type="text/css" media="all" href="/stylesheets/master2.css" />

	<!-- JavaScript -->
{include file='parcial_scripts.tpl'}



</head>
<body>
{include file='parcial_facebook.tpl'}

{include file='parcial_pag_topo_nav.tpl' capa_class='' sobre_class='current' blog_class=''}



<!-- Content -->
<div id="content">
    <hr class="hr-topo">
    <!-- Header -->
<div id="header">
  <div id="logo"><a href="/"><img alt="Política Aberta" src="/imagens/logo7.png"></a></div>
<!--  <div id="search">
  	<form action="/search" method="get">
	    <input class="hint" type="text" title="Find&hellip;" name="q"/>
	    <input type="submit" value="Search" />
	  </form>
  </div>-->
  <div class="clear"></div>
</div>
<!-- /Header -->

  <div class="clear"></div>
    
  <div class='content-primary'> 
  <h1>Sobre o Política Aberta</h1>
  
  <ul id="faq">
      <li><a href="#o-que-eh">O que é?</a></li>
      <li><a href="#foi-feito-para-quem">Foi feito para quem usar?</a></li>
      <li><a href="#de-onde-dados">De onde vêm os dados?</a></li>
      <li><a href="#informacoes-tecnicas">Informações técnicas</a></li>
      <li><a href="#quem-fez">Quem fez?</a></li>
      <li><a href="#agradecimentos">Agradecimentos</a></li>
      <li><a href="#contact-us">Contato</a></li>
    </ul>
	
	<h2 id="o-que-eh">O que é?</h2>
	<p>O Política Aberta é um aplicativo que busca apresentar, de maneira didática, dados relacionados ao funcionamento da política brasileira. Em especial, o objetivo é que o funcionamento do governo (e as influências externas sobre o governo) se tornem mais transparentes. O Política Aberta utiliza dados abertos (open data) e é construído em código aberto. Todos os dados são provenientes do <a href="http://www.portaltransparencia.gov.br/">Portal da Transparência</a> e do <a href="http://www.tse.jus.br/eleicoes/eleicoes-anteriores">Tribunal Superior Eleitoral</a>.</p>
	<hr />

      <h2 id="foi-feito-para-quem">Foi feito para quem usar?</h2>
      <p>O Política Aberta foi feito para qualquer pessoa com interesse no funcionamento da política brasileira. Em especial, pode ser usado por:</p>

      <ul>
          <li>cidadãos querendo entender o papel de empresas na política brasileira</li>
          <li>cidadãos interessados no tema do financiamento de campanhas</li>
          <li>jornalistas, como ferramenta de pesquisa</li>
          <li>órgãos do governo, interessados em maior divulgação/transparência de seus dados</li>
      </ul>
      <hr />

      <h2 id="de-onde-dados">De onde vêm os dados?</h2>
      <p>Todos os dados vêm do governo brasileiro. Mais especificamente, utilizamos as seguintes bases:

      <ul>
          <li><a href="http://www.portaltransparencia.gov.br/downloads/view.asp?c=GastosDiretos">Portal da Transparência - Download de Dados - Gastos Diretos - Pagamentos</a></li>
          <ul>
              <!--<li>Gastos Diretos - Pagamentos - 2011</li>-->
              <li>Gastos Diretos - Pagamentos - 2012</li>
          </ul>
          <li><a href="http://www.tse.jus.br/eleicoes/estatisticas/repositorio-de-dados-eleitorais">Tribunal Superior Eleitoral - Repositório de Dados Eleitorais</a></li>
          <ul>
              <li>Prestação de Contas - 2012</li>
              <!--<li>Prestação de Contas - 2010</li>-->
          </ul>
      </ul>

      <p>Os dados são apresentados de forma fiel, com apenas os seguintes tratamentos:</p>
      <ul>
          <li>Pagamentos a estatais foram omitidos (como elas foram omitidas uma a uma, talvez algumas ainda permaneçam nas listagens. Caso encontre alguma, favor entrar em contato conosco)</li>
          <li>Pagamentos a pessoas físicas foram omitidos, pois o objetivo inicial do Política Aberta enfoca o papel de pessoas jurídicas na política</li>
          <li>Pagamentos que aparecem censurados nos dados foram omitidos (alguns pagamentos do Portal da Transparência - talvez por segurança? - não vêm com todos os detalhes; estão marcados, nos dados, com a frase: "Detalhamento das informações bloqueado.")</li>
          <li>Quanto a doações de campanha, na página principal utilizamos apenas as feitas por pessoas jurídicas, conforme prestação de contas informada. (Repare que nós não corrigimos inconsistências que, provavelmente, foram causadas pelos usuários dos sistemas. Por exemplo, há candidatos que, em sua prestação de contas, colocaram repasse do partido como sendo "Recursos de pessoas jurídicas", enquanto outros colocaram "Recursos de partido político". Neste caso, os marcados como sendo de pessoa jurídica estarão incluídos aqui no Política Aberta). Na página específica de cada candidato, comitê ou partido, no entando, as informações de prestação de contas (doacões recebidas) estão completas, quer dizer, referem-se não só a pessoas jurídicas, mas também a doações de pessoas físicas, recursos próprios etc.</li>
      </ul>
    <div class='clear'></div>
    <hr />

    <h2 id="informacoes-tecnicas">Informações Técnicas</h2>
    <p>Este site foi construído em <a href="http://www.php.net">PHP</a> e <a href="http://www.mysql.com/">MySQL</a>. Para importar os arquivos CSV do Portal da Transparência e do TSE, fizemos primeiro um script SQL para criação de tabelas. O banco de dados referentes aos dados do Portal da Transparência (gastos diretos) foi normalizado apenas o necessário para a otimização (em especial, para a criação de covering indexes); ou seja, ainda usamos denormalization para otimizacao. Os scripts SQL estão disponíveis no <a href="https://github.com/gustavohmo/brasil-GastosDiretos-PortalTransparencia-rdbms-sql"">github</a>. Para a importação dos CSV para o MySQL, fizemos alguns shell scripts em <a href="http://www.perl.org/">Perl</a>. Em todo erro ou warning, editamos a linha do CSV para garantir a importação sem perda de dados.</p>

    <p>Para o layout/design do site, utilizamos o layout/design do <a href="http://www.chicagolobbyists.org/"">Chicago Lobbyists</a>, desenvolvido pelo pessoal do <a href="http://opencityapps.org/">Open City Apps</a> e liberado em código aberto.</p>

    <p>Todo o código-fonte desenvolvido é aberto e está <a href="https://github.com/gustavohmo/politica-aberta">disponível no github</a>.</p>
    <hr />

    <h2 id="agradecimentos">Agradecimentos</h2>
    <p>Várias pessoas ajudaram, direta ou indiretamente, na construção deste site:
        <ul>
          <li>Pessoal do Blue1647 - Ken, Emile, Patrick: vocês são demais. Obrigado pelo apoio e por este espaço de inovação e colaboração que vocês sabem manter tão bem. [<i>Folks from Blue1647 - Ken, Emile, Patrick: you guys rock. Thanks for the support and for the innovative and collaborative space you maintain so well</i>].
          <li>Juan Pablo e Derek: obrigado por todo o apoio, pelo layout (como mencionado acima) e por manter o inspirador Open Gov Hack Night. [<i>Juan Pablo and Derek: thanks for all the support, for the layout (as mentioned above) and for maintaining the inspirational Open Gov Hack Night</i>].
         </ul>
    <hr />

	<h2 id="quem-fez">Quem fez?</h2>
	<p>O Política Aberta foi desenvolvido por Gustavo H. M. Oliveira. O projeto teve início em Setembro de 2013, como parte do seu <i>fellowship</i> junto ao <a href="http://ethics.harvard.edu/">Edmond J. Safra Center for Ethics</a> da Universidade de Harvard.</p>
	<hr />
	

	<h2 id="contact-us">Contato</h2>
	<p>Se você tem quaisquer comentários, perguntas, sugestões, pedidos etc, favor nos contactar em <a href="mailto:politicaabertasite@gmail.com">politicaabertasite@gmail.com</a> ou no Facebook em <a href="https://www.facebook.com/PoliticaAbertaSite">Politica Aberta</a>.</p>
</div> 

<div class="content-secondary">
    <h2>Contato</h2>
    <p>Se você tem quaisquer comentários, perguntas, sugestões, pedidos etc, favor nos contactar em <a href="mailto:politicaabertasite@gmail.com">politicaabertasite@gmail.com</a> ou:</p>
    <ul>
        <li><a href="https://www.facebook.com/PoliticaAbertaSite">Facebook</a></li>
        <li><a href="https://twitter.com/PolitAberta">Twitter</a></li>
        <li><a href="https://github.com/gustavohmo">GitHub</a></li>
    </ul>
</div>

<!-- Footer -->
{include file='pag_foot_nav.tpl'}
<!-- /Footer -->

</div>
<!-- /Content -->

</body>
</html>
