#!/bin/bash
echo $$ > ols_stat.pid
while [ -f ols_stat.pid ]; do 
	ruby main.rb 
      	echo "sleeping"
       	sleep 30s
       	date
done
