<!DOCTYPE html>
<!-- saved from url=(0041)http://www.chicagolobbyists.org/lobbyists -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<!-- Title -->
	<title>Politica Aberta - Contratadas</title>
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
  
  <h1>Mais contratadas com dinheiro público</h1>
  
  <div class="dataTables_wrapper" id="listing_wrapper"><table id="listing" class="listing">
    <thead>
      <tr>
          <th rowspan="1" colspan="1" style="width: 50%;"><span>Contratada</span></th>
          <th style="width: 10%"><span>No. pagamentos</span></th>
          <th class="sorting_desc" rowspan="1" colspan="1" style="width: 472px;"><span>Valor pago</span></th>
      </tr>
    </thead>
    
  <tbody>
  {foreach $contratadas as $c}
      <tr>
          <td class=" sorting_2"><h3><a href="/entidade/{$c.cod_contratada}/{$c.nome_link}">{$c.posicao}. {$c.contratada}</a></h3></td>
          <td>{$c.pagamentos_count}</td>
          <td class="bar sorting_1"><span style="width: {$c.contratada_percent}%;"><strong>{$c.valor_total}</strong></span></td>
      </tr>
  {/foreach}
  </tbody></table></div>
   {foreach $paginacao as $p}
       {if $p.selecionada == 1}<b>{/if}
       <a href="/contratadas/{$p.pg}">{$p.range}</a>
       {if $p.selecionada == 1}</b>{/if}
   {/foreach}

<p></p>
  <!-- Footer -->
{include file='parcial_pag_foot_nav.tpl'}
<!-- /Footer -->

</div>
<!-- /Content -->



</body></html>