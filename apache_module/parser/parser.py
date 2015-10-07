import sys
import HTMLParser

h = HTMLParser.HTMLParser()

input = sys.stdin.read()

def exit_on_error(err_code):
	if err_code == -1:
		print input
		sys.exit(-1)

beginOfValueSearchString = "<td>"
endOfValueSearchString = "</td>"
searchStrings = ["<td>Titel:</td>", "<td>K&#252;nstlername:</td>",
			"<td>Vorname:</td>", "<td>Nachname:</td>",
			"<td>Geburtsname:</td>", "<td>Wohnort:</td>",
			"<td>Geburtsort:</td>", "<td>Geburtsdatum:</td>",
			"<td>Dokumententyp:</td>", "<td>Ausstellender Staat:</td>",
			"<td>Staatsangeh&#246;rigkeit:</td>", "<td>Aufenthaltserlaubnis I:</td>",
		]
		
stringList = []

for searchString in searchStrings:
	copyStart = input.find(searchString, 0)
	exit_on_error(copyStart)
	copyStart = input.find(beginOfValueSearchString, copyStart + len(beginOfValueSearchString))
	exit_on_error(copyStart)
	copyStart += len(beginOfValueSearchString)
	copyEnd = input.find(endOfValueSearchString, copyStart)
	exit_on_error(copyEnd)
	stringList.append(h.unescape(searchString.replace("<td>", "").replace("</td>", "")))
	stringList.append(h.unescape(input[copyStart:copyEnd]))

for s in stringList:
	print s.encode('utf-8')
	