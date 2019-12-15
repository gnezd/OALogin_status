#!/usr/bin/ruby
require './rpt_parse_lib.rb'
#Engineering test for mass pressure curve extraction

#pressure, curve = parse_rpt(ARGV[0])
#puts pressure
	#puts curve[0]
path1 = "../../testdata/rpts/Bode - AlKa - 23 - on.rpt"
path2 = "../../testdata/rpts/Bode - JF-9-184-10min.rpt"
rpt1 = OALogin_Report.new(path1)
rpt2 = OALogin_Report.new(path2)


#puts "max pessure: #{rpt.max_pressure}"
#puts rpt.curve.size
output = String.new
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
END_HTML_HEAD

	output+="data.addColumn('number', '#{path1}');
	data.addRows(["

rpt1.curve.each do |pt|
	output += "[#{pt[0]},#{pt[1]}], \n"
end
	output+="]);"
	output+="data.addColumn('number', '#{path2}');
	data.addRows(["



	output+="]);"
output += <<END_HTML_TAIL
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
