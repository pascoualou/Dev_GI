/*---------------------------------------------------------------------------
File      : ctsuptie.p
Purpose   : Contrôles avant suppression d'un role 
Author(s) : SY 13/01/2004  -  GGA 2018/04/18
Notes     : reprise adb/lib/ctsuprol.p

| 0001 | 28/09/2004 |   SY   |0104/0541 - gestion des couples               |
|      |            |        |ajout controle table litie                    |
| 0002 | 12/04/2006 |   SY   | 0404/0305 adaptation pour les PURGES (compta)| 
| 0003 | 05/05/2006 |   SY   | 0404/0305 ajout tache imm cle magnétique/bip | 
| 0004 | 09/08/2006 |   SY   | retrait du formatage roles.norol "99999"     | 
| 0005 | 10/04/2012 |   PL   | 0312/0009 message "suppr. impossible" un peu | 
|      |            |        | plus précis.                                 |
---------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}

function numeroImmeuble return int64 private(piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.
    return 0.

end function.

procedure controleTiers:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :   
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroTiers    as int64     no-undo.
    define input  parameter plAfficheMessage as logical   no-undo.
    define output parameter pcCodeRetour     as character no-undo.

    define variable vcMessageErreur as character no-undo.

    define buffer vbroles for roles.
    define buffer litie   for litie.
    define buffer tache   for tache.

    /* Le tiers ne doit pas avoir de role */
    for first vbroles no-lock
        where vbroles.notie = piNumeroTiers:
        if plAfficheMessage
        then do:
            /* suppression impossible. Le tiers %1 est rattache au role %2 */
            vcMessageErreur = outilTraduction:getLibelle(104432) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108482), 
                                                           substitute('&2&1&3', separ[1], piNumeroTiers, outilTraduction:getLibelleProg("O_ROL", vbroles.tprol))).
            mError:createError({&error}, vcMessageErreur).
        end.
        pcCodeRetour = "01".
        return.
    end.
    /* Le tiers ne doit pas faire partie d'un couple */
    for first litie no-lock
        where litie.noind = piNumeroTiers:
        if plAfficheMessage
        then do:
            /* suppression impossible. Le tiers %1 est rattache au couple %2 */
            vcMessageErreur = outilTraduction:getLibelle(104432) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(109053), 
                                                           substitute('&2&1&3', separ[1], piNumeroTiers, litie.notie)).
            mError:createError({&error}, vcMessageErreur).
        end.
        pcCodeRetour = "02".
        return.
    end.
    /* Il ne doit pas être rattaché à un BIP immeuble */
    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
          and integer(tache.pdges) = piNumeroTiers:
        if plAfficheMessage
        then do:
            /* suppression impossible. Le tiers %1 est propriétaire d'une carte magnétique de l'immeuble %2*/
            vcMessageErreur = outilTraduction:getLibelle(104432) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110043), 
                                                           substitute('&2&1&3', separ[1], piNumeroTiers, numeroImmeuble(tache.nocon, tache.tpcon))).
            mError:createError({&error}, vcMessageErreur).
        end.
        pcCodeRetour = "03".
        return.
    end. 
    pcCodeRetour = "00".

end procedure.
