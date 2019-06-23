/*------------------------------------------------------------------------
File        : supEvenementiel.p
Purpose     : Suppression des courriers lies à un identifiant 
Author(s)   : AF 03/02/2005  -  GGA 17/12/06
Notes       : reprise adb/event/supident.p

 Historique des modifications                                          
 Nø  |    Date    |Auteur|                    Objet                      
0001 | 14/04/2006 |  SY  | 0404/0305 Ajout suppression Dossi & suivi   
0002 | 26/04/2006 |  SY  | 0404/0305 correction suplidoc               
0003 | 13/10/2006 |  SY  | correction LbCorUse -> ssdos.lbcor          
0004 | 27/04/2009 |  PL  | 1108/0331:ne plus supprimer docum si encore 
     |            |      | utilisé dans un lien lidoc.(pb pré-bail)    
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{outils/include/lancementProgramme.i}

procedure SupEvenementiel:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as int64     no-undo.    
    define input-output parameter poCollectionHandlePgm as class collection no-undo.
 
    define variable vhProc as handle no-undo.
 
 message "SupEvenementiel " piNumeroIdentifiant "// " pcTypeIdentifiant. 
 
    /*--> Suppression des Dossiers */
    vhProc = lancementPgm ("evenementiel/dossi_CRUD.p", poCollectionHandlePgm).
    run deleteDossiSurNoidt in vhProc(pcTypeIdentifiant, piNumeroIdentifiant).
 
    vhProc = lancementPgm ("evenementiel/ssdos_CRUD.p", poCollectionHandlePgm).
    run deleteSsdosSurNoidt in vhProc(pcTypeIdentifiant, piNumeroIdentifiant, input-output poCollectionHandlePgm).
  
    vhProc = lancementPgm ("evenementiel/event_CRUD.p", poCollectionHandlePgm).
    run deleteEventParType in vhProc("", 0, pcTypeIdentifiant, piNumeroIdentifiant).
    
    /*--> Suppression du suivi traitements */
    vhProc = lancementPgm ("evenementiel/suivi_CRUD.p", poCollectionHandlePgm).
    run deleteSuiviSurNoidt in vhProc(pcTypeIdentifiant, piNumeroIdentifiant).

end procedure.
