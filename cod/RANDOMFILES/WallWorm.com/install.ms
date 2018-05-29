
/*
Script to Install Wall Worm or Wall Worm Pro.
http://dev.wallworm.com

*/

try (destroyDialog wallworm_EULA_agreement) catch ()

rollout wallworm_EULA_agreement "End User License Agreement" width:300 (
	local actualPath = (getFilenamePath (getThisScriptFilename()))

	function wallworm_install_wwVTFLib &addVTFToPluginsINI x:"64" = (
		if NOT addVTFToPluginsINI then (
			if (isDirectoryWriteable (symbolicPaths.getPathValue "$max")) then (
				local srcVTF = (::wallworm_installation_path + "/WallWorm.com/VTFLib/bin/x" + x + "/VTFLib.dll")
				local maxroot = substituteString (symbolicPaths.getPathValue "$max") "\\" "/"
				local targetVTF = (maxroot + "/VTFLib.dll")
				if copyFile srcVTF targetVTF then (
					addVTFToPluginsINI = true
				) else (
					format "!! Wall Worm Installer COULD NOT copy\n\n%\n\nto\n\n%\n\n" srcVTF targetVTF
				)
				copyFile (::wallworm_installation_path + "/WallWorm.com/VTFLib/VTFLib-LGPL.txt") (maxroot + "/VTFLib-LGPL.txt")
			)
		)
	)

	Hyperlink hyperlinkWWEULA "Wall Worm End User License Agreement" address:"http://dev.wallworm.com/topic/70/end_user_license_agreement.html"
	DotNetControl edtEULA "System.Windows.Forms.TextBox" width:290 height:300 align:#center
	CheckBox chkEULA "ACCEPT: I have read and agree to the EULA"
	--Checkbox chkStartup "Load WW Config at Max Start-up" tooltip:"This will load the WW settings file at Max Startup. Doing this speeds up opening WW Tools, especially when WW Pro is installed."
	Button btnInstall "Agree to Terms and Install" enabled:false width:260
	on wallworm_EULA_agreement open do (
		local eulatext = actualPath + "/EULA.txt"
		if doesFileExist eulatext then (
			stream = openFile eulatext mode:"r"
			local textstream = StringStream ""
			while eof stream == false do (
				format "%\r\n" (readLine stream) to:textstream
			)
			edtEULA.text = textstream as String
		) else (
			edtEULA.text = "EULA File Not Found\r\nRead the EULA at:\r\n\r\nhttp://dev.wallworm.com/topic/70/end_user_license_agreement.html"
		)
		edtEULA.multiline = true
		edtEULA.wordwrap = true
		edtEULA.acceptsreturn = true
		edtEULA.readOnly = true
		edtEULA.scrollbars = (DotNetClass "System.Windows.Forms.ScrollBars").Vertical
	)

	on chkEULA changed chk do (
		btnInstall.enabled = chk
	)

	on btnInstall pressed do (
		if NOT chkEULA.checked then (
			messageBox "You cannot install and use Wall Worm unless you click the checkbox signifying that you have read and agree to the EULA."
		) else (
			local wallworm_installation_errors = #()
			local wrapperFolder = pathConfig.stripPathToLeaf (actualPath)
			local addVTFToPluginsINI = (doesFileExist ((symbolicPaths.getPathValue "$max") + "/VTFLib.dll"))
			if wrapperFolder == "WallWorm.com\\" OR wrapperFolder != "WallWorm.com" OR wrapperFolder != "WallWorm.com/" then (
			) else (
				append wallworm_installation_errors "Wall Worm can only install if it has been extracted with the root WallWorm.com folder as the root of the folders. Please re-extract your zip file, including the WallWorm.com folder root."
			)

			if (::wallworm_userIni == undefined OR doesFileExist ::wallworm_userIni == false) then (
				::wwmtinifolder = ((symbolicPaths.getPathValue "$userScripts") + "/WallWorm.com/config")
				if (makeDir ::wwmtinifolder all:true == false) then (
					append wallworm_installation_errors "There is no config directory for the Wall Worm... and MAXScript does not have permission to write to the appropriate directory."
				)
				::wallworm_userIni = ((symbolicPaths.getPathValue "$userScripts") + "/WallWorm.com/config/wwmt.ini")
			)

			::wallworm_installation_path = pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename()))
			local wallworm_can_install = true
			local wallworm_isProInstall = false
			local env
			local x = "64"
			/*
			Check if WW Pro is in the installation ... if so see if there is permission to install
			*/
			if doesFileExist (::wallworm_installation_path + "/WallWorm.com/VTFLib") AND doesFileExist (::wallworm_installation_path + "/WallWorm.com/assemblies") then (
				wallworm_isProInstall = true
				env = DotNetClass "System.Environment"
				if NOT env.Is64BitProcess then (
					x = "86"
				) else (
					x = "64"
				)
				--see if VTFLib is already installed
				wallworm_install_wwVTFLib &addVTFToPluginsINI x:x
				if NOT addVTFToPluginsINI then (
					append wallworm_installation_errors "To install Wall Worm Pro, VTFLib.dll must be copied to the MAX ROOT directory. Try Running 3ds Max As Administrator or copy the file manually. Please read the WallWormPro.txt file for instructions."
				)
			)

			if wallworm_installation_errors.count == 0 then (
				local makeStartupFile = false
				if NOT pathConfig.pathsResolveEquivalent "$scripts" ::wallworm_installation_path then (
					makeStartupFile = true
					userpath = symbolicPaths.getPathValue "$userscripts"
					if userpath != ::wallworm_installation_path then (
						if NOT (queryBox ("Should Wall Worm install at the current path: \n" + ::wallworm_installation_path + "\n\nClick Yes to use that path.\n\nClick No to install at:\n" + userpath)) then (
							
							if NOT doesFileExist (userpath + "/WallWorm.com") then (
								makeDir (userpath + "/WallWorm.com")
							)

							str = "xcopy \"" + ::wallworm_installation_path + "\\WallWorm.com\" \"" + userpath + "\\WallWorm.com" + "\" /S /Y"

							hiddenDOSCommand str

							--Copy the contents of ::wallworm_installation_path to userpath
							::wallworm_installation_path = userpath
						)
					)

					::wallworm_installation_path = substituteString ::wallworm_installation_path "\\" "/"

					if wallworm_isProInstall then (
						wallworm_install_wwVTFLib &addVTFToPluginsINI x:x
					)
				)

				wwinstallationloader = "$userscripts/startup/wallworm_installation_path.ms"
				if makeStartupFile then (
					/*If the installation is not in the 3ds Max Scripts folder, add an entry into the startup scripts to set the wallworm installation path to this install.*/
					if doesFileExist wwinstallationloader then (
						wwstartupfile = openFile wwinstallationloader mode:"w+"
					) else (
						wwstartupfile = createFile wwinstallationloader
					)
					format "::wallworm_installation_path = \"%\"\n" ::wallworm_installation_path to:wwstartupfile
					close wwstartupfile
				) else (
					if doesFileExist wwinstallationloader then (
						deleteFile wwinstallationloader
					)
				)

				::wallwormInstallation = true
				::wallworm_EULA = true

				setINISetting ::wallworm_userIni "Agreement" "EULA" "true"

				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/addWWtoMaxMenu.ms.")
				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")

				--the EULA only gets set here meaning the user has agreed to these terms.

				fileIn (::wallworm_installation_path + "/WallWorm.com/common/version_funcs.ms")

				versions = ::wallworm_getMaxVersion()

				if (((versions[1] as Integer) == 14 OR (versions[1] as Integer) == 15) AND (versions[2] as Integer) <= 2) then (
					messageBox "You are using a version of Max that requires an update to properly use Wall Worm. Please install the latest service pack for your 3ds Max to avoid problems with Wall Worm."
				)

				macros.run "wallworm.com" "WallWormModelToolsConfigMCR"
				if wallworm_isProInstall then (
					setINISetting ::wallworm_userIni "Directories" "VTFCmdPath" (::wallworm_installation_path + "/WallWorm.com/VTFLib/bin/x" + x + "/VTFCmd.exe")
					if addVTFToPluginsINI then (
						messageBox "Wall Worm Pro is now installed.\n\nNow please set up your paths. When done, restart 3ds Max for VTF support."
					) else (
						messageBox "VTFLib failed to copy to the Max Root directory. Read the Wall Worm Pro docs on installing the file manually. Once you have copied VTFLib to your Max root, run the install script again."
					)
				) else (
					messageBox "Wall Worm is now installed.\n\nNow please set up your paths."
				)

				if wallworm_isProInstall AND addVTFToPluginsINI then (
					v = case ((maxVersion())[1]) of (
						14000: 2012
						15000: 2013
						16000: 2014
						17000: 2015
						18000: 2016
						default: undefined
					)
					if v != undefined then (
						--VTF Plugin only works in Max 2012+
						setINISetting ((symbolicPaths.getPathValue "$maxData") + "/Plugin.UserSettings.ini") "Directories" "Wall Worm VTF" ((::wallworm_installation_path + "\\WallWorm.com\\assemblies\\" + (v as String) + "\\x" + x + "\\"))
					)
				)
				--tracking code in links does not track individual users. the same code is used across all users to track the general user clicks from the additional help menu in Max.
				setINISetting ((symbolicPaths.getPathValue "$maxData") + "/Plugin.UserSettings.ini") "Help" "Level Design Guide" "https://wallworm.com/store/index.php?route=product/product&product_id=62&tracking=5602d26f624ea"
				setINISetting ((symbolicPaths.getPathValue "$maxData") + "/Plugin.UserSettings.ini") "Help" "Anatomy of a Design Team" "https://wallworm.com/store/index.php?route=product/product&product_id=61&tracking=5602d26f624ea"
				setINISetting ((symbolicPaths.getPathValue "$maxData") + "/Plugin.UserSettings.ini") "Help" "CorVex" "http://dev.wallworm.com/topic/66/corvex.html?tracking=5602d26f624ea"
				setINISetting ((symbolicPaths.getPathValue "$maxData") + "/Plugin.UserSettings.ini") "Help" "ShellVex" "http://dev.wallworm.com/topic/76/shellvex.html?tracking=5602d26f624ea"
				setINISetting ((symbolicPaths.getPathValue "$maxData") + "/Plugin.UserSettings.ini") "Help" "Snap Vertices To Grid" "http://dev.wallworm.com/topic/77/snap_verts_to_grid_modifier.html?tracking=5602d26f624ea"
				setINISetting ((symbolicPaths.getPathValue "$maxData") + "/Plugin.UserSettings.ini") "Help" "Wall Worm" "http://dev.wallworm.com?tracking=5602d26f624ea"
				destroyDialog wallworm_EULA_agreement
			) else (
				outmessage = StringStream ""
				format "There are problems:\n\n" to:outmessage
				for m in wallworm_installation_errors do (
					format "* %\n" m to:outmessage
				)
				messageBox (outmessage as String)
			)

		)

	)

)

createDialog wallworm_EULA_agreement