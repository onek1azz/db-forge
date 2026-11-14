use Front;

-- 1. закупки 

-- 1.1 какие виды доков есть и сколько их, тип 4 «поступление продуктов» это закупка
select dt.ID as type_id, dt.Description as document_type, count(*) as documents,
       sum(d.Amount) as amount, min(d.Period) as first_date, max(d.Period) as last_date
from bm_JournalBarnetDocs d
inner join bm_JournalTypeDocuments dt on dt.ID = d.DocumentTypeID
group by dt.ID, dt.Description
order by documents desc;

-- 1.2 строки операции 1 (поступление) встречаются в доках 2х типов, это 4 (закупка) и 6 (товарный чек), поэтому закупки нужно отбирать по типу документа, а не только по опеерации
select d.DocumentTypeID, count(*) as storage_rows, sum(o.Amount) as amount
from bm_StorageOperations o
inner join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1
group by d.DocumentTypeID;

-- 1.3 сумма доков закупки сходится с суммой их строк на складе

select
	(select sum(Amount) from bm_JournalBarnetDocs where DocumentTypeID = 4) as documents_amount,
	(select sum(o.Amount)
	 from bm_StorageOperations o
	 inner join bm_JournalBarnetDocs d on d.ID = o.DocumentID
	 where d.DocumentTypeID = 4) as storage_rows_amount;

-- 1.4 закупки по месяцам (шаг анализа месяц)
select format(d.Period, 'yyyy-MM') as month, count(*) as documents, sum(d.Amount) as amount
from bm_JournalBarnetDocs d
where d.DocumentTypeID = 4
group by format(d.Period, 'yyyy-MM')
order by month;

-- 1.5 чем отлич строки операции 1 в закупке (тип 4) и в товарном чеке (тип 6), в закупке есть поставщик, но а в чеке поставщика нет

select d.DocumentTypeID, count(*) as storage_rows,
       sum(case when o.VendorID = 0 then 1 else 0 end) as rows_without_vendor,
       count(distinct o.VendorID) as distinct_vendors,
       sum(o.Amount) as amount
from bm_StorageOperations o
inner join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1
group by d.DocumentTypeID;

-- 2. продажи 


-- 2.1 виды записей в журнале кассы, 101 продажа позиции, 211 оплата наличными, 501 итог чека
select j.transtype, t.description, count(*) as records, sum(j.amount) as amount,
       min(j.dater) as first_date, max(j.dater) as last_date
from journal j
left join transtype t on t.transtypeid = j.transtype
group by j.transtype, t.description
order by records desc;

-- 2.2 итог чека 501 = сумме проданных позиций 101 в том же чеке
select count(*) as receipts,
       sum(case when abs(items - total) < 0.01 then 1 else 0 end) as equal_receipts,
       sum(case when abs(items - total) >= 0.01 then 1 else 0 end) as different_receipts
from (
	select receiptn,
	       sum(case when transtype = 101 then amount end) as items,
	       sum(case when transtype = 501 then amount end) as total
	from journal
	where transtype in (101, 501)
	group by receiptn
) as r
where items is not null and total is not null;


-- 2.3 состав блюд привязаан к проданным позиц журнала
select j.transtype, count(*) as detail_rows, count(distinct d.SourceID) as sold_positions
from bm_Journal_Details d
inner join journal j on j.transnumber = d.SourceID
group by j.transtype;

-- 2.4 продажи по месяцам (опять же шаг анализа месяц)
select format(dater, 'yyyy-MM') as month, count(distinct receiptn) as receipts,
       count(*) as positions, sum(amount) as amount
from journal
where transtype = 101
group by format(dater, 'yyyy-MM')
order by month;

-- 2.5 чек из журнала касс соотв документу «товарный чек» (тип 6)
select count(*) as documents_type6,
       sum(case when j.receiptn is not null then 1 else 0 end) as found_in_journal
from bm_JournalBarnetDocs d
left join (select distinct receiptn from journal where transtype = 501) j on j.receiptn = d.TicketNumber
where d.DocumentTypeID = 6;

