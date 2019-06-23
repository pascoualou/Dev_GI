/*------------------------------------------------------------------------
File        : fusionDocument.cls
Purpose     : Classe des champs fusion utilisateur DOCUMENT
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionDocument:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property SignataireCourrierBis          as character no-undo get. set.
    define public property entete                         as character no-undo get. set.
    define public property PiedPage                       as character no-undo get. set.
    define public property TelSignataire1                 as character no-undo get. set.
    define public property TelSignataire2                 as character no-undo get. set.
    define public property DateCreationSousDossier        as character no-undo get. set.
    define public property DateFinSousDossier             as character no-undo get. set.
    define public property DateCreationCourrier           as character no-undo get. set.
    define public property DateeditionCourrier            as character no-undo get. set.
    define public property DateRelanceCourrier            as character no-undo get. set.
    define public property DateFinCourrier                as character no-undo get. set.
    define public property DateemailCourrier              as character no-undo get. set.
    define public property DateFaxCourrier                as character no-undo get. set.
    define public property ReferenceCourrier              as character no-undo get. set.
    define public property NumaR                          as character no-undo get. set.
    define public property FonctionSignataire1            as character no-undo get. set.
    define public property FonctionSignataire2            as character no-undo get. set.
    define public property DateLCreationSousDossier       as character no-undo get. set.
    define public property DateLFinSousDossier            as character no-undo get. set.
    define public property DateLCreationCourrier          as character no-undo get. set.
    define public property DateLeditionCourrier           as character no-undo get. set.
    define public property DateLRelanceCourrier           as character no-undo get. set.
    define public property DateLFinCourrier               as character no-undo get. set.
    define public property DateLemailCourrier             as character no-undo get. set.
    define public property DateLFaxCourrier               as character no-undo get. set.
    define public property DateCreationCourrierLettre     as character no-undo get. set.
    define public property DateeditionCourrierLettre      as character no-undo get. set.
    define public property DateRelanceCourrierLettre      as character no-undo get. set.
    define public property DateFinCourrierLettre          as character no-undo get. set.
    define public property DateemailCourrierLettre        as character no-undo get. set.
    define public property DateFaxCourrierLettre          as character no-undo get. set.
    define public property DateCreationSousDossierLettre  as character no-undo get. set.
    define public property DateFinSousDossierLettre       as character no-undo get. set.
    define public property InitialesSignataireCourrier    as character no-undo get. set.
    define public property InitialesSignataireCourrierBis as character no-undo get. set.
    define public property PortableSignataire             as character no-undo get. set.
    define public property PortableSignataireBis          as character no-undo get. set.
    define public property FaxSignataire                  as character no-undo get. set.
    define public property FaxSignataireBis               as character no-undo get. set.
    define public property emailSignataire                as character no-undo get. set.
    define public property emailSignataireBis             as character no-undo get. set.
    define public property cheminlogo                     as character no-undo get. set.
    define public property SignataireCourrier             as character no-undo get. set.
    define public property CommentaireTechnique           as character no-undo get. set.
    define public property CommentaireFinancier           as character no-undo get. set.
    
    define public property CheminEntete                   as character no-undo get. set.
    define public property CheminPied                     as character no-undo get. set.
end class.
