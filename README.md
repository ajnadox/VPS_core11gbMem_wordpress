VPS 1Core 1Gb Wordpress
=========================

This script sets up LEMP Stack on Ubuntu (14.04x64) with Nginx, MySql 5.5, PHP-FPM 5.5, phpMyAdmin


Optimized for 1 Core - 1024 MB, more finetuning can of course always be made, microcaching and gzip will be more tuned in next release.

Not much comments in script, will fill that in later so bear with me ;)

All suggestions are welcome / André - Nadox // aj@nadox.se


Test result with "siege -c 1650 -r 10 -b http://X.X.X.X"  "1650 simultaneous users & running it 10 times without delay between requests"

`sudo apt-get install siege`
>** Preparing 1650 concurrent users for battle.
>The server is now under siege..      done.
>
>Transactions:                  33000 hits
>Availability:                 100.00 %
>Elapsed time:                  21.25 secs
>Data transferred:              31.33 MB
>Response time:                  0.24 secs
>Transaction rate:            1552.94 trans/sec
>Throughput:                     1.47 MB/sec
>Concurrency:                  375.47
>Successful transactions:       33000
>Failed transactions:               0
>Longest transaction:           15.09
>Shortest transaction:           0.01



Quick Setup:


Login to the Ubuntu Server 14.04.1 LTS VPS you have created, then just run:

`wget https://raw.githubusercontent.com/ajnadox/VPS_core11gbMem_wordpress/master/VPS_LEMP_ndx.sh && sudo chmod +x VPS_LEMP_ndx.sh && sudo ./VPS_LEMP_ndx.sh`
