#unit category
SELECT     
        a.DEALSKUSEQ skuseq,
        a.SALESTATUS,
        c.UNITNAME1 unit,
        c.UNITNAME2 cate,
        NVL(b.FST_SALES_DY, 22221231) as FST_SALES_DY   
FROM     
        DEAL_SKU a       
        LEFT JOIN DWD_SKU b         
        ON a.DEALSKUSEQ = b.SKUSEQ       
        LEFT JOIN MANAGEMENT_CATEGORY_HIER_CURR c         
        on a.MANAGECATEGORYSEQ = c.MNGCATEID   
where     a.UNITEDSKU = 'Y'



#daily inputs orders oos 
with united_sku_info as (     
    select     
        aa.unitedskuseq,
        decode(aa.salestatus,2,'ACTIVE',1,'INACTIVE','HALT_PRODUCTION') status,
        aa.area     
    from (     
        SELECT 
            CASE WHEN DS.UNITEDSKU = 'Y' THEN DS.DEALSKUSEQ           
            ELSE NVL(DS.UNITEDSKUSEQ, DS.DEALSKUSEQ)         
            END as unitedskuseq,
            max(decode(ds.salestatus,'ACTIVE',2,'INACTIVE',1,0)) salestatus,
            sa.areacode area       
        FROM         
            big_data.deal_sku ds           
            join bi_mart.dwd_sku dwd    on ds.dealskuseq = dwd.skuseq          
            join analytics.SCM_AREAS sa on 1 = 1      
        where         
            dwd.FST_INBOUND_DY <= ${target_date}       
        group by 1,3 ) as aa     
        group by 1,2,3 ),
        order_sales_info as ( 
        SELECT  to_char(o.orderedat, 'yyyymmdd') day,
            case when nvl(zam.area, 'unknown') = 'unknown' then cam.area         
            else zam.area       
            end area,s.externalid skuseq,
            sum(oi.quantity) dailysales     
        FROM       ORDERS o         
            join ORDER_ITEMS oi on o.id = oi.orderid         
            left join ZIP_AREA_MAPPING zam  on o.RECIPIENTZIP = zam.ZIPCODE         
            join skus s on s.id = oi.skuid         
            join center_area_mapping cam on o.centerid = cam.centerid     
            where  o.status <> 'CANCELED'and date_trunc('day',o.orderedat) = to_date('${target_date}', 'yyyymmdd')   
            group by 1,2,3 ),
            inv_info as (   
            select dsd.skuseq skuseq,cam.area area,sum(dsd.USE_CNT) inventory 
            from SCM_DAILY_INVENTORY dsd        
            join center_area_mapping cam on dsd.centerid = cam.centerid     
            where  basis_day = ${target_date}  and dsd.USE_CNT > 0    
            group by 1,2,cam.area),
            lost_revenue as (     
            SELECT     DL.SKUSEQ,1 lostrevenue   
            FROM DLF_DEMAND_FORECASTING_ITEM_PV_ROLLING DL     
            WHERE DL.SOLDOUT_HOUR>1 AND DL.BASIS_DY=${oos_date}    
            group by 1 ) 
        select     '${target_date}' day,ssi.area,ssi.unitedskuseq,nvl(oi.dailysales, 0) dailysales,ssi.status,
            '' istopsku,nvl(ii.inventory, 0) inventory,0 outofstock,0 dailyshipment,0 poconfirm ,0 pocancel,
            0 openorder,0 dailyrevenue,'' vendorid,round(nvl(lr.lostrevenue, 0), 0) lostrevenue,0 revenue84   
        from     united_sku_info ssi       
        left join order_sales_info oi  
            on ssi.unitedskuseq = oi.skuseq and ssi.area = oi.area       
        left join inv_info ii   on ssi.unitedskuseq = ii.skuseq and ssi.area = ii.area       
        left join lost_revenue lr on ssi.unitedskuseq = lr.skuseq   
        where     $CONDITIONS
        #
select * from dwd_sku where salestatus = 'ACTIVE' and skutype='NORMAL' and live_yn=1 
        and FST_INBOUND_DY       and isnotnull(FST_SALES_DY)


#Get the tip used sku list 
with united_sku_info as (     
    select     
        aa.unitedskuseq,
        decode(aa.salestatus,2,'ACTIVE',1,'INACTIVE','HALT_PRODUCTION') status,
        aa.area     
    from (     
        SELECT 
            CASE WHEN DS.UNITEDSKU = 'Y' THEN DS.DEALSKUSEQ           
            ELSE NVL(DS.UNITEDSKUSEQ, DS.DEALSKUSEQ)         
            END as unitedskuseq,
            max(decode(ds.salestatus,'ACTIVE',2,'INACTIVE',1,0)) salestatus,
            sa.areacode area       
        FROM         
            big_data.deal_sku ds           
            join bi_mart.dwd_sku dwd on ds.dealskuseq = dwd.skuseq          
            join analytics.SCM_AREAS sa on 1 = 1      
        where         
            dwd.FST_INBOUND_DY <= '20170307'  
            and dwd.salestatus = 'ACTIVE'
            and dwd.skutype='NORMAL'
            and live_yn=1
            and FST_INBOUND_DY IS NOT NULL
            and FST_SALES_DY IS NOT NULL
        group by 1,3 ) as aa     
        group by 1,2,3 )
