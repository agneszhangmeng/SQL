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
    
 
with order_info as (
        select s.externalID, to_char(o.orderedAt,'yyyyMMdd') as orderDay, 
            decode(oi.quantity,0,'NO','YES') status
          from skus s
          left join ORDER_ITEMS oi
              on s.id = oi.skuid
          left join ORDERS o
              on oi.orderid = o.id
        group by 1,2
        having orderDay >= '20170101' and s.externalID = '41762'
    )   select b.externalID, b.orderDay, 
        case when 
        from deal_sku a
        left join order_info b
        on a.dealskuseq = b.externalID
        where a.unitedsku = 'Y' 
        group by 1
    
