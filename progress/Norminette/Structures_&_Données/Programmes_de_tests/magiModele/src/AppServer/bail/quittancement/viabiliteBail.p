/*------------------------------------------------------------------------
File        : viabiliteBail.p
Purpose     :
Author(s)   : GGA 2018/10/03
Notes       : 
----------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/param2locataire.i}

using parametre.pclie.parametrageRubriqueQuittHonoCabinet.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}

{bail/quittancement/procedureCommuneQuittance.i}    // procédures chgMoisQuittance, isRubMod

procedure ctrlQuittance:
    /*------------------------------------------------------------------------------
    Purpose: controle quittance
    Notes  : extrait de adb/tach/prmobqtt_srv.p 
    ------------------------------------------------------------------------------*/    
    define input parameter poCollectionContrat as class collection no-undo.

    define variable viNumeroContrat            as int64     no-undo.
    define variable vcTypeContrat              as character no-undo.
    define variable viNumeroMandat             as int64     no-undo.
    define variable viMoisModifiable           as integer   no-undo.
    define variable viMoisEchu                 as integer   no-undo.
    define variable viNumeroUL                 as integer   no-undo.
    
    define variable vlUlExiste as logical no-undo.

    assign
        viNumeroContrat  = poCollectionContrat:getInt64("iNumeroContrat")
        vcTypeContrat    = poCollectionContrat:getCharacter("cTypeContrat")
        viNumeroMandat   = truncate(viNumeroContrat / 100000, 0)
        viNumeroUL       = truncate((viNumeroContrat modulo 100000) / 100, 0)  // integer(substring(string(piNumeroContrat, "9999999999"), 6 ,3))
        viMoisModifiable = poCollectionContrat:getInteger("iMoisModifiable")
        viMoisEchu       = poCollectionContrat:getInteger("iMoisEchu")
    .

    define buffer ctrat for ctrat.
    define buffer unite for unite.
    define buffer cpuni for cpuni.

    find first ctrat no-lock
         where ctrat.tpcon = vcTypeContrat
           and ctrat.nocon = viNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 1000847, substitute("&2&1&3", separ[1], viNumeroContrat, vcTypeContrat)). //Contrat N° &1 de type &2 non trouvé
        return.
    end.
    if ctrat.dtree <> ? then return. 

    /* Ajout SY le 25/09/2014 - fiche 0814/0054 : vérifier qu'il y a des lots dans l'UL */
    for first unite no-lock
        where unite.nomdt = viNumeroMandat
          and unite.noapp = viNumeroUL
          and unite.noact = 0
      , first cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp:
        vlUlExiste = yes.
    end.
    if not vlUlExiste then return.

    if viMoisModifiable = ?                    //si apres maj depuis collection non renseigne, c'est que le chargement de ces dates n'a pas encore ete fait
    then do:
        run chgMoisQuittance (viNumeroMandat, input-output poCollectionContrat).     
        assign 
            viMoisModifiable = poCollectionContrat:getInteger("iMoisModifiable")
            viMoisEchu       = poCollectionContrat:getInteger("iMoisEchu")
        .
    end.
    
    if not can-find(first equit no-lock where equit.noloc = viNumeroContrat)
    then do:
        mError:createErrorGestion({&information}, 105671, ""). //Ce locataire n'a plus d'avis d'échéance.%s Voulez-vous les régénérer à partir de l'offre ?
        return.
    end.
    if not can-find(first equit no-lock    /* Ajout SY le 05/01/2010 - fiche 1209/0212: avis d'échéance erronés */
                    where equit.noloc = viNumeroContrat
                      and (   (equit.cdter = {&TERMEQUITTANCEMENT-avance} and equit.msqtt >= viMoisModifiable)
                           or (equit.cdter = {&TERMEQUITTANCEMENT-echu}   and equit.msqtt >= viMoisEchu)))
    then do: 
        mError:createError({&information}, 1000806).  //Les avis d'échéance de ce locataire sont périmés. Voulez-vous les supprimer et régénérer le quittancement à partir de l'offre ?
        return.
    end.
 
end procedure.
