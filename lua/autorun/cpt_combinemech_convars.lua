/*
	Cpt. Hazama Notes:

	Most of this mod is untouched to preserve the original functionality. All I have done is renamed some stuff,
	fixed some bugs, revamped some features to make them better, and the addition of new mechs/options. I played
	with this mod a lot when it first came out before GMod 13, so fixing it up and re-releasing it for everyone
	to enjoy again means a lot. If Sakarias wants me to remove this I will, though I would hope that he wouldn't
	as all of his mods are GMod classics and even to this day hold up as some of the best!
*/

CreateConVar("sv_combinemech_disablemodifiers",0,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY})
CreateConVar("sv_combinemech_maxhealth",400,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY})
CreateConVar("sv_combinemech_maxshield",100,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY})
CreateConVar("sv_combinemech_maxhoverheight",1000,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY})
CreateConVar("sv_combinemech_allowwepswhileflying",0,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_NOTIFY})