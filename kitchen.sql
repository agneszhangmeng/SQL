/* fast moving skus in kitchen */ 
with order_info as (
    select 
        to_char(o.orderedat, 'yyyymmdd') day, 
        a.dealskuseq,
        b.unitname1, sum(oi.quantity) actualsales
    from deal_sku a
        left join MANAGEMENT_CATEGORY_HIER_CURR b 
            on a.managecategoryseq = b.mngcateid
        left join skus s
            on a.dealskuseq = s.externalid
        left join ORDER_ITEMS oi 
            on s.id = oi.skuid 
        left join ORDERS o
            on oi.orderid = o.id 
    group by 1,2,3
) select * from order_info oo
    where oo.day >= to_date(20170101, 'yyyymmdd') and oo.unitname1 = 'Kitchen' and  oo.actualsales >= 20 
      
with temp as (
    select a.dealskuseq, to_char(o.orderedAt,'yyyyMMdd') as orderDay, b.unitname1, 
     count(oi.quantity) as sales, count(*) as total
    from deal_sku a
        left join MANAGEMENT_CATEGORY_HIER_CURR b 
            on a.managecategoryseq = b.mngcateid
        left join skus s
            on a.dealskuseq = s.externalid
        left join ORDER_ITEMS oi 
            on s.id = oi.skuid 
        left join ORDERS o
            on oi.orderid = o.id 
    group by 1,2,3 
    having orderDay >= '20170206' and b.unitname1 = 'Kitchen' and  a.unitedsku = 'Y' 
) select t.dealskuseq, t.sales/t.total as percentage 
    from temp t

/* select kitchen data */ 
with order_info as (
    select 
        to_char(o.orderedat, 'yyyymmdd') day, 
        a.dealskuseq,
        b.unitname1, 
        sum(oi.quantity) actualsales
    from deal_sku a
        left join MANAGEMENT_CATEGORY_HIER_CURR b 
            on a.managecategoryseq = b.mngcateid
        left join skus s
            on a.dealskuseq = s.externalid
        left join ORDER_ITEMS oi 
            on s.id = oi.skuid 
        left join ORDERS o
            on oi.orderid = o.id 
            
) select * from order_info oo
    where oo.day = to_date(20170207, 'yyyymmdd') and oo.unitname1 = 'Kitchen'



select to_char(o.orderedAt,'yyyyMMdd') as orderDay, s.externalID, 
            oi.quantity
          from skus s
          left join ORDER_ITEMS oi
              on s.id = oi.skuid
          left join ORDERS o
              on oi.orderid = o.id
        where orderDay >= '20170101' and s.externalID = '46464'
/* select percentage of 0 */ 
select d.DT as Date, s.externalID, b.unitname1,
            count(oi.quantity) actualsales
        from dim_date d 
        left join ORDERS o
            on cast(to_char(o.orderedAt,'yyyyMMdd') as int) = d.DT 
        left join ORDER_ITEMS oi
            on oi.orderid = o.id
        left join SKUS s
            on s.id = oi.skuid
        left join deal_sku a 
            on a.dealskuseq = s.externalid
        left join MANAGEMENT_CATEGORY_HIER_CURR b 
            on a.managecategoryseq = b.mngcateid
        group by 1,2,3
        having Date >= '20170205' and b.unitname1 = 'Kitchen'
