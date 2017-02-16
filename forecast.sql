
select 
    to_char(o.orderedat, 'yyyymmdd') day, 
    oi.quantity dailysales,
    a.dealskuseq,
    b.unitname1,b.unitname2,b.cate3,b.cate4,b.cate5,
from deal_sku a 
    left join MANAGEMENT_CATEGORY_HIER_CURR b
        on a.managecategoryseq = b.mngcateid 
    left join skus s 
        on a.dealskuseq = s.externalid
    left join ORDER_ITEMS oi
        on s.id = oi.skuid
    left join ORDERS o
        on oi.orderid = o.id
where 
    date_trunc('day',o.orderedat) >= to_date(20161212, 'yyyymmdd')



select 
    to_char(o.orderedat, 'yyyymmdd') day, 
    a.dealskuseq,
    b.unitname1,b.unitname2,b.cate3,b.cate4,b.cate5,oi.quantity actualsales,f.D1 Forecast
from deal_sku a 
    left join MANAGEMENT_CATEGORY_HIER_CURR b
        on a.managecategoryseq = b.mngcateid 
    left join skus s 
        on a.dealskuseq = s.externalid
    left join ORDER_ITEMS oi
        on s.id = oi.skuid
    left join ORDERS o
        on oi.orderid = o.id
    left join SCM_DAILY_FORECAST f 
    on to_char(o.orderedat,'yyyymmdd')=f.RUNDT and f.SKU = s.externalid

where 
    date_trunc('day',o.orderedat) >= to_date(20161212, 'yyyymmdd') and b.unitname1 = 'Baby Core' and o.STATUS <> 'CLOSED' 
    
    
 #-------------------
 SELECT A.*,f.D1 Forecast
FROM(
select 
    to_char(o.orderedat, 'yyyymmdd') day, 
    a.dealskuseq,
    b.unitname1,b.unitname2,b.cate3,b.cate4,b.cate5,sum(oi.quantity) actualsales
    
from deal_sku a 
    left join MANAGEMENT_CATEGORY_HIER_CURR b
        on a.managecategoryseq = b.mngcateid 
    left join skus s 
        on a.dealskuseq = s.externalid
    left join ORDER_ITEMS oi
        on s.id = oi.skuid
    left join ORDERS o
        on oi.orderid = o.id
        WHERE  b.unitname1 = 'Baby Core' and o.STATUS <> 'CLOSED' 
group by 1,2,3,4,5,6,7
) A
    left join SCM_DAILY_FORECAST f 
    on A.DAY=f.RUNDT and f.SKU = A.dealskuseq
where 
    F.RUNDT >= '20161211' AND F.RUNDT <= '20170107'

-----------------------------

with orders_info as (
    select
        a.dealskuseq,
        to_char(o.orderedat, 'yyyymmdd') day,
        sum(oi.quantity) actualsales
      from
        deal_sku a
          left join MANAGEMENT_CATEGORY_HIER_CURR m on a.managecategoryseq = m.mngcateid
          left join skus s on a.dealskuseq = s.externalid
          left join ORDER_ITEMS oi on s.id = oi.skuid
          left join ORDERS o on oi.orderid = o.id
      where
        a.unitedsku = 'Y' and o.STATUS <> 'CLOSED' and m.unitname1 = 'Baby Core'
      group by
        1,2
) select
    f.rundt,f.sku,
    m.unitname1,m.unitname2,m.cate3,m.cate4,m.cate5,g.actualsales, f.d1 forecast
  from
    SCM_DAILY_FORECAST f
     left join orders_info g on f.RUNDT = g.DAY and f.SKU = g.dealskuseq
     join deal_sku s on f.sku = s.dealskuseq
     join MANAGEMENT_CATEGORY_HIER_CURR m on s.managecategoryseq = m.mngcateid
  where
    f.area = 'national'
    and F.RUNDT >= '20161211'
    and F.RUNDT <= '20170107'
    and m.unitname1 = 'Baby Core'
    


--------------------------------
PO Automation 

select
   TO_CHAR(A.REGDTTM,'YYYYMMDD') As rundt
   , B.SKUSEQ AS SKUSEQ
   , status.SALESTATUS
   , status.SKUTYPE
   , aa.unit
   , aa.cate
   , case when status.SALESTATUS='ACTIVE' and status.SKUTYPE='NORMAL' then 'TIP-ELIGIBLE' else 'NON-TIP' end as TIP     
   , case when A.REGTYPE  in ( 'AUTO' ) then 'scmplanning'
      when A.REGTYPE  in (
      'AUTO_REISSUE_ADJUST_QUANTITY'
      ,'AUTO_REISSUE_CHANGE_DATE'
      ,'AUTO_REISSUE_MOQ_PO_AGGREGATION'
      ,'AUTO_REISSUE_OTHER'
      ,'AUTO_REISSUE_VENDOR_SHELF_LIFE_ERROR'
      ,'AUTO_REISSUE_WRONG_FC'
      ,'MANUAL_MAPLE_ORDER'
      ,'MANUAL_OOS'
      ,'MANUAL_OTHER'
      ,'MANUAL_PROMOTION'
      ,'MANUAL_REGULAR'
      ,'MANUAL_STATUS_CHANGE'
      ,'MANUAL_TIP_LIST_SKU_QTY' ) then 'instock'
       when A.REGTYPE  in ( 'MANUAL_REISSUE_RECEIVING_ERROR' ) then 'ICQA' else  'newsku'  end po_team
   , sum(B2.PURCHASEORDERCNT) AS po_cnt
   , sum(B.PURCHASEORDERTOTALPRICE) AS PO_amt
