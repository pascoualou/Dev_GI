
    ON "RETURN" OF CURRENT-WINDOW ANYWHERE DO:
        IF SELF:TYPE = "FILL-IN"
            OR SELF:TYPE = "COMBO-BOX" 
            OR SELF:TYPE = "TOGGLE-BOX" THEN DO:
            APPLY "TAB" TO SELF.
            RETURN NO-APPLY.
        END.	/* Inhiber le RETURN sur les Fill-In et les Combo. */
        ELSE DO:
            IF SELF:TYPE = "EDITOR" THEN DO:
                SELF:INSERT-STRING(CHR(13)).
                RETURN NO-APPLY.
            END.
            ELSE DO:
                IF CAN-DO(LIST-EVENTS(SELF), "CHOOSE") THEN DO:
                    APPLY "CHOOSE" TO SELF.
                END.
                ELSE DO:
                    IF CAN-DO(LIST-EVENTS(SELF), "DEFAULT-ACTION") THEN DO:
                        APPLY "DEFAULT-ACTION" TO SELF.
                    END. 
                END.
            END.
        END.	
    END.
