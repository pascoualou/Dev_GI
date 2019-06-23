/*------------------------------------------------------------------------
File        : GI_alimaj.p
Purpose     : Transferts: Mise a jour de la table des traces pour la Gestion
Author(s)   : GI PC    - 1997/01/31
              kantena  - 2016/11/28
Notes       :
09/01/2003 : Modification boucle for each maj de suppression : EXCLUSIVE-LOCK enlev‚
             et remplacé par FIND EXCLUSIVE-LOCK NO-WAIT dans la boucle (Pb Dead Lock en multi user)
02/10/2012 : BNP : pas de création de trace maj SADB car pas de transfert Site Central

Tables      : isoc ctrat maj
----------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure majTrace:
    /*--------------------------------------------------------------------------
    Purpose: Procedure pour tester si on peut créer la trace dans Maj
    Note   : Service utilisé par imble_crud.p
             Avant de rechercher s'il existe une trace précédente pour le code
             enregistrement, il faut interroger la table isoc de la base inter
             pour savoir si il y a un transfert possible sur cet enregistrement.
    ---------------------------------------------------------------------------*/
    define input parameter piCodeSociete as integer   no-undo.
    define input parameter pcNomLogique  as character no-undo.
    define input parameter pcNomTable    as character no-undo.
    define input parameter pcIdentifiant as character no-undo.

    define variable vlCreationMaj as logical  no-undo.
    define variable viTime        as integer  no-undo.
    define buffer isoc  for isoc.
    define buffer maj   for maj.

    for first isoc no-lock
        where isoc.soc-cd = piCodeSociete
          and isoc.fg-dispo:
        // - si trace Titre de copro (01004) ou Mutation (01005) ne pas créer la trace si le mandat maitre est déjà topé
        // - Inversement si trace Mandat Syndic (01003) RAZ des traces 01004 & 01005 associées au mandat
        if /* pcNomLogique = "SADB" and */ pcNomTable = "ctrat"
        then do:
            run isCreTrace (piCodeSociete, pcIdentifiant, output vlCreationMaj).
            if vlCreationMaj = false then return.
        end.
        /* Recherche s'il existe une trace précédente pour le code enregistrement */
        find first maj exclusive-lock
            where maj.soc-cd = piCodeSociete
              and maj.nmlog  = pcNomLogique
              and maj.nmtab  = pcNomTable
              and maj.cdenr  = pcIdentifiant no-wait no-error.
        if locked maj then do:
            mError:createError({&error}, 211652, pcNomTable + ': ' + pcIdentifiant).
            return.
        end.
        viTime = integer(replace(string(time, "HH:MM:SS"), ':', '')).
        if not available maj
        then do:
            create maj.
            assign
                maj.soc-cd   = piCodeSociete
                maj.nmlog    = pcNomLogique
                maj.nmtab    = pcNomTable
                maj.cdenr    = pcIdentifiant
                maj.jcremvt  = today
                maj.ihcremvt = viTime
            .
        end.
        assign
            maj.jmodmvt  = today
            maj.ihmodmvt = viTime
            Maj.jTrf     = ?
            Maj.ihTrf    = ?
        .
        if /* pcNomLogique = "SADB" and */ pcNomTable = "ctrat"
        then run razTrace(piCodeSociete, pcIdentifiant).
    end.
end procedure.

procedure isCreTrace private:
    /*--------------------------------------------------------------------------
    Purpose: Procedure pour tester si on peut créer la trace dans Maj
    Note   :
    ---------------------------------------------------------------------------*/
    define input  parameter piCodeSociete as integer   no-undo.
    define input  parameter pcIdentifiant as character no-undo.
    define output parameter plCreationMaj as logical   no-undo initial true.

    define variable viNumeroMandat as integer   no-undo.

    define buffer ctrat    for ctrat.
    define buffer vbCtrat for ctrat.
    define buffer maj      for maj.

    if piCodeSociete = 02053         /* Pas de trace maj SADB pour BNP car pas de transfert Site Central */
    then plCreationMaj = false.
    else for first ctrat no-lock
        where ctrat.nodoc = integer(pcIdentifiant)
          and (ctrat.tpcon = {&TYPECONTRAT-titre2copro} or ctrat.tpcon = {&TYPECONTRAT-mutation}):
        viNumeroMandat = integer(substring(string(ctrat.nocon, "9999999999"), 1 , 5, 'character')).
        for first vbCtrat no-lock
            where vbCtrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and vbCtrat.nocon = viNumeroMandat
          , first maj no-lock
            where maj.soc-cd = piCodeSociete
              and maj.nmlog  = "SADB"
              and maj.nmtab  = "ctrat"
              and maj.cdenr  = string(vbCtrat.nodoc, '>>>>>>>>9'):
            plCreationMaj = false.
            return.
        end.
    end.

end procedure.