-- 2.6 справочники из группы продаж действ связаны с журналом кассы (внешних ключей нет), виды оплаты (journal.transtype = paymenttype.paymenttypeid) и клиенты (journal.customerid = clients.clientid)
select 'paymenttype' as link, count(*) as rows_checked,
       sum(case when p.paymenttypeid is null then 1 else 0 end) as not_found
from journal j
left join paymenttype p on p.paymenttypeid = j.transtype
where j.transtype in (211, 216)
union all
select 'clients', count(*), sum(case when c.id is null then 1 else 0 end)
from journal j
left join clients c on c.clientid = j.customerid
where j.transtype = 101 and j.customerid <> '';

-- 3. поставщики

-- 3.1 поставщики по группам, внешний ключ vendors.clientgroup - vendorgroup
select g.vendorgroupid, g.description as vendor_group, count(*) as vendors, sum(v.IsUse) as active
from vendors v
inner join vendorgroup g on g.vendorgroupid = v.clientgroup
group by g.vendorgroupid, g.description;

-- 3.2 в поступлениях VendorID указ на существ поставщика, внешнего ключа нет

select count(*) as purchase_rows,
       sum(case when v.id is null then 1 else 0 end) as rows_without_vendor,
       count(distinct o.VendorID) as vendors_used
from bm_StorageOperations o
left join vendors v on v.id = o.VendorID
inner join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1 and d.DocumentTypeID = 4;

-- 3.3 закупки по месяцам, сколько поставщиков, документов ну и на какую сумму (шаг анализа месяц)
select format(o.DateAdd, 'yyyy-MM') as month, count(distinct o.VendorID) as vendors,
       count(distinct o.DocumentID) as documents, sum(o.Amount) as amount
from bm_StorageOperations o
inner join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1 and d.DocumentTypeID = 4
group by format(o.DateAdd, 'yyyy-MM')
order by month;

-- 3.3.1 10 крупнейших поставщиков за весь период
select top 10 v.clientid as vendor, count(distinct o.DocumentID) as documents,
       sum(o.Amount) as amount, min(o.DateAdd) as first_date, max(o.DateAdd) as last_date
from bm_StorageOperations o
inner join vendors v on v.id = o.VendorID
inner join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1 and d.DocumentTypeID = 4
group by v.clientid
order by amount desc;

-- 3.4 договоры пустые, значит связь с поставщиком идет только через складские строки и прайслист
select
	(select count(*) from bm_Contracts) as contracts,
	(select count(*) from pricelist where vendorid <> 0) as pricelist_rows_with_vendor,
	(select count(*) from product where vendorid <> 0) as products_with_vendor,
	(select count(*) from bm_StorageOperations where OperationID = 1 and ContractID <> 0) as income_rows_with_contract;

-- 3.5 дубли поставщиков, одно название в разных группах
select clientid, count(*) as records, min(clientgroup) as min_group, max(clientgroup) as max_group
from vendors
group by clientid
having count(*) > 1
order by records desc;

-- 4. персонал

-- 4.1 сотрудники по ролям и признаку "уволен"
select s.description as role, p.deleteflag, count(*) as employees
from personnel p
left join securityaccess s on s.securityaccessid = p.securityaccess
group by s.description, p.deleteflag
order by employees desc;

-- 4.2 в журнале кассы loginid это код сотрудника, внешнего ключа нет
select count(*) as sales_rows,
       sum(case when p.personid is null then 1 else 0 end) as rows_without_employee
from journal j
left join personnel p on p.personid = try_cast(j.loginid as int)
where j.transtype = 101;

-- 4.3 выручка по сотрудникам и кварталам (шаг анализа квартал)
select datepart(year, j.dater) as year, datepart(quarter, j.dater) as quarter,
       j.loginid as employee_id, count(distinct j.receiptn) as receipts, sum(j.amount) as amount
from journal j
where j.transtype = 101
group by datepart(year, j.dater), datepart(quarter, j.dater), j.loginid
order by year, quarter, amount desc;

