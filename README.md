# OALogin_status
## This is a bunch of scripts written
- Originally to monitor the Waters SQD Open Instrument at ETH-LOC to help arrange life
- Then became a tool that hopefully helps tracking down LC problems developing over time (pressure buildup)
- Or users from disobeying community rules
- And now becomes a toolbox to automate some tedious mass action of chromatogramms from these instruments

## Directory structure explanation
- product/ contains files indispensable for current daily functioning of the monitor
- engineering/ contains half-done fragments of new features or scripts to solve a one-time problem and are meant to be forgotten in due time
- scratch/ contains things even more random and cruder than in engineering/
- testdata/ contains some representative .OLB, .OLS and .rpt files collected from our instruments that has helped, and should further help with development

## Function
Given access to the Status.ols file from the computer running OALogin, and the directory storing sample reports, this script (product/main.rb) will
- List current jobs in the measurement queue
- Estimate the time needed to finish the queue
- Plot the pressure curve from the last five submissions

## Short manual to quick setup
- Consult product/settings.rb.default
- run htmout.sh or anyother means to call main.rb at your given moment

## Technical explanations/comments
- In lib.rb lies the oldest codes (with the most guessing effort) to parse the binary file Status.ols, summed up in function parse_ols(). A progress to wrap this up nicer is ongoing in my dreams.
- In engineering/rpt_parse/rpt_parse_lib.rb contained the codes to parse report files and wrapping up into defined OALogin_Report objects. Lessons learned here would be applied to attempts on parsing OLB(OALogin Batch) files and the ols binary.
- On parsing of the raw acquisition data, it's getting out of control and thus another [repo](https://github.com/gnezd/SQD_data_parse) was created for it.

Yi-Chung, 1750 09Feb 2020
