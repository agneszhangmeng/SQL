
###select order in PDA 

select 
    to_char(o.orderedat, 'yyyymmdd') day, 
    a.dealskuseq,
    b.unitname1,
    oi.quantity actualsales
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
    date_trunc('day',o.orderedat) >= to_date(20170726, 'yyyymmdd') and b.unitname1 = 'Baby Core' and o.STATUS <> 'CLOSED' 
    
  #####