-- 4.4 рабочие смены, начало 386 и окончание 387 работы по сотрудникам
select j.loginid as employee_id,
       sum(case when j.transtype = 386 then 1 else 0 end) as work_started,
       sum(case when j.transtype = 387 then 1 else 0 end) as work_finished,
       min(j.dater) as first_date, max(j.dater) as last_date
from journal j
where j.transtype in (386, 387)
group by j.loginid
order by work_started desc;

-- 4.5 документы тоже привязаны к сотруднику PersonID

select count(*) as documents,
       sum(case when p.personid is null then 1 else 0 end) as documents_without_employee
from bm_JournalBarnetDocs d
left join personnel p on p.personid = d.PersonID;

-- 4.6 права доступа, сколько прав у каждого сотрудника, внешний ключ на bm_SecurityObjects
select p.personid, p.firstname, count(*) as rights
from bm_PersonnelSecurity ps
inner join bm_SecurityObjects o on o.ID = ps.ObjectID
inner join personnel p on p.personid = ps.PersonID
where ps.IsUse = 1
group by p.personid, p.firstname
order by rights desc;

-- 5. остатки

-- 5.1 готовые таблицы остатков пустые или устарели
select 'stock' as table_name, count(*) as row_count, cast(null as datetime) as last_date from stock
union all select 'onhand', count(*), null from onhand
union all select 'closingcount', count(*), null from closingcount
union all select 'storagesonhand', count(*), null from storagesonhand
union all select 'stockperiod', count(*), max(datefinish) from stockperiod;

-- 5.2 движения склада по видам операций (знак задает Factor), видно в какой колонке хранится колво
select t.ID, t.Description, t.Factor, count(*) as rows_count,
       sum(o.Quantity) as sum_quantity, sum(o.[Count]) as sum_count, sum(o.Amount) as amount
from bm_StorageOperations o
inner join bm_StorageOperationsType t on t.ID = o.OperationID
group by t.ID, t.Description, t.Factor
order by t.ID;

-- 5.3 остаток по товарам = сумма Count (приход со знаком плюс, списание со знаком минус), 20 товаров с наиб приходом
select top 20 p.description as product,
       sum(case when o.OperationID = 1 then o.[Count] else 0 end) as income,
       sum(case when o.OperationID = 2 then o.[Count] else 0 end) as writeoff,
       sum(o.[Count]) as balance
from bm_StorageOperations o
inner join product p on p.id = o.ProductID
group by p.description
order by income desc;

-- 5.4 колонка Rest в строках склада, заполнена или нет
select count(*) as rows_count,
       sum(case when Rest <> 0 then 1 else 0 end) as rows_with_rest
from bm_StorageOperations;

-- 5.5 движения склада по неделям, последние 15 недель (шаг анализа неделя)
select top 15 w.week_start,
       sum(case when w.OperationID = 1 then 1 else 0 end) as incomes,
       sum(case when w.OperationID = 2 then 1 else 0 end) as writeoffs
from (
	select cast(dateadd(day, datediff(day, 0, DateAdd) / 7 * 7, 0) as date) as week_start, OperationID
	from bm_StorageOperations
) as w
group by w.week_start
order by w.week_start desc;

-- 5.5.1 сколько недель покрывают данные и сколько движений в среднем за неделю, по годам
select year(week_start) as year, count(*) as weeks, avg(movements) as avg_movements_per_week
from (
	select cast(dateadd(day, datediff(day, 0, DateAdd) / 7 * 7, 0) as date) as week_start, count(*) as movements
	from bm_StorageOperations
	group by cast(dateadd(day, datediff(day, 0, DateAdd) / 7 * 7, 0) as date)
) as w
group by year(week_start)
order by year;

-- 5.6 причины списания, ReasonID в строках списания связан со справочником bm_ReasonDebit, ну и внешнего ключа нет
select top 10 o.ReasonID, r.Description as reason, count(*) as rows_count, sum(o.Amount) as amount
from bm_StorageOperations o
left join bm_ReasonDebit r on r.ID = o.ReasonID
where o.OperationID = 2
group by o.ReasonID, r.Description
order by rows_count desc;