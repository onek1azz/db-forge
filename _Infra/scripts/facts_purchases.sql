do $$
begin
	
	begin

		create sequence seq_fact_purchases;
		
		create table fact_purchases
		(
			id bigint not null primary key default nextval('public.seq_fact_purchases'),
			product_id bigint not null,
			range_id bigint not null,
			category_id bigint not null,
			vendor_id bigint not null,
			quantity numeric(18, 4) not null,
			amount numeric(18, 2) not null,
			date_add timestamp not null default now(),
			time_id bigint not null
		);

		comment on table fact_purchases is 'Факты: закупки';
		comment on column fact_purchases.id is 'Уникальный код';
		comment on column fact_purchases.product_id is 'Код номенклатуры';
		comment on column fact_purchases.range_id is 'Код единицы измерения';
		comment on column fact_purchases.category_id is 'Код группы номенклатуры';
		comment on column fact_purchases.vendor_id is 'Код поставщика';
		comment on column fact_purchases.quantity is 'Количество';
		comment on column fact_purchases.amount is 'Сумма';
		comment on column fact_purchases.date_add is 'Дата вставки';
		comment on column fact_purchases.time_id is 'Код временного отрезка';

	exception when others then
		raise notice 'ошибка при создании таблицы закупок: %', sqlerrm;
		raise;
	end;



	begin
		alter table fact_purchases add foreign key (product_id) references dim_products (id);
		alter table fact_purchases add foreign key (range_id) references dim_ranges (id);
		alter table fact_purchases add foreign key (category_id) references dim_categories (id);
		alter table fact_purchases add foreign key (vendor_id) references dim_vendors (id);
		alter table fact_purchases add foreign key (time_id) references dim_time (id);

	exception when others then
		raise notice 'ошибка при создании связей закупок: %', sqlerrm;
		raise;
	end;


	commit;
end $$;