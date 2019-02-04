report 71900 "Sales Invoice Upload"
{
    ProcessingOnly = true;
    dataset
    {
        dataitem(ExcelBuffer; "Excel Buffer")
        {
            UseTemporary = true;
            DataItemTableView = sorting("Row No.", "Column No.");
        }
    }    
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("Import File Name"; ServerFileName)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true; 
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            FileManagement: Codeunit "File Management";
                        begin
                            ServerFileName := FileManagement.OpenFileDialog(Text000,'','');
                        end;
                    }
                    field("Sheet Name"; SheetName)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true; 
                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if ServerFileName <> '' then
                                SheetName := ExcelBuffer.SelectSheetsName(ServerFileName);
                        end;
                    }
                    field("Gen. Jnl. Template"; ImportTemplateName)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true; 
                        TableRelation = "Gen. Journal Template".Name;
                    }
                    field("Gen. Jnl. Batch"; ImportBatchName)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true; 
                        TableRelation = "Gen. Journal Batch".Name;
                    }
                    field("Posting Date"; ImportPostingDate)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true; 
                    }
                }
            }
        }
        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if (CloseAction = Action::OK) and((ServerFileName = '') or (SheetName = '') or (ImportPostingDate = 0D) or (ImportTemplateName = '') or (ImportBatchName = '')) then
                exit(false);
        end;
    }

    trigger OnInitReport()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        ImportTemplateName := SalesSetup."Journal Template Name";
        ImportBatchName := SalesSetup."Journal Batch Name";
        ImportPostingDate := Today();
    end;

    trigger OnPreReport()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NosMgt: Codeunit NoSeriesManagement;
        GenJnlLine: Record "Gen. Journal Line";
        DocNo: Code[20];
        LineNo: Integer;
        RowNo: Integer; 
        Rows: Integer;
        Amount: Decimal;
        BrandCode: Code[10];
        Win: Dialog;
    begin
        SalesSetup.Get();
        ExcelBuffer.OpenBook(ServerFileName,SheetName);
        ExcelBuffer.ReadSheet;
        ExcelBuffer.SetRange("Column No.", 1);
        ExcelBuffer.SetFilter(Formula, '<> 1', '');
        Rows := ExcelBuffer.Count();
        win.Open('@@@@@1');
        RowNo := 2;
        LineNo := GetNextLineNo();
        DocNo := NosMgt.GetNextNo(SalesSetup."Sales Upload No. Series", ImportPostingDate, true);
        while ExcelBuffer.get(RowNo, 1) do
        begin
            Win.Update(1, round(RowNo/Rows * 10000, 1));
            if Evaluate(Amount, GetValueAtCell(RowNo, 8)) and (Amount <> 0) then 
            begin
                BrandCode := GetBrandCode(GetValueAtCell(RowNo, 5));

                GenJnlLine.Init();
                GenJnlLine."Journal Template Name" := ImportTemplateName;
                GenJnlLine.validate("Journal Batch Name", ImportBatchName);
                GenJnlLine."Line No." := LineNo;
                GenJnlLine.validate("Posting Date", Today());
                GenJnlLine.Validate("Document Date", Today());
                GenJnlLine.Validate("Document No.", DocNo);
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Account No.", GetAccountNo(BrandCode, GetValueAtCell(RowNo, 3), GetValueAtCell(RowNo, 7), 1));
                GenJnlLine.validate(Description, copystr(GetValueAtCell(RowNo, 1) + ' - ' + GetValueAtCell(RowNo, 7) + ' - ' + GetValueAtCell(RowNo, 5), 1, 50));
                GenJnlLine.Validate(Amount, -Amount);
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                GenJnlLine.Validate("Bal. Account No.", GetAccountNo(BrandCode, GetValueAtCell(RowNo, 3), GetValueAtCell(RowNo, 7), 2));
                // GenJnlLine.Validate("Shortcut Dimension 1 Code", );
                // GenJnlLine.Validate("Shortcut Dimension 2 Code", );

                GenJnlLine.Insert();
                LineNo += 10000;
            end;
            RowNo += 1;
        end;
        Sleep(6000);
        win.Close();
    end;

    local procedure GetNextLineNo(): Integer
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Template Name", ImportTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", ImportBatchName);
        if GenJnlLine.FindLast() then
            exit(GenJnlLine."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            exit(ExcelBuffer."Cell Value as Text");
    end;
    local procedure GetBrandCode(BrandXls: Text): Code[10]
    var
        SalesSetup: Record "Sales & Receivables Setup";
        DimVal: Record "Dimension Value";
    begin
        SalesSetup.Get();
        dimval.SetRange("Dimension Code", SalesSetup."Brands Dimension");
        DimVal.SetRange(Name, BrandXls);
        if DimVal.FindFirst() then
            exit(DimVal.Code)
        else
            Error(Text005, BrandXls);

    end;
    local procedure GetAccountNo(Brand: Code[20]; Product: Code[20]; Desc: Text[60]; Index: Integer) : Code[20]
    var
        IncMap : Record "Income Mapping";
        ProductOpt: Option Casino, Sports, Lotto;
        DescOpt: Option "Bonus Bet Amount"
                        , "Bonus Bet Rollback Amount"
                        , "Bonus Bet Net Amount"
                        , "Bonus Win Amount"
                        , "Money Bet Amount"
                        , "Money Bet Rollback Amount"
                        , "Money Bet Net Amount"
                        , "Money Win Amount"
                        , "RM GGR"
                        , "Total GGR";
    begin
        case Product of
            'Casino': ProductOpt := ProductOpt::Casino;
            'Sports': ProductOpt := ProductOpt::Sports;
            'Lotto': ProductOpt := ProductOpt::Lotto;
            else Error(Text002, Product);
        end;
        case Desc of
            'Bonus Bet Amount': DescOpt := DescOpt::"Bonus Bet Amount";
            'Bonus Bet Rollback Amount': DescOpt := DescOpt::"Bonus Bet Rollback Amount";
            'Bonus Bet Net Amount': DescOpt := DescOpt::"Bonus Bet Net Amount";
            'Bonus Win Amount': DescOpt := DescOpt::"Bonus Win Amount";
            'Money Bet Amount': DescOpt := DescOpt::"Money Bet Amount";
            'Money Bet Rollback Amount': DescOpt := DescOpt::"Money Bet Rollback Amount";
            'Money Bet Net Amount': DescOpt := DescOpt::"Money Bet Net Amount";
            'Money Win Amount': DescOpt := DescOpt::"Money Win Amount";
            'RM GGR': DescOpt := DescOpt::"RM GGR";
            'Total GGR': DescOpt := DescOpt::"Total GGR";
            else Error(Text003, Desc);
        end;
        if not IncMap.Get(Brand,DescOpt,ProductOpt) then Error(Text004, Product, Desc);
        if Index = 1 then
            exit(IncMap."G/L Account No.")
        else
            exit(IncMap."Bal. A/C No.");
    end;

    var
        ServerFileName: Text;
        SheetName: Text;
        ImportTemplateName: Code[10];
        ImportBatchName: Code[10];
        ImportPostingDate: Date;
        Text000: Label 'Import Payroll Lines';
        Text001: Label 'Importing Lines...';
        Text002: Label 'Product ''%1'' not defined as a Option';
        Text003: Label 'Description ''%1'' not defined as a Option';
        Text004: Label 'Combination of Product ''%1'' and Description ''%2'' not found at Income Mapping table.';
        Text005: Label 'Dimension Code for Brand ''%1'' not found.';
}