-- Load Date
A = LOAD '/home/krishna/Desktop/Pig/PigProcessing.csv' using PigStorage(',') as 
(Record_Type,Revenue_Center_Number,Order_Type,Check_Number,Business_Date,Transaction_Date_Time,Detaily_Type,Price_Level,Record_Id,Void_Flag,Return_Flag,Line_Quantity,Line_Total,Report_Line_Quantity,Report_Line_Amount,Employee_Number,Reference_Info,Reference_Info_2,Do_Not_Show,file_name,store_id,cost,key);

-- Foreach to generate desired format data
B = foreach A {
    report_line_amount = ($14 is null?0:$14);
    prd_count = ($13 is null?0:$13);
    report_line_quantity = ($13 is null?0:$13);
    key = CONCAT($20,CONCAT('||',CONCAT($3,CONCAT('||',CONCAT($4,CONCAT('||',$5))))));

    generate store_id,Check_Number,Business_Date, Transaction_Date_Time,Record_Id,report_line_amount as report_line_amount,prd_count as prd_count, report_line_quantity as report_line_quantity,key as key;
    };

-- Aggregation Based on group
C = FOREACH (GROUP B BY key) {
    amount = SUM(B.report_line_amount);
    prd_count = DISTINCT B.prd_count;
    quantity = SUM(B.report_line_quantity);
    Product_Id = DISTINCT B.Record_Id;
    Record_Id = BagToString(Product_Id, '--');

    GENERATE B.store_id as store_id,B.Check_Number as check_number,B.Business_Date as business_date,B.Transaction_Date_Time as txn_date_time,Record_Id as record_id,amount as amount,prd_count as prd_count,quantity as quantity,Product_Id as Product_Id;
    };

-- flattening to produce the desired records
D =  foreach C {
    generate FLATTEN($0),FLATTEN($1),FLATTEN($2),FLATTEN($3),FLATTEN($4),
    $5,FLATTEN($6),$7,FLATTEN($8);
}                                                

dump D;
