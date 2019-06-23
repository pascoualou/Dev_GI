/*------------------------------------------------------------------------
File        : collection.cls
Purpose     : gestion d'une collection de variables.  
Author(s)   : kantena  -  2017/03/23
Notes       : Deux implémentations possibles (amélioration des performances)
              - A partir de la classe parametre.cls (pas performant - 30 secondes pour 20 000 set/get) 
              - A partir d'une temp-table (plus performant - 0,4 secondes pour 20 000 set/get)
             liste des type de données gérées: 
             "CLOB,CHARACTER,INTEGER,INT64,LOGICAL,DATETIME,DATETIME-TZ,DATE,DECIMAL,HANDLE,ROWID,PROCEDURE", mappés en
             "lc,c,i,i6,l,dt,dz,da,d,h,r,p"
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&scoped-define externalDataType CLOB,CHARACTER,INTEGER,INT64,LOGICAL,DATETIME,DATETIME-TZ,DATE,DECIMAL,HANDLE,ROWID
&scoped-define internalDataType lc,c,i,i6,l,dt,dz,da,d,h,r

// using OpenEdge.Core.Collections.Map.  ------------------------------------------
// using outils.parametre.               ------------------------------------------
block-level on error undo, throw.

class outils.collection serializable: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
//  define property moCollection as map no-undo get. set.  ------------------------------------------
    define temp-table ttVariables no-undo
        field cNomVariable as character
        field cdataType    as character
        field cValeur      as character
        field daValeur     as date
        field dtValeur     as datetime
        field dzValeur     as datetime-tz
        field dValeur      as decimal decimals 6
        field hValeur      as handle
        field iValeur      as integer
        field i64Valeur    as int64
        field lValeur      as logical
        field rValeur      as rowid
        field bValeur      as clob
        index primaire is primary unique cNomVariable
    .
    define variable gcErreur as character no-undo initial 'La variable [&1] est déjà définie en [&2]. Création en [&3] impossible.'.

    constructor public collection ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
//        moCollection = new map().
        empty temp-table ttVariables.
    end constructor.

    method public void clear():
        /*------------------------------------------------------------------------------
        Purpose: vide la collection
        Notes:
        ------------------------------------------------------------------------------*/
        empty temp-table ttVariables.
    end method.

    method public void delete(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose: Supprime un objet de la collection
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable:
            delete ttVariables.
        end.
        return.
    end method.

    method public logical isEmpty():
        /*------------------------------------------------------------------------------
        Purpose: la collection est-elle vide?
        Notes:
        ------------------------------------------------------------------------------*/
        not can-find(first ttVariables).
    end method.

    method public logical isEqual(poCollection as outils.collection):
        /*------------------------------------------------------------------------------
        Purpose: la collection est elle égale à une autre collection?
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcLongchar as longchar no-undo.
        for each ttVariables:
            case ttVariables.cDatatype:
                when 'lc' then do:
                    vcLongchar = ttVariables.bValeur.
                    if vcLongchar <> poCollection:getLongChar(cNomVariable) then return false.
                end.
                when 'c'  then if ttVariables.cValeur   <> poCollection:getCharacter(cNomVariable)  then return false.
                when 'i'  then if ttVariables.iValeur   <> poCollection:getInteger(cNomVariable)    then return false.
                when 'i6' then if ttVariables.i64Valeur <> poCollection:getInt64(cNomVariable)      then return false.
                when 'l'  then if ttVariables.lValeur   <> poCollection:getLogical(cNomVariable)    then return false.
                when 'dt' then if ttVariables.dtValeur  <> poCollection:getDatetime(cNomVariable)   then return false.
                when 'dz' then if ttVariables.dzValeur  <> poCollection:getDatetimeTZ(cNomVariable) then return false.
                when 'da' then if ttVariables.daValeur  <> poCollection:getDate(cNomVariable)       then return false.
                when 'd'  then if ttVariables.dValeur   <> poCollection:getDecimal(cNomVariable)    then return false.
                when 'h'  then if ttVariables.hValeur   <> poCollection:getHandle(cNomVariable)     then return false.
                when 'r'  then if ttVariables.rValeur   <> poCollection:getRowid(cNomVariable)      then return false.
            end case.
        end.
        return true.
    end method.

    method public longchar serialize():
        /*------------------------------------------------------------------------------
        Purpose: serialisation de l'objet en "code separ[2] valeur separ[1] ..."
        Notes:
        ------------------------------------------------------------------------------*/
        {application/include/glbsepar.i}
        define variable vcRetour   as longchar no-undo.

        for each ttVariables:
            case ttVariables.cDatatype:
                when 'C'  then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.cValeur).
                when 'LC' then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.bValeur).
                when 'L'  then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.lValeur).
                when 'I'  then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.iValeur).
                when 'I6' then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.i64Valeur).
                when 'D'  then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.dValeur).
                when 'DA' then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.daValeur).
                when 'DT' then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.dtValeur).
                when 'DZ' then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.dzValeur).
                when 'H'  then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.hValeur).
                when 'R'  then vcRetour = substitute('&1&2&3&4&5', vcRetour, separ[1], ttVariables.cNomVariable, separ[2], ttVariables.rValeur).
            end case.
        end.
        vcRetour = trim(vcRetour, separ[1]).
        return vcRetour.
    end method.

    method public void set(pcVariable as character, pcValeur as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "C"
            no-error.
        end.
        else if ttVariables.cdataType <> 'C' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'C').
        ttVariables.cValeur = trim(pcValeur).
    end method.
    method public character getCharacter(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "C":
            return ttVariables.cValeur.
        end.
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "LC":
            return string(ttVariables.bValeur).
        end.
        return ?.
    end method.
    method public void deleteCharacter(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'C':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, pcValeur as longchar):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "LC"
            no-error.
        end.
        else if ttVariables.cdataType <> 'LC' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'LC').
        ttVariables.bValeur = trim(pcValeur).
    end method.
    method public longchar getLongchar(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcLongchar as longchar no-undo.
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "LC":
            vcLongchar = ttVariables.bValeur. 
            return vcLongchar. 
        end.
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "C":
            return ttVariables.cValeur.
        end.
        return ?.
    end method.
    method public void deleteLongchar(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'LC':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, piValeur as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "I"
            no-error.
        end.
        else if ttVariables.cdataType <> 'I' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'I').
        ttVariables.iValeur = piValeur.
    end method.
    method public integer getInteger(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "I":
            return ttVariables.iValeur.
        end.
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "I6":
            return integer(ttVariables.i64Valeur).
        end.
        return ?.
    end method.
    method public void deleteInteger(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'I':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, piValeur as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "I6"
            no-error.
        end.
        else if ttVariables.cdataType <> 'I6' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'I6').
        ttVariables.i64Valeur = piValeur.
    end method.
    method public int64 getInt64(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "I6":
            return ttVariables.i64Valeur.
        end.
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "I":
            return ttVariables.iValeur.
        end.
        return ?.
    end method.
    method public void deleteInt64(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'I6':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, plValeur as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "L"
            no-error.
        end.
        else if ttVariables.cdataType <> 'L' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'L').
        ttVariables.lValeur = plValeur.
    end method.
    method public logical getLogical(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables where ttVariables.cNomVariable = pcVariable:
            return ttVariables.lValeur.
        end.
        return ?.
    end method.
    method public void deleteLogical(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'L':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, pdaValeur as date):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "DA"
            no-error.
        end.
        else if ttVariables.cdataType <> 'DA' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'DA').
        ttVariables.daValeur = pdaValeur.
    end method.
    method public date getDate(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "DA":
            return ttVariables.daValeur.
        end.
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "DT":
            return date(ttVariables.dtValeur).
        end.
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "DZ":
            return date(ttVariables.dzValeur).
        end.
        return ?.
    end method.
    method public void deleteDate(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'DA':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, pdtValeur as datetime):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "DT"
            no-error.
        end.
        else if ttVariables.cdataType <> 'DT' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'DT').
        ttVariables.dtValeur = pdtValeur.
    end method.
    method public datetime getDatetime(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "DT":
            return ttVariables.dtValeur.
        end.
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "DA":
            return datetime(ttVariables.daValeur).
        end.
        return ?.
    end method.
    method public void deleteDatetime(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'DT':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, pdzValeur as datetime-tz):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "DZ"
            no-error.
        end.
        else if ttVariables.cdataType <> 'DZ' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'DZ').
        ttVariables.dzValeur = pdzValeur.
    end method.
    method public datetime-tz getDatetimeTZ(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "DZ":
            return ttVariables.dzValeur.
        end.
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = "DA":
            return datetime-tz(ttVariables.daValeur).
        end.
        return ?.
    end method.
    method public void deleteDatetimeTZ(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'DZ':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, pdValeur as decimal):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "D"
            no-error.
        end.
        else if ttVariables.cdataType <> 'D' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'D').
        ttVariables.dValeur = pdValeur.
    end method.
    method public decimal getDecimal(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables where ttVariables.cNomVariable = pcVariable:
            return ttVariables.dValeur.
        end.
        return ?.
    end method.
    method public void deleteDecimal(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'D':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, phValeur as handle):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "H"
            no-error.
        end.
        else if ttVariables.cdataType <> 'H' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'H').
        ttVariables.hValeur = phValeur.
    end method.
    method public handle getHandle(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables where ttVariables.cNomVariable = pcVariable:
            return ttVariables.hValeur.
        end.
        return ?.
    end method.
    method public void deleteHandle(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'H':
            delete ttVariables.
        end.
        return.
    end method.

    method public void set(pcVariable as character, prValeur as rowid):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        find first ttVariables where ttVariables.cNomVariable = pcVariable no-error.
        if not available ttVariables then do:
            create ttVariables.
            assign
                ttVariables.cNomVariable = pcVariable
                ttVariables.cdataType    = "R"
            no-error.
        end.
        else if ttVariables.cdataType <> 'R' then return error substitute(gcErreur, pcVariable, ttVariables.cdataType, 'R').
        ttVariables.rValeur = prValeur.
    end method.
    method public rowid getRowid(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables where ttVariables.cNomVariable = pcVariable:
            return ttVariables.rValeur.
        end.
        return ?.
    end method.
    method public void deleteRowid(pcVariable as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for first ttVariables
            where ttVariables.cNomVariable = pcVariable
              and ttVariables.cdataType    = 'R':
            delete ttVariables.
        end.
        return.
    end method.

    method public character getShortMessage(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:  Pour transformer un blob en character, on passe par un longchar.
        Notes: si pcType dans "{&externalDataType}", mappé en "{&internalDataType}"
        ------------------------------------------------------------------------------*/
        define variable vcRetour   as character no-undo.
        define variable vcLongchar as longchar  no-undo.
        define variable vi         as integer   no-undo.

        vi = lookup(pcType, "{&externalDataType}").
        if vi > 0 then pcType = entry(vi, "{&internalDataType}").
        for each ttVariables
            where if pcType = ? or pcType = "" then true else ttVariables.cDatatype = pcType:
            case ttVariables.cDatatype:
                when 'C'  then vcRetour = substitute('&2&1&3: &4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.cValeur).
                when 'LC' then assign
                    vcLongchar = ttVariables.bValeur
                    vcLongchar = substring(vcLongchar, 1, 60) + (if length(vcLongchar) > 60 then "..." else "")
                    vcRetour   = substitute('&2&1&3: &4', chr(13), vcRetour, ttVariables.cNomVariable, string(vcLongchar))
                .
                when 'L'  then vcRetour = substitute('&2&1&3:&4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.lValeur).
                when 'I'  then vcRetour = substitute('&2&1&3:&4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.iValeur).
                when 'I6' then vcRetour = substitute('&2&1&3:&4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.i64Valeur).
                when 'D'  then vcRetour = substitute('&2&1&3:&4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.dValeur).
                when 'DA' then vcRetour = substitute('&2&1&3:&4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.daValeur).
                when 'DT' then vcRetour = substitute('&2&1&3:&4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.dtValeur).
                when 'DZ' then vcRetour = substitute('&2&1&3:&4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.dzValeur).
                when 'H'  then vcRetour = substitute('&2&1&3:&4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.hValeur).
                when 'R'  then vcRetour = substitute('&2&1&3:&4', chr(13), vcRetour, ttVariables.cNomVariable, ttVariables.rValeur).
            end case.
        end.
        return trim(vcRetour, chr(13)).
    end method.

    method public logical toTemptable(output table-handle phttCollection):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable bh       as handle  no-undo.
        define variable vlErreur as logical no-undo. // précise simplement s'il y a une erreur, pas ou.

        /* Create an empty, undefined TEMP-TABLE */
        create temp-table phttCollection.
        for each ttVariables
            break by ttVariables.cNomVariable:
            if first-of(ttVariables.cNomVariable)  // si 2 objets ont le même nom, on prend le premier.
            then do:
                case ttVariables.cDatatype:
                    when 'lc' then phttCollection:add-new-field(ttVariables.cNomVariable, "CLOB") no-error.
                    when 'c'  then phttCollection:add-new-field(ttVariables.cNomVariable, "CHARACTER") no-error.
                    when 'i'  then phttCollection:add-new-field(ttVariables.cNomVariable, "INTEGER") no-error.
                    when 'i6' then phttCollection:add-new-field(ttVariables.cNomVariable, "INT64") no-error.
                    when 'l'  then phttCollection:add-new-field(ttVariables.cNomVariable, "LOGICAL") no-error.
                    when 'dt' then phttCollection:add-new-field(ttVariables.cNomVariable, "DATETIME") no-error.
                    when 'dz' then phttCollection:add-new-field(ttVariables.cNomVariable, "DATETIME-TZ") no-error.
                    when 'da' then phttCollection:add-new-field(ttVariables.cNomVariable, "DATE") no-error.
                    when 'd'  then phttCollection:add-new-field(ttVariables.cNomVariable, "DECIMAL") no-error.
                    when 'h'  then phttCollection:add-new-field(ttVariables.cNomVariable, "HANDLE") no-error.
                    when 'r'  then phttCollection:add-new-field(ttVariables.cNomVariable, "ROWID") no-error.
                end case.
                if error-status:error then vlErreur = true.
            end.
        end.
        vlErreur = vlErreur no-error. // reset error-status
        /* No more fields will be added */
        phttCollection:temp-table-prepare("ttCollection") no-error.
        if error-status:num-messages > 0 then vlErreur = true.  // si aucun champ, le prepare ne positionne par error, mais juste num-messages
        /* Get the buffer handle for the temp-table */
        bh = phttCollection:default-buffer-handle no-error.
        if error-status:num-messages > 0 then vlErreur = true.  // si pb sur default..., le prepare ne positionne par error, mais juste num-messages
        bh:buffer-create() no-error.
        if error-status:error then vlErreur = true.
        for each ttVariables
            break by ttVariables.cNomVariable:
            if first-of(ttVariables.cNomVariable)  // si 2 objets ont le même nom, on prend le premier.
            then do:
                case ttVariables.cDatatype:
                    when 'lc' then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.bValeur no-error.
                    when 'c'  then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.cValeur no-error.
                    when 'i'  then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.iValeur no-error.
                    when 'i6' then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.i64Valeur no-error.
                    when 'l'  then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.lValeur no-error.
                    when 'dt' then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.dtValeur no-error.
                    when 'dz' then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.dzValeur no-error.
                    when 'da' then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.daValeur no-error.
                    when 'd'  then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.dValeur no-error.
                    when 'h'  then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.hValeur no-error.
                    when 'r'  then bh:buffer-field(ttVariables.cNomVariable):buffer-value() = ttVariables.rValeur no-error.
                end case.
                if error-status:error then vlErreur = true.
            end.
        end.
        bh:buffer-release() no-error.
        if error-status:error then vlErreur = true.
        delete object phttCollection.
        return vlErreur.
    end method.

/*   ------------------------------------------
    method public void set(pcChamp as character, pcValeur as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable moPar as parametre no-undo.
        moPar = new parametre(pcChamp).
        moPar:cValeur = pcValeur.
        moCollection:put(new OpenEdge.Core.String(pcChamp), moPar).
    end method.
    method public character getCharacter(pcChamp as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable moPar as parametre no-undo.
        moPar = cast(moCollection:get(new OpenEdge.Core.String(pcChamp)), parametre).
        return moPar:cValeur.
    end method.
*/

    destructor public collection():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
//      moCollection:clear().  ------------------------------------------
        empty temp-table ttVariables.
    end destructor.

end class.
