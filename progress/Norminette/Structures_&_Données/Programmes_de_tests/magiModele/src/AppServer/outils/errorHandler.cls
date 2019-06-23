/*------------------------------------------------------------------------
File        : errorHandler.cls
Purpose     :
Author(s)   : kantena - 2016/10/03
Notes       :
------------------------------------------------------------------------*/

using outils.outilTraduction.
using outils.outilFormatage.

block-level on error undo, throw.

class outils.errorHandler final serializable:
/*------------------------------------------------------------------------------
Purpose:
Notes:
------------------------------------------------------------------------------*/
    {application/include/error.i}
    {application/include/listeErreur.i}

	constructor public errorHandler ( ):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

	end constructor.

	destructor public errorHandler ( ):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        empty temp-table ttError.

	end destructor.




    method public void createListeErreur(pcLibelleAno as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        create ttListeErreur.
        assign
            ttListeErreur.cLibelle = pcLibelleAno
        .

    end method.








    method public void createError(piSeverity as integer, piMessage as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcMessageTraduit as character no-undo.

        vcMessageTraduit = outilTraduction:getLibelle(piMessage).
        create ttError.
        case piSeverity:
            when {&erreur} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', vcMessageTraduit, piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = substitute('(&1) - &2', piMessage, program-name(2))
            .
            when {&question} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', entry(1, vcMessageTraduit, '|'), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = substitute('&1:&2', piMessage, if num-entries(vcMessageTraduit, '|') > 1 then entry(2, vcMessageTraduit, '|') else '')
            .
            when {&questionYesNo} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = vcMessageTraduit
                ttError.lYesNo      = ?
                ttError.cComplement = ""
            .
            otherwise assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorid    = piMessage
                ttError.cError      = substitute('&1 (&2)', vcMessageTraduit, piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = ""
            .
        end case.

    end method.

    method public void createError(piSeverity as integer, pcMessage as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate    = now
            ttError.iType       = piSeverity       // 1: Info, 2: Warning, 3: Erreur, 4: Question
            ttError.iErrorId    = 999997
            ttError.cError      = pcMessage
            ttError.lYesNo      = ?
            ttError.cComplement = ""
        .
    end method.
    
    method public void createErrorComplement(piSeverity as integer, pcMessage as character, pcComplement as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: Utilisé par la ged pour faire remonter le code utilisateur (cComplement) de nodeJS vers l'IHM
    ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate    = now
            ttError.iType       = piSeverity       // 1: Info, 2: Warning, 3: Erreur, 4: Question
            ttError.iErrorId    = 999997
            ttError.cError      = pcMessage
            ttError.lYesNo      = ?
            ttError.cComplement = pcComplement
        .
    end method.
    

    method public void create2Error(piMessage1 as integer, piMessage2 as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate    = now
            ttError.iType       = {&erreur}
            ttError.iErrorId    = 999998
            ttError.cError      = substitute('&1: &2', outilTraduction:getLibelleCompta(piMessage1), outilTraduction:getLibelleCompta(piMessage2))
            ttError.lYesNo      = ?
            ttError.cComplement = ""
        .
    end method.

    method public void createError(piSeverity as integer, piMessage as integer, pcListeSubst as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        define variable vcMessageTraduit as character no-undo.

        vcMessageTraduit = outilTraduction:getLibelle(piMessage).
        create ttError.
        case piSeverity:
            when {&erreur} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubst(vcMessageTraduit, pcListeSubst), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = substitute('(&1) - &2', piMessage, program-name(2))
            .
            when {&question} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubst(entry(1, vcMessageTraduit, '|'), pcListeSubst), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = substitute('&1:&2', piMessage, if num-entries(vcMessageTraduit, '|') > 1 then entry(2, vcMessageTraduit, '|') else '')
            .
            when {&questionYesNo} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = outilFormatage:fSubst(vcMessageTraduit, pcListeSubst)
                ttError.lYesNo      = ?
                ttError.cComplement = ""
            .
            otherwise assign
                ttError.horodate    = now
                ttError.iType       = piSeverity       // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubst(vcMessageTraduit, pcListeSubst), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = ""
            .
        end case.

    end method.
    
    method public void createErrorComplement(piSeverity as integer, piMessage as integer, pcListeSubst as character, pcComplement as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: Utilisé par la ged pour faire remonter le code utilisateur (cComplement) de nodeJS vers l'IHM
    ------------------------------------------------------------------------------*/
        define variable vcMessageTraduit as character no-undo.

        vcMessageTraduit = outilTraduction:getLibelle(piMessage).
        create ttError.
        assign
            ttError.horodate    = now
            ttError.iType       = piSeverity       // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
            ttError.iErrorId    = piMessage
            ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubst(vcMessageTraduit, pcListeSubst), piMessage)
            ttError.lYesNo      = ?
            ttError.cComplement = pcComplement
            .
    end method.

    method public void createErrorGestion(piSeverity as integer, piMessage as integer, pcListeSubst as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        define variable vcMessageTraduit as character no-undo.

        vcMessageTraduit = outilTraduction:getLibelle(piMessage).
        create ttError.
        case piSeverity:
            when {&erreur} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubstGestion(vcMessageTraduit, pcListeSubst), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = substitute('(&1) - &2', piMessage, program-name(2))
            .
            when {&question} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubstGestion(entry(1, vcMessageTraduit, '|'), pcListeSubst), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = substitute('&1:&2', piMessage, if num-entries(vcMessageTraduit, '|') > 1 then entry(2, vcMessageTraduit, '|') else '')
            .
            when {&questionYesNo} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubstGestion(entry(1, vcMessageTraduit, '|'), pcListeSubst), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = ""
            .
            otherwise assign
                ttError.horodate    = now
                ttError.iType       = piSeverity       // 1: Info, 2: Warning, 3: Erreur, 4: QuestionYesNo 5: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubstGestion(vcMessageTraduit, pcListeSubst), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = ""
            .
        end case.

    end method.

    method public void createErrorRepondue(piMessage as integer, plReponse as logical):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate    = now
            ttError.iType       = {&NIVEAU-questionRepondue}
            ttError.iErrorId    = piMessage
            ttError.cError      = outilTraduction:getLibelle(piMessage)
            ttError.cComplement = ""
            ttError.lYesNo      = plReponse
        .
    end method.
    method public void createErrorRepondue(piMessage as integer, plReponse as logical, pcListeSubst as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate    = now
            ttError.iType       = {&NIVEAU-questionRepondue}
            ttError.iErrorId    = piMessage
            ttError.cError      = outilFormatage:fSubst(outilTraduction:getLibelle(piMessage), pcListeSubst)
            ttError.cComplement = ""
            ttError.lYesNo      = plReponse
        .
    end method.

    method public void createErrorRepondueGestion(piMessage as integer, plReponse as logical, pcListeSubst as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate    = now
            ttError.iType       = {&NIVEAU-questionRepondue}
            ttError.iErrorId    = piMessage
            ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubstGestion(entry(1, outilTraduction:getLibelle(piMessage), '|'), pcListeSubst), piMessage)
            ttError.cComplement = ""
            ttError.lYesNo      = plReponse
        .
    end method.

    method public void createErrorCompta(piSeverity as integer, piMessage as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        case piSeverity:
            when {&erreur} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilTraduction:getLibelleCompta(piMessage), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = substitute('(&1) - &2', piMessage, program-name(2))
            .
            otherwise assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilTraduction:getLibelleCompta(piMessage), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = ""
            .
        end case.

    end method.

    method public void createErrorCompta(piSeverity as integer, piMessage as integer, pcListeSubst as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        case piSeverity:
            when {&erreur} then assign
                ttError.horodate    = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubst(outilTraduction:getLibelleCompta(piMessage), pcListeSubst), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = substitute('(&1) - &3', piMessage, program-name(2))
            .
            otherwise assign
                ttError.horodate = now
                ttError.iType       = piSeverity    // 1: Info, 2: Warning, 3: Erreur, 4: Question
                ttError.iErrorId    = piMessage
                ttError.cError      = substitute('&1 (&2)', outilFormatage:fSubst(outilTraduction:getLibelleCompta(piMessage), pcListeSubst), piMessage)
                ttError.lYesNo      = ?
                ttError.cComplement = ""
            .
        end case.

    end method.

    method public void createInfoRowid(pcRowid as character):
    /*------------------------------------------------------------------------------
     Purpose: Pour un enregistrement créé, permet de renvoyer le rowid en réponse.
     Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate    = now
            ttError.iType       = -1    // -1: technique, 1: Info, 2: Warning, 3: Erreur, 4: Question
            ttError.iErrorId    = 999999
            ttError.cError      = '999999'
            ttError.lYesNo      = ?
            ttError.cComplement = pcRowid
            ttError.rRowid      = to-rowid(pcRowid)
        .
    end method.
    method public void createInfoRowid(prRowid as rowid):
    /*------------------------------------------------------------------------------
     Purpose: Pour un enregistrement créé, permet de renvoyer le rowid en réponse.
     Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate    = now
            ttError.iType       = -1    // -1: technique, 1: Info, 2: Warning, 3: Erreur, 4: Question
            ttError.iErrorId    = 999999
            ttError.cError      = '999999'
            ttError.lYesNo      = ?
            ttError.cComplement = string(prRowid)
            ttError.rRowid      = prRowid
        .
    end method.



    method public void getListeErreur(output table ttListeErreur):
        /*------------------------------------------------------------------------------
        Purpose: remonte la table liste des erreurs.
        Notes: 
        ------------------------------------------------------------------------------*/

    end method.










    method public void getErrors(output table ttError):
        /*------------------------------------------------------------------------------
        Purpose: remonte la table des erreurs.
        Notes: Mais attention, si une erreur ou question, on supprime les messages rowid
               créé, car il doit y avoir un rollback.
        ------------------------------------------------------------------------------*/
        if can-find(first ttError where ttError.iType >= {&error})
        then for each ttError where ttError.iType = -1: delete ttError. end.

    end method.

    method public logical erreur():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return can-find(first ttError where ttError.iType >= {&error}).
    end method.

    method public integer reponseQuestion (piNumero as integer):
        /*------------------------------------------------------------------------------
        Purpose:  recherche si question traite par l'ihm (repondu) existe dans la table ttError pour retourner la reponse
        Notes  :  0 - question inexistante dans table ttError
                  2 - repondu non a la question
                  3 - repondu oui a la question
        ------------------------------------------------------------------------------*/
        find first ttError where ttError.iType = {&questionRepondue} and ttError.iErrorId = piNumero no-error.
        if not available ttError then return 0.
        if ttError.lYesNo = yes 
        then return 3.
        else return 2.
    end method.

    method public void resetErrors():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        empty temp-table ttError.

    end method.

    method public void copyError(pdaHorodate as datetime, 
                                 piType as integer, 
                                 piErrorId as integer, 
                                 pcError as character, 
                                 plYesNo as logical, 
                                 pcComplement as character,
                                 prRowid as rowid):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate    = pdaHorodate
            ttError.iType       = piType       
            ttError.iErrorId    = piErrorId
            ttError.cError      = pcError
            ttError.lYesNo      = plYesNo
            ttError.cComplement = pcComplement
            ttError.rRowid      = prRowid
        .
    end method.

end class.
