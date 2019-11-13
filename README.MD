# What?
This is a dump of all products from the norwegian Vinmonopolet and the swedish Systembolaget, based on their own dumps buried within their web sites. They use different units of measurement, this dump has the same units across both.

# Why?
Originally I looked for any rum greater than 55% for a drink recipe. Neither of their search engines allowed to search based on alcohol percentage, so I created this dump to search for it myself.

# How?
I used Powershell, [here's the code](https://raw.githubusercontent.com/khaffner/booze/master/Get-Booze.ps1). Then just convert to json, csv and html and save to file.

# How up to date is this?
At the time of writing, no schedule or automatic update. Look at commit date for age.

# This is just the raw data, how do I use this?
Use it as you please, I have not yet created a user friendly searchable and sortable table for all the data. But now, if you're on Windows, I recommend simply using powershell.
```powershell
$d = Invoke-RestMethod -Uri https://raw.githubusercontent.com/khaffner/booze/master/dump.json
$d | Out-GridView
``` 
