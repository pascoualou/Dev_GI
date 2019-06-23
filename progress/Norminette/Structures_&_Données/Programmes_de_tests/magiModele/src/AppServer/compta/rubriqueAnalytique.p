/*-----------------------------------------------------------------------------
File        : paramBudgetLocatif.p
Purpose     :
Author(s)   : DMI 20180326
Notes       : à partir de adb/src/prmcl/pclbudlo.p
derniere revue: 2018/04/23 - phm: OK
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{compta/include/rubriqueAnalytique.i}

procedure getRubriqueAnalytique:
    /*------------------------------------------------------------------------------
    Purpose: chargement de la liste des rubriques analytiques 
    Notes  : Service externe
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeMandat as character no-undo.
    define input  parameter pcTypeCharge  as character no-undo.
    define input  parameter pcNumeroCompte as character no-undo.
    define output parameter table for ttRubriqueAnalytique.

    define buffer alrubhlp for alrubhlp.
    define buffer alrub for alrub.

    empty temp-table ttRubriqueAnalytique.
    for each alrubhlp no-lock
        where alrubhlp.soc-cd = integer(mtoken:cRefPrincipale)
          and alrubhlp.cdlng  = mtoken:iCodeLangueSession
      , first alrub no-lock
        where alrub.soc-cd = alrubhlp.soc-cd
          and alrub.rub-cd = alrubhlp.rub-cd
          and alrub.ssrub-cd = alrubhlp.ssrub-cd
          and (alrub.profil-cd = 0 or alrub.profil-cd = if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then 20 else 90)
          and (if pcTypeCharge > ""   then alrub.type-chg matches pcTypeCharge else alrub.type-chg = alrub.type-chg)
          and (if pcNumeroCompte > "" then alrub.cpt-cd   begins pcNumeroCompte else alrub.cpt-cd = alrub.cpt-cd)
          and  alrub.dafin = ?:
        create ttRubriqueAnalytique.
        outils:copyValidField(buffer alrubhlp:handle, buffer ttRubriqueAnalytique:handle).  // copy table physique vers temp-table        
    end.

end procedure.
