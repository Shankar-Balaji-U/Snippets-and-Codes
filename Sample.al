namespace Cetas.Purchases.Posting;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.History;
using Microsoft.Utilities;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Inventory;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Comment;

codeunit 50201 CITReceiptToInvoiceMgmt
{
    procedure CreatePurchInvHeaderFromRcptHeader(FromDocType: Enum "Purchase Document Type From"; var ToPurchHeader: Record "Purchase Header"; FromPurchRcptHeader: Record "Purch. Rcpt. Header")
    var
        SavedDimSetId: Integer;
        RecalculateLines: Boolean;
        MoveNegLines: Boolean;
        IncludeHeader: Boolean;
        PurchOrder: Record "Purchase Header";
        PurchInvCmt: Record "Purch. Comment Line";
        PurchOrderCmt: Record "Purch. Comment Line";
        PurchLine: Record "Purchase Line";
    begin
        RecalculateLines := true;
        MoveNegLines := true;
        IncludeHeader := true;

        with ToPurchHeader do begin
            Init();
            "Document Type" := Enum::"Purchase Document Type"::Invoice;
            Insert(true);
            Validate("Buy-from Vendor No.", FromPurchRcptHeader."Buy-from Vendor No.");
            TransferFields(FromPurchRcptHeader, false);
            Receive := true;
            if MoveNegLines or IncludeHeader then begin
                SavedDimSetId := "Dimension Set ID";
                Validate("Location Code");
                Validate("Dimension Set ID", SavedDimSetId);
            end;
            if MoveNegLines then
                Validate("Order Address Code");
            "No. Printed" := 0;
            "Applies-to Doc. Type" := "Applies-to Doc. Type"::" ";
            "Applies-to Doc. No." := '';
            "Applies-to ID" := '';
            "Quote No." := '';
            "CIT Receipt No." := FromPurchRcptHeader."No.";

            if PurchOrder.Get(PurchOrder."Document Type"::Order, FromPurchRcptHeader."Order No.") then begin
                "Vendor Invoice No." := PurchOrder."Vendor Invoice No.";
                "Pay-to Address 2" := PurchOrder."Pay-to Address 2";
                "Pay-to Country/Region Code" := PurchOrder."Pay-to Country/Region Code";
                "VAT Country/Region Code" := PurchOrder."VAT Country/Region Code";
                "Ship-to Country/Region Code" := PurchOrder."Ship-to Country/Region Code";
                "Buy-from County" := PurchOrder."Buy-from County";
                "Buy-from Country/Region Code" := PurchOrder."Buy-from Country/Region Code";
                "Invoice Received Date" := PurchOrder."Invoice Received Date";
                "Assigned User ID" := PurchOrder."Assigned User ID";
                "Include GST in TDS Base" := PurchOrder."Include GST in TDS Base";
                "Creditor No." := PurchOrder."Creditor No.";
                "Payment Reference" := PurchOrder."Payment Reference";
                "Remit-to Code" := PurchOrder."Remit-to Code";
                "Applies-to Doc. Type" := PurchOrder."Applies-to Doc. Type";
                "Applies-to Doc. No." := PurchOrder."Applies-to Doc. No.";
                "Applies-to ID" := PurchOrder."Applies-to ID";
                "GST Order Address State" := PurchOrder."GST Order Address State";
                "POS Out Of India" := PurchOrder."POS Out Of India";
            end;
            Modify();
        end;
        PurchOrderCmt.SetRange("Document Type", PurchOrderCmt."Document Type"::Order);
        PurchOrderCmt.SetRange("No.", FromPurchRcptHeader."Order No.");
        PurchOrderCmt.SetRange("Document Line No.", 0);

        if PurchOrderCmt.FindSet() then begin
            repeat
                PurchInvCmt."Document Type" := PurchInvCmt."Document Type"::Invoice;
                PurchInvCmt."No." := ToPurchHeader."No.";
                PurchInvCmt."Line No." := PurchOrderCmt."Line No.";
                PurchInvCmt.Insert(true);

                Message('PurchOrdCmt No. %1 / PurchInvCmt No.%2', PurchOrderCmt."No.", PurchInvCmt."No.");
                PurchInvCmt.TransferFields(PurchOrderCmt, false);
                PurchInvCmt.Modify();
            until PurchOrderCmt.Next() = 0
        end;

        Message('Comment Header Transfer Complete');
        /////////cmt header complete/////////////
        // PurchOrderCmt.Reset();
        // PurchOrderCmt.SetRange("Document Type", PurchOrderCmt."Document Type"::Order);
        // PurchOrderCmt.SetRange("No.", FromPurchRcptHeader."Order No.");
        // PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        // PurchLine.SetRange("Document No.", PurchOrder."No.");
        // PurchLine.SetFilter("Type", '<>%1', PurchLine.Type::" ");
        // if PurchLine.FindSet() then begin
        //     repeat
        //         Message('%1', PurchLine.Type);
        //         Message('%1', PurchLine."Line No.");
        //     until PurchLine.Next() = 0;
        // end;

        // PurchOrderCmt.SetRange("Document Line No.", PurchLine."Line No.");
        // PurchInvCmt.Reset();

        // if PurchOrderCmt.FindSet() then begin
        //     repeat
        //         PurchInvCmt.Init();
        //         PurchInvCmt."Document Type" := PurchInvCmt."Document Type"::Invoice;
        //         PurchInvCmt."No." := ToPurchHeader."No.";
        //         PurchInvCmt."Line No." := PurchOrderCmt."Line No.";
        //         PurchInvCmt."Document Line No." := PurchOrderCmt."Document Line No.";
        //         Message('PurchOrdCmt No. %1 / PurchInvCmt No.%2', PurchOrderCmt."No.", PurchInvCmt."No.");

        //         PurchInvCmt.Insert(true);
        //         PurchInvCmt.TransferFields(PurchOrderCmt, false);
        //         PurchInvCmt.Modify(true);
        //     until PurchOrderCmt.Next() = 0
        // end;

        // Message('Comment Line Transfer Complete');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure AfterPostPurchaseDocSub(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        PurchOrder: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        if PurchaseHeader."Document Type" <> Enum::"Purchase Document Type"::Invoice then
            exit;

        if PurchRcptHeader.Get(PurchaseHeader."CIT Receipt No.") and PurchOrder.Get(Enum::"Purchase Document Type"::Order, PurchRcptHeader."Order No.") then begin
            PurchLine.SetRange("Document Type", PurchOrder."Document Type"::Order);
            PurchLine.SetRange("Document No.", PurchOrder."No.");
            PurchLine.CalcSums("Quantity (Base)");
            PurchLine.CalcSums("Quantity Invoiced");
            if (PurchLine."Quantity (Base)" = PurchLine."Quantity Invoiced") then begin
                PurchOrder.Validate(Status, PurchOrder.Status::Open);
                PurchOrder.Modify(true);
                PurchLine.ModifyAll("Qty. Rcd. Not Invoiced", 0, true);
                PurchOrder.Delete(true);
            end;

        end;
        // Error('Stoping the Purch order delete');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Purchase Receipt Line", 'OnAfterCode', '', false, false)]
    procedure AfterCodeSub(var PurchRcptLine: Record "Purch. Rcpt. Line"; var UndoPostingManagement: Codeunit "Undo Posting Management")
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purchase Header";
    begin

        PurchInvHeader.SetRange("Document Type", Enum::"Purchase Document Type"::Invoice);
        PurchInvHeader.SetRange("CIT Receipt No.", PurchRcptLine."Document No.");
        if PurchInvHeader.FindFirst() then begin
            PurchInvHeader.Delete(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Get Receipt", 'OnAfterInsertInvoiceLineFromReceiptLine', '', false, false)]
    local procedure InsertInvoiceLineCmtFromReceiptLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line"; PurchRcptLine2: Record "Purch. Rcpt. Line"; TransferLine: Boolean)
    var
        PurchInvCmt: Record "Purch. Comment Line";
        PurchRcptCmt: Record "Purch. Comment Line";
    begin
        Message('Transfer Line %1', TransferLine);
        if not TransferLine then
            exit;


        PurchRcptCmt.SetRange("Document Type", PurchRcptCmt."Document Type"::Receipt);
        PurchRcptCmt.SetRange("No.", PurchRcptLine."Document No.");
        PurchRcptCmt.SetRange("Document Line No.", PurchRcptLine."Line No.");

        if PurchRcptCmt.FindSet() then begin
            repeat
                PurchInvCmt.Init();
                PurchInvCmt."Document Type" := PurchInvCmt."Document Type"::Invoice;
                PurchInvCmt."No." := PurchRcptCmt."No.";
                PurchInvCmt."Line No." := PurchRcptCmt."Line No.";
                PurchInvCmt."Document Line No." := PurchLine."Line No.";
                Message('PurchOrdCmt No. %1 / PurchInvCmt No.%2', PurchRcptCmt."No.", PurchInvCmt."No.");

                PurchInvCmt.Insert(true);
                PurchInvCmt.TransferFields(PurchRcptCmt, false);
                PurchInvCmt.Modify(true);

            until PurchRcptCmt.Next() = 0;
        end;
    end;

    var
        PurchHeader: Record "Purchase Header";
        GLSetup: Record "General Ledger Setup";
}
