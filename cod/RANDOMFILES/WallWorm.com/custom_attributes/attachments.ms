
global wallworm_attachment_CA = attributes "wallworm_attachment_CA" version:5 (
	local wallworm = true
	local wwmt_is_attachment = true
	local vmf_exclude = true
	local att -- for storing the attachment_struct
	local thisNode, paramrollout
	function getNode = (
		if thisNode == undefined then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
		thisNode
	)
	parameters main rollout:paramrollout (
		attachName type:#string ui:edtAttachment
		absolute type:#boolean default:false ui:chkAbsolute
		rigid type:#boolean default:false ui:chkRigid
	)

	function setAtt atstr:undefined = (
		if atstr != undefined then (
			att = atstr
		)
		global wwmt_attachment

		if wwmt_attachment == undefined then (
			local scriptPath = ::wallworm_installation_path
			if scriptPath == undefined then (
				scriptPath = "$scripts"
			)
			scriptPath = (scriptPath + "/WallWorm.com/WallWormModelTools/wwmt_struct_attachment.ms")
			if doesFileExist scriptPath then (
				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/wwmt_struct_attachment.ms")
			)
		)
		if wwmt_attachment != undefined then (
			if att == undefined then (
				att = (wwmt_attachment())
			)
			att.rigid = rigid
			att.absolute = absolute
			getNode()
			if isValidNode thisNode then (
				att.atPoint = thisNode
				att.pb = thisNode.parent
				att.attachment = thisNode.name
			)
		)
		att
	)

	function setFromAttachement att = (
		getNode()
		rigid = att.rigid
		absolute = att.absolute
		attachName = att.attachment
		if isValidNode thisNode then (
			thisNode.name = attachName
		)
	)

	rollout paramrollout "WWMT Attachment" (
		EditText edtAttachment "Name"
		CheckBox chkAbsolute "Is Absolute?"
		CheckBox chkRigid "Is Rigid?"
		on paramrollout open do (
			setAtt()
		)
	)
	on clone orig do thisNode = undefined
)