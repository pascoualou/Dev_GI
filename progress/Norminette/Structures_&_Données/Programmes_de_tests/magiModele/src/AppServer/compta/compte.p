/*------------------------------------------------------------------------
File        : compte.p
Description :
Author(s)   : RFA - 2017/01/13
Notes       :
derniere revue: 2018/03/23 - phm
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{compta/include/listeCompte.i}

procedure getListeCompte:
    /*--------------------------------------------------------------------------
    Purpose:
    Note   : service utilisé par beCompte.cls
    ---------------------------------------------------------------------------*/
    define input  parameter poCollection as class collection no-undo.
    define output parameter table for ttListeCompte.

    define variable viNumeroSociete    as integer   no-undo.
    define variable vcRegroupement     as character no-undo.
    define variable viTypeCompteDebut  as integer   no-undo.
    define variable viTypeCompteFin    as integer   no-undo.

    define buffer ccpt for ccpt.

    assign
        viNumeroSociete   = poCollection:getInteger  ('iNumeroSociete')  
        vcRegroupement    = poCollection:getCharacter('cRegroupement')   
        viTypeCompteDebut = poCollection:getInteger  ('iTypeCompteDebut')
        viTypeCompteFin   = poCollection:getInteger  ('iTypeCompteFin')  
    .
    for each ccpt no-lock
        where ccpt.soc-cd      = viNumeroSociete
          and ccpt.coll-cle    = vcRegroupement
          and ccpt.libtype-cd >= viTypeCompteDebut and ccpt.libtype-cd <= viTypeCompteFin
        break by ccpt.cpt-cd:
        if first-of(ccpt.cpt-cd) then do:
            create ttListeCompte.
            assign
                ttListeCompte.iNumeroSociete = viNumeroSociete
                ttListeCompte.cRegroupement  = vcRegroupement
                ttListeCompte.iTypeCompte    = ccpt.libtype-cd
                ttListeCompte.cCompte        = ccpt.cpt-cd
                ttListeCompte.cLibelleCompte = ccpt.lib
            .
        end.
    end.

end procedure.
