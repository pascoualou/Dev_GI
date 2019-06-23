/*------------------------------------------------------------------------
File        : ged/rechercheGed.p
Purpose     :
Description :
Author(s)   : LGI/  -  2017/03/13
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{role/include/typeRole.i}
{ged/include/libged.i}
{ged/include/recherche.i}
{ged/include/visibiliteExtranet.i}
{ged/include/documentGidemat.i}
{application/include/glbsepar.i}

&SCOPED-DEFINE MAXRETURNEDROWS  2000
define variable giNumSeq     as integer          no-undo.
define variable goCollection as class collection no-undo.

define temp-table ttTypeDocument no-undo
    field orig-cd        as character
    field cLibelle       as character
    field typdoc-cd      as integer
    field gidemat-typdoc as character
    field typedossier    as character
    field theme-cd       as character
    index idx2 orig-cd gidemat-typdoc
.
define temp-table ttRequete no-undo
    field cTypeDocument     as character
    field cMandat           as character
    field cTiers            as character
    field cNumeroTraitement as character
    field cChemise          as character
    field cImmeuble         as character
    field cLot              as character
    field cObjet            as character
    field cAnneeMois        as character
    field cNumeroSociete    as character
    field daDebut           as date
    field daFin             as date
.
define temp-table ttRgrpTiers no-undo
    field cColl-Cle as character
    field cCpt-cd   as character
.
define temp-table ttTiers no-undo
    field coll-cle  as character
    field cpt-cd    as character
    field mandat-cd as integer
.

function fIsNull returns logical(pcString as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.

end function.
function fIsNotNull returns logical(pcString as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return trim(pcString) > "".

end function.

function fCreatettTiers returns logical(pcCle as character, pcCpt as character, piMandat as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    create ttTiers.
    assign
        ttTiers.coll-cle  = pcCle
        ttTiers.cpt-cd    = pcCpt
        ttTiers.mandat-cd = piMandat
    .
end function.

function fCreateRegroupement returns logical(pcColl as character, pcCpt as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    create ttRgrpTiers.
    assign
        ttRgrpTiers.cColl-Cle = pcColl
        ttRgrpTiers.cCpt-cd   = pcCpt
    .
end function.

function serialise returns character (buffer pbttrequete for ttRequete):
/*------------------------------------------------------------------------------
Purpose:     TODO - a supprimer quand versement.p corrigé
Notes:
------------------------------------------------------------------------------*/
    if available pbttrequete
    then return substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9|'
                   , pbttrequete.cTypeDocument
                   , pbttrequete.cMandat
                   , pbttrequete.cTiers
                   , pbttrequete.cNumeroTraitement
                   , pbttrequete.cChemise
                   , pbttrequete.cImmeuble
                   , pbttrequete.cLot
                   , pbttrequete.cObjet
                   , pbttrequete.cAnneeMois
        )
        + substitute('&1|&2|&3'
                   , pbttrequete.cNumeroSociete
                   , substitute('&1-&2-&3', string(year(pbttrequete.daDebut), "9999"), string(month(pbttrequete.daDebut), "99"), string(day(pbttrequete.daDebut), "99"))
                   , substitute('&1-&2-&3', string(year(pbttrequete.daFin),   "9999"), string(month(pbttrequete.daFin),   "99"), string(day(pbttrequete.daFin),   "99"))
        ).
    return ''.

end function.

function f_ListeTypeDocument returns character (pcLibelleTypeDocument as character):
/*------------------------------------------------------------------------------
  Purpose:
  Notes:
------------------------------------------------------------------------------*/
    define variable vcMatch             as character no-undo.
    define variable vcListeTypeDocument as character no-undo.

    vcMatch = substitute('*&1*', pcLibelleTypeDocument).
    for each ttTypeDocument
        where ttTypeDocument.cLibelle matches vcMatch:
        vcListeTypeDocument = substitute('&1,&2', vcListeTypeDocument, string(ttTypeDocument.typdoc-cd)).
    end.
    return trim(vcListeTypeDocument, ',').

end function.

function f_ListeTypeDossier returns character ():
/*------------------------------------------------------------------------------
  Purpose:
  Notes:
------------------------------------------------------------------------------*/
    define variable vcListetypedossier as character no-undo.
    define buffer tutil for tutil.

    for first tutil no-lock where tutil.ident_u = mtoken:cUser:
        if num-entries(tutil.GEd) >= 4 and entry(4, tutil.GEd) = "O" then vcListetypedossier = "GER".
        if num-entries(tutil.GEd) >= 5 and entry(5, tutil.GEd) = "O" then vcListetypedossier = vcListetypedossier + ",COP".
        if num-entries(tutil.GEd) >= 6 and entry(6, tutil.GEd) = "O" then vcListetypedossier = vcListetypedossier + ",PAI".
        if num-entries(tutil.GEd) >= 7 and entry(7, tutil.GEd) = "O" then vcListetypedossier = vcListetypedossier + ",CAB".
        if num-entries(tutil.GEd) >= 8 and entry(8, tutil.GEd) = "O" then vcListetypedossier = vcListetypedossier + ",SOC".
    end.
    return trim(vcListetypedossier, ',').

end function.

