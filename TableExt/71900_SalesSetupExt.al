tableextension 71900 "Sales Setup Ext." extends "Sales & Receivables Setup"
{
    fields
    {
        field(71900; "Brands Dimension"; Code[20])
        {
            TableRelation = Dimension;
        }
        field(71901; "Journal Template Name"; Code[20])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(71902; "Journal Batch Name"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where ("Journal Template Name" = field ("Journal Template Name"));
        }
        field(71903; "Sales Upload No. Series"; Code[20])
        {
            TableRelation = "No. Series";
        }
    }
}