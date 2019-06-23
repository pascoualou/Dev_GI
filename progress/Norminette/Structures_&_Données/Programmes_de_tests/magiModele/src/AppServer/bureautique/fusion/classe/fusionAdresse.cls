/*------------------------------------------------------------------------
File        : fusionAdresse.cls
Description : 
Author(s)   : kantena - 2018/01/15
Notes       : 
----------------------------------------------------------------------*/
block-level on error undo, throw.

class bureautique.fusion.classe.fusionAdresse: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define public property adresse         as character no-undo get. set.
    define public property codePays        as character no-undo get. set.
    define public property codePostal      as character no-undo get. set.
    define public property codeVoie        as character no-undo get. set.
    define public property complementVoie  as character no-undo
        get:
            if this-object:complementVoie = "-" or this-object:complementVoie = "." then return "".
            return this-object:complementVoie.
        end.
        set.
    define public property fax             as character no-undo get. set.
    define public property identAdresse    as character no-undo get. set.
    define public property libellePays     as character no-undo get. set.
    define public property libelleVoie     as character no-undo get. set.
    define public property mail            as character no-undo get. set.
    define public property natureVoie      as character no-undo get. set.
    define public property numeroVoie      as character no-undo get. set.
    define public property portable        as character no-undo get. set.
    define public property telephone       as character no-undo get. set.
    define public property typeIdentifiant as character no-undo get. set.
    define public property ville           as character no-undo get. set.
    define public property cedex           as character no-undo get. set.

    method public character villeSansCedex():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return trim(entry(1, this-object:ville, "cedex")).
    end method.
    method public character getLibelleAdresse():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return left-trim(substitute('&1 &2 &3 &4', this-object:numeroVoie, this-object:codeVoie, this-object:natureVoie, this-object:libelleVoie)).
    end method.
end class.