FROM BIGDATA.PURCHASE_ORDER A  #join B,  status, aa, B1, B2 
JOIN BIGDATA.PURCHASE_ORDER_SKU B
    ON (A.PURCHASEORDERSEQ = B.PURCHASEORDERSEQ)
LEFT OUTER JOIN DLF_DEMAND_FORECASTING_ITEM_PV_ROLLING status
    on TO_CHAR(A.REGDTTM,'YYYYMMDD')= status.BASIS_DY
    and B.SKUSEQ=status.SKUSEQ
JOIN (SELECT rank() OVER (PARTITION BY k.MNGCATEID ORDER BY k.DW_LOAD_DT DESC) AS RK,
    k.unitname1 unit,
    k.unitname2 cate,
    ds.skuseq,
    ds.salestatus   
    FROM dwd_sku ds   
    left join bi_mart.MANAGEMENT_CATEGORY_HIER_CURR k
    on ds.MNGCATEID = k.MNGCATEID ) as aa
    ON (B.SKUSEQ=aa.SKUSEQ)
JOIN
        (
        SELECT
        B1.*
         , ROW_NUMBER() OVER(PARTITION BY PURCHASEORDERSKUSEQ, CENTERCODE ORDER BY PURCHASEORDERSKUCENTERSEQ DESC) RNK
        FROM BIGDATA.PURCHASE_ORDER_SKU_CENTER B1
        )
        B1
    ON (B.PURCHASEORDERSKUSEQ = B1.PURCHASEORDERSKUSEQ AND B1.RNK = 1)
JOIN
        (
        SELECT
        B1.*
        , ROW_NUMBER() OVER(PARTITION BY PURCHASEORDERSKUSEQ, CENTERCODE ORDER BY PURCHASEORDERSKUCENTERSEQ) RNK
        FROM BIGDATA.PURCHASE_ORDER_SKU_CENTER B1)
       B2
    ON (B.PURCHASEORDERSKUSEQ = B2.PURCHASEORDERSKUSEQ AND B1.CENTERCODE = B2.CENTERCODE AND B2.RNK = 1)

WHERE aa.rk = 1
    and TO_CHAR(A.REGDTTM,'YYYYMMDD') = '20170101'
    group by 1,2,3,4,5,6,7,8;





/* Sales Frequency */ 
with orders_info as (
    select
        a.dealskuseq, a.managecategoryseq,
        d.MM month,
        oi.quantity actualSales
      from
        DEAL_SKU a
          left join SKUS s on a.dealskuseq = s.externalid
          left join ORDER_ITEMS oi on s.id = oi.skuid
          left join ORDERS o on oi.orderid = o.id
          left join DIM_DATE d on to_char(o.orderedat, 'yyyymmdd') = d.DT
      where
        a.unitedsku='Y' and o.STATUS <> ‘CLOSED'
        and d.DT >= 20161001 and d.DT <= 20161231),
    unit as (select m.unitname1, mngcateid from MANAGEMENT_CATEGORY_HIER_CURR m )
select dealskuseq, month, unitname1,
       count(actualSales) salesFreq,
       sum(actualSales) sales
from orders_info
    left join unit
    on orders_info.managecategoryseq = unit.mngcateid
group by 1, 2, 3




with order_info as (
        select s.externalID, to_char(o.orderedAt,'yyyyMMdd') as orderDay 
        from skus s 
            left join ORDER_ITEMS oi
                on s.id = oi.skuid
            left join ORDERS o
                on oi.orderid = o.id
        where oi.quantity > 0 
    )
    select externalID, count(distinct orderDay) 
    from order_info
    group by externalID
    having count(distinct orderDay) = 0 



with order_info as (
    select s.externalID, to_char(o.orderedAt,'yyyyMMdd') as orderDay, oi.orderid 
    from skus s 
        left join ORDER_ITEMS oi
            on s.id = oi.skuid
        left join ORDERS o
            on oi.orderid = o.id
    where oi.quantity > 0 
) 
select b.externalID, b.orderDay
from deal_sku a
    left join order_info b 
        on a.dealskuseq = b.externalid
where a.unitedsku = 'Y' and a.salestatus = 'ACTIVE' and a.skutype = 'NORMAL'
group by b.externalID, b.orderDay
having count(distinct b.orderDay) = 0


select a.dealskuseq, to_char(o.orderedAt,'yyyyMMdd') as orderDay, count(oi.quantity) as times 
      from deal_sku a
          left join skus s 
              on a.dealskuseq = s.externalID
          left join ORDER_ITEMS oi
              on s.id = oi.skuid
          left join ORDERS o
              on oi.orderid = o.id
      where to_char(o.orderedAt,'yyyyMMdd') >= '20161122' 
      group by a.dealskuseq, orderDay 
      having times = 0 




