/*------------------------------------------------------------------------
    File        : mode2gestionFournisseurLoyer.i
    Purpose     : Variables préprocesseur des modes de gestion  des fournisseurs de loyer (sous-location)
    Author(s)   : spo- 2018/09/04
    Notes       : Paramètre sys_pr "SLMOD" du module optionnel pclie "GESFL"
  ----------------------------------------------------------------------*/
// RESIDE ETUDES (client parti)
&GLOBAL-DEFINE MODELE-ResidenceLocative-ComptaSociete       "00001"
// 03028 ee 03062 LCL
&GLOBAL-DEFINE MODELE-LotIsole-ComptaSociete                "00002"
// 01501 Eurostudiome (client parti) & Standard sous-location
&GLOBAL-DEFINE MODELE-ResidenceLocative-ComptaAdb           "00003"
// 02053 BNP
&GLOBAL-DEFINE MODELE-ResidenceLocativeEtDeleguee-ComptaAdb "00004"

