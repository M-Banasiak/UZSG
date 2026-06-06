extends Node

enum Factions {fcRazemki, fcLibki, fcNaziole, fcKlechy, fcPlayer}
const faction_dict: Dictionary = {Factions.fcRazemki: "Razemki",
								  Factions.fcLibki: "Libki", 
								  Factions.fcNaziole: "Naziole", 
								  Factions.fcKlechy: "Klechy", 
								  Factions.fcPlayer: "Player"}

enum ObjectType {otNpc, otPlayer, otWall, otActiveObject, otCorpse}

enum HitData {htStartPos, htDirection, htPower, htPenetration, htAttacker, htFaction, htDistance, 
			  htIsGlancing, htTarget}
