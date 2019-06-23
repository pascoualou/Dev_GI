/*------------------------------------------------------------------------
File        : etat2traitement.i
Purpose     : Variables préprocesseur pour les phases des traitements (charges, appels de fonds...)
Author(s)   : GI SPo - 2018/09/06
Notes       : sys_pr "ETTRT" / champ trfpm.ettrt
------------------------------------------------------------------------*/
&GLOBAL-DEFINE ETATTRAITEMENT-NonTraite                        "00001"
&GLOBAL-DEFINE ETATTRAITEMENT-EmisEnAttenteIntegration         "00002"
&GLOBAL-DEFINE ETATTRAITEMENT-Traite                           "00003"
&GLOBAL-DEFINE ETATTRAITEMENT-RetirageDemande                  "00011"
&GLOBAL-DEFINE ETATTRAITEMENT-RetirageEmisEnAttenteIntegration "00012"
&GLOBAL-DEFINE ETATTRAITEMENT-RetirageTraite                   "00013"
// traité mais pas dans la référence en cours MaGI (ex : duplication d'une autre ref) donc retirage impossible
&GLOBAL-DEFINE ETATTRAITEMENT-TraiteEnExterne                  "00099"
