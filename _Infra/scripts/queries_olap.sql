-- 1. ед измерения из классификатора
select 'insert into dim_ranges (external_id, group_external_id, short_name, name) values ('
       + cast(ID as varchar(20)) + ', '
       + isnull(cast(GroupID as varchar(20)), 'null') + ', '
       + isnull('''' + replace(ShortName, '''', '''''') + '''', 'null') + ', '''
       + replace(isnull(Description, ''), '''', '''''') + ''');' as [sql]

from [Front].[dbo].[bm_classifierSizes]
order by GroupID, ID;

-- 2. категории товаров, сначала корневые потом вложенные, чтоб родитель уже был вставлен
with tree as (
	select id, ParentID, description, 0 as lvl
	from category
	where isnull(ParentID, 0) = 0
	union all
	select c.id, c.ParentID, c.description, t.lvl + 1
	from category c
	inner join tree t on c.ParentID = t.id
)

select 'insert into dim_categories (external_id, name, parent_id) values ('
       + cast(id as varchar(20)) + ', '''
       + replace(isnull(description, ''), '''', '''''') + ''', '
       + case when lvl = 0 then 'null'
              else '(select id from dim_categories where external_id = ' + cast(ParentID as varchar(20)) + ')' end
       + ');' as [sql]
from tree
order by lvl, id;


-- 3. товары
select 'insert into dim_products (external_id, code, name) values ('
       + cast(id as varchar(20)) + ', '
       + isnull('''' + replace(productid, '''', '''''') + '''', 'null') + ', '''
       + replace(isnull(description, ''), '''', '''''') + ''');' as [sql]
from product
order by id;

-- 4. поставщики вместе с назв группы
select 'insert into dim_vendors (external_id, name, group_external_id, group_name) values ('
       + cast(v.id as varchar(20)) + ', '''
       + replace(isnull(v.clientid, ''), '''', '''''') + ''', '
       + isnull(cast(v.clientgroup as varchar(20)), 'null') + ', '
       + isnull('''' + replace(g.description, '''', '''''') + '''', 'null') + ');' as [sql]

from vendors v
left join vendorgroup g on g.vendorgroupid = v.clientgroup
order by v.id;

-- 5. виды оплаты
select 'insert into dim_payment_types (external_id, name) values ('
       + cast(paymenttypeid as varchar(20)) + ', '''
       + replace(isnull(description, ''), '''', '''''') + ''');' as [sql]
from paymenttype
order by paymenttypeid;


-- 6. сотрудники
select 'insert into dim_employees (external_id, name) values ('
       + cast(personid as varchar(20)) + ', '''
       + replace(ltrim(rtrim(isnull(lastname, '') + ' ' + isnull(firstname, ''))), '''', '''''') + ''');' as [sql]

from personnel
order by personid;

-- 7. склады
select 'insert into dim_storages (external_id, name) values ('
       + cast(id as varchar(20)) + ', '''
       + replace(isnull(description, ''), '''', '''''') + ''');' as [sql]
from storages
order by id;


-- 8. причины списания, дерево как у категорий и сначала корневые
with tree as (
	select ID, ParentID, Description, 0 as lvl
	from bm_ReasonDebit
	where isnull(ParentID, 0) = 0
	union all
	select r.ID, r.ParentID, r.Description, t.lvl + 1
	from bm_ReasonDebit r
	inner join tree t on r.ParentID = t.ID
)

select 'insert into dim_reasons (external_id, name, parent_id) values ('
       + cast(ID as varchar(20)) + ', '''
       + replace(isnull(Description, ''), '''', '''''') + ''', '
       + case when lvl = 0 then 'null'
              else '(select id from dim_reasons where external_id = ' + cast(ParentID as varchar(20)) + ')' end
       + ');' as [sql]
from tree
order by lvl, ID;