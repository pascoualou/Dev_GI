/*------------------------------------------------------------------------
File        : token.cls
Purpose     :
Author(s)   : kantena - 2016/05/24
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

block-level on error undo, throw.

class oerealm.token serializable: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property cItemSep             as character no-undo get. set.
    define public property cCodeSep             as character no-undo get. set.
    define public property JSessionId           as character no-undo get. set.
    define public property horodate             as datetime  no-undo get. set.
    define public property iUser                as integer   no-undo get. set.
    define public property cUser                as character no-undo get. set.
    define public property iCodeSociete         as integer   no-undo get. set.
    define public property cRefPrincipale       as character no-undo get. set.
    define public property cRefCopro            as character no-undo get. set.
    define public property cRefGerance          as character no-undo get. set.
    define public property iGestionnaire        as integer   no-undo get. set.
    define public property iCollaborateur       as integer   no-undo get. set.
    define public property lDebug               as logical   no-undo get. set.
    define public property iTraceLevel          as integer   no-undo get. set.  // Niveau de trace
    define public property iCodeLangueSession   as integer   no-undo get. set.
    define public property iCodeLangueReference as integer   no-undo get. set.
    define public property cValeur              as character no-undo get. set.
    define public property daDateFinRespGerance as date      no-undo get. set.
    define public property daDateFinRespCopro   as date      no-undo get. set.
    define public property cDeviseReference     as character no-undo get. set.
    define public property cDeviseSession       as character no-undo get. set.

    method public character getValeur(pcCode as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable viCpt     as integer   no-undo.
        define variable viEntries as integer   no-undo.
        define variable vcEntry   as character no-undo.

        viEntries = num-entries(this-object:cValeur, this-object:cItemSep).
        do viCpt = 1 to viEntries:
            vcEntry = entry(viCpt, this-object:cValeur, this-object:cItemSep).
            if entry(1, vcEntry, this-object:cCodeSep) = pcCode
            then if num-entries(vcEntry, this-object:cCodeSep) > 1
                 then return entry(2, vcEntry, this-object:cCodeSep).
                 else return ''.
        end.
        return ?.

    end method.

    method public integer getSociete (pcTypeMandat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return integer(if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic}
                       then this-object:cRefCopro
                       else if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then this-object:cRefGerance else this-object:cRefPrincipale).
    end method.

end class.
