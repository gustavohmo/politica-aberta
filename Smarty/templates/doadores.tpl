<!DOCTYPE html>
<!-- saved from url=(0041)http://www.chicagolobbyists.org/lobbyists -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<!-- Title -->
	<title>Politica Aberta - Doadores</title>
    <link rel="Shortcut Icon" href="/favicon.ico" type="image/x-icon" />
	
	<!-- Info -->
    <script src="/js4/ga.js" type="text/javascript"></script>

	<!-- Styles -->
	<link rel="stylesheet" type="text/css" media="all" href="/stylesheets/master2.css">

	<!-- JavaScript -->
{include file='parcial_scripts.tpl'}

</head>
<body>
{include file='parcial_facebook.tpl'}

{include file='parcial_pag_topo_nav.tpl' capa_class='' sobre_class='' blog_class=''}
{include file='parcial_pag_topo.tpl'}
{include file='parcial_pag_topo_stats.tpl'}
<hr>
  
<div class="clear"></div>
  
  <h1>Doadores para Campanhas</h1>
  
  <div class="dataTables_wrapper" id="listing_wrapper"><table id="listing" class="listing">
    <thead>
      <tr>
          <th rowspan="1" colspan="1" style="width: 50%"><span>Doador</span></th>
          <th style="width: 10%"><span>No. doações</span></th>
          <th class="sorting_desc" rowspan="1" colspan="1" style="width: 472px;"><span>Valor total doado</span></th>
      </tr>
    </thead>
    
  <tbody>
  {foreach $doadores as $d}
      <tr>
          <td class=""><h3><a href="/entidade/{$d.cod_doador}/{$d.nome_link}">{$d.posicao}. {$d.doador}</a></h3></td>
          <td style="text-align: center">{$d.prestacao_total_ccp_count}</d>
          <td class="bar sorting_1"><span style="width: {$d.doador_percent}%;"><strong>{$d.valor_total_ccp}</strong></span></td>
      </tr>
  {/foreach}
  </tbody></table></div>
   {foreach $paginacao as $p}
       {if $p.selecionada == 1}<b>{/if}
       <a href="/doadores/{$p.pg}">{$p.range}</a>
       {if $p.selecionada == 1}</b>{/if}
   {/foreach}

<p></p>
  <!-- Footer -->
{include file='parcial_pag_foot_nav.tpl'}
<!-- /Footer -->

</div>
<!-- /Content -->



</body></html>