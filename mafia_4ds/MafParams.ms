MafParams_def = attributes "MafParams" attribID:#(0x4c8354c9, 0x47113d19)
(
	parameters main
	(
		objectType type:#string default:"mesh"


		 --only visual types
		renderFlags type:#integer default:0    
		renderFlags2 type:#integer default:42
		cullFlags type:#integer default:9
		userParams type:#string  default:""

		--LOD
		lodDist type:#float default:0.0
		dontOptimize type:#boolean default:false


		--Portal
		nearRange type:#float default:0.0
		farRange type:#float default:10.0


		--Billboard
		rotAxis type:#integer default:1
		rotMode type:#integer default:1
	)	
)