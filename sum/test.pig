-- Plain Sum
A = load 'input' as (number:int);
B = group A All;
C = foreach B generate SUM($1);
dump C;  

-- Group And Sum
B = group A by $0;
C = foreach B generate SUM($1);
dump C;

