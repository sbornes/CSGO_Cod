XmlPath = "C:\Users\Shawn\AppData\Local\Autodesk\3dsMax\2012 - 64bit\enu\scripts\WallWorm.com\config\presets.xml"
XmlDoc = DotNetObject "system.xml.xmlDocument"
if doesFileExist XmlPath then
(
	XmlDoc.load XmlPath
	DocElem = XmlDoc.documentElement
	print (DocElem.InnerXml)
	if DocElem != undefined then
	(
		presetCount = DocElem.firstChild.ChildNodes.count
		for i = 0 to presetCount - 1 do
		(
			Anim = DocElem.ChildNodes.itemOf[i]
			print Anim.InnerXml
		)
	) else messageBox "DocElem is Undefined"
) else messageBox "Xml File does not exist"
