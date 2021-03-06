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
                        where o1.orderedAt>='20170101' and o1.status<>'CANCELED'
                    ) b on a.id = b.skuId
                    join deal_sku c on a.externalId = c.dealskuseq 
                    join MANAGEMENT_CATEGORY_HIER_CURR d on c.managecategoryseq = d.mngcateid
                    join DLF_DEMAND_FORECASTING_ITEM_PV_ROLLING p on p.skuseq = a.externalId 
                    where d.unitname1 = 'Kitchen'  and c.skutype = 'NORMAL' 
                           and c.salestatus = 'ACTIVE'and p.basis_dy='20170216'        
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
  select 
    a.externalId, 
    sum(b.quantity) as actualsales
    from skus a 
        left join (
            select
                o1.orderedAt,
                o2.skuId, 
                o2.quantity
            from orders o1 
                join order_items o2 on o1.id = o2.orderid
            where o1.orderedAt>='20170120' and o1.orderedAt <= '20170216' and o1.status<>'CANCELED'
        ) b on a.id = b.skuId
        join deal_sku c on a.externalId = c.dealskuseq 
        join MANAGEMENT_CATEGORY_HIER_CURR d on c.managecategoryseq = d.mngcateid
        join DLF_DEMAND_FORECASTING_ITEM_PV_ROLLING p on p.skuseq = a.externalId 
        where d.unitname1 = 'Kitchen'  and c.skutype = 'NORMAL' 
        and c.salestatus = 'ACTIVE' and p.basis_dy='20170216'
    group by a.externalId
    
    
   # month percentage 
   with temp as ( 
    with sales as (
            select 
                a.externalId, 
                to_char(b.orderedAt, 'MM') as month,
                d.unitname2, 
                sum(b.quantity) as sale_times
                from skus a 
                    left join (
                        select
                            o1.orderedAt,
                            o2.skuId, 
                            o2.quantity
                        from orders o1 
                            join order_items o2 on o1.id = o2.orderid
                        where  o1.orderedAt>='20160701' and o1.orderedAt <= '20170131' and o1.status<>'CANCELED'
                    ) b on a.id = b.skuId
                    left join deal_sku c on a.externalId = c.dealskuseq 
                    left join MANAGEMENT_CATEGORY_HIER_CURR d on c.managecategoryseq = d.mngcateid
                    where d.unitname1 = 'Kitchen' 
                group by 1,2,3
            ) 
        select 
            a.MM,
            a.externalId,
            s.unitname2,
            s.sale_times
        from 
            ( select distinct d.MM, e.externalId
                from sales e 
                join dim_date d on 1=1
                where (d.MM >= 07 and d.MM <= 12 ) or d.MM = 01 
            ) a 
            left join sales s on a.MM = s.month and a.externalId = s.externalId
    ) select 
        t.dt, t.externalId, 
        r.unitname2, t.sale_times
        from 
            (select distinct m.unitname2, t.externalId
                from temp t
                join MANAGEMENT_CATEGORY_HIER_CURR m on 1=1
            ) r
            left join temp t on t.externalId = r.externalId
            
            
            
            
            
            
  with temp as (
    select s.externalid, sum(oi.quantity) as dailysales
    from skus s 
    left join order_items oi on oi.SKUID = s.id
    left join orders o on o.id = oi.orderid 
    where to_char(o.orderedAt,'yyyymmdd') = '20170312' and o.status <> 'CANCELED'
    group by s.externalid
    ) 
    select sku, UNIT1, t.dailysales, D1,D2,D3,D4,D5,D6,D7
    from SCM_DAILY_FORECAST F
    join SCM_FORECAST_MODEL M on F.MODEL_ID = M.ID
    left join temp t on t.externalid = F.sku 
    where F.RUNDT = '20170312' and AREA = 'national' and MODEL_ID = 30 
    
    --select actual sales with forecast 
select s.externalid, to_char(a.orderedAt,'yyyymmdd') day, sum(a.quantity) as dailysales
    from skus s
        left join (
            select
                    o1.orderedAt,
                    o2.skuId, 
                    o2.quantity
                from orders o1 
                    join order_items o2 on o1.id = o2.orderid
                where  o1.orderedAt >= '20170301' and o1.orderedAt < '20170315' and o1.status<>'CANCELED' and o1.status <> 'CLOSED'
            ) a on a.skuId = s.id
        left join SCM_DAILY_FORECAST f on f.sku = s.externalid and to_char(a.orderedat,'yyyymmdd')=f.RUNDT
    where f.AREA = 'national' and f.sku = '23959' 
    group by 1,2 

--oos 
select p.skuseq, p.SOLDOUT_HOUR
    from DLF_DEMAND_FORECASTING_ITEM_PV_ROLLING p 
    where p.basis_dy = '20170315' and p.skuseq = '23959'
    
    
    
    
    select cast(SKUSEQ as varchar(30)) skuseq,          
        cast(date(START_DT) as varchar(30)) stardt,          
        cast(date(END_DT) as varchar(30)) enddt  
from DWD_SKU_EDIT_HIST 
where EDITFIELD = 'SkuType' and value in ('PROMOTION', 'OUTLET', 'outlet', 'OUTLETx') 
    and enddt >= now() - 130 and $CONDITIONS"
    
    
    
    
    
    
    
    
        with sales as (
            select 
                a.externalId, 
                to_char(b.orderedAt,'yyyyMMdd') as orderDay, 
                d.UNITNAME1,
                d.UNITNAME2,
                sum(b.quantity) as sales
                from skus a 
                    left join (
                        select
                            o1.orderedAt,
                            o2.skuId, 
                            o2.quantity
                        from orders o1 
                            join order_items o2 on o1.id = o2.orderid
                        where o1.orderedAt >= '20160214' and o1.orderedAt >= '20161008' and o1.status<>'CANCELED'
                    ) b on a.id = b.skuId
                    join deal_sku c on a.externalId = c.dealskuseq 
                    join MANAGEMENT_CATEGORY_HIER_CURR d on c.managecategoryseq = d.mngcateid
                    
                group by 1,2,3,4
        ) 
    select 
        a.dt,
        a.externalId,
        s.UNITNAME1, 
        s.UNITNAME2,
        s.sales
    from 
        ( select distinct d.dt, e.externalId
            from sales e 
            join dim_date d on 1=1
            where d.dt >= 20160214 and d.dt <= 20161008
        ) a 
        left join sales s on a.dt = s.orderDay and a.externalId = s.externalId
    order by a.externalId,a.dt 
