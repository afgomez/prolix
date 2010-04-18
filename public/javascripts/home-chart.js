
function go_back(date,days) {
  today = date.getDate();
  date.setDate( today - days );
  return date;
}


var ticks = [];
var tooltip_tpl = '<h3>Aciertos de...</h3><dl><dt class="max">T. max:</dt><dd>{tmax} %</dd><dt class="min">T. min:</dt><dd>{tmin} %</dd><dt class="precip">Precip.:</dt><dd>{precipitaciones} %</dd></dl>';

var data_length = data.length;
for (var i = 0; i < data_length; i++) {
  
  // Etiquetas de los días
  var d = new Date;
  var back = go_back(d, (data_length-1-i));
  ticks.push([i, '' + back.getDate() + '/' + (back.getMonth()+1)]);
}


var plot = $.plot($('#graph_placeholder'), [{
  label: '% aciertos',
  data: data
}], {
  series: {
    lines: { show:true },
    points : { show: true }
  },
  grid: { hoverable: true, clickable: true },
  xaxis: {
    ticks: ticks
  }
});

$('#graph_placeholder').bind('plotclick', function(e, pos, item) {
  
  var $tooltip = document.getElementById('tooltip') ? $('#tooltip') : $('<div id="tooltip"></div>');
  
  if (item) {
    var index = item.dataIndex;
    var tooltip_data = tooltips[index];


    var parsed_tpl = tooltip_tpl.replace(/\{(\w+)\}/g, function() {
      return Math.round(tooltip_data[arguments[1]] * 100) / 100;
    });

    var css = {
      left: (item.pageX - 66) + 'px',
      top: (item.pageY - 90) + 'px',
      display: 'none'
    };


    $tooltip.html(parsed_tpl).css(css).appendTo('body').fadeIn('fast');
  }
  else {
    $tooltip.fadeOut('fast');
  }
  
  
});

