/*------------------------------------------------------------------------
File      : organismeSocial.p
Purpose   :
Author(s) : kantena  -  2017/06/20
Notes     : vient de lstorsoc_srv.p
------------------------------------------------------------------------*/
using parametre.pclie.parametrageTypeCentre.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{organismeSocial/include/organismeSocial.i}

procedure creationTT private:
    /*------------------------------------------------------------------------------
    Purpose: creation enregistrement dans table ttOrganismeSocial a partir
             du buffer de la table orsoc en parametre
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer orsoc for orsoc.

    create ttOrganismeSocial.
    outils:copyValidLabeledField(buffer orsoc:handle, buffer ttOrganismeSocial:handle).
    assign ttOrganismeSocial.cLibelleAdresse = 
               (if ttOrganismeSocial.cAdresseCentre     > "" then trim(ttOrganismeSocial.cAdresseCentre)     + " " else "")
             + (if ttOrganismeSocial.cComplementAdresse > "" and ttOrganismeSocial.cComplementAdresse <> "." 
                                                             then trim(ttOrganismeSocial.cComplementAdresse) + " " else "")
             + (if ttOrganismeSocial.cCodePostal        > "" then trim(ttOrganismeSocial.cCodePostal)        + " " else "")
             + ttOrganismeSocial.cVille
    .
end procedure.

procedure getOrganismeSocial:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beOrganismeSocial.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCentre as character no-undo.
    define output parameter table for ttOrganismeSocial.

    define variable voTypeCentre as class parametrageTypeCentre no-undo.

    empty temp-table ttOrganismeSocial.
    voTypeCentre = new parametrageTypeCentre().
    /** Paramétrage : Gestion des SIE / Fiche 0905/0081 **/
    if lookup(pcTypeCentre, "CDI,CDA,ODB,OTS,ORP") > 0
    and can-find(first orsoc no-lock where orsoc.tporg = "SIE")
    and voTypeCentre:isDbParameter
    then if voTypeCentre:isGesTypeCentre()
        then run getSieActif(pcTypeCentre).         // La gestion des SIE est activée
        else run getSiePreparation(pcTypeCentre).   // La gestion des SIE est en cours de préparation dans les écrans de saisie en comptabilité
    else run getSieFiche09050081(pcTypeCentre).
end procedure.

procedure getSieActif private:
    /*------------------------------------------------------------------------------
    Purpose: Renvoie la liste si la gestion SIE ests activée
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCentre as character no-undo.
    define buffer orsoc   for orsoc.
    define buffer vbOrsoc for orsoc.

    if pcTypeCentre <> "CDA"
    then for each orsoc no-lock
        where orsoc.tporg = pcTypeCentre
          and orsoc.mssup = 0
          and (orsoc.sie-ass = ? or orsoc.sie-ass = "")
          and can-find(first vbOrsoc no-lock
                       where vbOrsoc.tporg = "SIE"
                         and vbOrsoc.ident = orsoc.ident):
        run creationTT(buffer orsoc).
    end.
    else for each orsoc no-lock
        where orsoc.tporg = pcTypeCentre
          and orsoc.mssup = 0:
        if can-do("001,002,003", orsoc.ident) then run creationTT (buffer orsoc).
    end.
end procedure.

procedure getSiePreparation private:
    /*------------------------------------------------------------------------------
    Purpose: Renvoie la liste si gestion SIE en cours de préparation
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCentre as character no-undo.
    define buffer orsoc   for orsoc.
    define buffer vbOrsoc for orsoc.

    if pcTypeCentre <> "CDA"
    then for each orsoc no-lock
        where orsoc.TpOrg = pcTypeCentre
          and orsoc.mssup = 0
          and not can-find(first vbOrsoc no-lock
                           where vbOrsoc.tporg = "SIE"
                             and vbOrsoc.ident = orsoc.ident):
        run creationTT (buffer orsoc).
    end.
    else for each orsoc no-lock
        where orsoc.TpOrg = pcTypeCentre
          and orsoc.mssup = 0:
        if not can-do("001,002,003", orsoc.ident) then run creationTT(buffer orsoc).
    end.
end procedure.

procedure getSieFiche09050081 private:
    /*------------------------------------------------------------------------------
    Purpose: Liste des SIE si type de centre n'est pas dans la liste "CDI,CDA,ODB,OTS,ORP"
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeCentre as character no-undo.
    define buffer orsoc  for orsoc.

    for each orsoc no-lock
       where Orsoc.TpOrg = pcTypeCentre
         and Orsoc.mssup = 0:
        run creationTT(buffer orsoc).
    end.
end procedure.
