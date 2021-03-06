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
        
        
 /* 空白值percentage*/
 with percentage as (
    with sales as (
            select 
                a.externalId, 
                to_char(b.orderedAt,'yyyyMMdd') as orderDay, 
                count(b.quantity) as sale_times
                from skus a 
                    left join (
                        select
                            o1.orderedAt,
                            o2.skuId, 
                            o2.quantity
                        from orders o1 
                            join order_items o2 on o1.id = o2.orderid
                        where o1.orderedAt>='20170101' and o1.status<>'CLOSED'
                    ) b on a.id = b.skuId
                    join deal_sku c on a.externalId = c.dealskuseq 
                    join MANAGEMENT_CATEGORY_HIER_CURR d on c.managecategoryseq = d.mngcateid
                    where d.unitname1 = 'Kitchen'  
                group by a.externalId,orderDay
        ) 
    select 
        a.dt,
        a.externalId,
        s.sale_times
    from 
        ( select distinct d.dt, e.externalId
            from sales e 
            join dim_date d on 1=1
            where d.dt >=20170101 and d.dt<=20170131
        ) a 
        left join sales s on a.dt = s.orderDay and a.externalId = s.externalId
    order by a.externalId,a.dt 
) select p.externalId, count(p.sale_times)/cast(31 as decimal) as percent
    from percentage p
    group by 1
    
    
/*select ROQ */ 
select r.sku, r.ROQ, r.IS_TODAY_ORDER_DAY, r.TIP, r.INVENTORY, r.OPEN_ORDER, r.time 
    from SCM_ROQ_RELEASE r
    where r.unit = 'Kitchen' and r.time >= '20170101' and r.time <= '20170131' 
    
   /* week period */ 
with percentage as (
    with sales as (
            select 
                a.externalId, 
                to_char(b.orderedAt,'yyyyMMdd') as orderDay,
                case when orderDay >= 20170101 and orderDay <= 20170107 then 1
                    when orderDay >= 20170108 and orderDay <= 20170115 then 2
                    when orderDay >= 20170116 and orderDay <= 20170123 then 3
                    else 4
                    end as week,
                count(b.quantity) as sale_times
                from skus a 
                    left join (
                        select
                            o1.orderedAt,
                            o2.skuId, 
                            o2.quantity
                        from orders o1 
                            join order_items o2 on o1.id = o2.orderid
                        where o1.orderedAt>='20170101' and o1.status<>'CLOSED'
                    ) b on a.id = b.skuId
                    join deal_sku c on a.externalId = c.dealskuseq 
                    join MANAGEMENT_CATEGORY_HIER_CURR d on c.managecategoryseq = d.mngcateid
                    where d.unitname1 = 'Kitchen'  
                group by a.externalId,orderDay
        ) 
    select 
        a.dt,
        s.week,
        a.externalId,
        s.sale_times
    from 
        ( select distinct d.dt, e.externalId
            from sales e 
            join dim_date d on 1=1
            where d.dt >=20170101 and d.dt<=20170131
        ) a 
        left join sales s on a.dt = s.orderDay and a.externalId = s.externalId
    order by a.externalId, a.dt 
) select p.externalId, p.week, count(p.sale_times) as weektimes 
    from percentage p
    group by 1,2

/* week period for three months */ 
with percentage as (
    with sales as (
            select 
                a.externalId, 
                to_char(b.orderedAt,'yyyyMMdd') as orderDay,
                case 
                    when orderDay >= 20161001 and orderDay <= 20161007 then 1
                    when orderDay >= 20161008 and orderDay <= 20161014 then 2
                    when orderDay >= 20161015 and orderDay <= 20161021 then 3
                    when orderDay >= 20161022 and orderDay <= 20161028 then 4
                    when orderDay >= 20161029 and orderDay <= 20161104 then 5
                    when orderDay >= 20161105 and orderDay <= 20161111 then 6
                    when orderDay >= 20161112 and orderDay <= 20161118 then 7
                    when orderDay >= 20161119 and orderDay <= 20161125 then 8
                    when orderDay >= 20161126 and orderDay <= 20161202 then 9
                    when orderDay >= 20161203 and orderDay <= 20161209 then 10
                    when orderDay >= 20161210 and orderDay <= 20161216 then 11
                    when orderDay >= 20161217 and orderDay <= 20161223 then 12
                    when orderDay >= 20161224 and orderDay <= 20161230 then 13
                    when orderDay >= 20161231 and orderDay <= 20170106 then 14
                    when orderDay >= 20170107 and orderDay <= 20170113 then 15
                    when orderDay >= 20170114 and orderDay <= 20170120 then 16
                    when orderDay >= 20170121 and orderDay <= 20170127 then 17
                    end as week,
                count(b.quantity) as sale_times
                from skus a 
                    left join (
                        select
                            o1.orderedAt,
                            o2.skuId, 
                            o2.quantity
                        from orders o1 
                            join order_items o2 on o1.id = o2.orderid
                        where o1.orderedAt>='20170101' and o1.status<>'CLOSED'
                    ) b on a.id = b.skuId
                    join deal_sku c on a.externalId = c.dealskuseq 
                    join MANAGEMENT_CATEGORY_HIER_CURR d on c.managecategoryseq = d.mngcateid
                    where d.unitname1 = 'Kitchen'  
                group by a.externalId,orderDay
        ) 
    select 
        a.dt,
        s.week,
        a.externalId,
        s.sale_times
    from 
        ( select distinct d.dt, e.externalId
            from sales e 
            join dim_date d on 1=1
            where d.dt >=20161001 and d.dt<=20170127
        ) a 
        left join sales s on a.dt = s.orderDay and a.externalId = s.externalId
    order by a.externalId, a.dt 
) select p.externalId, p.week, count(p.sale_times) as weektimes 
    from percentage p
    group by 1,2
