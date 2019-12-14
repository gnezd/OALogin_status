#!/usr/bin/ruby
require './rpt_parse_lib.rb'
#Engineering test for mass pressure curve extraction

#pressure, curve = parse_rpt(ARGV[0])
#puts pressure
	#puts curve[0]
path = "../../testdata/rpts/Bode - AlKa - 23 - on.rpt"
rpt = OALogin_Report.new(path)

puts "max pessure: #{rpt.max_pressure}"
puts rpt.curve.size
output = String.new
sample_name=path
output += <<-END_HTML_HEAD
  <html>
  <head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['corechart','line']});
      google.charts.setOnLoadCallback(drawChart);

      function drawChart() {
        var data = new google.visualization.DataTable();
	data.addColumn('number', 'X');
	data.addColumn('number', '#{sample_name}');
	data.addRows([
END_HTML_HEAD

rpt.curve.each do |pt|
	output += "[#{pt[0]},#{pt[1]}], "
end


output += <<END_HTML_TAIL
	]);
	var options = {
        hAxis: {
          title: 'RetentionTime'
        },
        vAxis: {
          title: 'Pressure'
        },
        backgroundColor: '#f1f8e9'
      	}
	var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
      	chart.draw(data, options);	
        }
    </script>
  </head>
  <body>
    <div id="chart_div" style="width: 900px; height: 500px"></div>
  </body>
</html>
END_HTML_TAIL

htmlout = File.open("plot/p_plot.html", "w")
htmlout.write(output)
htmlout.close
