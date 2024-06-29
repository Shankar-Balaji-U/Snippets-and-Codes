PurchOrderCmt.SetRange("Document Type", PurchOrderCmt."Document Type"::Order); PurchOrderCmt.SetRange("No.", FromPurchRcptHeader."Order No."); PurchOrderCmt.SetRange("Document Line No.", 0); PurchInvCmt.Validate("Document Type", PurchInvCmt."Document Type"::Invoice); PurchInvCmt.Validate("No.", ToPurchHeader."No."); PurchInvCmt.Validate("Document Line No.", 0); PurchInvCmt.Insert(true); PurchInvCmt.SetRange("Document Type", PurchInvCmt."Document Type"::Invoice); PurchInvCmt.SetRange("No.", ToPurchHeader."No."); PurchInvCmt.SetRange("Document Line No.", 0); if PurchOrderCmt.FindSet() then begin repeat Message('PurchOrdCmt No. %1 / PurchInvCmt No.%2',PurchOrderCmt."No.",PurchInvCmt."No."); PurchInvCmt.Validate(Date, PurchOrderCmt.Date); PurchInvCmt.Validate(Code, PurchOrderCmt.Code); PurchInvCmt.Validate(Comment, PurchOrderCmt.Comment); PurchInvCmt.Modify(); until PurchOrderCmt.Next() = 0 end; Message('Comment Header Transfer Complete'); /////////cmt header complete///////////// PurchOrderCmt.Reset(); PurchOrderCmt.SetRange("Document Type", PurchOrderCmt."Document Type"::Order); PurchOrderCmt.SetRange("No.", FromPurchRcptHeader."Order No."); PurchInvCmt.Reset(); PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order); PurchLine.SetRange("Document No.", PurchOrder."No."); PurchInvCmt.Validate("Document Type", PurchInvCmt."Document Type"::Invoice); PurchInvCmt.Validate("No.", ToPurchHeader."No."); if PurchLine.FindSet() then begin repeat PurchInvCmt.Validate("Document Line No.", PurchLine."Line No."); until PurchLine.Next() = 0 end; PurchInvCmt.Insert(true); PurchInvCmt.Reset(); PurchInvCmt.SetRange("Document Type", PurchInvCmt."Document Type"::Invoice); PurchInvCmt.SetRange("No.", ToPurchHeader."No."); Message('Purch order cmt count %1', PurchOrderCmt.Count()); Message('Purch Invoice cmt count %1', PurchInvCmt.Count()); if PurchOrderCmt.FindSet() then begin repeat PurchInvCmt.Validate(Date, PurchOrderCmt.Date); PurchInvCmt.Validate(Code, PurchOrderCmt.Code); PurchInvCmt.Validate(Comment, PurchOrderCmt.Comment); PurchInvCmt.Modify(); until PurchOrderCmt.Next() = 0 end;
