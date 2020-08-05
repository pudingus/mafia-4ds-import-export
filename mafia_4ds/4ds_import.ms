
struct MafiaTools_Import4ds (	

	--imports--
	Layers = MafiaTools_Layers,
	parser = MafiaTools_4dsParser,
	-----------
	
	godmat,
	filename,


	--n_mesh_array = #(),
	--n_normal_array = #(),

	--returns array of nodes
	fn CreateMesh mmesh mobj = (
		local nodes = #()		
		
		if mmesh.lods.count == 0 then (
			nodes[1] = Editable_mesh()
		)
		else (
			local lodId = 0
			for mlod in mmesh.lods do (	
				local lodNode = mesh mesh:mlod.mesh
				lodNode.wirecolor = color 0 0 0
				
				for j = 1 to lodNode.numFaces do (
					local matId = mlod.matIds[j]
					if matId == 0 then matId = godmat.numsubs
					setFaceMatID lodNode j matId
				)				
				
				if lodId > 0 then (  --todo: move to CreateObjects
					lodNode.name = "$lod" + (lodId as string) + "__" + mobj.name
					lodNode.parent = nodes[1]
					hide lodNode
				)

				if mmesh.lods.count > 1 then Layers.AddTo lodNode ("Lod"+(lodId as string))

				custAttributes.add lodNode MafParams_def baseObject:false 
				local gp = custAttributes.get lodNode mafParams_def baseObject:false

				gp.objectType = "Lod"
				gp.lodDist = mlod.distance
				gp.dontOptimize = true

				lodNode.material = godmat
				
				append nodes lodNode
				
				
				local cmod = CachedNormals()
				cmod.normals = mlod.normals
				addModifier lodnode cmod
				
				
				-- append n_mesh_array lodNode
				-- append n_normal_array mlod.normals
				
				lodId += 1
			)					
		)
		nodes
	),


	fn CreateMorph mmorph mobj mmesh nnode = (	
		local inc = -0.4
		local totalInc = inc	
		
		local baseMesh = mmesh.lods[1].mesh	
		local meshes = #()
		
		for chan in mmorph.sections do (
			local sectionMeshes = #()
					
			for i = 1 to mmorph.numTargets do (
				sectionMeshes[i] = copy baseMesh
			)
			
			for i = 1 to chan.vertices.count do (
				local vertId = chan.vertexLinks[i] + 1			
				local mvert = chan.vertices[i]
				
				for j = 1 to mvert.targets.count do (
					local target = mvert.targets[j]
					local vert = target.pos
					setVert sectionMeshes[j] vertId vert
				)
			)
			append meshes sectionMeshes	
			
		)
		
		local tmod = Morpher()
		addModifier nnode tmod
		tmod.Autoload_of_targets = 1
		
		--local sectionNames = #("mouth", "eyes", "brows")
		local sectionNames = #("A", "B", "C")
		local layerNames = #("layer A", "layer B", "layer C")
		
		local sectionId = 1
		local marker = 1
		
		for sectMesh in meshes do (
			local sectionName = sectionNames[sectionId]
			WM3_CreateMarker tmod marker layerNames[sectionId]
			
			local targetId = 1
			
			for targetMesh in sectMesh do (
				local tnode = mesh mesh:targetMesh
				tnode.material = godmat			
				local name = stringstream ""
				format "$morph %%" sectionName targetId to:name	
				tnode.name = name as string			
				tnode.transform = mobj.GetMatrix() * (transMatrix [totalInc, 0, 0])	
				tnode.parent = nnode
				
				hide tnode
				
				local finalId = (marker + targetId - 1)
				
				WM3_MC_BuildFromNode tmod finalId tnode				
				WM3_MC_SetName tmod finalId (sectionName + " " + (targetId as string))			
							
				targetId += 1			
				totalInc += inc	
			)
			marker = (sectionId * 10 + 1)
			sectionId += 1
		)
		
		WM3_SetCurrentMarker tmod 1		
	),




	fn CreateBillboard mbillboard nnode = (		
		custAttributes.add nnode MafParams_def baseObject:false
		local gp = custAttributes.get nnode MafParams_def baseObject:false

		gp.rotAxis = mbillboard.rotAxis + 1
		gp.rotMode = mbillboard.rotMode + 1
	),




	fn CreateGlow mglows mobj = (
		-- local nnode = point()
		-- nnode.constantscreensize = true
		-- nnode.box = true
		-- nnode.centermarker = true
		-- nnode.cross = false	
		
		-- local nnode = box length:0.1 width:0.1 height:0.1	
		-- nnode.wirecolor = color 248 128 0	
		
		
		local nnode = dummy()
		nnode.boxsize = [0.2, 0.2, 0.2]
		
		nnode
	),





	fn CreateMirror mmirror mobj = (
		nnode = mesh mesh:mmirror.mesh
	),




	fn CreateDummy mdummy mobj = (
		local dmin = mdummy.dmin
		local dmax = mdummy.dmax
		local nnode = dummy()
		nnode.boxsize = [(abs (dmin.x-dmax.x)), (abs (dmin.y-dmax.y)), (abs (dmin.z-dmax.z))]	
		
		hide nnode
			
		nnode
	),


	--returns array of nodes
	fn CreateSector msector mobj = (
		local nodes	= #()
		
		nodes[1] = mesh mesh:msector.mesh
		nodes[1].wirecolor = (color 255 199 0)	
		
		local portalId = 0
		for mportal in msector.portals do (
			local numverts = mportal.verts.count
			local portalNode = mesh numverts:numVerts
			portalNode.name = "$portal" + (formattedPrint portalId format:".2u") + "__" + mobj.name
			
			for v = 1 to numVerts do (
				local vert = mportal.verts[v]
				setVert portalNode v vert
			)
			local face = for v = 1 to numVerts collect v
			portalNode = convertToPoly portalNode
			polyop.createPolygon portalNode face

			portalNode.wirecolor = (color 255 0 199)
			portalNode.parent = nodes[1]		
			
			custAttributes.add portalNode MafParams_def baseObject:false
			local gp = custAttributes.get portalNode MafParams_def baseObject:false	
			
			gp.objectType = "Portal"
			gp.nearRange = mportal.nearRange
			gp.farRange = mportal.farRange		
			
			Layers.AddTo portalNode "Portals"
			
			append nodes portalNode
			
			portalId += 1
		)
		nodes
	),




	-- returns Node
	fn CreateTarget mtarget mobj = (
		local nnode = dummy()
		nnode.boxsize = [0.1, 0.1, 0.1]
		
		-- local nnode = TargetObject()
		
		-- local nnode = point()
		-- nnode.size = 0.1
		-- nnode.constantscreensize = false
		-- nnode.box = true
		-- nnode.centermarker = true
		-- nnode.cross = false
		-- nnode.wirecolor = color 28 122 210

		hide nnode
		
		nnode
	),

	fn CreateBone mbone mobj = (	
		--local nnode = dummy()
		--local size = 0.0
		--nnode.boxsize = [size, size, size]	
		
		--local nnode = box length:0.1 width:0.1 height:0.1	
		
		local nnode = bonesys.createBone [0,0,0] [0,0,0] [0,0,0]	
		nnode.width = 0.0
		nnode.height = 0.0		
		
		nnode.setBoneEnable false sliderTime	
		nnode.showlinks = true
		
		--format "  boneId: %\n" mbone.boneId	
				
		nnode
	),


	fn CreateMaterials mmats = (	
		if mmats.count > 0 then (
			pngio.ipngio.setType #gray8
			pngio.ipngio.setInterlaced false
			pngio.ipngio.setAlpha false
			godmat = multimaterial numsubs:(mmats.count+1)
			godmat[mmats.count+1] = undefined
			godmat.name = filename + " Materials"	

			for m = 1 to mmats.count do (
				local mmat = mmats[m]
				local mat = MafMat4()
				mat.name = "4dsMat"+(m as string)

				local flags = mmat.flags

				--Diffuse Map
				mat.diffuseMapEnable = (bit.get flags 19)

				mat.colored = (bit.get flags 28)
				mat.mipMapping = (bit.get flags 24)
				mat.twoSided = (bit.get flags 29)
				mat.animatedDiffuse = (bit.get flags 27)
				mat.animatedAlpha = (bit.get flags 26)

				--Environment Map
				mat.envMapEnable = (bit.get flags 20)

				mat.envOverlay = (bit.get flags 9)
				mat.envMultiply = (bit.get flags 10)
				mat.envAdditive = (bit.get flags 11)
				mat.YProj = (bit.get flags 13)
				mat.YDetail = (bit.get flags 14)
				mat.ZDetail = (bit.get flags 15)

				--Additional Effect
				mat.addEffect = (bit.get flags 16)
				mat.alphaMapEnable = (bit.get flags 31)
				mat.colorKey = (bit.get flags 30)
				mat.additiveMixing = (bit.get flags 32)

				mat.ambient = mmat.ambient
				mat.diffuse = mmat.diffuse
				mat.emission = mmat.emission
				mat.opacity = mmat.opacity*100			
				

				if mat.envMapEnable then (
					mat.envMapAmount = mmat.envMapAmount*100
					if mmat.envMapName != undefined then (
						mat.envMap = bitmaptex filename:mmat.envMapName name:mmat.envMapName
					)
				)
				
				if mmat.diffMapName != undefined then (
					mat.diffuseMap = bitmaptex filename:mmat.diffMapName name:mmat.diffMapName 
					showTextureMap mat on				

					if mat.alphaMapEnable and (mmat.alphaMapName != undefined) then (					
						mat.alphaMap = bitmaptex filename:mmat.alphaMapName	name:mmat.alphaMapName					
					)
				)						

				if mat.animatedDiffuse then (
					mat.animFrames = mmat.animFrames
					mat.animPeriod = mmat.animPeriod
				)

				godmat[m] = mat
			)
		)
	),

	TWorldBuffer = (
		struct TWorldBuffer (
			skinBuffer = #(),   --array of TObjPair
			targetBuffer = #(),  --array of TObjPair
			boneNodes = #(),   --array of nodes sorted in boneid order
			normalNodes = #(),    --array of nodes for modifier normals
			mafiaNodes = #()
		)
	),

	TObjPair = (
		struct TObjPair (
			mdefs,   --mafia object definitions
			nodes
		)
	),


	fn CreateSkins skinBuffer boneNodes  = (
		for pair in skinBuffer do (
			local mskins = pair.mdefs
			local nodes = pair.nodes			
			
			for q = 1 to nodes.count do (			
				local nnode = nodes[q]
				local mskin = mskins[q]
			
				local oskin = Skin()	
				oskin.bone_Limit = 2
				oskin.showNoEnvelopes = true
				addModifier nnode oskin				
				max modify mode			
				select nnode
				
				for i = 1 to boneNodes.count do (
					skinOps.AddBone oskin boneNodes[i] 1
				)
						
				for i = 1 to boneNodes.count do (			
					for j = 1 to nnode.numverts do (				
						skinOps.ReplaceVertexWeights oskin j i 0.0				
					)
				)
				
				local vertId = 1
				
				for i = 1 to mskin.vgroups.count do (
					local grp = mskin.vgroups[i]	
					local boneid1 = i
					local boneid2 = grp.boneId
					
					for j = 1 to grp.numW1Verts do (
						local weight = 1.0
						skinOps.SetVertexWeights oskin vertId boneid1 weight				
						
						vertId += 1
					)
					
					for weight in grp.weights do (		
						if boneid2 == 0 then skinOps.unNormalizeVertex oskin vertId true						
						skinOps.SetVertexWeights oskin vertId boneid1 weight
						
						if boneid2 != 0 then (
							skinOps.SetVertexWeights oskin vertId boneid2 (1.0 - weight)
						)
								
						vertId += 1
					)
				)
			)		
		)
		
		for boneNode in boneNodes do (
			boneNode.setBoneEnable true sliderTime
		)
	),

	fn CreateObjects mobjects = (	
		local buffer = TWorldBuffer()	
		
		for i = 1 to mobjects.count do (		
			local mobj = mobjects[i]		
			local nnode
			
			case mobj.objectType of (
				1: case mobj.visualType of (
					0: (  --standardmesh
						local mmesh = mobj.definitions[1]
						
						local nodes = #()
						if mmesh.instanceId == 0 then (
							nodes = CreateMesh mmesh mobj
						)
						else (
							nodes[1] = instance buffer.mafiaNodes[mmesh.instanceId]							
						)
												
						nnode = nodes[1]
					)
					2: (  --singlemesh
						local mmesh = mobj.definitions[1]
						local mskins = mobj.definitions[2]
						local nodes = CreateMesh mmesh mobj
						nnode = nodes[1]
									
						append buffer.skinBuffer (TObjPair mdefs:mskins nodes:nodes)
					)
					3: (  --singlemorph
						local mmesh = mobj.definitions[1]
						local mskins = mobj.definitions[2]
						local mmorph = mobj.definitions[3]
						local nodes = CreateMesh mmesh mobj
						nnode = nodes[1]
						
						append buffer.skinBuffer (TObjPair mdefs:mskins nodes:nodes)			
						
						CreateMorph mmorph mobj mmesh nnode
					)
					4: ( 
						local mmesh = mobj.definitions[1]
						local mbillboard = mobj.definitions[2]
						local nodes = CreateMesh mmesh mobj
						nnode = nodes[1]
						CreateBillboard mbillboard nnode
						
						Layers.AddTo nnode "Billboards"
						
						
						--append buffer.normalNodes
					)
					5: ( --morph
						local mmesh = mobj.definitions[1]
						local mmorph = mobj.definitions[2]
						local nodes = CreateMesh mmesh mobj
						nnode = nodes[1]			
						CreateMorph mmorph mobj mmesh nnode
					)
					6: (
						local mglows = mobj.definitions[1]
						nnode = CreateGlow mglows mobj
						Layers.AddTo nnode "Glows"
					)
					8: (
						local mmirror = mobj.definitions[1]
						nnode = CreateMirror mmirror mobj
					)
				)
				5: (
					local msector = mobj.definitions[1]
					nnode = (CreateSector msector mobj)[1]
					Layers.AddTo nnode "Sectors"
				)
				6: (
					local mdummy = mobj.definitions[1]
					nnode = CreateDummy mdummy mobj
					Layers.AddTo nnode "Dummies"
				)
				7: (
					local mtarget = mobj.definitions[1]
					nnode = CreateTarget mtarget mobj
					
					append buffer.targetBuffer (TObjPair mdefs:mtarget nodes:nnode)
				)
				10: (
					local mbone = mobj.definitions[1]
					nnode = CreateBone mbone mobj				
					Layers.AddTo nnode "Bones"
					
					buffer.boneNodes[mbone.boneId+1] = nnode
					
					--format "% | objId: % | boneid: %\n" mobj.name i mbone.boneid
				)
			)
			
			if mobj.cullFlags == 16 then (
				Layers.AddTo nnode "Disabled"
			)				

			nnode.name = mobj.name
			
			if mobj.parentId > 0 then (
				nnode.parent = buffer.mafiaNodes[mobj.parentId]
				nnode.transform = mobj.GetMatrix() * nnode.parent.transform					
			)
			else (
				nnode.transform = mobj.GetMatrix()
			)				

			custAttributes.add nnode MafParams_def baseObject:false
			local gp = custAttributes.get nnode MafParams_def baseObject:false

			gp.objectType = case mobj.objectType of (
				1: case mobj.visualType of (
					6: "Dummy"
					4: "Billboard"
					default: "Mesh"
				)
				5: "Sector"
				default: "Dummy"
			)
					
			gp.renderFlags = mobj.renderFlags
			gp.renderFlags2 = mobj.renderFlags2
			gp.cullFlags = mobj.cullFlags
			if mobj.strParams != undefined then gp.strParams = mobj.strParams
			
			append buffer.mafiaNodes nnode
		)
		
		buffer
	),

	fn LinkTargets targetBuffer mafiaNodes = (
		for pair in targetBuffer do (
			local mtarget = pair.mdefs
			local targetNode = pair.nodes
			
			custAttributes.add targetNode MafParams_def baseObject:false
			local gp = custAttributes.get targetNode MafParams_def baseObject:false
			
			for linkId in mtarget.linkIds do (
				append gp.targetLinks mafiaNodes[linkId]
			)
			
			--for linkId in mtarget.linkIds do (
			--	local lnode = mafiaNodes[linkId]
			--	lnode.rotation.controller = LookAt_Constraint()
			--	lnode.rotation.controller.relative = true
			--	lnode.rotation.controller.viewline_length_abs = false
			--	lnode.rotation.controller.appendTarget nnode 50
			--)		
			
			print gp.targetLinks		
		)
	),

	fn ImportNormals normalNodes = (
		max modify mode
		select n_mesh_array

		local norm = Edit_Normals()
		norm.displayLength = 0.1
		norm.SelLevel = #object
		modpanel.addmodtoselection norm
		

		--print (n_mesh_array.count as string)
		--print (n_normal_array.count as string)

		disableRefMsgs()  --makes a huge difference, 41 seconds with vs. 904 seconds without
		for i = 1 to n_mesh_array.count do
		(
			--print (n_normal_array[i].count as string)
			local p = n_mesh_array[i]

			local pn = n_normal_array[i]
			
			for i = 1 to p.numverts do
			(
				local vert_sel = #{i} --define a bitArray specifying vertex 1
				local normal_sel = #{} --define an empty bitArray to store the result
				--call the method with the two bitArrays passed by-reference:
				norm.ConvertVertexSelection &vert_sel &normal_sel node:p
				n = (normal_sel as array)[1]
				--norm.SetNormalExplicit n node:p
				norm.setnormal n pn[i] node:p
			)

			local vert_sel = #{1..p.numverts}
			local normal_sel = #{}
			norm.ConvertVertexSelection &vert_sel &normal_sel node:p
			norm.MakeExplicit selection:normal_sel node:p
		)


		enableRefMsgs()

		norm.RebuildNormals()
		clearSelection()
	),	

	------------------------
	---------MAIN-----------
	------------------------
	fn Import4ds file = (
		
		--delete $*
		--gc()
		
		if getCommandPanelTaskMode() == #modify then (
			setCommandPanelTaskMode #create
		)
		
		filename = getFilenameFile file

		format "importing: %\n" file
		local start = timeStamp()		

		gc light:true

		local used_start = (heapsize - heapfree) / 1024.0

		local f = fopen file "rb"			
		local m4ds = parser.Read4ds f
		fclose f

		if m4ds == undefined then (
			messageBox "This file cannot be imported. Unknown version or format." icon:#critical			
		)
		else (	
			-- if MafiaTools.editName.text == "" then (
			-- 	MafiaTools.editName.text = filename		
			-- )				
			with redraw off (			
				CreateMaterials m4ds.materials
				local buffer = CreateObjects m4ds.objects	
				

				
				-- if MafiaTools.importNormals.checked == true then (
				-- 	ImportNormals()			
				--)
				
				--LinkTargets buffer.targetBuffer
				
				CreateSkins buffer.skinBuffer buffer.boneNodes
				
				Layers.Hide #("Disabled")
				--Layers.HideLods #{1..9}											
			)	

			CompleteRedraw()
			gc light:true
			
			local end = timeStamp()		
			if end < start then end += 86400000 --timing over midnight
			local dur = (end - start) / 1000.0	

			local used_end = (heapsize - heapfree) / 1024.0
			format "memory used ~ % KiB\n" (used_end - used_start)

			

			local message = "Importing took " + (dur as string) + " seconds\n"
			format message
			--messageBox message
			
			dur
		)	
		
		
		
	)


)
--MafiaTools_Import4ds = MafiaTools_Import4ds()