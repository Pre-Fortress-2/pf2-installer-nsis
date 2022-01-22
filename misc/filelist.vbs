sub dorecurse(dpath, spath)
	if fs.folderexists(spath) then
		out1.writeline "SetOutPath """ & dpath & """"
 
		set d = fs.getfolder(spath)
		for each f in d.files
			str = "File """ & f.Path & """"
			out1.writeline str
			str = "Delete """ & dpath & "\" & f.Name & """"
			out2.writeline str
		next
		for each d2 in d.subfolders
			str = "CreateDirectory """ & dpath & "\" & d2.Name & """"
			out1.writeline str
			dorecurse dpath & "\" & d2.Name, spath & "\" & d2.Name
			str = "RMDir """ & dpath & "\" & d2.Name & """"
			out2.writeline str
		next
	end if
end sub
 
set fs = createobject("Scripting.FileSystemObject")
 
instdir = wscript.arguments(0)
rootdir = wscript.arguments(1)
filename1 = wscript.arguments(2)
filename2 = wscript.arguments(3)
 
set out1 = fs.createtextfile(filename1, true)
set out2 = fs.createtextfile(filename2, true)
 
dorecurse instdir, rootdir
 
out1.close
out2.close