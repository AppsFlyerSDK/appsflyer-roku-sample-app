' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********
function init()
  scrolltext = m.top.findNode("exampleScrollableText")
  scrolltext.width = "1920"
  scrolltext.height = "1080"
  scrolltext.setFocus(true)
end function


function onKeyEvent(key as string, press as boolean) as boolean
  if press then
    if (key = "options") then
      trackEventValues = { "af_revenue": 24.22, "af_currency": "ILS", "freeHandParam": "freeHandValue" }

      AppsFlyer().logEvent("af_purchase", trackEventValues)
    else if (key = "OK") then
      scrolltext = m.top.findNode("exampleScrollableText")
      afText = ReadAsciiFile("tmp:/aflog.txt")
      if afText <> invalid and afText <> "" then
        scrolltext.text = afText
      else
        scrolltext.text = "Unable to read file"
      end if
    end if
  end if
  return true
end function