function f_ImmEtab returns logical (piReference as integer, piNumeroImmeuble as integer, piNumeroMandat as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer ietab for ietab.

    for first ietab no-lock
        where ietab.soc-cd  = piReference
          and ietab.etab-cd = piNumeroMandat:
        if ietab.profil-cd modulo 10 = 0 then return false.

        if can-find(first intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.tpcon = (if ietab.profil-cd = 21 then {&TYPECONTRAT-mandat2Gerance} else {&TYPECONTRAT-mandat2Syndic})
              and intnt.nocon = piNumeroMandat
              and intnt.noidt = piNumeroImmeuble) then return true.
    end.
    return false.

end function.

function fFiltreTiers returns logical(pcMandat as character, piReference as integer, piNumeroImmeuble as integer, pcTypedossier as character, pcTypdoc as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer ietab for ietab.

    if integer(pcMandat) > 0  then do:
        find first ietab no-lock
            where ietab.soc-cd = piReference
              and ietab.etab-cd = integer(pcMandat) no-error.
        if available ietab then do:
            if ietab.profil-cd = 21 and lookup(pcTypedossier, "GER,PAI,CAB") = 0 then return false.
            if ietab.profil-cd = 91 and lookup(pcTypedossier, "COP,PAI,CAB") = 0 then return false.
            if ietab.etab-cd <> integer(pcMandat) then return false.
            if piNumeroImmeuble > 0 and f_ImmEtab(piReference, piNumeroImmeuble, ietab.etab-cd) = false then return false.
        end.
        else return false.
    end.

     /* Filtre selon le collectif */
     case ttTiers.coll-cle:
        when "P" then do:
            if lookup(pcTypdoc, substitute("&1,&2,&3,&4", "2000", "2100", "2210", "2300")) = 0 /* comptes de gerance */
            and not  pcTypdoc begins "75" /* cheques / virements */
            then return false.
        end.
        when "EI" then do:
            if  not pcTypdoc begins "40" /* Paie */
            and not pcTypdoc begins "75" /* cheques / virements */
            then return false.
        end.
        when "C" then do:
            if  not pcTypdoc begins "3" /* Appels de fond */
            and not pcTypdoc begins "75" /* cheques / virements */
            then return false.
        end.
        when "L" then do:
            if not pcTypdoc begins "1" /* Quittances... */
            then return false.
        end.
        when "F" then do:
            if ttTiers.cpt-cd <> "00000" and not pcTypdoc begins "75" then return false. /* Cheque / Virement */

            if ttTiers.cpt-cd = "00000"  /* fournisseur cabinet */
            and not can-do("60*,61*,62*,73*,75*,800*,801*,900*", pcTypdoc) then return false.
        end.
        when "" then if can-do("60*,61*,62*,73*,!7550,75*,800*,801*,900*", pcTypdoc) then return false.
    end case.
    return true.

end function.

function f_contains returns logical (pcChaine-In as character, pcLstWords-In as character, plBegins as logical):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: pcChaine-In = Chaine source de la recherche
           pcLstWords-In = Mots clés à rechercher dans pcChaine-In, séparateur espace
    ------------------------------------------------------------------------------*/
    define variable vcItem  as character no-undo.
    define variable vcMot   as character no-undo.
    define variable viI     as integer   no-undo.
    define variable viJ     as integer   no-undo.
    define variable vlOK    as logical   no-undo.

boucleMot:
    do viI = 1 to num-entries(pcLstWords-In, " "): /* Pour chaque mot recherché */
        assign
            vcItem = entry(viI, pcLstWords-In, " ")
            vlOK   = false
        .
        {&_proparse_ prolint-nowarn(weakchar)}
        if vcItem = "" then next boucleMot.  // Attention, si plusieurs espaces dans la chaine, entry peut être " " !!!

        do viJ = 1 to num-entries(pcChaine-In, " "):    /* Chaque mot de la chaine source de recherche */
            vcMot = entry(viJ, pcChaine-In, " ").
            if plBegins and vcMot begins vcItem then do:
                vlOK = true.
                next boucleMot. /* Le mot a été trouvé dans la chaine, on passe au suivant */
            end.
            else if not plBegins and vcMot = vcItem then do:
                vlOK = true.
                next boucleMot. /* Le mot a été trouvé dans la chaine, on passe au suivant */
            end.
        end.
        if vlOK = false then return false. /* Le mot n'a pas été trouvé */
    end.
    return true.

end function.

procedure getRecherche:
/*------------------------------------------------------------------------------
Purpose:
Notes:   service utilisé par beVersement.cls
------------------------------------------------------------------------------*/
    define input  parameter pcFiltre as longchar no-undo.
    define input  parameter table for ttTypeRole.
    define output parameter table for ttDocumentGED.
    define output parameter table for ttVisibiliteExtranet.

    define variable vcFormatDate              as character no-undo.
    define variable vhttFilter                as handle    no-undo.
    define variable vhBuffer                  as handle    no-undo.
    define variable vcChamp                   as character no-undo.
    define variable viI                       as integer   no-undo.
    define variable vcListeNumeroTypeDocument as character no-undo initial "".
    define variable vcListeNumeroLot          as character no-undo initial "".

    goCollection = new collection().
    create temp-table vhttFilter.
    pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide (type de document et numéro de lot)
    if pcFiltre begins "~{" and pcFiltre <> "~{~}"
    then do: /* */
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error.
        if not error-status:error
        then do:
            vhBuffer = vhttFilter:default-buffer-handle.
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do on error undo, retry :
                if retry then do :
                    mError:createError({&erreur}, 1000200, vcChamp). /* 1000200 Paramètre &1 incorrect */
                    delete object vhttFilter.
                    message 'MAGI - erreur gerée correctement.'.   // informe dans le log que l'erreur est gerée.
                    return.
                end.
                assign
                    vcChamp = "cFormatDate"
                    vcFormatDate = vhBuffer:buffer-field(vcChamp):buffer-value()
                .
                goCollection:set(vcChamp, vcFormatDate).
                vcChamp = "iCodeReferenceSociete".
                goCollection:set(vcChamp, integer(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "iNumeroMandat".
                goCollection:set(vcChamp, integer(vhBuffer:buffer-field(vcChamp):buffer-value())).
                /* Extent type de document */
                vcChamp = "iNumeroTypeDocument".
                if vhBuffer:buffer-field(vcChamp):extent > 0
                    then do :
                        do viI = 1 to vhBuffer:buffer-field(vcChamp):extent:
                            vcListeNumeroTypeDocument = substitute('&1,&2', vcListeNumeroTypeDocument, vhBuffer:buffer-field(vcChamp):buffer-value(viI)).
                        end.
                        vcListeNumeroTypeDocument = trim(vcListeNumeroTypeDocument,",").
                    end.
                    else do :
                        viI = integer(vhBuffer:buffer-field(vcChamp):buffer-value()).
                        if viI > 0 then vcListeNumeroTypeDocument = string(viI).
                    end.
                goCollection:set("cListeNumeroTypeDocument", vcListeNumeroTypeDocument).
                vcChamp = "cLibelleTypeDocument".
                goCollection:set(vcChamp, string(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "daDateDebut".
                goCollection:set(vcChamp, outils:convertionDate(vcFormatDate, vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "daDateFin".
                goCollection:set(vcChamp, outils:convertionDate(vcFormatDate, vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "cObjet".
                goCollection:set(vcChamp, string(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "cCodeNatureDocument".
                goCollection:set(vcChamp, string(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "iNumeroImmeuble".
                goCollection:set(vcChamp, integer(vhBuffer:buffer-field(vcChamp):buffer-value())).
                /* Extent numero de lot */
                vcChamp = "iNumeroLot".
                if vhBuffer:buffer-field(vcChamp):extent > 0
                    then do :
                        do viI = 1 to vhBuffer:buffer-field(vcChamp):extent:
                            vcListeNumeroLot = substitute('&1,&2', vcListeNumeroLot, vhBuffer:buffer-field(vcChamp):buffer-value(viI)).
                        end.
                        vcListeNumeroLot = trim(vcListeNumeroLot,",").
                    end.
                    else do :
                        viI = integer(vhBuffer:buffer-field(vcChamp):buffer-value()).
                        if viI > 0 then vcListeNumeroLot = string(viI).
                    end.
                goCollection:set("cListeNumeroLot", vcListeNumeroLot).
                vcChamp = "iNumeroTiers".
                goCollection:set(vcChamp, int64(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "iCodeTypeRole".
                goCollection:set(vcChamp, integer(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "iNumeroRole".
                goCollection:set(vcChamp, int64(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "cCodeTypeContrat".
                goCollection:set(vcChamp, string(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "iNumeroContrat".
                goCollection:set(vcChamp, int64(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "iNumeroDossierTravaux".
                goCollection:set(vcChamp, integer(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "cMotcle".
                goCollection:set(vcChamp, string(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "cListeCodeThemeGed".
                goCollection:set(vcChamp, string(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "cDescriptif".
                goCollection:set(vcChamp, string(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "iNumeroContratFournisseur".
                goCollection:set(vcChamp, integer(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "lPublie".
                goCollection:set(vcChamp, logical(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "lPubliable".
                goCollection:set(vcChamp, logical(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "lNonPubliable".
                goCollection:set(vcChamp, logical(vhBuffer:buffer-field(vcChamp):buffer-value())).
                vcChamp = "lGedUniquement".
                goCollection:set(vcChamp, logical(vhBuffer:buffer-field(vcChamp):buffer-value())).
                if goCollection:getInt64("iNumeroTiers") > 0 then do:
                    goCollection:set("cCodeTypeContrat", "").
                    goCollection:set("iNumeroContrat", int64(0)).
                    goCollection:set("iCodeTypeRole",  0).
                    goCollection:set("iNumeroRole",    int64(0)).
                end.
                vcChamp = "cTypeIdentifiant".
                goCollection:set(vcChamp, string(vhBuffer:buffer-field(vcChamp):buffer-value())) no-error. // ce champs n'est pas obligatoire
                vcChamp = "iNumeroIdentifiant".
                goCollection:set(vcChamp, int64(vhBuffer:buffer-field(vcChamp):buffer-value())) no-error. // ce champs n'est pas obligatoire
            end.
            else do :
                mError:createError({&erreur}, 1000199). /* Filtre incorrect */
                delete object vhttFilter.
                return.
            end.
        end.
        else do:
            mError:createError({&erreur}, 1000199). /* Filtre incorrect */
            delete object vhttFilter.
            return.
        end.
    end.
    else do:
        mError:createError({&erreur}, 1000199). /* Filtre incorrect */
        delete object vhttFilter.
        return.
    end.
    delete object vhttFilter.

    empty temp-table ttDocumentGED.
    empty temp-table ttVisibiliteExtranet.
    // run getListeTypeRole(goCollection:getInteger("iCodeReferenceSociete")).
    run getTypeDocument.
    run recherche_ged.
    if giNumSeq < {&MAXRETURNEDROWS}
    and not goCollection:getLogical("lPublie")
    and not goCollection:getLogical("lGedUniquement") then run recherche_gidemat.
    // if not can-find(first ttDocumentGed) then mError:createError({&info}, 1000083). /* Aucun document */

end procedure.

procedure recherche_ged private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vlPubliable         as logical   no-undo.
    define variable vlPublie            as logical   no-undo.
    define variable vlNonPubliable      as logical   no-undo.
    define variable vcListeCodeThemeGed as character no-undo.
    define variable vcObjet             as character no-undo.
    define variable vcMotcle            as character no-undo.
    define variable vcDescriptif        as character no-undo.
    define variable vcLbRech            as character no-undo.
    define variable viTmp               as integer   no-undo.
    define variable vi2Tmp              as integer   no-undo.
    define variable vlDocPublie         as logical   no-undo.
    define variable vlDocNonPublie      as logical   no-undo.
    define variable vlDocNonPubliable   as logical   no-undo.
    define variable vcTmp               as character no-undo.
    define variable vcWhereClause       as character no-undo.
    define variable vhQuery             as handle    no-undo.
    define variable vhBuffer            as handle    no-undo.
    define variable vcListeTypeDossier  as character no-undo.
    define variable vcListeTypeDocument as character no-undo.
    define variable vcListeTemporaire   as character no-undo.
    define variable vhProcVersement     as handle    no-undo.
    define variable vdaDateDebut        as date      no-undo.
    define variable vdaDateFin          as date      no-undo.
    define variable vcTypeIdentifiant   as character no-undo.
    define variable viNumeroIdentifiant as int64     no-undo. 
    define buffer igedtypd for igedtypd.

    run ged/versement.p persistent set vhProcVersement.
    run getTokenInstance in vhProcVersement(mToken:JSessionId).
    /* Code société */
    if goCollection:getInteger("iCodeReferenceSociete") > 0
    then vcLbRech = " NUMSOC_" + string(goCollection:getInteger("iCodeReferenceSociete"), "99999").
    /* Type de doc */
    vcListeTemporaire = goCollection:getCharacter("cListeNumeroTypeDocument").
    if vcListeTemporaire > ""
    then do:
boucleDocument:
        do viTmp = 1 to num-entries(vcListeTemporaire):
            vi2Tmp = integer(entry(viTmp, vcListeTemporaire)) no-error.
            if error-status:error or vi2Tmp <= 0 then next boucleDocument.

            vcTmp = substitute("&1 ^ TYPDOC_&2", vcTmp, vi2tmp).
        end.
        vcTmp = trim(vcTmp," ^ ").
        if vcTmp > "" then vcLbRech = substitute("&1 (&2)", vcLbRech, vcTmp).
    end.
    {&_proparse_ prolint-nowarn(weakchar)}
    if vcTmp = "" and goCollection:getCharacter("cLibelleTypeDocument") > ""
    then vcListeTypeDocument = f_ListeTypeDocument(goCollection:getCharacter("cLibelleTypeDocument")). /* recherche full text */
    /* Nature */
    if trim(goCollection:getCharacter("cCodeNatureDocument")) > ""
    then vcLbRech = substitute("&1 CDNAT_&2", vcLbRech, goCollection:getCharacter("cCodeNatureDocument")).
    /* Mandat */
    if goCollection:getInteger("iNumeroMandat") > 0
    then vcLbRech = substitute("&1 MDT_&2", vcLbRech, string(goCollection:getInteger("iNumeroMandat"), "99999")).
    /* Immeuble */
    if goCollection:getInteger("iNumeroImmeuble") > 0
    then vcLbRech = substitute("&1 IMM_&2", vcLbRech, string(goCollection:getInteger("iNumeroImmeuble"), "999999999")).
    /* Lot */
    assign
        vcTmp             = ""
        vcListeTemporaire = goCollection:getCharacter("cListeNumeroLot")
    .
    if vcListeTemporaire > ""
    then do:
boucleLot:
        do viTmp = 1 to num-entries(vcListeTemporaire):
            vi2Tmp = integer(entry(viTmp, vcListeTemporaire)) no-error.
            if error-status:error or vi2Tmp <= 0 then next boucleLot.

            vcTmp = substitute("&1 ^ LOT_&2", vcTmp, string(vi2Tmp, "999999999")).
        end.
        vcTmp = trim(vcTmp," ^ ").
        if vcTmp > "" then vcLbRech = substitute("&1 (&2)", vcLbRech, vcTmp).
    end.
    /* Tiers */
    if goCollection:getInt64("iNumeroTiers") > 0 or goCollection:getInteger("iCodeTypeRole") > 0 or goCollection:getInt64("iNumeroRole") > 0
    then vcLbRech = vcLbRech + " TIERS_"
                  + (if goCollection:getInt64("iNumeroTiers") = 0 and goCollection:getInteger("iCodeTypeRole") = 0
                     then ""
                     else if goCollection:getInt64("iNumeroTiers") > 0
                          then "T" + string(goCollection:getInt64("iNumeroTiers"))
                          else substitute("F&1-&2", string(goCollection:getInteger("iCodeTypeRole")), string(goCollection:getInt64("iNumeroRole")))).
    /* contrat associé */
    if goCollection:getCharacter("cCodeTypeContrat") > "" and goCollection:getInt64("iNumeroContrat") > 0
    then vcLbRech = substitute("&1 CTRASS_&2-&3", vcLbRech, goCollection:getCharacter("cCodeTypeContrat"), string(goCollection:getInt64("iNumeroContrat"))).
    /* No dossier travaux */
    if goCollection:getInteger("iNumeroDossierTravaux") > 0
    then vcLbRech = substitute("&1 NODOSS_&2", vcLbRech, string(goCollection:getInteger("iNumeroDossierTravaux"))).

    assign
        vlPubliable         = goCollection:getLogical("lPubliable")
        vlPublie            = goCollection:getLogical("lPublie")
        vlNonPubliable      = goCollection:getLogical("lNonPubliable")
        vcListeCodeThemeGed = goCollection:getCharacter("cListeCodeThemeGed")
        vcObjet             = goCollection:getCharacter("cObjet")
        vcDescriptif        = goCollection:getCharacter("cDescriptif")
        vcMotcle            = goCollection:getCharacter("cMotcle")
        vdaDateDebut        = goCollection:getDate("daDateDebut")
        vdaDateFin          = goCollection:getDate("daDateFin")
        vcTypeIdentifiant   = goCollection:getCharacter("cTypeIdentifiant")
        viNumeroIdentifiant = goCollection:getint64("iNumeroIdentifiant")
    .
    /* Thème GED */
    if vlPubliable and num-entries(vcListeCodeThemeGed) > 1 then do:
        do viTmp = 1 to num-entries(vcListeCodeThemeGed):
            vcTmp = substitute("&1THM_&2 ", vcTmp, entry(viTmp, vcListeCodeThemeGed)).
            if viTmp <> num-entries(vcListeCodeThemeGed) then vcTmp = vcTmp + "! ".
        end.
        vcLbRech = substitute("&1 (&2)", vcLbRech, trim(vcTmp)).
    end.
    else if integer(vcListeCodeThemeGed) > 0 then vcLbRech = substitute("&1 THM_&2", vcLbRech, string(integer(vcListeCodeThemeGed), "99999")).
    /* ctrat fournisseur */
    if goCollection:getInteger("iNumeroContratFournisseur") > 0 then vcLbRech = substitute("&1 CTRATF_&2", vcLbRech, replace(string(goCollection:getInteger("iNumeroContratFournisseur")), " ", "_")).

    assign
        vcLbRech           = if vcLbRech > "" then trim(vcLbRech) else "MDT_*"     /* Au moins un critère, sinon plantage du contains */
        vcListeTypeDossier = f_ListeTypeDossier()
        vcWhereClause      = substitute("where igeddoc.lbrech contains '&1'", vcLbRech)
    .

message "Recherche locale : " vcLbRech.
message "Liste des types de document : type de doc " string(goCollection:getCharacter("cListeNumeroTypeDocument"))
                                     " libellé " goCollection:getCharacter("cLibelleTypeDocument")
                                     " liste " vcListeTypeDocument.

    if vdaDateDebut <> ? then vcWhereClause = substitute("&1 and igeddoc.dadoc >= &2",vcWhereClause , vdaDateDebut).
    if vdaDateFin   <> ? then vcWhereClause = substitute("&1 and igeddoc.dadoc <= &2",vcWhereClause , vdaDateFin).
    if vcTypeIdentifiant > "" and viNumeroIdentifiant >= 0 
    then vcWhereClause = substitute("&1 and igeddoc.tpidt = '&2' and igeddoc.noidt = &3",vcWhereClause , vcTypeIdentifiant, viNumeroIdentifiant).
    
    create buffer vhBuffer for table "igeddoc".
    create query vhQuery.
    vhQuery:set-buffers(vhBuffer).
    vhQuery:query-prepare(substitute('for each igeddoc no-lock &1', vcWhereClause)).
    vhQuery:query-open().
boucleDocument:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucleDocument.

        /* Controle suplémentaire sur les zones non balisées (saisie de texte libre) */
        if vcObjet      > "" and not (vhBuffer::libobj   matches substitute("*&1*", vcObjet))      then next boucleDocument.    /* Objet */
        if vcDescriptif > "" and not (vhBuffer::libdesc  matches substitute("*&1*", vcDescriptif)) then next boucleDocument.    /* descriptif */
        if vcMotcle     > "" and not f_contains(vhBuffer::cdivers1, vcMotcle, true)                then next boucleDocument.    /* mots clé */

        assign
            vlDocPublie       = (vhBuffer::web-fgmadisp = true)
            vlDocNonPublie    = (vhBuffer::web-fgmadisp = false)
            vlDocNonPubliable = (vhBuffer::cdivers4 = "O")
        .

/*
message "vhBuffer::id-fich" vhBuffer::id-fich
        "vlNonPubliable" vlNonPubliable
        "vlPublie" vlPublie
        "vlPubliable" vlPubliable
        "vlDocPublie" vlDocPublie
        "vlDocNonPublie" vlDocNonPublie
        "vlDocNonPubliable" vlDocNonPubliable
        .
*/

        if not ((vlPublie and vlDocPublie)
        or (vlPubliable and vlDocNonPublie and not vlDocNonPubliable)
        or (vlNonPubliable and vlDocNonPubliable))
        then next boucleDocument.

        if vcListeTypeDocument > "" and lookup(string(vhBuffer::typdoc-cd), vcListeTypeDocument) = 0 then next boucleDocument.

        find first igedtypd no-lock
            where igedtypd.typdoc-cd = vhBuffer::typdoc-cd
              and num-entries(igedtypd.cdivers, separ[1]) >= 2
              and lookup(entry(2, igedtypd.cdivers, separ[1]), vcListeTypeDossier) > 0 no-error.
        if not available igedtypd then next boucleDocument.

        run createttDocumentGed(vhBuffer, vhProcVersement).

        giNumSeq = giNumSeq + 1.
        if giNumSeq >= {&MAXRETURNEDROWS} then do:               /* > {&MAXRETURNEDROWS} tiers trouvés */
            mError:createError({&information}, 211668, "{&MAXRETURNEDROWS}"). /* Nombre maximum d'enregistrements atteint (maxi [&1]) */
            leave boucleDocument.
        end.
    end.
    if valid-handle(vhProcVersement) then run destroy in vhProcVersement.

end procedure.

procedure getTypeDocument private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer igedtypd for igedtypd.

    empty temp-table ttTypeDocument.
    {&_proparse_ prolint-nowarn(wholeindex)}
    for each igedtypd no-lock:
        create ttTypeDocument.
        assign
            ttTypeDocument.typdoc-cd      = igedtypd.typdoc-cd
            ttTypeDocument.orig-cd        = igedtypd.orig-cd
            ttTypeDocument.cLibelle       = igedtypd.lib
            ttTypeDocument.gidemat-typdoc = igedtypd.gidemat-typdoc
            ttTypeDocument.typedossier    = (if num-entries(igedtypd.cdivers,separ[1]) >= 2 then entry(2, igedtypd.cdivers, separ[1]) else "")
            ttTypeDocument.theme-cd       = (if num-entries(igedtypd.cdivers,separ[1]) >= 4 then entry(4, igedtypd.cdivers, separ[1]) else "")
        .
        if num-entries(igedtypd.cdivers, separ[1]) >= 5 and entry(5, igedtypd.cdivers, separ[1]) > ""
        then ttTypeDocument.cLibelle = entry(5, igedtypd.cdivers, separ[1]). /* Libellé client */
        ttTypeDocument.cLibelle = caps(substring(ttTypeDocument.cLibelle, 1, 1, 'character')) + lc(substring(ttTypeDocument.cLibelle, 2)).
    end.

end procedure.

procedure recherche_gidemat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable viReference               as integer   no-undo.
    define variable viNumeroImmeuble          as integer   no-undo.
    define variable vhProcGidemat             as handle    no-undo.
    define variable vcListeNumeroTypeDocument as character no-undo.
    define variable vcListeCodeThemeGed       as character no-undo.
    define variable viNoeudMdt                as integer   no-undo.
    define variable vcNoeudTiers              as character no-undo.
    define variable vcCodeTiers               as character no-undo.
    define variable vcTpRol                   as character no-undo.
    define variable viTprol                   as integer   no-undo.
    define variable viNoTie                   as integer   no-undo.
    define variable viNoRol                   as int64     no-undo.
    define variable vcCodeColl                as character no-undo.
    define variable vcListeDoc                as character no-undo.
    define variable vcTmp                     as character no-undo.
    define variable vcListeTypeDossier        as character no-undo.
    define variable viNombredocument          as integer   no-undo.
    define variable vhProcRole                as handle    no-undo.

    define buffer vbttRequete for ttRequete.
    define buffer vbRoles     for roles.
    define buffer intnt       for intnt.
    define buffer isoc        for isoc.
    define buffer ietab       for ietab.
    define buffer aparm       for aparm.
    define buffer ccptcol     for ccptcol.
    define buffer imble       for imble.
    define buffer igedtypd    for igedtypd.

    run role/role.p persistent set vhProcRole.
    run getTokenInstance in vhProcRole(mToken:JSessionId).

    /* Extraction à partir de Gidemat */
    run ged/gidemat.p persistent set vhProcGidemat.
    run getTokenInstance in vhProcGidemat(mToken:JSessionId).

    empty temp-table ttRgrpTiers.
    empty temp-table ttTiers.
    empty temp-table ttRequete.
    /* Mandat */
    viNoeudMdt = goCollection:getInteger("iNumeroMandat").
    if viNoeudMdt = 0 then viNoeudMdt = ?.
    assign
        vcNoeudTiers              = ""
        viReference               = goCollection:getInteger("iCodeReferenceSociete")
        viNumeroImmeuble          = goCollection:getInteger("iNumeroImmeuble")
        vcListeNumeroTypeDocument = goCollection:getCharacter("cListeNumeroTypeDocument")
        vcListeCodeThemeGed       = goCollection:getCharacter("cListeCodeThemeGed")
    .
    /* Tiers */
    if goCollection:getInt64("iNumeroTiers") > 0  or (goCollection:getInteger("iCodeTypeRole") > 0 and goCollection:getInt64("iNumeroRole") > 0)
    then do:
        vcNoeudTiers = if goCollection:getInt64("iNumeroTiers") = 0 and goCollection:getInteger("iCodeTypeRole") = 0
                       then ""
                       else if goCollection:getInt64("iNumeroTiers") > 0
                            then "T" + trim(string(goCollection:getInt64("iNumeroTiers"), ">>>>>99999"))
                            else substitute("F&1-&2", string(goCollection:getInteger("iCodeTypeRole")), goCollection:getInt64("iNumeroRole")).
        if vcNoeudTiers begins "F" then do: /* compte fournisseur */
            vcCodeTiers = string(integer(entry(2, vcNoeudTiers,"-")), "99999").
            find first ttTiers
                where ttTiers.coll-cle = "F"
                  and ttTiers.cpt-cd = vcCodeTiers no-error.
            if not available ttTiers then fCreatettTiers("F", vcCodeTiers, viNoeudMdt).
        end.
        else if vcNoeudTiers begins "T" then do:                  /* compte autre tiers */
            vcCodeTiers = substring(entry(1, vcNoeudTiers, "-"), 2).
            run contratTiers(vcCodeTiers, viReference, viNoeudMdt, viNumeroImmeuble, vhProcRole).  /* tous les contrats du tiers */
        end. /* T */
        else fCreatettTiers("", "", viNoeudMdt).
    end.  /* Tiers */
    else do:
        if viNumeroImmeuble > 0
        then
boucleMandat:
            for each ietab no-lock                  /* tous les mandats de l'immeuble */
            where ietab.soc-cd = viReference:
            if viNoeudMdt > 0 and ietab.etab-cd <> viNoeudMdt then next boucleMandat.

            if viNumeroImmeuble > 0 and f_ImmEtab(viReference, viNumeroImmeuble, ietab.etab-cd) = false then next boucleMandat.

            if f_ImmEtab(viReference, viNumeroImmeuble, ietab.etab-cd) = false then next boucleMandat.

            fCreatettTiers("", "", ietab.etab-cd).
        end.
        else fCreatettTiers("", "", viNoeudMdt).       /* Mandat */
    end.

    for each ttTiers
        break by ttTiers.coll-cle
              by ttTiers.cpt-cd
              by ttTiers.mandat-cd:
        if not first-of(ttTiers.mandat-cd) then delete ttTiers.
    end.

    /*** Immeuble ****/
    if fisNull(trim(vcListeNumeroTypeDocument)) and not fisNull(goCollection:getCharacter("cLibelleTypeDocument"))
    then vcListeNumeroTypeDocument = f_ListeTypeDocument(goCollection:getCharacter("cLibelleTypeDocument")). /* recherche full text */

    run createRequete(vcListeNumeroTypeDocument).

    /* Si +sieurs requetes avec types doc différents et param identiques  -> 1 seule requete avec liste de type de doc */
    for each ttRequete
        break by ttRequete.cTypeDocument
              by ttRequete.cMandat
              by ttRequete.cTiers
              by ttRequete.cNumeroTraitement
              by ttRequete.cChemise
              by ttRequete.cImmeuble
              by ttRequete.cLot
              by ttRequete.cObjet
              by ttRequete.cAnneeMois
              by ttRequete.cNumeroSociete
              by ttRequete.daDebut
              by ttRequete.daFin:
        if first-of(ttRequete.daFin) then vcListeDoc = ?.
        {&_proparse_ prolint-nowarn(weakchar)}
        if vcListeDoc <> ""    // Attention, laisser <>, ne pas mettre >. On teste bien <> "" ou = ?
        then do:
            if fIsNull(ttRequete.cTypeDocument)
            then vcListeDoc = "". /* "" = Tous */
            else do:
                if vcListeDoc = ? then vcListeDoc = "".
                vcListeDoc = vcListeDoc + ":" + ttRequete.cTypeDocument.
            end.
        end.
        if last-of(ttRequete.daFin) then assign
            vcListeDoc = trim(vcListeDoc, ':')
            ttRequete.cTypeDocument = vcListeDoc
        .
        else delete ttRequete.
    end. /* ttRequete */

    /* nettoyage requete */
    for each ttRequete
        where ttRequete.cTypeDocument > ""
           or ttRequete.cMandat > ""
           or ttRequete.cTiers > ""
           or ttRequete.cNumeroTraitement > ""
           or ttRequete.cChemise > ""
           or ttRequete.cImmeuble > ""
           or ttRequete.cLot > ""
           or ttRequete.cObjet > ""
           or ttRequete.cAnneeMois > ""
           or ttRequete.cNumeroSociete > ""
           or ttRequete.daDebut <> ?
           or ttRequete.daFin <> ?:
        /**                fIsNull(nom de la table) ne fonctionne pas dans un can-find(nom de la table...)
        if can-find(first vbttRequete
            where rowid(vbttRequete) <> rowid(ttRequete)
              and (vbttRequete.cTypeDocument     = ttRequete.cTypeDocument     or fIsNull(vbttRequete.cTypeDocument))
              and (vbttRequete.cMandat           = ttRequete.cMandat           or fIsNull(vbttRequete.cMandat))
              and (vbttRequete.cTiers            = ttRequete.cTiers            or fIsNull(vbttRequete.cTiers))
              and (vbttRequete.cNumeroTraitement = ttRequete.cNumeroTraitement or fIsNull(vbttRequete.cNumeroTraitement))
              and (vbttRequete.cChemise          = ttRequete.cChemise          or fIsNull(vbttRequete.cChemise))
              and (vbttRequete.cImmeuble         = ttRequete.cImmeuble         or fIsNull(vbttRequete.cImmeuble))
              and (vbttRequete.cLot              = ttRequete.cLot              or fIsNull(vbttRequete.cLot))
              and (vbttRequete.cObjet            = ttRequete.cObjet            or fIsNull(vbttRequete.cObjet))
              and (vbttRequete.cAnneeMois        = ttRequete.cAnneeMois        or fIsNull(vbttRequete.cAnneeMois))
              and (vbttRequete.cNumeroSociete    = ttRequete.cNumeroSociete    or fIsNull(vbttRequete.cNumeroSociete))
              and (vbttRequete.daDebut           = ttRequete.daDebut           or vbttRequete.daDebut = ?)
              and (vbttRequete.daFin             = ttRequete.daFin             or vbttRequete.daFin = ?))
        then delete ttRequete.
        **/
        if can-find(first vbttRequete
            where rowid(vbttRequete) <> rowid(ttRequete)
              and (vbttRequete.cTypeDocument     = ttRequete.cTypeDocument     or vbttRequete.cTypeDocument     = "" or vbttRequete.cTypeDocument     = ?)
              and (vbttRequete.cMandat           = ttRequete.cMandat           or vbttRequete.cMandat           = "" or vbttRequete.cMandat           = ?)
              and (vbttRequete.cTiers            = ttRequete.cTiers            or vbttRequete.cTiers            = "" or vbttRequete.cTiers            = ?)
              and (vbttRequete.cNumeroTraitement = ttRequete.cNumeroTraitement or vbttRequete.cNumeroTraitement = "" or vbttRequete.cNumeroTraitement = ?)
              and (vbttRequete.cChemise          = ttRequete.cChemise          or vbttRequete.cChemise          = "" or vbttRequete.cChemise          = ?)
              and (vbttRequete.cImmeuble         = ttRequete.cImmeuble         or vbttRequete.cImmeuble         = "" or vbttRequete.cImmeuble         = ?)
              and (vbttRequete.cLot              = ttRequete.cLot              or vbttRequete.cLot              = "" or vbttRequete.cLot              = ?)
              and (vbttRequete.cObjet            = ttRequete.cObjet            or vbttRequete.cObjet            = "" or vbttRequete.cObjet            = ?)
              and (vbttRequete.cAnneeMois        = ttRequete.cAnneeMois        or vbttRequete.cAnneeMois        = "" or vbttRequete.cAnneeMois        = ?)
              and (vbttRequete.cNumeroSociete    = ttRequete.cNumeroSociete    or vbttRequete.cNumeroSociete    = "" or vbttRequete.cNumeroSociete    = ?)
              and (vbttRequete.daDebut           = ttRequete.daDebut           or vbttRequete.daDebut           = ?)
              and (vbttRequete.daFin             = ttRequete.daFin             or vbttRequete.daFin             = ?))
        then delete ttRequete.

    end.

    /* execution requete WS */
    empty temp-table ttDocumentGidemat.
    for each ttRequete
        break by ttRequete.cTypeDocument
              by ttRequete.cMandat
              by ttRequete.cTiers
              by ttRequete.cNumeroTraitement
              by ttRequete.cChemise
              by ttRequete.cImmeuble
              by ttRequete.cLot
              by ttRequete.cObjet
              by ttRequete.cAnneeMois
              by ttRequete.cNumeroSociete
              by ttRequete.daDebut
              by ttRequete.daFin:
        if first-of(ttRequete.daFin) then do:

message "execution requete -> ttRequete.cParam" serialise(buffer ttRequete).

            run gidemat_extract_liste in vhProcGidemat (",CRIT," + serialise(buffer ttRequete), output table ttDocumentGidemat append).

message "fin execution requete -> ttRequete.cParam" serialise(buffer ttRequete).

        end.
    end.

    /* Nettoyage documents reçus */
    assign
        vcListeTypeDossier = f_ListeTypeDossier()
        viNombredocument   = 0
    .
    for each ttDocumentGidemat:
        viNombredocument = viNombredocument + 1.
    end.

message "Nombre documents gidemat renvoyés par maarch " viNombredocument.

    viNombredocument = 0.
boucleDocument:
    for each ttDocumentGidemat
        break by ttDocumentGidemat.iIdentifiantGidemat:
        if not first-of(ttDocumentGidemat.iIdentifiantGidemat) /* suppression des doublons */
        or (ttDocumentGidemat.cTypeDocument begins "75"
         and not can-find(first ttRgrpTiers where ttDocumentGidemat.cLibellecompte matches substitute("*&1&2*", ttRgrpTiers.cColl-Cle, ttRgrpTiers.cCpt-cd)))
        then do:
            delete ttDocumentGidemat.
            next boucleDocument.
        end.
        find first ttTypeDocument
            where ttTypeDocument.gidemat-typdoc = ttDocumentGidemat.cTypeDocument
              and ttTypeDocument.orig-cd = "3"   /* uniquement types de doc production */
              and (if vcListeNumeroTypeDocument > ""
                         then lookup(string(ttTypeDocument.typdoc-cd), vcListeNumeroTypeDocument) > 0
                         else true)
              and (if fIsNull(vcListeCodeThemeGed) then true else ttTypeDocument.theme-cd = vcListeCodeThemeGed) no-error.
        if not available ttTypeDocument then do:
            delete ttDocumentGidemat.
            next boucleDocument.
        end.
        find first igedtypd no-lock
            where igedtypd.typdoc-cd = ttTypeDocument.typdoc-cd
              and num-entries(igedtypd.cdivers,separ[1]) >= 2
              and lookup(entry(2, igedtypd.cdivers, separ[1]), vcListeTypeDossier) > 0 no-error.
        if not available igedtypd then do:
            delete ttDocumentGidemat.
            next boucleDocument.
        end.
        create ttDocumentGED.
        assign
            vcTpRol                           = ""
            viTprol                           = integer(vcTpRol)
            viNoTie                           = 0
            viNoRol                           = 0
            viNombredocument                  = viNombredocument + 1
            ttDocumentGED.iIdentifiantGed     = 0
            ttDocumentGED.cIdentifiantGidemat = (if ttDocumentGidemat.iIdentifiantGidemat > 0 then string(ttDocumentGidemat.iIdentifiantGidemat) else "")  /* Resid Maarch */
            ttDocumentGED.iNumeroMandat       = integer(ttDocumentGidemat.cNumeroMandat)
            ttDocumentGED.cNumeroCompte       = ttDocumentGidemat.cNumeroCompte
            ttDocumentGED.cLibelleTiers       = ttDocumentGidemat.cLibelleCompte
            ttDocumentGED.iNumeroTypeDocument = ttTypeDocument.typdoc-cd
            ttDocumentGED.cLibelleTypeDocument= ttTypeDocument.cLibelle
            ttDocumentGED.cObjet              = ttDocumentGidemat.cLibelleTraitement
            ttDocumentGED.cCodeThemeGed       = ttTypeDocument.theme-cd
            ttDocumentGED.rRowid              = ?                /* Les documents issus de gidemat (production) ne sont pas modifiables */
            ttDocumentGED.CRUD                = "R"
            ttDocumentGED.dtTimestamp         = ?
	        ttDocumentGED.daDateDuDoc         = date(integer(substring(ttDocumentGidemat.cDateDocument, 6, 2, 'character')),
                                                     integer(substring(ttDocumentGidemat.cDateDocument, 9, 2, 'character')),
                                                     integer(substring(ttDocumentGidemat.cDateDocument, 1, 4, 'character')))
        .
        /* Libelle mandat */
        if ttDocumentGED.iNumeroMandat > 0
        then
BoucleMandat:
        for each isoc no-lock                     // todo : whole index pas dramatique, mais pas normal.
            where isoc.specif-cle = 1000          // si! dramatique car on prend le premier enregistrement
          , first ietab no-lock                   // comment est on sur que c'est le bon soc-cd??????
            where ietab.soc-cd  = isoc.soc-cd
              and ietab.etab-cd = ttDocumentGED.iNumeroMandat:
            ttDocumentGED.cLibelleMandat = substitute('&1 - &2', string(ietab.etab-cd, "99999"), trim(substring(ietab.lbrech, 1, 60, 'character'))).
            leave BoucleMandat.
        end.

        /* Type de role   */
        {&_proparse_ prolint-nowarn(release)}
        release ccptcol.
        if ttTypeDocument.orig-cd = "3" and  ttTypeDocument.gidemat-typdoc begins "1"  /* quitt */
        then do:
            vcTpRol = {&TYPEROLE-locataire}.
            find first ccptcol no-lock
                where ccptcol.soc-cd   = viReference
                  and ccptcol.coll-cle = "L" no-error.
        end.
        else if ttTypeDocument.orig-cd = "3"
           and (ttTypeDocument.gidemat-typdoc begins "20"   /* comptes de gerance */
             or ttTypeDocument.gidemat-typdoc begins "21"   /* fact fourn loyer */
             or ttTypeDocument.gidemat-typdoc begins "221"  /* irf def */
             or ttTypeDocument.gidemat-typdoc begins "223") /* RELEVE DE QUITT */
        then do:
            vcTpRol = {&TYPEROLE-mandant}. /* Mandant */
            find first ccptcol no-lock
                where ccptcol.soc-cd   = viReference
                  and ccptcol.coll-cle = "P" no-error.
        end.
        else if ttTypeDocument.orig-cd = "3"
           and (ttTypeDocument.gidemat-typdoc begins "30"   /* Appels de fond */
             or ttTypeDocument.gidemat-typdoc begins "31")  /* Charges de copro */
        then do:
            vcTpRol = {&TYPEROLE-coproprietaire}. /* Copropriétaire */
            find first ccptcol no-lock
                where ccptcol.soc-cd   = viReference
                  and ccptcol.coll-cle = "C" no-error.
        end.
        else if ttTypeDocument.orig-cd = "3"
                  and (ttTypeDocument.gidemat-typdoc begins "40") /* bulletins */
        then do :
            if ttDocumentGidemat.cNumeroTraitement = "PZ"
                then vcTpRol = {&TYPEROLE-salariePegase}. /* Salarié pegaze*/
                else vcTpRol = {&TYPEROLE-salarie}. /* Salarié */
            find first ccptcol no-lock where ccptcol.soc-cd = viReference
                          and ccptcol.coll-cle = "EI" no-error.
        end.
        else if ttTypeDocument.orig-cd = "3"
                  and ttTypeDocument.gidemat-typdoc begins "7550" /* bordereau de remise */
        then assign
               vcTmp = entry(num-entries(ttDocumentGED.cLibelleTiers, " "), ttDocumentGED.cLibelleTiers, " ")
               vcTpRol = "".
        else if ttTypeDocument.orig-cd = "3"
                  and (ttTypeDocument.gidemat-typdoc begins "75") /* lettres cheques / virements */
        then do:
            assign
                vcTmp = entry(num-entries(ttDocumentGED.cLibelleTiers, " "), ttDocumentGED.cLibelleTiers, " ")
                vcCodeColl = ""
                vcCodeColl = substring(vcTmp, 1, length(vcTmp, 'character') - 5, 'character')
	        no-error.
            find first ccptcol no-lock
                where ccptcol.soc-cd = viReference
                  and ccptcol.coll-cle = vcCodeColl no-error.
            vcTpRol = if available ccptcol
                      then if ccptcol.coll-cle = "EI"
                          then {&TYPEROLE-salariePegase}
                          else string(ccptcol.tprol, "99999")
                      else "".
        end.
        find first ttTypeRole where ttTypeRole.cTypeRole = vcTpRol no-error.
        ttDocumentGED.cLibelleTypeRole = (if available ttTypeRole then ttTypeRole.cLibelleTypeRole else "").

        /* Tiers */
        if available ccptcol and (ccptcol.tprol >= 4000 and ccptcol.tprol <= 4999) /* OS -> pas de tiers */
        then viNoRol = int64(ttDocumentGED.cNumeroCompte).
        else if available ccptcol and ccptcol.tprol = 12 /* fournisseur -> pas de tiers */
        then for first aparm no-lock
            where aparm.tppar = "GEDFOU" and aparm.cdpar = string(viReference, "99999"):
            assign
                viTprol = integer(aparm.lib) /* tprol du fournisseur compta dans la table roles  */
                viNoRol = int64(ttDocumentGED.cNumeroCompte)
            .
        end.
        else do: /* recherche du N° de tiers */
            if available ccptcol and ccptcol.coll-cle = "P" then do: /* 16 (co) indivisaire */
                viNoRol = int64(ttDocumentGED.cNumeroCompte).
                find first vbRoles no-lock
                    where vbRoles.tprol = {&TYPEROLE-coIndivisaire}
                      and vbRoles.norol = viNoRol no-error.
                if not available vbRoles
                then find first vbRoles no-lock
                    where vbRoles.tprol = {&TYPEROLE-mandant}
                      and vbRoles.norol = viNoRol no-error.
                if available vbRoles then viTprol = integer(vbRoles.tprol).
            end.
            else if  available ccptcol and ccptcol.coll-cle = "EI" then do:
                if ttDocumentGidemat.cNumeroTraitement = "PA"
                then assign
                    viNoRol = integer(ttDocumentGed.cNumeroCompte)
                    viTprol = integer({&TYPEROLE-salarie})
                .
                else assign /* PZ Pegaze */
                    viNoRol = integer(string(ttDocumentGED.iNumeroMandat) + ttDocumentGed.cNumeroCompte)
                    viTprol = integer({&TYPEROLE-salariePegase})
                .
            end.
            else if available ccptcol and ccptcol.coll-cle = "L"
                 then viNoRol = integer(string(ttDocumentGED.iNumeroMandat,"99999") + ttDocumentGED.cNumeroCompte).
            else if not ttTypeDocument.gidemat-typdoc begins "7550"
                 then viNoRol = integer(ttDocumentGed.cNumeroCompte).
        end.
        find first vbRoles no-lock
            where vbRoles.tprol = string(viTprol, "99999") and vbRoles.norol = viNoRol no-error.
        if available vbRoles then viNoTie = vbRoles.notie.
        assign
            ttDocumentGed.iCodeTypeRole = (if viTprol >= 0 then viTprol else 0)
            ttDocumentGed.iNumeroRole = (if viNoRol >= 0 then viNoRol else 0)
            ttDocumentGed.iNumeroTiers = (if viNoTie >= 0 then viNoTie else 0)
        .
        /* Immeuble */
        if integer(ttDocumentGED.iNumeroMandat) > 0 then do :
            find first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and intnt.nocon = integer(ttDocumentGED.iNumeroMandat) no-error.
            if not available intnt
            then find first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and intnt.nocon = integer(ttDocumentGED.iNumeroMandat) no-error.
            if available intnt then ttDocumentGed.iNumeroImmeuble  = intnt.noidt.
            if ttDocumentGed.iNumeroImmeuble > 0
            then for first imble no-lock where imble.noimm = ttDocumentGed.iNumeroImmeuble:
                ttDocumentGED.cLibelleImmeuble = substitute("&1 &2", string(imble.NoImm), imble.lbnom).
            end.
        end.

        giNumSeq = giNumSeq + 1.
        if giNumSeq >= {&MAXRETURNEDROWS} then do:
            mError:createError({&information}, 211668, "{&MAXRETURNEDROWS}"). /* Nombre maximum d'enregistrements atteint (maxi [&1]) */
            leave boucleDocument.
        end.
    end. /* ttDocumentGidemat */

message "Nombre de documents gidemat filtrés " viNombredocument.

    if valid-handle(vhProcGidemat) then run destroy in vhProcGidemat.
    if valid-handle(vhProcGidemat) then run destroy in vhProcRole.

end procedure.

procedure createttDocumentGed private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter phBuffer        as handle no-undo.
    define input parameter phProcVersement as handle no-undo.

    define variable vlLocataire       as logical   no-undo.
    define variable vlCoproprietaire  as logical   no-undo.
    define variable vlProprietaire    as logical   no-undo.
    define variable vlConseilSyndical as logical   no-undo.
    define variable vlEmployeImmeuble as logical   no-undo.
    define variable voCollection      as collection no-undo.

    define buffer igedtypd for igedtypd.
    define buffer pclie    for pclie.
    define buffer ctrat    for ctrat.
    define buffer ctctt    for ctctt.
    define buffer vbRoles  for roles.
    define buffer imble    for imble.
    define buffer local    for local.
    define buffer ietab    for ietab.
    define buffer trdos    for trdos.

    find first igedtypd no-lock
        where igedtypd.typdoc-cd = phBuffer::typdoc-cd no-error.
    find first ttTypeRole
        where ttTypeRole.cTypeRole = string(phBuffer::tprol, "99999") no-error.
    assign
        voCollection      = f_VisibiliteRoleExtranet(string(phBuffer::tprol, "99999"), phBuffer::noimm, phBuffer::nomdt)
        vlConseilSyndical = (if num-entries(phBuffer::cdivers5) >= 1 then entry(1, phBuffer::cdivers5) = "O" else voCollection:getLogical('voirConseilSyndic')   = true)
        vlLocataire       = (if num-entries(phBuffer::cdivers5) >= 2 then entry(2, phBuffer::cdivers5) = "O" else voCollection:getLogical('voirLocataire')       = true)
        vlProprietaire    = (if num-entries(phBuffer::cdivers5) >= 3 then entry(3, phBuffer::cdivers5) = "O" else voCollection:getLogical('voirProprietaire')    = true)
        vlCoproprietaire  = (if num-entries(phBuffer::cdivers5) >= 4 then entry(4, phBuffer::cdivers5) = "O" else voCollection:getLogical('voircoproprietaire')  = true)
        vlEmployeImmeuble = (if num-entries(phBuffer::cdivers5) >= 5 then entry(5, phBuffer::cdivers5) = "O" else voCollection:getLogical('voirEmployeImmeuble') = true)
    .
    create ttDocumentGED.
    assign
        ttDocumentGED.daDateDuDoc                = phBuffer::dadoc
        ttDocumentGED.daDateCreation             = phBuffer::dacre
        ttDocumentGED.iIdentifiantGed            = phBuffer::id-fich /* Id ged locale */
        ttDocumentGED.cIdentifiantGidemat        = (if int64(phBuffer::resid) > 0 then phBuffer::resid else "")  /* Resid Maarch */
        ttDocumentGED.iNumeroMandat              = phBuffer::nomdt
        ttDocumentGED.cNumeroCompte              = phBuffer::cnumcpt
        ttDocumentGED.cLibelleTiers              = phBuffer::clibcpt
        ttDocumentGED.iNumeroTypeDocument        = phBuffer::typdoc-cd
        ttDocumentGED.cLibelleTypeDocument       = (if available igedtypd then igedtypd.lib else "")
        ttDocumentGED.cObjet                     = phBuffer::libobj
        ttDocumentGED.iCodeTypeRole              = phBuffer::tprol
        ttDocumentGED.cLibelleTypeRole           = (if available ttTypeRole then ttTypeRole.cLibelleTypeRole else "")
        ttDocumentGED.iNumeroRole                = phBuffer::norol
        ttDocumentGED.iNumeroTiers               = phBuffer::notie
        ttDocumentGED.iNumeroContrat             = phBuffer::noctt
        ttDocumentGED.cCodeTypeContrat           = phBuffer::tpctt
        ttDocumentGED.cCodeNatureDocument        = phBuffer::cdnat
        ttDocumentGED.iNumeroDossier             = phBuffer::nodoss
        ttDocumentGED.iNumeroImmeuble            = phBuffer::noimm
        ttDocumentGED.iNumeroLot                 = phBuffer::nolot
        ttDocumentGED.cCodeThemeGed              = phBuffer::theme-cd
        ttDocumentGED.lPublie                    = (if phBuffer::web-fgmadisp = true then true else false)
        ttDocumentGED.cCodeThemeGiExtranet       = phBuffer::web-theme-cd /* theme extranet */
        ttDocumentGED.cObjetGiExtranet           = phBuffer::web-libobjet
        ttDocumentGED.lVisibiliteCS              = vlConseilSyndical
        ttDocumentGED.lVisibiliteLocataire       = vlLocataire
        ttDocumentGED.lVisibiliteProprietaire    = vlProprietaire
        ttDocumentGED.lVisibiliteCoproprietaire  = vlCoproprietaire
        ttDocumentGED.lVisibiliteEmployeImmeuble = vlEmployeImmeuble
        ttDocumentGED.lNonPubliable              = (phBuffer::cdivers4 = "O")
        ttDocumentGED.cStatutTransfert           = phBuffer::statut-cd
        ttDocumentGED.cNomFichier                = phBuffer::nmfichier
        ttDocumentGED.iNumeroContratFournisseur  = integer(phBuffer::noctrat)
        ttDocumentGED.iCodeReferenceSociete      = phBuffer::num-soc
        ttDocumentGED.iNumeroOrdre               = phBuffer::noord
        ttDocumentGED.rRowid                     = phBuffer:rowid
        ttDocumentGED.cDescriptif                = phBuffer::libdesc
        ttDocumentGED.cMotCle                    = phBuffer::cdivers1
        ttDocumentGED.cTypeIdentifiant           = phbuffer::tpidt
        ttDocumentGED.iNumeroIdentifiant         = phbuffer::noidt
        ttDocumentGED.CRUD                       = "R"
        ttDocumentGED.dtTimestamp                = datetime(phBuffer::dtmsy, phBuffer::hemsy)
    .
    find first pclie no-lock
        where pclie.tppar = "THEME"
          and pclie.zon01 = ttDocumentGED.cCodeThemeGed no-error.
    ttDocumentGED.cLibelleThemeGed = (if available pclie then pclie.zon02 else "").

    /* nom du role */
    if phBuffer::notie = 0 and phBuffer::norol = 0 and phBuffer::tprol = 0
    then ttDocumentGED.cLibelleTiers = "".
    else do:
        if phBuffer::notie > 0
        then find first vbRoles no-lock
            where vbRoles.notie    = phBuffer::notie
              and vbRoles.fg-princ = true no-error.
        else find first vbRoles no-lock
            where vbRoles.tprol = string(phBuffer::tprol,"99999")
              and vbRoles.norol = phBuffer::norol no-error.
        ttDocumentGED.cLibelleTiers = if available vbRoles
                                      then entry(1, vbRoles.lbrech, separ[1])
                                      else substitute("??? &1  - &2 - &3", phBuffer::tprol, string(phBuffer::norol), string(phBuffer::notie)).
    end.
    /* libelle contrat */
    if phBuffer::noctt > 0 then do:
        find first ctrat no-lock
            where ctrat.tpcon = phBuffer::tpctt
              and ctrat.nocon = phBuffer::noctt no-error.
        {&_proparse_ prolint-nowarn(release)}
        if available ctrat
        then find first vbRoles no-lock
            where vbRoles.tprol = ctrat.tprol
              and vbRoles.norol = ctrat.norol no-error.
        else release vbRoles.
    end.
    else find first vbRoles no-lock
        where vbRoles.tprol = string(phBuffer::tprol, "99999")
          and vbRoles.norol = phBuffer::norol no-error.
    ttDocumentGED.cLibelleRoleContrat = if phBuffer::tprol > 0
                                        then substitute('&1 N° &2       -       &3&4     &5'
                                               , ttDocumentGED.cLibelleTypeRole
                                               , trim(string(phBuffer::norol, ">>>>>99999"))
                                               , outilTraduction:getLibelleProg("O_CLC", phBuffer::tpctt)
                                               , if phBuffer::noctt > 0 then " N° " + string(phBuffer::noctt) else ""
                                               , if available vbRoles then entry(1, vbRoles.lbrech, separ[1]) else "")
                                        else "".

    /* Libelle immeuble */
    if phBuffer::noimm > 0
    then for first imble no-lock
        where imble.noimm = phBuffer::noimm:
        ttDocumentGED.cLibelleImmeuble = substitute("&1 &2", string(imble.NoImm), imble.lbnom).
    end.
    /* Libellé lot */
    for first local no-lock
        where local.nolot = phBuffer::nolot
          and local.noimm = phBuffer::noimm:
         ttDocumentGED.cLibelleLot = outilTraduction:getLibelleParam("NTLOT", local.ntlot).
    end.
    /* Libelle mandat / contrat fournisseur */
    for first ietab no-lock
        where ietab.soc-cd = phBuffer::num-soc
          and ietab.etab-cd = phBuffer::nomdt:
        /* Mandat */
        ttDocumentGED.cLibelleMandat = substitute('&1 - &2', string(ietab.etab-cd, "99999"), trim(substring(ietab.lbrech, 1, 60, 'character'))).
        /* Libelle contrat fournisseur */
        if integer(phBuffer::noctrat) > 0 and lookup(string(ietab.profil-cd),"91,21") > 0
        then for first ctctt no-lock
            where ctctt.tpct1 = (if ietab.profil-cd = 91 then {&TYPECONTRAT-mandat2Syndic} else {&TYPECONTRAT-mandat2Gerance})
              and ctctt.noct1 = ietab.etab-cd
              and ctctt.tpct2 = {&TYPECONTRAT-fournisseur}
              and ctctt.noct2 = integer(phBuffer::noctrat)
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2
          , first pclie no-lock
            where pclie.tppar = "CTENT"
              and num-entries(ctrat.lbdiv, "#") >= 4
              and pclie.zon02 = entry(3, ctrat.lbdiv, "#")
              and pclie.zon03 = entry(4, ctrat.lbdiv, "#"):
            ttDocumentGED.cLibelleContratFournisseur = pclie.zon04.
        end.
    end.
    /* cLibelleDossierTravaux */
    for first trdos no-lock
        where trdos.nocon = phBuffer::nomdt
          and trdos.nodos = phBuffer::nodoss :
        ttDocumentGED.cLibelleDossierTravaux = trdos.lbdos.
    end.

    /* Visibilité giextranet */
    if valid-handle(phProcVersement)
    then run getVisibiliteRoleExtranetDocument in phProcVersement(buffer ttDocumentGED, output table ttVisibiliteExtranet append).

end procedure.

procedure getDocumentGED:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input parameter prRowid as rowid no-undo.
    define output parameter table for ttDocumentGed.
    define output parameter table for ttVisibiliteExtranet.

    define variable vhProcVersement as handle  no-undo.
    define variable vhProcRole      as handle  no-undo.
    define variable vhBuffer        as handle  no-undo.
    define variable vhQuery         as handle  no-undo.

    run role/role.p persistent set vhProcRole.
    run getTokenInstance in vhProcRole(mToken:JSessionId).
    run ged/versement.p persistent set vhProcVersement.
    run getTokenInstance in vhProcVersement(mToken:JSessionId).

    empty temp-table ttDocumentGED.
    create buffer vhBuffer for table "igeddoc".
    create query vhQuery.
    vhQuery:set-buffers(vhBuffer).
    // Ne fonctionne pas : vhQuery:query-prepare(substitute("for each igeddoc no-lock where rowid(igeddoc) = &1", prRowid)).
    vhQuery:query-prepare(substitute("for each igeddoc no-lock where rowid(igeddoc) = to-rowid('&1')", prRowid)).
    vhQuery:query-open().
boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.
        run getTypeRoleParReference in vhProcRole (vhBuffer::num-soc, output table ttTypeRole).
        run getTypeDocument.
        run createttDocumentGed(vhBuffer, vhProcVersement).
    end.
    if not can-find(first ttDocumentGed) then mError:createError({&info}, 1000083). /* Aucun document */
    if valid-handle(vhProcVersement) then run destroy in vhProcVersement.
    if valid-handle(vhProcRole) then run destroy in vhProcRole.

end procedure.

procedure contratTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeTiers      as character no-undo.
    define input  parameter piReference      as integer   no-undo.
    define input  parameter piNoeudMdt       as integer   no-undo.
    define input  parameter piNumeroImmeuble as integer   no-undo.
    define input  parameter phProcRole       as handle    no-undo.

    define variable viBoucle   as integer   no-undo.
    define variable vcLsCttAss as character no-undo.
    define variable vcTpCttAss as character no-undo.
    define variable viMandat   as integer   no-undo.
    define variable vcCpt-cd   as character no-undo.
    define buffer vbCtrat for ctrat.
    define buffer ccptcol for ccptcol.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer ctctt   for ctctt.
    define buffer vbRoles for roles.

    for each vbRoles no-lock
        where vbRoles.notie = integer(pcCodeTiers):
        if lookup(vbRoles.tprol, substitute("&1,&2", {&TYPEROLE-salariePegase}, {&TYPEROLE-salarie})) > 0
        then find first ccptcol no-lock
            where ccptcol.soc-cd = piReference
              and ccptcol.tprol  = integer({&TYPEROLE-salarie}) no-error.
        else find first ccptcol no-lock
            where ccptcol.soc-cd = piReference
              and ccptcol.tprol  = integer(if vbRoles.tprol = {&TYPEROLE-mandant } then {&TYPEROLE-coIndivisaire} else vbRoles.tprol) no-error.
        if available ccptcol then do:
            case string(ccptcol.tprol, "99999"):
                when {&TYPEROLE-coproprietaire} then vcLsCttAss = {&TYPECONTRAT-titre2copro}.
                when {&TYPEROLE-locataire}     then vcLsCttAss = {&TYPECONTRAT-bail}.
                when {&TYPEROLE-salarie}       then vcLsCttAss = substitute("&1,&2", {&TYPECONTRAT-Salarie}, {&TYPECONTRAT-SalariePegase}).
                when {&TYPEROLE-mandant }      then vcLsCttAss = if piReference = 10 then {&TYPECONTRAT-bail} else {&TYPECONTRAT-mandat2Gerance}.
                when {&TYPEROLE-coIndivisaire} then vcLsCttAss = substitute("&1,&2", {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-titre2copro}).
                otherwise         vcLsCttAss = "".
            end case.
            if vcLsCttAss > "" then do viBoucle = 1 to num-entries(vcLsCttAss):
                vcTpCttAss = entry(viBoucle, vcLsCttAss).
boucle:
                for each intnt no-lock
                    where intnt.tpidt = vbRoles.tprol
                      and intnt.noidt = vbRoles.norol
                      and intnt.tpcon = vcTpCttAss
                  , first ctrat no-lock
                    where ctrat.tpcon = intnt.tpcon
                      and ctrat.nocon = intnt.nocon
                      and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}:
                    /* Recherche du mandat */
                    viMandat = 0.
                    if lookup(ctrat.tpcon, substitute("&1,&2", {&TYPECONTRAT-mandat2Syndic}, {&TYPECONTRAT-mandat2Gerance})) > 0
                    then do:
                        viMandat = ctrat.nocon.
                        find first vbCtrat no-lock
                            where vbCtrat.tpcon = intnt.tpcon
                              and vbCtrat.nocon = intnt.nocon no-error.
                    end.
                    else for first ctctt no-lock
                        where ctctt.tpct1 >= {&TYPECONTRAT-mandat2Syndic} and ctctt.tpct1 <= {&TYPECONTRAT-mandat2Gerance}
                          and ctctt.tpct2 = ctrat.tpcon
                          and ctctt.noct2 = ctrat.nocon:
                        find first vbCtrat no-lock
                            where vbCtrat.tpcon = ctctt.tpct1
                              and vbCtrat.nocon = ctctt.noct1 no-error.
                        if not available vbCtrat then next boucle.
                        viMandat = vbCtrat.nocon.
                    end.
                    if piNoeudMdt > 0 and viMandat > 0 and viMandat <> piNoeudMdt then next boucle.
                    if viMandat > 0 and piNumeroImmeuble > 0
                    and not f_ImmEtab(piReference, piNumeroImmeuble , viMandat) then next boucle. /* filtre sur l'immeuble */
                    vcCpt-cd = if vbRoles.tprol  = {&TYPEROLE-salarie}
                               then string(vbRoles.norol, "999999")
                               else substring(string(vbRoles.norol, ">>>>>99999"), 6, 5, 'character').
                    find first ttTiers
                        where ttTiers.coll-cle = ccptcol.coll-cle
                          and ttTiers.cpt-cd = vcCpt-cd no-error.
                    if not available ttTiers
                    then fCreatettTiers(if vbRoles.tprol = {&TYPEROLE-coIndivisaire}
                                        then if vbCtrat.tpcon = {&TYPECONTRAT-mandat2Syndic} then "C" else "P"
                                             else if vbRoles.tprol = {&TYPEROLE-mandant}       then "P" else ccptcol.coll-cle
                                      , vcCpt-cd, viMandat).
                end.
            end. /* DO viBoucle = 1 TO num-entries(vcLsCttAss): */
        end.
        else if lookup(string(vbRoles.notie), dynamic-function("f_lstCabinet" in phProcRole)) > 0
        then fCreatettTiers("F", "00000", piNoeudMdt). /* Tiers cabinet */
    end. /* roles */

end procedure.

procedure createRequete private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcListeTypeDocument as character  no-undo.

    define variable viReference          as integer   no-undo.
    define variable viNumeroImmeuble     as integer   no-undo.
    define variable viNumeroTypeDocument as integer   no-undo.
    define variable vcListeCodeThemeGed  as character no-undo.
    define variable vcObjet              as character no-undo.
    define variable vdaDateDebut         as date      no-undo.
    define variable vdaDateFin           as date      no-undo.
    define variable vcChemise            as character no-undo.
    define variable vcMandat             as character no-undo.
    define variable vcReqTypDoc          as character no-undo.
    define variable vcCodeTiers          as character no-undo.

    define buffer intnt  for intnt.
    define buffer csscpt for csscpt.
    define buffer ietab  for ietab.
    define buffer isoc   for isoc.

    assign
        viReference          = goCollection:getInteger("iCodeReferenceSociete")
        viNumeroImmeuble     = goCollection:getInteger("iNumeroImmeuble")
        viNumeroTypeDocument = goCollection:getInteger("iNumeroTypeDocument")
        vcListeCodeThemeGed  = goCollection:getCharacter("cListeCodeThemeGed")
        vcObjet              = goCollection:getCharacter("cObjet")
        vdaDateDebut         = goCollection:getDate("daDateDebut")
        vdaDateFin           = goCollection:getDate("daDateFin")
    .
DOC:
    for each ttTypeDocument
        where ttTypeDocument.orig-cd = "3" /* uniquement types de doc production */
          and (if pcListeTypeDocument > "" then lookup(string(ttTypeDocument.typdoc-cd), pcListeTypeDocument) > 0 else true)
          and (if entry(1, vcListeCodeThemeGed) > "" then ttTypeDocument.theme-cd = entry(1, vcListeCodeThemeGed) else true):

        vcChemise = "".
        /* Recherche du n° de compte */
boucleTiers:
        for each ttTiers:
            vcMandat = if ttTiers.mandat-cd <> ? then string(ttTiers.mandat-cd, "99999") else "".
            if not fFiltreTiers(vcMandat, viReference, viNumeroImmeuble, ttTypeDocument.typedossier, ttTypeDocument.gidemat-typdoc)
            then next boucleTiers.
            /* Filtre selon le type de mandat */
            assign
                vcReqTypDoc = (if viNumeroTypeDocument > 0  or pcListeTypeDocument > "" then ttTypeDocument.gidemat-typdoc  else "")
                vcCodeTiers = ttTiers.cpt-cd
            .
            /* Construction de la requete Gidemat */
            case ttTypeDocument.gidemat-typdoc:
                when "2000" then do:                          /* compte de gerance, Tous les mandats du tiers */
                    vcMandat = "".
                    if ttTiers.mandat-cd > 0 and fIsNull(vcCodeTiers)
                    then for each csscpt no-lock
                        where csscpt.soc-cd     = viReference
                          and csscpt.etab-cd    = ttTiers.mandat-cd
                          and csscpt.coll-cle   = "P"
                          and csscpt.sscoll-cle = "P":
                        if not can-find(first ttRequete
                            where ttRequete.cTypeDocument  = ttTypeDocument.gidemat-typdoc
                              and ttRequete.cMandat        = vcMandat
                              and ttRequete.cTiers         = csscpt.cpt-cd
                              and ttRequete.cObjet         = replace(vcObjet, "*", "%")
                              and ttRequete.cNumeroSociete = string(viReference, "99999")
                              and ttRequete.daDebut        = vdaDateDebut
                              and ttRequete.daFin          = vdaDateFin)
                        then do:
                            create ttRequete.
                            assign
                                ttRequete.cTypeDocument     = ttTypeDocument.gidemat-typdoc
                                ttRequete.cMandat           = vcMandat
                                ttRequete.cTiers            = csscpt.cpt-cd
                                ttRequete.cObjet            = replace(vcObjet, "*", "%")
                                ttRequete.cNumeroSociete    = string(viReference, "99999")
                                ttRequete.daDebut           = vdaDateDebut
                                ttRequete.daFin             = vdaDateFin
                            .
                        end.
                        if not can-find(first ttRgrpTiers
                            where ttRgrpTiers.cColl-Cle = ttTiers.coll
                              and ttRgrpTiers.cCpt-cd   = vcCodeTiers)
                        then fCreateRegroupement(ttTiers.coll, vcCodeTiers).
                    end.
                    else do:
                        if not can-find(first ttRequete
                            where ttRequete.cTypeDocument  = ttTypeDocument.gidemat-typdoc
                              and ttRequete.cMandat        = vcMandat
                              and ttRequete.cTiers         = vcCodeTiers
                              and ttRequete.cObjet         = replace(vcObjet, "*", "%")
                              and ttRequete.cNumeroSociete = string(viReference, "99999")
                              and ttRequete.daDebut        = vdaDateDebut
                              and ttRequete.daFin          = vdaDateFin)
                        then do:
                            create ttRequete.
                            assign
                                ttRequete.cTypeDocument     = string(ttTypeDocument.gidemat-typdoc)
                                ttRequete.cMandat           = vcMandat
                                ttRequete.cTiers            = vcCodeTiers
                                ttRequete.cObjet            = replace(vcObjet, "*", "%")
                                ttRequete.cNumeroSociete    = string(viReference, "99999")
                                ttRequete.daDebut           = vdaDateDebut
                                ttRequete.daFin             = vdaDateFin
                            .
                        end.
                        if not can-find(first ttRgrpTiers
                            where ttRgrpTiers.cColl-Cle = ttTiers.coll
                              and ttRgrpTiers.cCpt-cd   = vcCodeTiers)
                        then fCreateRegroupement(ttTiers.coll, vcCodeTiers).
                    end.
                end.
                otherwise do:
                    if ttTypeDocument.gidemat-typdoc = "2100"  /* factures fournisseurs de loyers -> Le numéro d'immeuble est dans le numéro de mandat */
                    then do:
                        if ttTiers.mandat-cd > 0
                        then for each isoc no-lock
                            where isoc.soc-cd = viReference
                          , first ietab no-lock
                            where ietab.soc-cd = isoc.soc-cd
                              and ietab.etab-cd = ttTiers.mandat-cd
                          , first intnt no-lock
                            where intnt.tpidt = {&TYPEBIEN-immeuble}
                              and intnt.tpcon = (if ietab.profil-cd = 21 then {&TYPECONTRAT-mandat2Gerance} else {&TYPECONTRAT-mandat2Syndic} )
                              and intnt.nocon = ietab.etab-cd:
                            assign
                                vcMandat    = string(intnt.noidt, "99999")
                                vcReqTypDoc = ttTypeDocument.gidemat-typdoc /* requete spécifique avec type de doc forcé */
                            .
                            leave.
                        end.
                        else if viNumeroImmeuble > 0
                        then assign
                            vcMandat    = string(viNumeroImmeuble,"99999")
                            vcReqTypDoc = ttTypeDocument.gidemat-typdoc /* requete spécifique avec type de doc forcé */
                        .
                    end.
                    else if ttTypeDocument.gidemat-typdoc begins "7550" /* Bordereau remise de cheque */
                    then do:
                        if fIsNull(vcCodeTiers) then do:
                            if integer(vcMandat) = 0 then vcMandat = "".
                            assign
                                vcReqTypDoc = ttTypeDocument.gidemat-typdoc     /* requete spécifique avec type de doc forcé */
                                vcChemise   = "BR"
                            .
                        end.
                        else next boucleTiers.
                    end.
                    else if ttTypeDocument.gidemat-typdoc begins "75" /* cheques / virements */
                    then assign
                        vcReqTypDoc = ttTypeDocument.gidemat-typdoc           /* requete spécifique avec type de doc forcé */
                        vcChemise   = if ttTypeDocument.gidemat-typdoc = "7550"
                                     then "BR"
                                     else if ttTypeDocument.gidemat-typdoc = "7500"
                                          then "CH"
                                          else "VT"
                    .
                    else if ttTypeDocument.gidemat-typdoc begins "60" or ttTypeDocument.gidemat-typdoc begins "73"
                    then assign
                        vcMandat    = "00000"
                        vcCodeTiers = ""
                        vcChemise   = "QU"
                    .
                    else if ttTypeDocument.gidemat-typdoc begins "61" or ttTypeDocument.gidemat-typdoc begins "62"
                    then assign
                        vcMandat    = "00000"
                        vcCodeTiers = ""
                        vcChemise   = "PA"
                    .
                    else if ttTypeDocument.gidemat-typdoc begins "80" or ttTypeDocument.gidemat-typdoc = "90"
                    then assign
                        vcReqTypDoc = ttTypeDocument.gidemat-typdoc /* requete spécifique avec type de doc forcé */
                        vcMandat    = "00000"
                        vcCodeTiers = "000000"
                    .
                    else if ttTiers.coll-cle = "F" and ttTiers.cpt-cd = "00000"
                    then vcReqTypDoc = ttTypeDocument.gidemat-typdoc. /* requete spécifique avec type de doc forcé */.
                    if not can-find(first ttRequete
                        where ttRequete.cTypeDocument  = string(if viNumeroTypeDocument > 0 or pcListeTypeDocument > "" then ttTypeDocument.gidemat-typdoc else vcReqTypDoc)
                          and ttRequete.cMandat        = vcMandat
                          and ttRequete.cTiers         = vcCodeTiers
                          and ttRequete.cChemise       = vcChemise
                          and ttRequete.cObjet         = replace(vcObjet, "*", "%")
                          and ttRequete.cNumeroSociete = string(viReference, "99999")
                          and ttRequete.daDebut        = vdaDateDebut
                          and ttRequete.daFin          = vdaDateFin)
                    then do:
                        create ttRequete.
                        assign
                            ttRequete.cTypeDocument     = if viNumeroTypeDocument > 0 or pcListeTypeDocument > "" then string(ttTypeDocument.gidemat-typdoc) else vcReqTypDoc
                            ttRequete.cMandat           = vcMandat
                            ttRequete.cTiers            = vcCodeTiers
                            ttRequete.cChemise          = vcChemise
                            ttRequete.cObjet            = replace(vcObjet,"*","%")
                            ttRequete.cNumeroSociete    = string(viReference, "99999")
                            ttRequete.daDebut           = vdaDateDebut
                            ttRequete.daFin             = vdaDateFin
                        .
                     end.
                     if not can-find(first ttRgrpTiers
                         where ttRgrpTiers.cColl-Cle = ttTiers.coll
                           and ttRgrpTiers.cCpt-cd   = vcCodeTiers)
                     then fCreateRegroupement(ttTiers.coll, vcCodeTiers).
                end.
            end case.
        end. /* ttTiers */
    end. /* ttTypeDocument */

end procedure.
