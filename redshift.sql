--oos 
select basis_dy,skuseq,unitname1,unitname2,salestatus, skutype,soldout_hour
from bimart.DLF_DEMAND_FORECASTING_ITEM_PV_ROLLING 
where skuseq = 3063220 
order by basis_dy desc








--actual sales 

SELECT 
	s.externalid as skuseq, 
	d.iyyyy_1_wk AS wk, 
	sum( oi.quantity ) as dailysales
FROM 
	ods.ORDERS o join ods.ORDER_ITEMS oi on o.id = oi.orderid 
	join ods.skus s on s.id = oi.skuid 
	JOIN bimart.dim_date d ON trunc(d.dates)=trunc(o.orderedat) 
        where o.status <> 'CANCELED'  
	and date(o.orderedat) >= to_date('20170701','yyyymmdd') 
	and skuseq = 3120610
group by 1,2
order by wk

--forecast 
select 
	f.sku,
	d.iyyyy_1_wk AS wk,
	sum(f.d1+f.d2+f.d3+f.d4+f.d5+f.d6+f.d7) forecast 
from sb_scm.scm_daily_forecast f
left join  bimart.dim_date d on trunc(d.dates) = to_date(f.rundt,'yyyymmdd' )
where f.sku = 3120610 and trunc(d.dates)  >= '2017-11-01'
group by 1,2
order by wk

--select trunc(d.dates) from bimart.dim_date d limit 100
--select to_date(f.rundt,'yyyymmdd') from sb_scm.scm_daily_forecast f limit 100 


SELECT 
	A.skuseq,
	A.wk AS wk,
	sum(A.dailysales) as sales,
	sum(f.d1+f.d2+f.d3+f.d4+f.d5+f.d6+f.d7) Forecast
FROM(
	SELECT 
		s.externalid as skuseq, 
		d.iyyyy_1_wk AS wk, 
		sum( oi.quantity ) as dailysales
	FROM 
		ods.ORDERS o join ods.ORDER_ITEMS oi on o.id = oi.orderid 
		join ods.skus s on s.id = oi.skuid 
		JOIN bimart.dim_date d ON trunc(d.dates) = trunc(o.orderedat) 
	        where o.status <> 'CANCELED'  
		and date(o.orderedat) >= to_date('20171001','yyyymmdd') 
		and skuseq = 3120610
	group by 1,2
	order by wk
) A
left join sb_scm.scm_daily_forecast f on f.sku = A.skuseq 
left join  bimart.dim_date d on trunc(d.dates) = to_date(f.rundt,'yyyymmdd' ) and A.wk = d.iyyyy_1_wk
where f.sku = 3120610 and trunc(d.dates)  >= '2017-10-01'
group by 1,2
order by wk
    

 