procedure razTrace private:
    /*--------------------------------------------------------------------------
    Purpose: Procedure pour supprimer les traces Titre copro et mutation si l'on vient
             de créer la trace pour le mandat maitre
    Note   :
    ---------------------------------------------------------------------------*/
    define input  parameter piCodeSociete as integer   no-undo.
    define input  parameter pcIdentifiant as character no-undo.

    define variable viNumeroMandat as integer   no-undo.
    define variable viContratMin   as integer   no-undo.
    define variable viContratMax   as integer   no-undo.

    define buffer ctrat   for ctrat.
    define buffer vbCtrat for ctrat.
    define buffer maj     for maj.
    define buffer vbMaj   for maj.

    for first ctrat no-lock
        where ctrat.nodoc = integer(pcIdentifiant)
          and ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}:
        assign    // On notera la modification de travail direct sur les entiers au lieu de conversion chaîne de caractères
            viNumeroMandat = ctrat.nocon
            viContratMin = viNumeroMandat * 100000 +     1 /* kantena 2017/09/21 integer(string(viNumeroMandat, "99999") + "00001") modif SY le 18/09/2008 */
            viContratMax = viNumeroMandat * 100000 + 99999 /* kantena 2017/09/21 integer(string(viNumeroMandat, "99999") + "99999") modif SY le 18/09/2008 */
        .
        for each vbMaj no-lock
            where vbMaj.soc-cd = piCodeSociete
              and vbMaj.nmlog  = "SADB"
              and vbMaj.nmtab  = "ctrat"
          , first vbCtrat no-lock
            where vbCtrat.nodoc = integer(vbMaj.cdenr)
              and (vbCtrat.tpcon = {&TYPECONTRAT-titre2copro} or vbCtrat.tpcon = {&TYPECONTRAT-mutation})
              and vbCtrat.nocon >= viContratMin and vbCtrat.nocon <= viContratMax
          , first maj exclusive-lock
            where maj.soc-cd = piCodeSociete
              and maj.nmlog  = "SADB"
              and maj.nmtab  = "ctrat"
              and maj.cdenr  = vbMaj.cdenr:
            {application/include/tracemaj.i piCodeSociete}
        end.
    end.

end procedure.

procedure majTraceCompta:
    /*--------------------------------------------------------------------------
    Purpose: a partir de cadb/gestion/soldmdt2.p procedure alimacpt
             todo a verifier si vraiment necessairte d'ajouter cette procedure ici 
    Note   : service externe
    ---------------------------------------------------------------------------*/
    define input parameter piCodeSociete as integer   no-undo.
    define input parameter pcNomLogique  as character no-undo.
    define input parameter pcNomTable    as character no-undo.
    define input parameter pcIdentifiant as character no-undo.
    define input parameter pdaCompta     as date      no-undo. 
    define input parameter pcGestCd      as character no-undo.
    define input parameter pcMandatCd    as character no-undo. 

    define variable viLongCleCom  as integer   no-undo.
    define variable viTime        as integer  no-undo.
    
    define buffer isoc  for isoc.
    define buffer maj   for maj.

    for first isoc no-lock
        where isoc.soc-cd = piCodeSociete
          and isoc.fg-dispo:
        
        //On recherche la longueur de la clé communes aux tables CECRSAI, CECRLN, CECRLNANA       
        viLongCleCom = length(string(pcIdentifiant)) - 6.
        
        //On regarde si une trace n'existe pas déjà pour CECRSAI
        //On la crée uniquement si elle n'existe pas. Sinon on metà jour les dates et heures de mise à jour et on réinitialiseles dates et heures de transfert à ?   
        find first maj exclusive-lock
            where maj.soc-cd = piCodeSociete
              and maj.nmlog  = pcNomLogique
              and maj.nmtab  = pcNomTable
              and maj.cdenr  begins substring(pcIdentifiant, 1, viLongCleCom) no-wait no-error.
        if locked maj then do:
            mError:createError({&error}, 211652, pcNomTable + ': ' + pcIdentifiant).
            return.
        end.
        viTime = integer(replace(string(time, "HH:MM:SS"), ':', '')).
        if not available maj
        then do:
            create maj.
            assign
                maj.soc-cd    = piCodeSociete
                maj.nmlog     = pcNomLogique
                maj.nmtab     = pcNomTable
                maj.cdenr     = substring(pcIdentifiant, 1, viLongCleCom) + string(0,">>>>>9")
                maj.jcremvt   = today
                maj.ihcremvt  = viTime
                maj.DateComp  = pdaCompta
                maj.Gest-Cle  = pcGestCd
                maj.Mandat-Cd = pcMandatCd                
            .
        end.
        assign
            maj.jmodmvt  = today
            maj.ihmodmvt = viTime
            Maj.jTrf     = ?
            Maj.ihTrf    = ?
        .
        
        // On regarde si des traces n'existent pas déjà pour les écritures non analytiques associées à l'entête mise à jour et dans ce cason les supprime                                                 */                
        for each maj exclusive-lock
            where maj.soc-cd = piCodeSociete
            and maj.nmlog    = pcNomLogique
            and maj.nmtab    = "CECRLN"
            and maj.cdenr    begins substring(pcIdentifiant, 1, viLongCleCom):
            delete maj.
        end. 
    
    end.
end procedure.


