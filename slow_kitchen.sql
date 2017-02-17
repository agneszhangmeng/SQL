#find kitchen history data 
    with sales as (
            select 
                a.externalId, 
                to_char(b.orderedAt,'yyyyMMdd') as orderDay, 
                sum(b.quantity) as sale_times
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
            where d.dt >=20170107 and d.dt<= 20170203
        ) a 
        left join sales s on a.dt = s.orderDay and a.externalId = s.externalId
    order by a.externalId,a.dt 
    
    
    
  #find actual sales data 
  