, order_sales_info as ( 
        SELECT  to_char(o.orderedat, 'yyyymmdd') day,
            case when nvl(zam.area, 'unknown') = 'unknown' then cam.area         
            else zam.area       
            end area,s.externalid skuseq,
            sum(oi.quantity) dailysales     
        FROM      ORDERS o         
            join ORDER_ITEMS oi on o.id = oi.orderid         
            left join ZIP_AREA_MAPPING zam  on o.RECIPIENTZIP = zam.ZIPCODE         
            join skus s on s.id = oi.skuid         
            join center_area_mapping cam on o.centerid = cam.centerid     
            where  o.status <> 'CANCELED'and date_trunc('day',o.orderedat) < to_date('20170307', 'yyyymmdd') and date_trunc('day',o.orderedat) > to_date('20170101','yyyymmdd')  
            group by 1,2,3)
, unit as (SELECT a.DEALSKUSEQ skuseq 
    ,a.SALESTATUS 
    ,c.UNITNAME1 unit 
    ,c.UNITNAME2 cate
    ,NVL(b.FST_SALES_DY, 22221231) as FST_SALES_DY  
    FROM DEAL_SKU a 
    LEFT JOIN DWD_SKU b 
    ON a.DEALSKUSEQ = b.SKUSEQ 
    LEFT JOIN MANAGEMENT_CATEGORY_HIER_CURR c 
    on a.MANAGECATEGORYSEQ = c.MNGCATEID
    where    
    a.UNITEDSKU = 'Y')
    
select  '20170308' dt,
        oi.day 
        ,unit.unit
        ,unit.cate
        ,ssi.status
        ,ssi.unitedskuseq
        ,sum(nvl(oi.dailysales, 0)) dailysales
        from united_sku_info ssi       
        left join order_sales_info oi  
            on ssi.unitedskuseq = oi.skuseq and ssi.area = oi.area       
       left join unit on unit.skuseq=ssi.unitedskuseq
        group by dt,oi.day,unit.unit,unit.cate,ssi.unitedskuseq,ssi.status

#outlet 
select cast(SKUSEQ as varchar(30)) skuseq,          
        cast(date(START_DT) as varchar(30)) stardt,          
        cast(date(END_DT) as varchar(30)) enddt  
from DWD_SKU_EDIT_HIST 
where EDITFIELD = 'SkuType' and value in ('PROMOTION', 'OUTLET', 'outlet', 'OUTLETx') 
    and enddt >= now() - 130 and $CONDITIONS"
    
    #get daily input 
    with united_sku_info as (     
    select     
        aa.unitedskuseq,
        decode(aa.salestatus,2,'ACTIVE',1,'INACTIVE','HALT_PRODUCTION') status,
        aa.area     
    from (     
        SELECT 
            CASE WHEN DS.UNITEDSKU = 'Y' THEN DS.DEALSKUSEQ           
            ELSE NVL(DS.UNITEDSKUSEQ, DS.DEALSKUSEQ)         
            END as unitedskuseq,
            max(decode(ds.salestatus,'ACTIVE',2,'INACTIVE',1,0)) salestatus,
            sa.areacode area       
        FROM         
            big_data.deal_sku ds           
            join bi_mart.dwd_sku dwd on ds.dealskuseq = dwd.skuseq          
            join analytics.SCM_AREAS sa on 1 = 1      
        where         
            dwd.FST_INBOUND_DY <= '20170307'  
            and dwd.salestatus = 'ACTIVE'
            and dwd.skutype='NORMAL'
            and live_yn=1
            and FST_INBOUND_DY IS NOT NULL
            and FST_SALES_DY IS NOT NULL
        group by 1,3 ) as aa     
        group by 1,2,3 )
, order_sales_info as ( 
        SELECT  to_char(o.orderedat, 'yyyymmdd') day,
            case when nvl(zam.area, 'unknown') = 'unknown' then cam.area         
            else zam.area       
            end area,s.externalid skuseq,
            sum(oi.quantity) dailysales     
        FROM      ORDERS o         
            join ORDER_ITEMS oi on o.id = oi.orderid         
            left join ZIP_AREA_MAPPING zam  on o.RECIPIENTZIP = zam.ZIPCODE         
            join skus s on s.id = oi.skuid         
            join center_area_mapping cam on o.centerid = cam.centerid     
            where  o.status <> 'CANCELED'and date_trunc('day',o.orderedat) < to_date('20170307', 'yyyymmdd') and date_trunc('day',o.orderedat) > to_date('20170101','yyyymmdd')  
            group by 1,2,3)
, unit as (SELECT a.DEALSKUSEQ skuseq 
    ,a.SALESTATUS 
    ,c.UNITNAME1 unit 
    ,c.UNITNAME2 cate
    ,NVL(b.FST_SALES_DY, 22221231) as FST_SALES_DY  
    FROM DEAL_SKU a 
    LEFT JOIN DWD_SKU b 
    ON a.DEALSKUSEQ = b.SKUSEQ 
    LEFT JOIN MANAGEMENT_CATEGORY_HIER_CURR c 
    on a.MANAGECATEGORYSEQ = c.MNGCATEID
    where    
    a.UNITEDSKU = 'Y')
    
select  '20170308' dt,
        oi.day 
        ,unit.unit
        ,unit.cate
        ,ssi.status
        ,ssi.unitedskuseq
        ,sum(nvl(oi.dailysales, 0)) dailysales
        from united_sku_info ssi       
        left join order_sales_info oi  
            on ssi.unitedskuseq = oi.skuseq and ssi.area = oi.area       
       left join unit on unit.skuseq=ssi.unitedskuseq
        group by dt,oi.day,unit.unit,unit.cate,ssi.unitedskuseq,ssi.status
