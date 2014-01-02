<!-- Content -->
<div id="content">
  <hr class="hr-topo">

  <!-- Header -->
<div id="header">
  <div id="logo"><a href="/"><img alt="Política Aberta" src="/imagens/logo7.png"></a></div>
  <div id="search">
  	<form action="/buscar" method="post">
	    <input id="buscar" name="buscar" class="buscar" type="text" value="Buscar por empresa ou candidato" title="Procurar…" autocomplete="off">
	    <input id="cod_hidden" name="cod_hidden" class="" type="hidden" value="ff">
	    <input type="submit" value="Busca">
	  </form>
  </div>
  <div class="clear"></div>
</div>
<!-- /Header -->

<script>
$(document).on("click","input.buscar",function() {
  $("#buscar").val('');
  $("#buscar").css('color','black');
});

$( "form" ).on( "submit", function( event ) {
    event.preventDefault();
    //console.log( $( this ).serialize() );
    //$.post('/buscar', $(this).serialize());

    $('html').fadeTo("slow",0.3);

    $('body').spin({
        lines: 13, // The number of lines to draw
        length: 16, // The length of each line
        width: 4, // The line thickness
        radius: 30, // The radius of the inner circle
        corners: 1, // Corner roundness (0..1)
        rotate: 0, // The rotation offset
        direction: 1, // 1: clockwise, -1: counterclockwise
        color: '#000', // #rgb or #rrggbb or array of colors
        speed: 1, // Rounds per second
        trail: 60, // Afterglow percentage
        shadow: false, // Whether to render a shadow
        hwaccel: false, // Whether to use hardware acceleration
        className: 'spinner', // The CSS class to assign to the spinner
        zIndex: 2e9, // The z-index (defaults to 2000000000)
        top: 'auto', // Top position relative to parent in px
        left: 'auto' // Left position relative to parent in px
    });

    request = $.ajax({
        url: '/buscar',
        cache: false,
        type: "POST",
        data: $(this).serialize()
    })
            .done(function(resultado) {
                /*alert( "success" );*/
                $('html').fadeTo("slow",1);
                $('body').html(resultado);
            })
            .fail(function() {
                $('html').fadeTo("slow",1);
                alert( "Ocorreu um erro ao buscar os dados. Por favor tente mais tarde." );
                $('body').spin(false);
            })
            .always(function() {
                $('html').fadeTo("slow",1);
                $('body').spin(false);
            });
});
</script>