# Description:
#   Get Prets soup(s) of the day. Because everyone likes soup.
#
# Dependencies:
#   "htmlparser": "1.7.6"
#   "soupselect: "0.2.0"
#
# Configuration:
#   None
#
# Commands:
#   hubot (what's the )soup? - Gets today's soups at Pret
#
# Author:
#   mattheath

Select     = require("soupselect").select
HTMLParser = require "htmlparser"

module.exports = (robot) ->
  robot.respond /(what)?(')?(s the )?soup(\?)?/i, (msg) ->
    soupMe msg, (text) ->
      msg.send text

soupMe = (msg, cb) ->
  pretSoupUrl = "http://www.pret.co.uk/todays_soups.htm"

  msg.http(pretSoupUrl)
    .header('User-Agent', 'Hubot Soup Location Engine')
    .get() (err, res, body) ->
      return cb "Sorry, the tubes are broken." if err or res.statusCode != 200

      soupList = parseHTML(body, "#flowpanes .panel .content ul li")
      soups = findSoups(soupList)

      return cb "Have a look for yourself:" + pretSoupUrl if soups.length is 0
      cb "Today's soups are: " + soups.join(', ')

# Find soups on the list
findSoups = (soupList) ->
  return null if soupList.length is 0
  soups = []
  for soup in soupList
    do (soup) ->
      soups.push findSoupName(soup)

  # Return soup names
  soups

# Parse soup list item from Pret site html (gah):
#<li><img class="" src="/graphics/soup_hearty/hearty.png" border="0" alt="hearty"><br>
#  <a class="" href="/menu/sushi_salads_soups/PUK1768.shtm" onmouseout="MM_swapImgRestore()"
#  onmouseover="MM_swapImage('ge_ro_image1021','','/graphics/product_name_/Sausage+Hotpot.png',0)">
# <img src="http://www.pret.co.uk/graphics/product_name/Sausage+Hotpot.png" alt="Sausage Hotpot"
# name="ge_ro_image1021" border="0" id="ge_ro_image1021"></a></li>
findSoupName = (soup) ->
  soupImg = Select soup, "a img"
  soupImg[0].attribs.alt

# Utility method borrowed from wikipedia.coffee
parseHTML = (html, selector) ->
  handler = new HTMLParser.DefaultHandler((() ->),
    ignoreWhitespace: true
  )
  parser  = new HTMLParser.Parser handler
  parser.parseComplete html

  Select handler.dom, selector
